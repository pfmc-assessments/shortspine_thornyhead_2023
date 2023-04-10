# ============================================================ #
# Script used to develop the model(s) considered in the 
# sensitivity analysis: Item 5.1 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic:  Update Terminal RecDev Year Update Initial RecDev Year S-R Steepness Bias Adjustment Years 
# 	- Update Terminal RecDev Year 
# 	- Update Initial RecDev Year 
# 	- S-R Steepness 
# 	- Bias Adjustment Years 
# Author:  Team Thornyheads 
# Date: 2023-04-10 13:43:47 
# Names of the models created:
# -  23.model.recdevs_termYear 
# -  23.model.recdevs_initYear 
# -  23.model.recdevs_steep 
# -  23.model.recdevs_bias 
# *** 
# 
# This analysis has been developed based on the following models: 
# New model 	 Base model
# 23.model.recdevs_termYear 	 23.mortality.update 
# 23.model.recdevs_initYear 	 23.model.recdevs_termYear 
# 23.model.recdevs_steep 	 23.model.recdevs_initYear 
# 23.model.recdevs_bias 	 23.model.recdevs_steep 
# 
# Results are stored in the following foler: 
#	 C:/GitHub/Official_shortspine_thornyhead_2023/model/Sensitivity_Anal/5.1_Explore_RecDevs 
# 
# General features: 
# Exploration of recruitment deviation options including the initial and terminal years, steepness assumptions, and bias adjustment. 
# 
# Model features:
# - Model 23.model.recdevs_termYear:
# Changing the terminal year. 
# - Model 23.model.recdevs_initYear:
# Changing the initial year. 
# - Model 23.model.recdevs_steep:
# Changing the steepness parameter to h=0.72 from TOR. 
# - Model 23.model.recdevs_bias:
# Updating bias correction parameters. 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package. 
# The new input files are then written in the root directory of each model and the 
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/GitHub/Official_shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/5.1_Explore_RecDevs_Outputs.R 

# *************************************
# ---           WARNINGS            ---
# *************************************
# 
# => The base model(s) you specified for the following new model(s):
# 	 23.model.recdevs_initYear, 23.model.recdevs_steep, 23.model.recdevs_bias 
# do(es) not exist yet. This means you'll have to start by developping its/their own base model before creating your new model !!!!
# Specifically, you must first develop the following model(s):
# 	 23.model.recdevs_termYear, 23.model.recdevs_initYear, 23.model.recdevs_steep 
# 
# *************************************
# *************************************

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
dir_SensAnal <- file.path(dir_model, 'Sensitivity_Anal', fsep = fsep)

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
var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.model.recdevs_termYear  ----
# ----------------------------------------------------------- #

# Path to the 23.model.recdevs_termYear repertory
Dir_23_model_recdevs_termYear <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','1_23.model.recdevs_termYear' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_recdevs_termYear') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_recdevs_termYear 
# Data file :			 Dat23_model_recdevs_termYear 
# Control file :			 Ctl23_model_recdevs_termYear 
# Forecast file :			 Fore23_model_recdevs_termYear 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already 
# wrote a new SS input file for your new model and need to modify it (It ensure 
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_model_recdevs_termYear, 'starter.ss', fsep = fsep)
Start23_model_recdevs_termYear <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_recdevs_termYear ,
      # dir =  Dir_23_model_recdevs_termYear, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_recdevs_termYear, 'starter.ss')
#  Start23_model_recdevs_termYear <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_recdevs_termYear')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_recdevs_termYear,Start23_model_recdevs_termYear$datfile, fsep = fsep)
Dat23_model_recdevs_termYear <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 


# Save the data file for the model
# SS_writedat(
      # datlist =  Dat23_model_recdevs_termYear ,
      # outfile = file.path(Dir_23_model_recdevs_termYear, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_recdevs_termYear, 'SST_data.ss', fsep = fsep)
