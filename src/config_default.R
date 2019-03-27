library("ssh")

### Connect to HPC
ssh_host = "nvanunen@hpcsubmit.op.umcutrecht.nl"
ssh_key = "C:/Users/QExactive Plus/.ssh/hpc_nvanunen"

### Default parameters
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

### Root for raw data file selector  
root = "C:/Xcalibur/data/Research"

### Root for experimental design file selector (sample sheet)
root2 = "Y:/Metabolomics/Research Metabolic Diagnostics/Metabolomics Projects"

### Folders on HPC
base = "/hpc/dbg_mz"
scriptDir = "/production/DIMS"
proteowizardDir = "/tools/proteowizard_3.0.19056-6b6b0a2b4"

### Log git branch and number
commit <- paste(system("git name-rev HEAD", intern = TRUE), system("git rev-parse HEAD", intern = TRUE))