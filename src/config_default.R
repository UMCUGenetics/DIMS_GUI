library("ssh")

### Settings

# Root for raw data file selector
root <- "C:/Xcalibur/data/Research"

# Root for experimental design file selector (sample sheet)
root2 <- "Y:/Metabolomics/Research Metabolic Diagnostics/Metabolomics Projects"

# Locations on HPC
base <- "/hpc/dbg_mz"
scriptDir <- paste0(base, "/production/DIMS")
proteowizard <- paste0(base, "/tools/proteowizard_3.0.19252-aa45583de")
db <- paste0(base, "/tools/db/HMDB_add_iso_corrNaCl_withIS_withC5OH.RData")
db2 <- paste0(base, "/tools/db/HMDB_with_info_relevance_IS_C5OH.RData")

### Default parameters - for lists it defaults to the first one
run_pipeline=TRUE  # put on FALSE if you solely want to upload data
login <- "nvanunen"
mail <- "n.vanunen@umcutrecht.nl"
run_name <- ""
nrepl <- 3  # why string?
normalization <- list("disabled", "total_IS", "total_ident", "total")
matrix <- list("Plasma", "DBS", "Research")
trim <- 0.1
resol <- 140000
dims_thresh <- 100
thresh2remove <- 500000000
thresh_pos <- 2000
thresh_neg <- 2000
z_score <- 1

list(500000000, 1000000000) #dbs, plasma

### Connect to HPC
ssh_transfer <- "hpct01.op.umcutrecht.nl"
ssh_submit <- "hpcsubmit.op.umcutrecht.nl"


### Log git branch and commit ID
commit <- paste(system("git name-rev HEAD", intern = TRUE), 
                system("git rev-parse HEAD", intern = TRUE))


# TODO Default job times