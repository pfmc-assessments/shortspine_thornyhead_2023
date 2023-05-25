# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 4.1 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  biological_Info 
# Specific item in that topic: 
# 	- Growth Sensitivity High 
# 	- Growth Sensitivity Low 
# Author:  Sabrina Beyer and Jane Sullivan 
# Date: 2023-04-30 18:42:11 
# Names of the models created:
# 	-  23.growth.high 
# 	-  23.growth.low 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.growth.high 				 23.model.francis_2 
# 23.growth.low 				 23.model.francis_2 
# 
# Results are stored in the following foler: 
#	 C:/Users/sgbey/Documents/Github/shortspine_thornyhead_2023/model/Sensitivity_Anal/4.1_Growth_Sensitivity 
# 
# General features: 
# Sensitivity of the base model (23.model.francis_2) to different growth curves 
# 
# Model features:
# - Model 23.growth.high:
# Sensitivity of the model to a growth curve 25% higher 
# - Model 23.growth.low:
# Sensitvitity of the base model to a growth curve 10% lower 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/Users/sgbey/Documents/Github/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/4.1_Growth_Sensitivity_Outputs.R 

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


# Compute the hessian matrix 
# For each model, indicate if you want to compute the Hessian matrix.
# If noHess = TRUE for a given model, then the Hessian matrix
# won't be estimated.
# Reminder - The following models are considered:# 	-  23.growth.high 
# 	-  23.growth.low 
noHess <- c(FALSE,FALSE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.growth.high  ----
# ----------------------------------------------------------- #

# Path to the 23.growth.high repertory
Dir_23_growth_high <- file.path(dir_SensAnal, '4.1_Growth_Sensitivity','1_23.growth.high' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_growth_high') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_growth_high 
# Data file :			 Dat23_growth_high 
# Control file :			 Ctl23_growth_high 
# Forecast file :			 Fore23_growth_high 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.growth.high", files="all")


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_growth_high, 'starter.ss', fsep = fsep)
Start23_growth_high <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_growth_high ,
      # dir =  Dir_23_growth_high, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_growth_high, 'starter.ss')
#  Start23_growth_high <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_growth_high')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_growth_high,Start23_growth_high$datfile, fsep = fsep)
Dat23_growth_high <- SS_readdat_3.30(
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
      # datlist =  Dat23_growth_high ,
      # outfile = file.path(Dir_23_growth_high, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_growth_high, 'SST_data.ss', fsep = fsep)
#  Dat23_growth_high <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_growth_high')
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
Ctlfile <-file.path(Dir_23_growth_high,Start23_growth_high$ctlfile, fsep = fsep)
Ctl23_growth_high <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_growth_high, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 


# Sensitivity to a higher growth sensitivity:
# Sensitivity to the higher growth of SST in the 
# Kline dataset (unsexed fish), which was not used in the base model

# Change length at a_1 and length at a_2 change to higher values 
# (25% higher than the base model, which is based on Butler age data (sexed fish))

# K and CV does not change in this sensitivity 
# Is this correct?

# Check
SS_Param2023$MG_params$Growth$base_2023  # base model growth (Butler)
SS_Param2023$MG_params$Growth$upper_sensitivity  # upper sensitivity (25% higher for length at a_1 and length at a_2)

# Make the change
Ctl23_growth_high$MG_parms[SS_Param2023$MG_params$Growth$base_2023$Parameter,]$INIT <- SS_Param2023$MG_params$Growth$upper_sensitivity$Value

# Also change the upper bound for male length at a_2
Ctl23_growth_high$MG_parms["L_at_Amax_Mal_GP_1",]$INIT # new value for upper sensitivity
Ctl23_growth_high$MG_parms["L_at_Amax_Mal_GP_1",]$HI <- 85 # change the upper bound from 75 cm to 85 cm

# Check
Ctl23_growth_high$MG_parms


# Save the control file for the model
 SS_writectl(
       ctllist =  Ctl23_growth_high ,
       outfile = file.path(Dir_23_growth_high, 'SST_control.ss', fsep = fsep),
       version = '3.30',
       overwrite = TRUE
       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_growth_high')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_growth_high, 'forecast.ss', fsep = fsep)
Fore23_growth_high <-SS_readforecast(
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
      # mylist =  Fore23_growth_high ,
      # dir = Dir_23_growth_high, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_growth_high, 'forecast.ss', fsep = fsep)
#  Fore23_growth_high <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_growth_high')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_growth_high,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.growth.highfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = '' # ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_growth_high, 'run', fsep = fsep)

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

# End development for model 23.growth.high 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_growth_high','Dat23_growth_high','Ctl23_growth_high','Fore23_growth_high')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.growth.low  ----
# ----------------------------------------------------------- #

# Path to the 23.growth.low repertory
Dir_23_growth_low <- file.path(dir_SensAnal, '4.1_Growth_Sensitivity','2_23.growth.low' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_growth_low') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_growth_low 
# Data file :					 Dat23_growth_low 
# Control file :					 Ctl23_growth_low 
# Forecast file :					 Fore23_growth_low 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.growth.low", files="all")


# 4.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_growth_low, 'starter.ss', fsep = fsep)
Start23_growth_low <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_growth_low ,
      # dir =  Dir_23_growth_low, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_growth_low, 'starter.ss')
#  Start23_growth_low <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_growth_low')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_growth_low,Start23_growth_low$datfile, fsep = fsep)
Dat23_growth_low <- SS_readdat_3.30(
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
      # datlist =  Dat23_growth_low ,
      # outfile = file.path(Dir_23_growth_low, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_growth_low, 'SST_data.ss', fsep = fsep)
#  Dat23_growth_low <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_growth_low')
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
Ctlfile <-file.path(Dir_23_growth_low,Start23_growth_low$ctlfile, fsep = fsep)
Ctl23_growth_low <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_growth_low, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

# Updates for the lower growth sensitivity:
# Length at a_1 and length at a_2 change to lower values 
# (10% lower than the base model)

# K and CV do not change 
# Is this correct?

SS_Param2023$MG_params$Growth$base_2023        # base model growth (Butler)
SS_Param2023$MG_params$Growth$lwr_sensitivity  # lower sensitivity (10% lower for length at a_1 and length at a_2)

# Make the change
Ctl23_growth_low$MG_parms[SS_Param2023$MG_params$Growth$base_2023$Parameter,]$INIT <- SS_Param2023$MG_params$Growth$lwr_sensitivity$Value

# Check
Ctl23_growth_low$MG_parms


# Save the control file for the model
 SS_writectl(
       ctllist =  Ctl23_growth_low ,
       outfile = file.path(Dir_23_growth_low, 'SST_control.ss', fsep = fsep),
       version = '3.30',
       overwrite = TRUE
       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_growth_low')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_growth_low, 'forecast.ss', fsep = fsep)
Fore23_growth_low <-SS_readforecast(
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
      # mylist =  Fore23_growth_low ,
      # dir = Dir_23_growth_low, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_growth_low, 'forecast.ss', fsep = fsep)
#  Fore23_growth_low <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_growth_low')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_growth_low,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.growth.lowfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = '' #ifelse(noHess[2], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_growth_low, 'run', fsep = fsep)

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
# This can be done using the 4.1_Growth_Sensitivity_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------