#  Dat23_model_recdevs_termYear <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_recdevs_termYear')
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
Ctlfile <-file.path(Dir_23_model_recdevs_termYear,Start23_model_recdevs_termYear$ctlfile, fsep = fsep)
Ctl23_model_recdevs_termYear <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_recdevs_termYear, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_recdevs_termYear ,
      # outfile = file.path(Dir_23_model_recdevs_termYear, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_recdevs_termYear')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_recdevs_termYear, 'forecast.ss', fsep = fsep)
Fore23_model_recdevs_termYear <-SS_readforecast(
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
# SS_writeforecast(
      # mylist =  Fore23_model_recdevs_termYear ,
      # dir = Dir_23_model_recdevs_termYear, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_recdevs_termYear, 'forecast.ss', fsep = fsep)
#  Fore23_model_recdevs_termYear <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_recdevs_termYear')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_recdevs_termYear, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.recdevs_termYear folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_recdevs_termYear, 'run', fsep = fsep)

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

# End development for model 23.model.recdevs_termYear 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_recdevs_termYear','Dat23_model_recdevs_termYear','Ctl23_model_recdevs_termYear','Fore23_model_recdevs_termYear')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.model.recdevs_initYear  ----
# ----------------------------------------------------------- #

# Path to the 23.model.recdevs_initYear repertory
Dir_23_model_recdevs_initYear <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','2_23.model.recdevs_initYear' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_recdevs_initYear') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_model_recdevs_initYear 
# Data file :					 Dat23_model_recdevs_initYear 
# Control file :					 Ctl23_model_recdevs_initYear 
# Forecast file :					 Fore23_model_recdevs_initYear 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already 
# wrote a new SS input file for your new model and need to modify it (It ensure 
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 4.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_model_recdevs_initYear, 'starter.ss', fsep = fsep)
Start23_model_recdevs_initYear <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_recdevs_initYear ,
      # dir =  Dir_23_model_recdevs_initYear, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_recdevs_initYear, 'starter.ss')
#  Start23_model_recdevs_initYear <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_recdevs_initYear')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_recdevs_initYear,Start23_model_recdevs_initYear$datfile, fsep = fsep)
Dat23_model_recdevs_initYear <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 


# Save the data file for the model
# SS_writedat(
      # datlist =  Dat23_model_recdevs_initYear ,
      # outfile = file.path(Dir_23_model_recdevs_initYear, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_recdevs_initYear, 'SST_data.ss', fsep = fsep)
#  Dat23_model_recdevs_initYear <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_recdevs_initYear')
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
Ctlfile <-file.path(Dir_23_model_recdevs_initYear,Start23_model_recdevs_initYear$ctlfile, fsep = fsep)
Ctl23_model_recdevs_initYear <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_recdevs_initYear, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_recdevs_initYear ,
      # outfile = file.path(Dir_23_model_recdevs_initYear, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_recdevs_initYear')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_recdevs_initYear, 'forecast.ss', fsep = fsep)
Fore23_model_recdevs_initYear <-SS_readforecast(
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
# SS_writeforecast(
      # mylist =  Fore23_model_recdevs_initYear ,
      # dir = Dir_23_model_recdevs_initYear, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_recdevs_initYear, 'forecast.ss', fsep = fsep)
#  Fore23_model_recdevs_initYear <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_recdevs_initYear')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_recdevs_initYear, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.recdevs_initYear folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_recdevs_initYear, 'run', fsep = fsep)

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

# End development for model 23.model.recdevs_initYear 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_recdevs_initYear','Dat23_model_recdevs_initYear','Ctl23_model_recdevs_initYear','Fore23_model_recdevs_initYear')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.model.recdevs_steep  ----
# ----------------------------------------------------------- #

# Path to the 23.model.recdevs_steep repertory
Dir_23_model_recdevs_steep <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','3_23.model.recdevs_steep' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_recdevs_steep') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_recdevs_steep 
# Data file :			 Dat23_model_recdevs_steep 
# Control file :			 Ctl23_model_recdevs_steep 
# Forecast file :			 Fore23_model_recdevs_steep 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already 
# wrote a new SS input file for your new model and need to modify it (It ensure 
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 5.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_model_recdevs_steep, 'starter.ss', fsep = fsep)
Start23_model_recdevs_steep <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_recdevs_steep ,
      # dir =  Dir_23_model_recdevs_steep, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_recdevs_steep, 'starter.ss')
