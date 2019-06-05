library("ssh")

### Settings
run_pipeline=TRUE # put on FALSE if you solely want to upload data

# Root for raw data file selector  
root = "C:/Xcalibur/data/Research"

# Root for experimental design file selector (sample sheet)
root2 = "Y:/Metabolomics/Research Metabolic Diagnostics/Metabolomics Projects"

### Folders on HPC
base = "/hpc/dbg_mz"
scriptDir = paste0(base, "/production/DIMS")
proteowizardDir = paste0(base, "/tools/proteowizard_3.0.19056-6b6b0a2b4")
db = paste0(base, "/tools/db/HMDB_add_iso_corrNaCl.RData")
db2 = paste0(base, "/tools/db/HMDB_with_relevance.RData")

### Default job times


### Default parameters - for lists it defaults to the first one
mail = "n.vanunen@umcutrecht.nl"
run_name = ""
nrepl = "3"
normalization = list("disabled", "total_IS", "total_ident", "total")
data_type = list("Plasma", "Blood Spots", "Research")
trim = 0.1
resol = 140000
dims_thresh = 100
thresh2remove = 500000000
thresh_pos = 2000
thresh_neg = 2000
matrix = "DBS"


### Connect to HPC
ssh_host = "nvanunen@hpcsubmit.op.umcutrecht.nl"
ssh_key = "C:/Users/QExactive Plus/.ssh/hpc_nvanunen"


### Log git branch and commit ID
commit <- paste(system("git name-rev HEAD", intern = TRUE), system("git rev-parse HEAD", intern = TRUE))
