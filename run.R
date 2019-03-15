library("shiny")
library("shinyFiles")
suppressPackageStartupMessages(library("shinyjs"))

### Set workdir to location of this script
setwd(dirname(parent.frame(2)$ofile))

### Clear all variables
rm(list=ls())   

### Source functions and config file
source("src/config.R")
source("src/functions.R")
df = NULL

### Recreate tmp dir 
tmpDir = paste(getwd(), "tmp", sep="/")
unlink(tmpDir, recursive = TRUE)
dir.create(tmpDir, showWarnings = FALSE)

### Start
runApp("src")