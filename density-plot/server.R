library(shiny)
# For more information, please see https://plot.ly/r/shinyapp-explore-diamonds/
library(ggplot2)
library(plotly)
library(RColorBrewer)

shinyServer(function(input, output, session) {
  # to relay the height/width of the plot's container, we'll query this 
  # session's client data http://shiny.rstudio.com/articles/client-data.html
  cdata <- session$clientData

  dataFunc <- reactive({
    data
  })

  colors <- reactiveValues(new = c())
  observeEvent(input$density_plot_change_color, {
    col_var <- if (input$density_plot_col == "None") NULL else dataFunc()[,input$density_plot_col]
    if (is.null(col_var)) {
      colors$new <- c()
    }

    col_var <- as.vector(col_var)
    dataType <- 'all'
    is.wholenumber <- function(x, tol = .Machine$double.eps^0.5)  abs(x - round(x)) < tol
    if (all(unlist(lapply(col_var, is.character)))) {
      dataType <- 'div'
    } else if (all(unlist(lapply(col_var, is.wholenumber)))) {
      dataType <- 'qual'
    } else {
      dataType <- 'seq'
    }

    n <- length(unique(col_var))
    allChoices <- brewer.pal.info

    availableChoices <- allChoices[allChoices$maxcolors > n & allChoices$category == dataType,]

    if (dim(availableChoices)[1] != 0) {
      colorPal <- sample(rownames(availableChoices), size=1)
      colors$new <- brewer.pal(n, colorPal)
    } else {
      colors$new <- c()
    }
  })

  observeEvent(input$density_plot_col, {
    colors$new <- c()
  })

  observeEvent(input$showpanel, {
    if(input$showpanel == TRUE) {
      removeCssClass("main", "col-sm-12")
      addCssClass("main", "col-sm-8")
      shinyjs::show(id = "sidebar")
      shinyjs::enable(id = "sidebar")
    }
    else {
      removeCssClass("main", "col-sm-8")
      addCssClass("main", "col-sm-12")
      shinyjs::hide(id = "sidebar")
    }

    output$densityPlot <- renderPlotly({
      x_var <- dataFunc()[, input$density_plot_x]
      col_var <- dataFunc()[, input$density_plot_col]
      angle <- as.integer(input$density_plot_x_angle)
      density_plot_col <- if (attrs$fillEnable) input$density_plot_col else NULL
      
      # count the mean value and show it as a vertical line
      mu <- aggregate(x_var, by=list(col_var), function(x) mean(x, na.rm=T))
      # build graph with ggplot syntax
      p <- ggplot(dataFunc(),
                  aes_string(x=input$density_plot_x,
                             color=input$density_plot_col,
                             fill=density_plot_col)) + 
           geom_density(alpha=0.4) +
           geom_vline(data=mu, aes(xintercept=x, color=Group.1), linetype="dashed") +
           theme(axis.text.x=element_text(angle=angle, hjust=1,
                                          size=input$density_plot_x_labelsize),
                 axis.text.y=element_text(size=input$density_plot_y_labelsize),
                 text=element_text(size=input$density_plot_title_size),
                 legend.text=element_text(size=input$density_plot_legend_labelsize),
                 legend.title=element_blank(),
                 panel.background=element_rect(fill = "white"),
                 axis.line=element_line(colour='black'))

      ggplotly(p) %>% layout(autosize=TRUE)
    })
  })
})
