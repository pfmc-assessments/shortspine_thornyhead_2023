# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 5.22 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic: 
# 	- Low-State 045 
# 	- Base Case 045 
# 	- High-State 045 
# Author:  Team Thornyhead 
# Date: 2023-06-08 15:42:54 
# Names of the models created:
# 	- 23.dt.low_045 
# 	- 23.dt.base_045 
# 	- 23.dt.high_045 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.dt.low_045 				 23.STAR.base 
# 23.dt.base_045 				 23.STAR.base 
# 23.dt.high_045 				 23.STAR.base 
# 
# Results are stored in the following foler: 
#	 /Users/jzahner/Desktop/Projects/shortspine_thornyhead_2023/model/Sensitivity_Anal/STAR_Panel/5.22_STAR_decision_table_045 
# 
# General features: 
# Decision table for STAR panel using P*=0.45. Axes of uncertainty are on natural mortality. 
# 
# Model features:
# - Model 23.dt.low_045:
# M=0.0373 
# - Model 23.dt.base_045:
# M=0.040 
# - Model 23.dt.high_045:
# M=0.046 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# /Users/jzahner/Desktop/Projects/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/5.22_STAR_decision_table_045_Outputs.R 

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
# 	-  23.dt.low_045 
# 	-  23.dt.base_045 
# 	-  23.dt.high_045 
noHess <- c(TRUE,TRUE,TRUE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.dt.low_045  ----
# ----------------------------------------------------------- #

# Path to the 23.dt.low_045 repertory
Dir_23_dt_low_045 <- file.path(dir_SensAnal, '5.22_STAR_decision_table_045','1_23.dt.low_045' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_dt_low_045') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_dt_low_045 
# Data file :			 Dat23_dt_low_045 
# Control file :			 Ctl23_dt_low_045 
# Forecast file :			 Fore23_dt_low_045 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.STAR.base',
      curr.model = '23.dt.low_045',
      files = 'all')


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_dt_low_045, 'starter.ss', fsep = fsep)
Start23_dt_low_045 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_dt_low_045 ,
      dir =  Dir_23_dt_low_045, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_dt_low_045, 'starter.ss')
