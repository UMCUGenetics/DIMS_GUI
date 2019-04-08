# DIMS GUI
R Shiny application to start the [DIMS pipeline](https://github.com/UMCUGenetics/DIMS/), which runs on the HPC server.

## Setup
### GIT
- Install [GIT](https://git-scm.com/downloads). 
- Create a folder anywhere, then make 2 sub folders called development and production.
- In `/development`, clone the dev branch of the startDIMS repo.
```
git clone -b master --single-branch git@github.com:UMCUGenetics/DIMS_GUI.git
```
- In `/production`, clone the master branch of the startDIMS repo.
```
git clone -b master --single-branch git@github.com:UMCUGenetics/DIMS_GUI.git
```

### R
- Install [R](https://cran.r-project.org/mirrors.html) & [RStudio](https://www.rstudio.com/products/rstudio/download/). *Make sure to use a version of R that is compatible with all libraries listed below.*
- Install required packages:
```
install.packages(“shiny”)
install.packages(“shinyFiles”)
install.packages(“shinyjs”)
install.packages(“shinythemes”)
install.packages(“ssh”)
```
- Make a copy of the config_default.R file called config.R for both production and development, and make sure everything is pointing to the correct place. A ssh key is required of the HPC account that also made the proteowizard singularity docker on the HPC.

## Usage
To run the RShiny application, simply run `run.R`. Then in the GUI, do the following:
  1. Select the folder that contains all the RAW data files. 
  2. Select the file that contains the file name and sample names (generally sampleNames.txt).
  3. Deselect any files and/or samples that don't need to be processed
  4. Select all the parameters.
  5. Press run.
After the data has been uploaded and the pipeline had been started, the RShiny program can be closed. 
