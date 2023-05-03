# ============================================================ #
# Script used to develop the model(s) considered in the 
# sensitivity analysis: Item 5.4 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic:  Survey Timing Settlement Events 
# 	- Survey Timing 
# 	- Settlement Events 
# Author:  Team Thornyheads 
# Date: 2023-04-18 14:48:28 
# Names of the models created:
# -  23.model.survey_timing 
# -  23.model.settlement_events 
# *** 
# 
# This analysis has been developed based on the following models: 
# New model 	 Base model
# 23.model.survey_timing 	 23.model.francis 
# 23.model.settlement_events 	 23.model.survey_timing 
# 
# Results are stored in the following foler: 
#	 /Users/jzahner/Desktop/Projects/shortspine_thornyhead_2023/model/Sensitivity_Anal/5.4_SS_Model_Warnings 
# 
# General features: 
# These models will fix outstanding warnings from SS. 
# 
# Model features:
# - Model 23.model.survey_timing:
# Fix survey timing to be -1 as expected by SS. 
# - Model 23.model.settlement_events:
# Simplify settlement event structure. 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package. 
# The new input files are then written in the root directory of each model and the 
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# /Users/jzahner/Desktop/Projects/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/5.4_SS_Model_Warnings_Outputs.R 

# *************************************
# ---           WARNINGS            ---
# *************************************
# 
# => The base model(s) you specified for the following new model(s):
# 	 23.model.settlement_events 
# do(es) not exist yet. This means you'll have to start by developping its/their own base model before creating your new model !!!!
# Specifically, you must first develop the following model(s):
# 	 23.model.survey_timing 
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

#  3. Developing model 23.model.survey_timing  ----
# ----------------------------------------------------------- #

# Path to the 23.model.survey_timing repertory
Dir_23_model_survey_timing <- file.path(dir_SensAnal, '5.4_SS_Model_Warnings','1_23.model.survey_timing' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_survey_timing') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_survey_timing 
# Data file :			 Dat23_model_survey_timing 
# Control file :			 Ctl23_model_survey_timing 
# Forecast file :			 Fore23_model_survey_timing 


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
StarterFile <- file.path(Dir_23_model_survey_timing, 'starter.ss', fsep = fsep)
Start23_model_survey_timing <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_survey_timing ,
      # dir =  Dir_23_model_survey_timing, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_survey_timing, 'starter.ss')
#  Start23_model_survey_timing <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_survey_timing')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_survey_timing,Start23_model_survey_timing$datfile, fsep = fsep)
Dat23_model_survey_timing <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

Dat23_model_survey_timing$fleetinfo$surveytiming <- c(-1, -1, -1, 7, 7, 7)

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 


# Save the data file for the model
SS_writedat(
  datlist =  Dat23_model_survey_timing ,
  outfile = file.path(Dir_23_model_survey_timing, 'SST_data.ss', fsep = fsep),
  version = '3.30',
  overwrite = TRUE
)

# Check file structure
# DatFile <- file.path(Dir_23_model_survey_timing, 'SST_data.ss', fsep = fsep)
#  Dat23_model_survey_timing <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_survey_timing')
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
Ctlfile <-file.path(Dir_23_model_survey_timing,Start23_model_survey_timing$ctlfile, fsep = fsep)
Ctl23_model_survey_timing <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_survey_timing, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_survey_timing ,
      # outfile = file.path(Dir_23_model_survey_timing, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_survey_timing')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_survey_timing, 'forecast.ss', fsep = fsep)
Fore23_model_survey_timing <-SS_readforecast(
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
      # mylist =  Fore23_model_survey_timing ,
      # dir = Dir_23_model_survey_timing, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_survey_timing, 'forecast.ss', fsep = fsep)
#  Fore23_model_survey_timing <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_survey_timing')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_survey_timing, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.survey_timing folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = '-nohess'
      # this is if we want to use '-nohess' 
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_survey_timing, 'run', fsep = fsep)

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

# End development for model 23.model.survey_timing 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_survey_timing','Dat23_model_survey_timing','Ctl23_model_survey_timing','Fore23_model_survey_timing')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.model.settlement_events  ----
# ----------------------------------------------------------- #

# Path to the 23.model.settlement_events repertory
Dir_23_model_settlement_events <- file.path(dir_SensAnal, '5.4_SS_Model_Warnings','2_23.model.settlement_events' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_settlement_events') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_model_settlement_events 
# Data file :					 Dat23_model_settlement_events 
# Control file :					 Ctl23_model_settlement_events 
# Forecast file :					 Fore23_model_settlement_events 


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
StarterFile <- file.path(Dir_23_model_settlement_events, 'starter.ss', fsep = fsep)
Start23_model_settlement_events <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_settlement_events ,
      # dir =  Dir_23_model_settlement_events, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_settlement_events, 'starter.ss')
#  Start23_model_settlement_events <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_settlement_events')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_settlement_events,Start23_model_settlement_events$datfile, fsep = fsep)
Dat23_model_settlement_events <- SS_readdat_3.30(
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
      # datlist =  Dat23_model_settlement_events ,
      # outfile = file.path(Dir_23_model_settlement_events, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_settlement_events, 'SST_data.ss', fsep = fsep)
#  Dat23_model_settlement_events <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_settlement_events')
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
Ctlfile <-file.path(Dir_23_model_settlement_events,Start23_model_settlement_events$ctlfile, fsep = fsep)
Ctl23_model_settlement_events <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_settlement_events, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 
Ctl23_model_settlement_events$recr_dist_method <- 4
Ctl23_model_settlement_events$MG_parms <- Ctl23_model_settlement_events$MG_parms %>% tibble::rownames_to_column() %>% filter(!(grepl("RecrDist", rowname))) %>% tibble::column_to_rownames() %>% as.data.frame

# Save the control file for the model
SS_writectl(
  ctllist =  Ctl23_model_settlement_events ,
  outfile = file.path(Dir_23_model_settlement_events, 'SST_control.ss', fsep = fsep),
  version = '3.30',
  overwrite = TRUE
)
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_settlement_events')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_settlement_events, 'forecast.ss', fsep = fsep)
Fore23_model_settlement_events <-SS_readforecast(
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
      # mylist =  Fore23_model_settlement_events ,
      # dir = Dir_23_model_settlement_events, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_settlement_events, 'forecast.ss', fsep = fsep)
#  Fore23_model_settlement_events <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_settlement_events')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_settlement_events, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.settlement_events folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = "-nohess"
      # this is if we want to use '-nohess' 
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_settlement_events, 'run', fsep = fsep)

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
# This can be done using the 4.1_Test_Bio_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------


