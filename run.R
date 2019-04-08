library("shiny")
library("shinyFiles")
suppressPackageStartupMessages(library("shinyjs"))

cat("Doing application setup\n")

onStop(function() {
  cat("Doing application cleanup\n")
  config <- NULL
  functions <- NULL
  rm(list=ls())
  gc()
})

### Set workdir to location of this script
setwd(dirname(parent.frame(2)$ofile))

### Clear all variables from memory
rm(list=ls())   

### Source functions and config file
config <- new.env()
functions <- new.env()
source("src/config.R", local=config)
source("src/functions.R", local=functions)
df = NULL

### Recreate tmp dir 
tmpDir = paste(getwd(), "tmp", sep="/")
unlink(tmpDir, recursive = TRUE)
dir.create(tmpDir, showWarnings = FALSE)

### Start
runApp("src")