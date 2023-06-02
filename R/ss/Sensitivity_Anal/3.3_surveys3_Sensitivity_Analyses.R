# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 3.3 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  surveys 
# Specific item in that topic: 
# 	- 2 survey vs 4 survey structure 
# 	- extra SD on WCGBTS 
# 	- No Triennial Survey 
# Author:  Andrea Odell 
# Date: 2023-06-01 10:56:12 
# Names of the models created:
# 	- 23.surveys.useslope 
# 	- 23.surveys.extaSDwcgbts 
# 	- 23.surveys.notriennial 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.surveys.useslope 				 23.model.francis_2 
# 23.surveys.extaSDwcgbts 				 23.model.francis_2 
# 23.surveys.notriennial 				 23.model.francis_2 
# 
# Results are stored in the following foler: 
#	 /Users/andrea/Desktop/shortspine_thornyhead_2023/model/Sensitivity_Anal/3.3_surveys3_Sensitivity 
# 
# General features: 
# This sensitivity analysis broadly explores the effect of different survey structures to understand the importance (or lack thereof) of the slope surveys and the triennial surveys 
# 
# Model features:
# - Model 23.surveys.useslope:
# 4 survey structure (slope surveys included) 
# - Model 23.surveys.extaSDwcgbts:
# base model + additional estimated SD for WCGBTS 
# - Model 23.surveys.notriennial:
# 1 survey structure (triennial excluded) 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# /Users/andrea/Desktop/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/3.3_surveys3_Sensitivity_Outputs.R 

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
# Reminder - The following models are considered:# 	-  23.surveys.useslope 
# 	-  23.surveys.extaSDwcgbts 
# 	-  23.surveys.notriennial 
noHess <- c(TRUE,TRUE,TRUE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.surveys.useslope  ----
# ----------------------------------------------------------- #

# Path to the 23.surveys.useslope repertory
Dir_23_surveys_useslope <- file.path(dir_SensAnal, '3.3_surveys3_Sensitivity','1_23.surveys.useslope' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_surveys_useslope') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_surveys_useslope 
# Data file :			 Dat23_surveys_useslope 
# Control file :			 Ctl23_surveys_useslope 
# Forecast file :			 Fore23_surveys_useslope 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.surveys.useslope", files="all")


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_surveys_useslope, 'starter.ss', fsep = fsep)
Start23_surveys_useslope <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_surveys_useslope ,
      # dir =  Dir_23_surveys_useslope, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_surveys_useslope, 'starter.ss')
#  Start23_surveys_useslope <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_surveys_useslope')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_surveys_useslope,Start23_surveys_useslope$datfile, fsep = fsep)
Dat23_surveys_useslope <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 

# adjust Nfleets
Dat23_surveys_useslope$Nfleets <- SS_Param2023$Nfleets$data$ThreeFleets_UseSlope_CombineTriennial

# adjust Fleet info
Dat23_surveys_useslope$fleetinfo <- SS_Param2023$fleet_info$data$ThreeFleets_UseSlope_CombineTriennial %>% 
  mutate(surveytiming = c(-1,-1,-1, 7, 7, 7, 7, 7))

#adjust fleet names
Dat23_surveys_useslope$fleetnames <- SS_Param2023$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial

# adjust CPUE info
Dat23_surveys_useslope$CPUEinfo <- SS_Param2023$CPUEinfo$data$ThreeFleets_UseSlope_CombineTriennial

# adjust CPUE data
Dat23_surveys_useslope$CPUE <- SS_Param2023$Indices$data$ThreeFleets_UseSlope_CombineTriennial

# adjust areas
Dat23_surveys_useslope$areas <- SS_Param2023$areas$data$ThreeFleets_UseSlope_CombineTriennial 

# adjust survey timing
Dat23_surveys_useslope$surveytiming <- SS_Param2023$surveytiming$data$ThreeFleets_UseSlope_CombineTriennial

# adjust length info
Dat23_surveys_useslope$len_info <- SS_Param2023$len_info$data$ThreeFleets_UseSlope_CombineTriennial 

# adjust length comps
Dat23_surveys_useslope$lencomp <- SS_Param2023$Fishery_LengthComp$data$ThreeFleets_UseSlope_CombineTriennial

# adjust number of surveys
Dat23_surveys_useslope$Nsurveys <- SS_Param2023$Nsurveys$data$ThreeFleets_UseSlope_CombineTriennial

# adjust survey timing vector
Dat23_surveys_useslope$surveytiming <- c(-1,-1,-1, 7, 7, 7, 7, 7)

# adjust max combined length bins to match number of fleet/surveys
Dat23_surveys_useslope$max_combined_lbin <- c(0,0,0,0,0,0,0,0)

# Save the data file for the model
SS_writedat(
     datlist =  Dat23_surveys_useslope ,
     outfile = file.path(Dir_23_surveys_useslope, 'SST_data.ss', fsep = fsep),
     version = '3.30',
     overwrite = TRUE
     )

# Check file structure
#DatFile <- file.path(Dir_23_surveys_useslope, 'SST_data.ss', fsep = fsep)
#Dat23_surveys_useslope <-
#      SS_readdat_3.30(
#      file = DatFile,
#      verbose = TRUE,
#      section = TRUE
#      )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_surveys_useslope')
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
Ctlfile <-file.path(Dir_23_surveys_useslope,Start23_surveys_useslope$ctlfile, fsep = fsep)
Ctl23_surveys_useslope <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_surveys_useslope, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 


# Adjust Nfleets

# Adjust fleetnames

# adjust Q_options

# adjust Qparms


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_surveys_useslope ,
      # outfile = file.path(Dir_23_surveys_useslope, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_surveys_useslope')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_surveys_useslope, 'forecast.ss', fsep = fsep)
Fore23_surveys_useslope <-SS_readforecast(
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
      # mylist =  Fore23_surveys_useslope ,
      # dir = Dir_23_surveys_useslope, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_surveys_useslope, 'forecast.ss', fsep = fsep)
#  Fore23_surveys_useslope <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_surveys_useslope')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_surveys_useslope,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.surveys.useslopefolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_surveys_useslope, 'run', fsep = fsep)

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

# End development for model 23.surveys.useslope 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_surveys_useslope','Dat23_surveys_useslope','Ctl23_surveys_useslope','Fore23_surveys_useslope')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.surveys.extaSDwcgbts  ----
# ----------------------------------------------------------- #

# Path to the 23.surveys.extaSDwcgbts repertory
Dir_23_surveys_extaSDwcgbts <- file.path(dir_SensAnal, '3.3_surveys3_Sensitivity','2_23.surveys.extaSDwcgbts' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_surveys_extaSDwcgbts') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_surveys_extaSDwcgbts 
# Data file :					 Dat23_surveys_extaSDwcgbts 
# Control file :					 Ctl23_surveys_extaSDwcgbts 
# Forecast file :					 Fore23_surveys_extaSDwcgbts 


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
StarterFile <- file.path(Dir_23_surveys_extaSDwcgbts, 'starter.ss', fsep = fsep)
Start23_surveys_extaSDwcgbts <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_surveys_extaSDwcgbts ,
      # dir =  Dir_23_surveys_extaSDwcgbts, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_surveys_extaSDwcgbts, 'starter.ss')
#  Start23_surveys_extaSDwcgbts <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_surveys_extaSDwcgbts')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_surveys_extaSDwcgbts,Start23_surveys_extaSDwcgbts$datfile, fsep = fsep)
Dat23_surveys_extaSDwcgbts <- SS_readdat_3.30(
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
      # datlist =  Dat23_surveys_extaSDwcgbts ,
      # outfile = file.path(Dir_23_surveys_extaSDwcgbts, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_surveys_extaSDwcgbts, 'SST_data.ss', fsep = fsep)
#  Dat23_surveys_extaSDwcgbts <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_surveys_extaSDwcgbts')
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
Ctlfile <-file.path(Dir_23_surveys_extaSDwcgbts,Start23_surveys_extaSDwcgbts$ctlfile, fsep = fsep)
Ctl23_surveys_extaSDwcgbts <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_surveys_extaSDwcgbts, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_surveys_extaSDwcgbts ,
      # outfile = file.path(Dir_23_surveys_extaSDwcgbts, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_surveys_extaSDwcgbts')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_surveys_extaSDwcgbts, 'forecast.ss', fsep = fsep)
Fore23_surveys_extaSDwcgbts <-SS_readforecast(
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
      # mylist =  Fore23_surveys_extaSDwcgbts ,
      # dir = Dir_23_surveys_extaSDwcgbts, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_surveys_extaSDwcgbts, 'forecast.ss', fsep = fsep)
#  Fore23_surveys_extaSDwcgbts <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_surveys_extaSDwcgbts')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_surveys_extaSDwcgbts,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.surveys.extaSDwcgbtsfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[2], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_surveys_extaSDwcgbts, 'run', fsep = fsep)

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

# End development for model 23.surveys.extaSDwcgbts 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_surveys_extaSDwcgbts','Dat23_surveys_extaSDwcgbts','Ctl23_surveys_extaSDwcgbts','Fore23_surveys_extaSDwcgbts')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.surveys.notriennial  ----
# ----------------------------------------------------------- #

# Path to the 23.surveys.notriennial repertory
Dir_23_surveys_notriennial <- file.path(dir_SensAnal, '3.3_surveys3_Sensitivity','3_23.surveys.notriennial' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_surveys_notriennial') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_surveys_notriennial 
# Data file :			 Dat23_surveys_notriennial 
# Control file :			 Ctl23_surveys_notriennial 
# Forecast file :			 Fore23_surveys_notriennial 


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
StarterFile <- file.path(Dir_23_surveys_notriennial, 'starter.ss', fsep = fsep)
Start23_surveys_notriennial <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_surveys_notriennial ,
      # dir =  Dir_23_surveys_notriennial, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_surveys_notriennial, 'starter.ss')
#  Start23_surveys_notriennial <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_surveys_notriennial')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_surveys_notriennial,Start23_surveys_notriennial$datfile, fsep = fsep)
Dat23_surveys_notriennial <- SS_readdat_3.30(
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
      # datlist =  Dat23_surveys_notriennial ,
      # outfile = file.path(Dir_23_surveys_notriennial, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_surveys_notriennial, 'SST_data.ss', fsep = fsep)
#  Dat23_surveys_notriennial <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_surveys_notriennial')
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
Ctlfile <-file.path(Dir_23_surveys_notriennial,Start23_surveys_notriennial$ctlfile, fsep = fsep)
Ctl23_surveys_notriennial <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_surveys_notriennial, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_surveys_notriennial ,
      # outfile = file.path(Dir_23_surveys_notriennial, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_surveys_notriennial')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_surveys_notriennial, 'forecast.ss', fsep = fsep)
Fore23_surveys_notriennial <-SS_readforecast(
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
      # mylist =  Fore23_surveys_notriennial ,
      # dir = Dir_23_surveys_notriennial, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_surveys_notriennial, 'forecast.ss', fsep = fsep)
#  Fore23_surveys_notriennial <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_surveys_notriennial')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_surveys_notriennial,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.surveys.notriennialfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[3], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_surveys_notriennial, 'run', fsep = fsep)

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
# This can be done using the 3.3_surveys3_Sensitivity_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------


