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

# Path to the 23.model.recdevs_termYear repertory
Dir_23_model_recdevs_termYear <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','1_23.model.recdevs_termYear' , 'run',fsep = fsep)
# Path to the 23.model.recdevs_initYear repertory
Dir_23_model_recdevs_initYear <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','2_23.model.recdevs_initYear' , 'run',fsep = fsep)
# Path to the 23.model.recdevs_steep repertory
Dir_23_model_recdevs_steep <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','3_23.model.recdevs_steep' , 'run',fsep = fsep)
# Path to the 23.model.recdevs_bias repertory
Dir_23_model_recdevs_bias <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','4_23.model.recdevs_bias' , 'run',fsep = fsep)

dirlist <- c(Dir_23_model_recdevs_termYear, Dir_23_model_recdevs_initYear, Dir_23_model_recdevs_steep, Dir_23_model_recdevs_bias)

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
