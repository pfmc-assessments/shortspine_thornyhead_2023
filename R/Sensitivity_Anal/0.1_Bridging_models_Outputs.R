# ============================================================ #
# Script used to analyze and compare the model(s) considered in the 
# sensitivity analysis: Item 0.1 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  transition 
# Specific item in that topic:  Param fixed Param estimated 
# Author:  Matthieu VERON 
# Date: 2023-03-13 12:49:00 
# Names of the models created:
# -  23.sq.fix 
# -  23.sq.est 
# *** 
# 
# This analysis has been developped based on the following models: 
# New model 	 Base model
# 23.sq.fix 	 23.sq.fixQ 
# 23.sq.est 	 23.sq.fixQ 
# 
# Results are stored in the following foler: 
#	 C:/Users/Matthieu Verson/Documents/GitHub/Forked_repos/shortspine_thornyhead_2023/model/Sensitivity_Anal/0.1_Bridging_models 
# 
# General features: 
# Revisiting the transition of the 2013 model considering i) a model where all the parameters are fixed to their estimated value from the 2013 assessment and ii) a second model where these parameters are freely estimated (those that were estimated in the 2013 assessment). 
# 
# Model features:
# - Model 23.sq.fix:
# Model with all parameters fixed to their values as estimated in the 2013 assessment. 
# - Model 23.sq.est:
# Model where parameters that were estimated in the 2013 assessment are freely estimated, using the same initial values, bounds and prior. 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# The results of the model run have been plot in the 'plots' sub-directory of 
# the 'run' folder. The comparison plots between models for the sensitivity analysis will be
# stored in the 'SA_plots' folder housed in the root directory of this sensitivity analysis.

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

rm(list = ls(all.names = TRUE)) 

# 1. Update r4ss ----

update <- FALSE 

if (update) { 
# Indicate the library directory to remove the r4ss package from
mylib <- '~/R/win-library/4.1' 
remove.packages('r4ss', lib = mylib) 
# Install r4ss from GitHub 
remotes::install_github('r4ss/r4ss') 
} 
# ----------------------------------------------------------- 

# 2. Set up ---- 

rm(list = ls(all.names = TRUE)) 
# Local declaration 
fsep <- .Platform$file.sep #easy for file.path() function 

# packages 
library(r4ss) 
library(dplyr) 
library(reshape2) 
library(stringr) 

# Directories 
# Path to the model folder 
dir_model <- file.path(here::here(), 'model', fsep = fsep)

# Path to the Executable folder 
Exe_path <- file.path(dir_model, 'ss_executables') 

# Path to the R folder 
dir_script <- file.path(here::here(), 'R', fsep = fsep)

# Path to the Sensitivity analysis folder 
dir_SensAnal <- file.path(dir_model, 'Sensitivity_Anal', fsep = fsep)

# Useful function
source(file=file.path(dir_script,'utils','clean_functions.R', fsep = fsep))
source(file=file.path(dir_script,'utils','ss_utils.R', fsep=fsep))

# Save directories and function
# save.dir <- c('dir_model', 
        # 'Exe_path',
        # 'dir_script',
        # 'dir_SensAnal') 
save.dir <- ls()
# ----------------------------------------------------------- 

# 3.4  Make comparison plots between models ----
# ======================= #

# Use the SSgetoutput() function that apply the SS_output()
# to get the outputs from different models
# Path to the base model ( 23.sq.fixQ ) repertory
Dir_Base <- file.path(dir_SensAnal, 'model','2013_SST_SSV3_30_21' , 'run',fsep = fsep)
# Path to the 23.sq.fix repertory
Dir_23_sq_fix <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.fix' , 'run',fsep = fsep)

# Path to the 23.sq.est repertory
Dir_23_sq_est <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.est' , 'run',fsep = fsep)


# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = c( Dir_Base,Dir_Base23_sq_fix,Dir_Base23_sq_est ))

# Rename the list holding the report files from each model
names(SensiMod)
names(SensiMod) <- c('23.sq.fixQ','23.sq.fix','23.sq.est')

# summarize the results
Version_Summary <- SSsummarize(SensiMod)

# make plots comparing the models
SSplotComparisons(
      Version_Summary,
      # print = TRUE,
      pdf = TRUE,
      plotdir = SST_path,
      legendlabels = c('23.sq.fixQ','23.sq.fix','23.sq.est')
    )
