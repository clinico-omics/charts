library(shiny)
library(shinyBS)
library(shinyjs)
library(plotly)
library(colourpicker)

choices <- colnames(data)
names(choices) <- colnames(data)

shinyUI(fluidPage(
  useShinyjs(),
  tags$head(
    tags$style("
      .chart-title-area {margin: 20px; width: 100%;}
      .chart-title-area .title {display: flex; justify-content: center; font-size: 16px;}
      .chart-title-area .content {margin-left: 70px; overflow: visible;}
      #main {display: flex; flex-direction: column; align-items: flex-end;}
      #showpanel {width: 120px; margin-bottom: 10px; background-color: #f5f5f5; box-shadow: none;}
    "),
    tags$script(src="http://kancloud.nordata.cn/2019-02-27-iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),
  sidebarLayout(
    mainPanel(
      id='main',
      bsButton("showpanel", "Show/hide", icon=icon('far fa-chart-bar'),
               type = "toggle", value = attrs$showpanel),
      plotlyOutput('stackBarPlot', width = "100%", height = "700px"),
      tags$div(
        class="chart-title-area",
        tags$h2(class="title", attrs$title),
        tags$p(class="content", attrs$text)
      )
    ),
    sidebarPanel(
      id = "sidebar",
      selectInput("stack_barplot_x", "X variable :",
                  choices = choices,
                  selected = attrs$xAxis),
      selectInput("stack_barplot_y", "Y variable :",
                  choices = choices,
                  selected = attrs$yAxis),
      selectInput("stack_barplot_label", "Label variable :",
                  choices = c("None" = "None", choices),
                  selected = attrs$labelAttr),
      selectInput("stack_barplot_smart_color", "Smart color mapping variable :",
                  choices = c("None" = "None", choices),
                  selected = attrs$smartColor),
      selectInput("stack_barplot_bar_pos", "Bar position :",
                  choices = c("stack" = "stack",
                              "dodge" = "dodge",
                              "fill" = "fill"),
                  selected = attrs$barPos),
      sliderInput("stack_barplot_xyl_labelsize", "X&Y&Legend labels size :",
                  min = 0, max = 25, value = 11),
      sliderInput("stack_barplot_title_size", "X&Y Title size :",
                  min = 0, max = 25, value = 11),
      tags$p(
        actionButton("stack_barplot-reset-zoom", 
                      HTML("<span class='glyphicon glyphicon-search' aria-hidden='true'></span> Reset Zoom")),
        actionButton("stack_barplot_change_color", 
                     HTML("<span class='glyphicon glyphicon-screenshot' aria-hidden='true'></span> Change Color"))
      )
    )
  )
))