#  Start23_dt_low_045 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_dt_low_045')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_dt_low_045,Start23_dt_low_045$datfile, fsep = fsep)
Dat23_dt_low_045 <- SS_readdat_3.30(
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
      datlist =  Dat23_dt_low_045 ,
      outfile = file.path(Dir_23_dt_low_045, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_dt_low_045, 'SST_data.ss', fsep = fsep)
#  Dat23_dt_low_045 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_dt_low_045')
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
Ctlfile <-file.path(Dir_23_dt_low_045,Start23_dt_low_045$ctlfile, fsep = fsep)
Ctl23_dt_low_045 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_dt_low_045, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_dt_low_045$MG_parms[c("NatM_p_1_Fem_GP_1", "NatM_p_2_Fem_GP_1", "NatM_p_1_Mal_GP_1", "NatM_p_2_Mal_GP_1"),]$INIT <- c(0.03, 0.03, 0.03, 0.03)




# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_dt_low_045 ,
      outfile = file.path(Dir_23_dt_low_045, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_dt_low_045')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
file.copy(from = file.path(here::here(),"model", "sst_forecast_STAR_Pstar_45.ss"), to = file.path(Dir_23_dt_low_045, "forecast.ss"), overwrite = TRUE)

ForeFile <- file.path(Dir_23_dt_low_045, 'forecast.ss', fsep = fsep)

Fore23_dt_low_045 <-SS_readforecast(
      file = ForeFile,
      version = '3.30',
      verbose = T,
      readAll = T
      )

# Save the forecast file for the model
SS_writeforecast(
  mylist =  Fore23_dt_low_045 ,
  dir = Dir_23_dt_low_045, 
  file = 'forecast.ss',
  writeAll = TRUE,
  verbose = TRUE,
  overwrite = TRUE
)

#Fore23_dt_low_045$Flimitfraction <- 1
#Fore23_dt_low_045$Flimitfraction_m <- data.frame()
#
#forecast_catches <- replist$timeseries %>% select(Yr, starts_with#("dead(B)")) %>% filter(Yr > 2022)
#fore_catches = forecast_catches %>% 
#  tidyr::pivot_longer(starts_with("dead(B)"), names_to="Fleet", #values_to="Catch(or_F)") %>%
#  mutate(
#    Seas=1,
#    Fleet = case_when(
#      Fleet=="dead(B):_1" ~ 1,
#      Fleet=="dead(B):_2" ~ 2,
#      Fleet=="dead(B):_3" ~ 3
#    )
#  ) %>% 
#  select(Yr, Seas, Fleet, "Catch(or_F)") %>%
#  print(n=100)
#
#Fore23_dt_low_045$ForeCatch <- fore_catches

# Save the forecast file for the model
#SS_writeforecast(
#      mylist =  Fore23_dt_low_045 ,
#      dir = file.path(here::here(),"model"), 
#      file = 'sst_forecast_STAR_Pstar_45.ss',
#      writeAll = TRUE,
#      verbose = TRUE,
#      overwrite = TRUE
#      )



# Check file structure
# ForeFile <- file.path(Dir_23_dt_low_045, 'forecast.ss', fsep = fsep)
#  Fore23_dt_low_045 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_dt_low_045')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_dt_low_045,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.dt.low_045folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_dt_low_045, 'run', fsep = fsep)

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

# End development for model 23.dt.low_045 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_dt_low_045','Dat23_dt_low_045','Ctl23_dt_low_045','Fore23_dt_low_045')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.dt.base_045  ----
# ----------------------------------------------------------- #

# Path to the 23.dt.base_045 repertory
Dir_23_dt_base_045 <- file.path(dir_SensAnal, '5.22_STAR_decision_table_045','2_23.dt.base_045' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_dt_base_045') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_dt_base_045 
# Data file :					 Dat23_dt_base_045 
# Control file :					 Ctl23_dt_base_045 
# Forecast file :					 Fore23_dt_base_045 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.STAR.base',
      curr.model = '23.dt.base_045',
      files = 'all')


# 4.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_dt_base_045, 'starter.ss', fsep = fsep)
Start23_dt_base_045 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_dt_base_045 ,
      dir =  Dir_23_dt_base_045, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_dt_base_045, 'starter.ss')
#  Start23_dt_base_045 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_dt_base_045')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_dt_base_045,Start23_dt_base_045$datfile, fsep = fsep)
Dat23_dt_base_045 <- SS_readdat_3.30(
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
      datlist =  Dat23_dt_base_045 ,
      outfile = file.path(Dir_23_dt_base_045, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_dt_base_045, 'SST_data.ss', fsep = fsep)
#  Dat23_dt_base_045 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_dt_base_045')
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
Ctlfile <-file.path(Dir_23_dt_base_045,Start23_dt_base_045$ctlfile, fsep = fsep)
Ctl23_dt_base_045 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_dt_base_045, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_dt_base_045 ,
      outfile = file.path(Dir_23_dt_base_045, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_dt_base_045')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
file.copy(from = file.path(here::here(),"model", "sst_forecast_STAR_Pstar_45.ss"), to = file.path(Dir_23_dt_base_045, "forecast.ss"), overwrite = TRUE)

ForeFile <- file.path(Dir_23_dt_base_045, 'forecast.ss', fsep = fsep)

file.copy(from = file.path(here::here(),"model", "sst_forecast_45.ss"), to = ForeFile, overwrite = TRUE)


Fore23_dt_base_045 <-SS_readforecast(
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
      mylist =  Fore23_dt_base_045 ,
      dir = Dir_23_dt_base_045, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_dt_base_045, 'forecast.ss', fsep = fsep)
#  Fore23_dt_base_045 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_dt_base_045')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_dt_base_045,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.dt.base_045folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[2], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_dt_base_045, 'run', fsep = fsep)

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

# End development for model 23.dt.base_045 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_dt_base_045','Dat23_dt_base_045','Ctl23_dt_base_045','Fore23_dt_base_045')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.dt.high_045  ----
# ----------------------------------------------------------- #

# Path to the 23.dt.high_045 repertory

Dir_23_dt_high_045 <- file.path(dir_SensAnal, '5.22_STAR_decision_table_045','3_23.dt.high_045' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_dt_high_045') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_dt_high_045 
# Data file :			 Dat23_dt_high_045 
# Control file :			 Ctl23_dt_high_045 
# Forecast file :			 Fore23_dt_high_045 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.STAR.base',
      curr.model = '23.dt.high_045',
      files = 'all')


# 5.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_dt_high_045, 'starter.ss', fsep = fsep)
Start23_dt_high_045 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_dt_high_045 ,
      dir =  Dir_23_dt_high_045, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_dt_high_045, 'starter.ss')
#  Start23_dt_high_045 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_dt_high_045')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_dt_high_045,Start23_dt_high_045$datfile, fsep = fsep)
Dat23_dt_high_045 <- SS_readdat_3.30(
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
      datlist =  Dat23_dt_high_045 ,
      outfile = file.path(Dir_23_dt_high_045, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_dt_high_045, 'SST_data.ss', fsep = fsep)
#  Dat23_dt_high_045 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_dt_high_045')
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
Ctlfile <-file.path(Dir_23_dt_high_045,Start23_dt_high_045$ctlfile, fsep = fsep)
Ctl23_dt_high_045 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_dt_high_045, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

Ctl23_dt_high_045$MG_parms[c("NatM_p_1_Fem_GP_1", "NatM_p_2_Fem_GP_1", "NatM_p_1_Mal_GP_1", "NatM_p_2_Mal_GP_1"),]$INIT <- c(0.05, 0.05, 0.05, 0.05)


# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_dt_high_045 ,
      outfile = file.path(Dir_23_dt_high_045, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_dt_high_045')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
file.copy(from = file.path(here::here(),"model", "sst_forecast_STAR_Pstar_45.ss"), to = file.path(Dir_23_dt_high_045, "forecast.ss"), overwrite = TRUE)

ForeFile <- file.path(Dir_23_dt_high_045, 'forecast.ss', fsep = fsep)
Fore23_dt_high_045 <-SS_readforecast(
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
      mylist =  Fore23_dt_high_045 ,
      dir = Dir_23_dt_high_045, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_dt_high_045, 'forecast.ss', fsep = fsep)
#  Fore23_dt_high_045 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_dt_high_045')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_dt_high_045,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.dt.high_045folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[3], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_dt_high_045, 'run', fsep = fsep)

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
# This can be done using the 5.22_STAR_decision_table_045_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------


