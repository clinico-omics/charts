library(configr)
library(dplyr)

config <- read.config(file = 'config.json')
dataConfig <- config$data
attributes <- config$attributes

if (dataConfig$dataType == 'rds') {
    rawData <- readRDS(dataConfig$dataFile)
} else if (dataConfig$dataType == 'csv') {
    rawData <- read.csv(dataConfig$dataFile, header=TRUE)
}

getVector <- function(value) {
    if (!is.null(value)) {
        return(as.vector(as.matrix(value)))
    } else {
        return(NULL)
    }
}

getBool <- function(value) {
    if (value %in% c('True', 'TRUE', 'T', '1')) {
        return(TRUE)
    } else {
        return(FALSE)
    }
}

data <- rawData

scaleValue <- getVector(attributes$scale)
scale <- if (scaleValue %in% c('row', 'column', 'none')) scaleValue else 'both'

labRowValue <- getVector(attributes$labRow)
labRow <- if (labRowValue %in% colnames(data)) labRowValue else rownames(data)
labCol <- getBool(getVector(attributes$labCol))

colNameLstValue <- getVector(attributes$colNameLst)
colNameLst <- unlist(strsplit(colNameLstValue, ','))

colNameLst <- if (all(colNameLst %in% colnames(data))) colNameLst else NULL

attrs <- list(
    title=getVector(attributes$title),
    subtitle=getVector(attributes$subtitle),
    text=getVector(attributes$text),
    rowv=getBool(attributes$rowv),
    colv=getBool(attributes$colv),
    distfun=getVector(attributes$distfun),
    hclustfun=getVector(attributes$hclustfun),
    scale=scale,
    labRow=labRow,
    labCol=labCol,
    colNameLst=colNameLst,
    queryURL=getVector(attributes$queryURL),
    showpanel=getBool(getVector(attributes$showpanel))
)
