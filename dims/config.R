library("ssh")

### Connect to HPC
ssh_host = "nvanunen@hpcsubmit.op.umcutrecht.nl"
ssh_key = "C:/Users/QExactive Plus/.ssh/hpc_nvanunen"

### Default mail
mail = "n.vanunen@umcutrecht.nl"

### Root for raw data file selector  
#root = "C:/Xcalibur/data/Research"
root = "Y:/Metabolomics/DIMS_pipeline/R_workspace_NvU"

### Root for experimental design file selector 
#root2 = "Y:/Metabolomics/Research Metabolomic Diagnostics/Metabolomics Projects"
root2 = root

### Base folders on HPC
base = "/hpc/dbg_mz"
scriptDir = "/production/DIMS"