#  Start23_model_recdevs_steep <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_recdevs_steep')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_recdevs_steep,Start23_model_recdevs_steep$datfile, fsep = fsep)
Dat23_model_recdevs_steep <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 


# Save the data file for the model
# SS_writedat(
      # datlist =  Dat23_model_recdevs_steep ,
      # outfile = file.path(Dir_23_model_recdevs_steep, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_recdevs_steep, 'SST_data.ss', fsep = fsep)
#  Dat23_model_recdevs_steep <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_recdevs_steep')
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
Ctlfile <-file.path(Dir_23_model_recdevs_steep,Start23_model_recdevs_steep$ctlfile, fsep = fsep)
Ctl23_model_recdevs_steep <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_recdevs_steep, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_recdevs_steep ,
      # outfile = file.path(Dir_23_model_recdevs_steep, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_recdevs_steep')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_recdevs_steep, 'forecast.ss', fsep = fsep)
Fore23_model_recdevs_steep <-SS_readforecast(
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
# SS_writeforecast(
      # mylist =  Fore23_model_recdevs_steep ,
      # dir = Dir_23_model_recdevs_steep, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_recdevs_steep, 'forecast.ss', fsep = fsep)
#  Fore23_model_recdevs_steep <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_recdevs_steep')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_recdevs_steep, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.recdevs_steep folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_recdevs_steep, 'run', fsep = fsep)

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

# End development for model 23.model.recdevs_steep 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_recdevs_steep','Dat23_model_recdevs_steep','Ctl23_model_recdevs_steep','Fore23_model_recdevs_steep')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  6. Developing model 23.model.recdevs_bias  ----
# ----------------------------------------------------------- #

# Path to the 23.model.recdevs_bias repertory
Dir_23_model_recdevs_bias <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','4_23.model.recdevs_bias' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_recdevs_bias') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_recdevs_bias 
# Data file :			 Dat23_model_recdevs_bias 
# Control file :			 Ctl23_model_recdevs_bias 
# Forecast file :			 Fore23_model_recdevs_bias 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already 
# wrote a new SS input file for your new model and need to modify it (It ensure 
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 6.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_model_recdevs_bias, 'starter.ss', fsep = fsep)
Start23_model_recdevs_bias <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_recdevs_bias ,
      # dir =  Dir_23_model_recdevs_bias, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_recdevs_bias, 'starter.ss')
#  Start23_model_recdevs_bias <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_recdevs_bias')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_recdevs_bias,Start23_model_recdevs_bias$datfile, fsep = fsep)
Dat23_model_recdevs_bias <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 


# Save the data file for the model
# SS_writedat(
      # datlist =  Dat23_model_recdevs_bias ,
      # outfile = file.path(Dir_23_model_recdevs_bias, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_recdevs_bias, 'SST_data.ss', fsep = fsep)
#  Dat23_model_recdevs_bias <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_recdevs_bias')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS 
# in a designated file.

# Read in the file
Ctlfile <-file.path(Dir_23_model_recdevs_bias,Start23_model_recdevs_bias$ctlfile, fsep = fsep)
Ctl23_model_recdevs_bias <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_recdevs_bias, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_recdevs_bias ,
      # outfile = file.path(Dir_23_model_recdevs_bias, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_recdevs_bias')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_recdevs_bias, 'forecast.ss', fsep = fsep)
Fore23_model_recdevs_bias <-SS_readforecast(
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
# SS_writeforecast(
      # mylist =  Fore23_model_recdevs_bias ,
      # dir = Dir_23_model_recdevs_bias, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_recdevs_bias, 'forecast.ss', fsep = fsep)
#  Fore23_model_recdevs_bias <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_recdevs_bias')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 6.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_recdevs_bias, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.recdevs_bias folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 6.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_recdevs_bias, 'run', fsep = fsep)

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

# You are ready to analyze the differences between the models 
# considered in this sensitivity analysis.
# This can be done using the 5.1_Explore_RecDevs_Outputs.R script.


# -----------------------------------------------------------
# -----------------------------------------------------------


