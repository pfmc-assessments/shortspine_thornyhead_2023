# Script to get individual model plots without having to run the full Analysis
# script
# Jane and Josh

update <- FALSE 

if (update) { 
  # Indicate the library directory to remove the r4ss package from
  mylib <- '~/R/win-library/4.1' 
  remove.packages('r4ss', lib = mylib) 
  # Install r4ss from GitHub 
  pak::pkg_install('r4ss/r4ss') 
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

# Path to data folder 
dir_data <- file.path(here::here(), 'data', 'for_ss', fsep = fsep)

# Useful function
source(file=file.path(dir_script,'utils','clean_functions.R', fsep = fsep))
source(file=file.path(dir_script,'utils','ss_utils.R', fsep=fsep))
source(file=file.path(dir_script,'utils','sensistivity_analysis_utils.R', fsep=fsep))

# Path to the base model (23.sq.floatQ) repertory
Dir_Base23_sq_floatQ <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.floatQ' , 'run',fsep = fsep)
# Path to the base model (23.land.update) repertory
Dir_Base23_land_update <- file.path(dir_SensAnal, '0.2_Update_Data','1_23.land.update' , 'run',fsep = fsep)
# Path to the base model (23.disc.update) repertory
Dir_Base23_disc_update <- file.path(dir_SensAnal, '0.2_Update_Data','2_23.disc.update' , 'run',fsep = fsep)
# Path to the base model (23.surv_db.update) repertory
Dir_Base23_surv_db_update <- file.path(dir_SensAnal, '0.2_Update_Data','3_23.surv_db.update' , 'run',fsep = fsep)
# Path to the base model (23.lcs_survey.update) repertory
Dir_Base23_lcs_survey_update <- file.path(dir_SensAnal, '0.2_Update_Data','4_23.lcs_survey.update' , 'run',fsep = fsep)
# Path to the base model (23.lcs_fisheries.update) repertory
Dir_Base23_lcs_fisheries_update <- file.path(dir_SensAnal, '0.2_Update_Data','5_23.lcs_fisheries.update' , 'run',fsep = fsep)
# Path to the base model (23.disc_weight.update) repertory
Dir_Base23_disc_weight_update <- file.path(dir_SensAnal, '0.2_Update_Data','6_23.disc_weight.update' , 'run',fsep = fsep)
# Path to the base model (23.growth.update) repertory
Dir_Base23_growth_update <- file.path(dir_SensAnal, '0.2_Update_Data','7_23.growth.update' , 'run',fsep = fsep)
# Path to the base model (23.maturity.update) repertory
Dir_Base23_maturity_update <- file.path(dir_SensAnal, '0.2_Update_Data','8_23.maturity.update' , 'run',fsep = fsep)
# Path to the base model (23.fecundity.update) repertory
Dir_Base23_fecundity_update <- file.path(dir_SensAnal, '0.2_Update_Data','9_23.fecundity.update' , 'run',fsep = fsep)
# Path to the base model (23.mortality.update) repertory
Dir_Base23_mortality_update <- file.path(dir_SensAnal, '0.2_Update_Data','10_23.mortality.update' , 'run',fsep = fsep)
# Path to the RecDev Exploratory model (23.model.recdevs_termYear) repertory
Dir_Explore23_RecDev_termYear <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','1_23.model.recdevs_termYear' , 'run',fsep = fsep)
# Path to the RecDev Exploratory model (23.model.recdevs_initYear) repertory
Dir_Explore23_RecDevs_initYear <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','2_23.model.recdevs_initYear' , 'run',fsep = fsep)

# dirlist <- c(Dir_Base23_sq_floatQ, Dir_Base23_land_update, Dir_Base23_disc_update,
#              Dir_Base23_surv_db_update, Dir_Base23_lcs_survey_update, Dir_Base23_lcs_fisheries_update,
#              Dir_Base23_disc_weight_update)

#dirlist <- c(Dir_Explore23_RecDev_termYear, Dir_Explore23_RecDevs_initYear)

dirlist <- c(Dir_Base23_mortality_update)

for(i in 1:length(dirlist)){
  
  dir <- dirlist[i]
  
  replist <- SS_output(
    dir = dir,
    verbose = TRUE,
    printstats = TRUE
  )
  
  SS_plots(replist,
           dir = dir,
           printfolder = 'plots'
  )}
