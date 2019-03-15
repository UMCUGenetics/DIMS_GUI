library("ssh")

### Connect to HPC
ssh_host = "nvanunen@hpcsubmit.op.umcutrecht.nl"
ssh_key = "C:/Users/QExactive Plus/.ssh/hpc_nvanunen"

### Default mail
mail = "n.vanunen@umcutrecht.nl"

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