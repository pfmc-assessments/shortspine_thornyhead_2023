# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 4.5 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  biological_Info 
# Specific item in that topic: 
# 	- Sensitivity to sigmaR 
# Author:  Sabrina Beyer 
# Date: 2023-06-07 09:22:36 
# Name of the model created:
# 	- 23.SigmaR.sensitivity 
# *** 
# 
# This analysis has been developped based on the following model: 
# 23.model.francis_2 
# 
# Results are stored in the following foler: 
#	 C:/Users/sgbey/Documents/Github/shortspine_thornyhead_2023/model/Sensitivity_Anal/STAR_Panel/4.5_SigmaR_Sensitivity 
# 
# Features: 
#  Change the sigmaR input to 0.76 as suggested in model tuning 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/Users/sgbey/Documents/Github/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/4.5_SigmaR_Sensitivity_Outputs.R 

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
dir_SensAnal <- file.path(dir_model, 'Sensitivity_Anal', 'STAR_Panel', fsep = fsep)

# Path to data folder 
dir_data <- file.path(here::here(), 'data', 'for_ss', fsep = fsep)

# Useful function
source(file=file.path(dir_script,'utils','clean_functions.R', fsep = fsep))
source(file=file.path(dir_script,'utils','ss_utils.R', fsep=fsep))
source(file=file.path(dir_script,'utils','sensistivity_analysis_utils.R', fsep=fsep))

# Load the .Rdata object with the parameters and data for 2023
load(file.path(dir_data,'SST_SS_2023_Data_Parameters.RData', fsep = fsep))
# Save directories and function
# var.to.save <- c('dir_model',
        # 'Exe_path',
        # 'dir_script',
        # 'dir_SensAnal') 


# Compute the hessian matrix 
# For each model, indicate if you want to compute the Hessian matrix.
# If noHess = TRUE for a given model, then the Hessian matrix
# won't be estimated.
# Reminder - The following models are considered:
# 	-  23.SigmaR.sensitivity 
noHess <- c(FALSE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.SigmaR.sensitivity  ----
# ----------------------------------------------------------- #

# Path to the 23.SigmaR.sensitivity repertory
Dir_23_SigmaR_sensitivity <- file.path(dir_SensAnal, '4.5_SigmaR_Sensitivity','1_23.SigmaR.sensitivity' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_SigmaR_sensitivity') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_SigmaR_sensitivity 
# Data file :			 Dat23_SigmaR_sensitivity 
# Control file :			 Ctl23_SigmaR_sensitivity 
# Forecast file :			 Fore23_SigmaR_sensitivity 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.model.francis_2',
      curr.model = '23.SigmaR.sensitivity',
      files = 'all')


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_SigmaR_sensitivity, 'starter.ss', fsep = fsep)
Start23_SigmaR_sensitivity <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_SigmaR_sensitivity ,
      dir =  Dir_23_SigmaR_sensitivity, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_SigmaR_sensitivity, 'starter.ss')
#  Start23_SigmaR_sensitivity <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_SigmaR_sensitivity')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_SigmaR_sensitivity,Start23_SigmaR_sensitivity$datfile, fsep = fsep)
Dat23_SigmaR_sensitivity <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 


# Save the data file for the model
SS_writedat(
      datlist =  Dat23_SigmaR_sensitivity ,
      outfile = file.path(Dir_23_SigmaR_sensitivity, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_SigmaR_sensitivity, 'SST_data.ss', fsep = fsep)
#  Dat23_SigmaR_sensitivity <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_SigmaR_sensitivity')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS
# in a designated file.

# Read in the file
Ctlfile <-file.path(Dir_23_SigmaR_sensitivity,Start23_SigmaR_sensitivity$ctlfile, fsep = fsep)
Ctl23_SigmaR_sensitivity <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_SigmaR_sensitivity, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

#run a sensitivity to suggested sigmaR
Ctl23_SigmaR_sensitivity$SR_parms["SR_sigmaR",]$INIT<-0.76



# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_SigmaR_sensitivity ,
      outfile = file.path(Dir_23_SigmaR_sensitivity, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_SigmaR_sensitivity')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_SigmaR_sensitivity, 'forecast.ss', fsep = fsep)
Fore23_SigmaR_sensitivity <-SS_readforecast(
      file = ForeFile,
      version = '3.30',
      verbose = T,
      readAll = T
      )

# Make your modification if applicable
# Code modifying the forecast file 
# ..... 
# ..... 


# Save the forecast file for the model
SS_writeforecast(
      mylist =  Fore23_SigmaR_sensitivity ,
      dir = Dir_23_SigmaR_sensitivity, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_SigmaR_sensitivity, 'forecast.ss', fsep = fsep)
#  Fore23_SigmaR_sensitivity <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_SigmaR_sensitivity')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_SigmaR_sensitivity,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.SigmaR.sensitivityfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = '-nohess' #ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_SigmaR_sensitivity, 'run', fsep = fsep)

replist <- SS_output(
      dir = Dirplot,
      verbose = TRUE,
      printstats = TRUE
      )

# plots the results (store in the 'plots' sub-directory)
SS_plots(replist,
      dir = Dirplot,
      printfolder = 'plots'
      )

# =======================


# -----------------------------------------------------------
# -----------------------------------------------------------

## End section ##

# You are ready to analyze the differences between the models
# considered in this sensitivity analysis.
# This can be done using the 4.5_SigmaR_Sensitivity_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------


