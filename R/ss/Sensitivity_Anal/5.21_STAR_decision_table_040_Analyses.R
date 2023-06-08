# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 5.21 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic: 
# 	- Low-State 040 
# 	- Base Case 040 
# 	- High-State 040 
# Author:  Team Thornyhead 
# Date: 2023-06-08 15:40:22 
# Names of the models created:
# 	- 23.dt.low 
# 	- 23.dt.base 
# 	- 23.dt.high 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.dt.low 				 23.STAR.base 
# 23.dt.base 				 23.STAR.base 
# 23.dt.high 				 23.STAR.base 
# 
# Results are stored in the following foler: 
#	 /Users/jzahner/Desktop/Projects/shortspine_thornyhead_2023/model/Sensitivity_Anal/STAR_Panel/5.21_STAR_decision_table_040 
# 
# General features: 
# Decision table models for STAR Panel. Axes of uncertainty are the value of natural mortality. 
# 
# Model features:
# - Model 23.dt.low:
# Low state of nature M=0.0373 
# - Model 23.dt.base:
# Base case M=0.040 
# - Model 23.dt.high:
# High state of nature M=0.0461 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# /Users/jzahner/Desktop/Projects/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/5.21_STAR_decision_table_040_Outputs.R 

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
# 	-  23.dt.low 
# 	-  23.dt.base 
# 	-  23.dt.high 
noHess <- c(FALSE,FALSE,FALSE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.dt.low  ----
# ----------------------------------------------------------- #

# Path to the 23.dt.low repertory
Dir_23_dt_low <- file.path(dir_SensAnal, '5.21_STAR_decision_table_040','1_23.dt.low' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_dt_low') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_dt_low 
# Data file :			 Dat23_dt_low 
# Control file :			 Ctl23_dt_low 
# Forecast file :			 Fore23_dt_low 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.STAR.base',
      curr.model = '23.dt.low',
      files = 'all')


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_dt_low, 'starter.ss', fsep = fsep)
Start23_dt_low <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_dt_low ,
      dir =  Dir_23_dt_low, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_dt_low, 'starter.ss')
#  Start23_dt_low <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_dt_low')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_dt_low,Start23_dt_low$datfile, fsep = fsep)
Dat23_dt_low <- SS_readdat_3.30(
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
      datlist =  Dat23_dt_low ,
      outfile = file.path(Dir_23_dt_low, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_dt_low, 'SST_data.ss', fsep = fsep)
#  Dat23_dt_low <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_dt_low')
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
Ctlfile <-file.path(Dir_23_dt_low,Start23_dt_low$ctlfile, fsep = fsep)
Ctl23_dt_low <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_dt_low, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_dt_low ,
      outfile = file.path(Dir_23_dt_low, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_dt_low')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_dt_low, 'forecast.ss', fsep = fsep)
Fore23_dt_low <-SS_readforecast(
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
      mylist =  Fore23_dt_low ,
      dir = Dir_23_dt_low, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_dt_low, 'forecast.ss', fsep = fsep)
#  Fore23_dt_low <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_dt_low')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_dt_low,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.dt.lowfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_dt_low, 'run', fsep = fsep)

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

# End development for model 23.dt.low 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_dt_low','Dat23_dt_low','Ctl23_dt_low','Fore23_dt_low')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.dt.base  ----
# ----------------------------------------------------------- #

# Path to the 23.dt.base repertory
Dir_23_dt_base <- file.path(dir_SensAnal, '5.21_STAR_decision_table_040','2_23.dt.base' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_dt_base') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_dt_base 
# Data file :					 Dat23_dt_base 
# Control file :					 Ctl23_dt_base 
# Forecast file :					 Fore23_dt_base 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.STAR.base',
      curr.model = '23.dt.base',
      files = 'all')


# 4.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_dt_base, 'starter.ss', fsep = fsep)
Start23_dt_base <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_dt_base ,
      dir =  Dir_23_dt_base, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_dt_base, 'starter.ss')
#  Start23_dt_base <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_dt_base')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_dt_base,Start23_dt_base$datfile, fsep = fsep)
Dat23_dt_base <- SS_readdat_3.30(
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
      datlist =  Dat23_dt_base ,
      outfile = file.path(Dir_23_dt_base, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_dt_base, 'SST_data.ss', fsep = fsep)
#  Dat23_dt_base <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_dt_base')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS
# in a designated file.

# Read in the file
Ctlfile <-file.path(Dir_23_dt_base,Start23_dt_base$ctlfile, fsep = fsep)
Ctl23_dt_base <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_dt_base, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_dt_base ,
      outfile = file.path(Dir_23_dt_base, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_dt_base')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_dt_base, 'forecast.ss', fsep = fsep)
Fore23_dt_base <-SS_readforecast(
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
      mylist =  Fore23_dt_base ,
      dir = Dir_23_dt_base, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_dt_base, 'forecast.ss', fsep = fsep)
#  Fore23_dt_base <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_dt_base')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_dt_base,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.dt.basefolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[2], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_dt_base, 'run', fsep = fsep)

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

# End development for model 23.dt.base 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_dt_base','Dat23_dt_base','Ctl23_dt_base','Fore23_dt_base')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.dt.high  ----
# ----------------------------------------------------------- #

# Path to the 23.dt.high repertory
Dir_23_dt_high <- file.path(dir_SensAnal, '5.21_STAR_decision_table_040','3_23.dt.high' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_dt_high') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_dt_high 
# Data file :			 Dat23_dt_high 
# Control file :			 Ctl23_dt_high 
# Forecast file :			 Fore23_dt_high 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.STAR.base',
      curr.model = '23.dt.high',
      files = 'all')


# 5.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_dt_high, 'starter.ss', fsep = fsep)
Start23_dt_high <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_dt_high ,
      dir =  Dir_23_dt_high, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_dt_high, 'starter.ss')
#  Start23_dt_high <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_dt_high')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_dt_high,Start23_dt_high$datfile, fsep = fsep)
Dat23_dt_high <- SS_readdat_3.30(
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
      datlist =  Dat23_dt_high ,
      outfile = file.path(Dir_23_dt_high, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_dt_high, 'SST_data.ss', fsep = fsep)
#  Dat23_dt_high <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_dt_high')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS
# in a designated file.

# Read in the file
Ctlfile <-file.path(Dir_23_dt_high,Start23_dt_high$ctlfile, fsep = fsep)
Ctl23_dt_high <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_dt_high, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_dt_high ,
      outfile = file.path(Dir_23_dt_high, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_dt_high')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_dt_high, 'forecast.ss', fsep = fsep)
Fore23_dt_high <-SS_readforecast(
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
      mylist =  Fore23_dt_high ,
      dir = Dir_23_dt_high, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_dt_high, 'forecast.ss', fsep = fsep)
#  Fore23_dt_high <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_dt_high')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_dt_high,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.dt.highfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[3], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_dt_high, 'run', fsep = fsep)

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
# This can be done using the 5.21_STAR_decision_table_040_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------


