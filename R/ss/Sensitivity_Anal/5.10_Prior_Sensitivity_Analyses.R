# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 5.10 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic: 
# 	- Prior on Selectivity - 1 Blk 
# 	- Prior on Selectivity - 2 Blks 
# 	- Prior on Selectivity - 3 Blks 
# Author:  Pierre-Yves Hernvann & Matthieu Veron 
# Date: 2023-05-08 10:59:58 
# Names of the models created:
# 	-  23.slx.Prior.1Blk 
# 	-  23.slx.Prior.2Blk 
# 	-  23.slx.Prior.3Blk 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.slx.Prior.1Blk 				 23.blkret.T3 
# 23.slx.Prior.2Blk 				 23.blkret.T3 
# 23.slx.Prior.3Blk 				 23.blkret.T3 
# 
# Results are stored in the following foler: 
#	 C:/Users/Matthieu Verson/Documents/GitHub/Forked_repos/shortspine_thornyhead_2023/model/Sensitivity_Anal/5.10_Prior_Selectivity_Sensitivity 
# 
# General features: 
# Incorporation of Priors and time blocks in Selx parameters (peak) 
# 
# Model features:
# - Model 23.slx.Prior.1Blk:
# Time block 1 
# - Model 23.slx.Prior.2Blk:
# Time block 2 
# - Model 23.slx.Prior.3Blk:
# Time block 3 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/Users/Matthieu Verson/Documents/GitHub/Forked_repos/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/5.10_Prior_Sensitivity_Outputs.R 

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
# Reminder - The following models are considered:# 	-  23.slx.Prior.1Blk 
# 	-  23.slx.Prior.2Blk 
# 	-  23.slx.Prior.3Blk 
# noHess <- c(FALSE,FALSE,FALSE)
noHess <- c(TRUE,TRUE,TRUE)

var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.slx.Prior.1Blk  ----
# ----------------------------------------------------------- #

# Path to the 23.slx.Prior.1Blk repertory
Dir_23_slx_Prior_1Blk <- file.path(dir_SensAnal, '5.10_Prior_Selectivity_Sensitivity','1_23.slx.Prior.1Blk' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_slx_Prior_1Blk') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_slx_Prior_1Blk 
# Data file :			 Dat23_slx_Prior_1Blk 
# Control file :			 Ctl23_slx_Prior_1Blk 
# Forecast file :			 Fore23_slx_Prior_1Blk 


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
StarterFile <- file.path(Dir_23_slx_Prior_1Blk, 'starter.ss', fsep = fsep)
Start23_slx_Prior_1Blk <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_slx_Prior_1Blk ,
      # dir =  Dir_23_slx_Prior_1Blk, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_slx_Prior_1Blk, 'starter.ss')
#  Start23_slx_Prior_1Blk <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_slx_Prior_1Blk')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_slx_Prior_1Blk,Start23_slx_Prior_1Blk$datfile, fsep = fsep)
Dat23_slx_Prior_1Blk <- SS_readdat_3.30(
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
      # datlist =  Dat23_slx_Prior_1Blk ,
      # outfile = file.path(Dir_23_slx_Prior_1Blk, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_slx_Prior_1Blk, 'SST_data.ss', fsep = fsep)
#  Dat23_slx_Prior_1Blk <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_slx_Prior_1Blk')
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
Ctlfile <-file.path(Dir_23_slx_Prior_1Blk,Start23_slx_Prior_1Blk$ctlfile, fsep = fsep)
Ctl23_slx_Prior_1Blk <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_slx_Prior_1Blk, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

# This block will be based on Block pattern 3
# Block dates 2003-2022
Ctl23_slx_Prior_1Blk$Block_Design[[3]][1] <- 2003 


# Add the specification of the time block and function in the
# selex matrix
tmp <- Ctl23_slx_Prior_1Blk$size_selex_parms
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block_Fxn"] <- 3
Ctl23_slx_Prior_1Blk$size_selex_parms <- tmp
rm(tmp)

# Set up the time varying params
tmp <- Ctl23_slx_Prior_1Blk$size_selex_parms_tv
tmp<-rbind(c(-10, 10, 0,0,5,6,2),
           tmp)
Ctl23_slx_Prior_1Blk$size_selex_parms_tv <- tmp
rm(tmp)

# Save the control file for the model
SS_writectl(
ctllist =  Ctl23_slx_Prior_1Blk ,
outfile = file.path(Dir_23_slx_Prior_1Blk, 'SST_control.ss', fsep = fsep),
version = '3.30',
overwrite = TRUE
)
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_slx_Prior_1Blk')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_slx_Prior_1Blk, 'forecast.ss', fsep = fsep)
Fore23_slx_Prior_1Blk <-SS_readforecast(
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
      # mylist =  Fore23_slx_Prior_1Blk ,
      # dir = Dir_23_slx_Prior_1Blk, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_slx_Prior_1Blk, 'forecast.ss', fsep = fsep)
#  Fore23_slx_Prior_1Blk <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_slx_Prior_1Blk')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_slx_Prior_1Blk,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.slx.Prior.1Blkfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_slx_Prior_1Blk, 'run', fsep = fsep)

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

# End development for model 23.slx.Prior.1Blk 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_slx_Prior_1Blk','Dat23_slx_Prior_1Blk','Ctl23_slx_Prior_1Blk','Fore23_slx_Prior_1Blk')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.slx.Prior.2Blk  ----
# ----------------------------------------------------------- #

# Path to the 23.slx.Prior.2Blk repertory
Dir_23_slx_Prior_2Blk <- file.path(dir_SensAnal, '5.10_Prior_Selectivity_Sensitivity','2_23.slx.Prior.2Blk' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_slx_Prior_2Blk') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_slx_Prior_2Blk 
# Data file :					 Dat23_slx_Prior_2Blk 
# Control file :					 Ctl23_slx_Prior_2Blk 
# Forecast file :					 Fore23_slx_Prior_2Blk 


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
StarterFile <- file.path(Dir_23_slx_Prior_2Blk, 'starter.ss', fsep = fsep)
Start23_slx_Prior_2Blk <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_slx_Prior_2Blk ,
      # dir =  Dir_23_slx_Prior_2Blk, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_slx_Prior_2Blk, 'starter.ss')
#  Start23_slx_Prior_2Blk <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_slx_Prior_2Blk')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_slx_Prior_2Blk,Start23_slx_Prior_2Blk$datfile, fsep = fsep)
Dat23_slx_Prior_2Blk <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 





# Save the data file for the model
# SS_writedat(
      # datlist =  Dat23_slx_Prior_2Blk ,
      # outfile = file.path(Dir_23_slx_Prior_2Blk, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_slx_Prior_2Blk, 'SST_data.ss', fsep = fsep)
#  Dat23_slx_Prior_2Blk <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_slx_Prior_2Blk')
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
Ctlfile <-file.path(Dir_23_slx_Prior_2Blk,Start23_slx_Prior_2Blk$ctlfile, fsep = fsep)
Ctl23_slx_Prior_2Blk <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_slx_Prior_2Blk, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 



# This block will be based on Block pattern 3
# Block dates 2003-2022
Ctl23_slx_Prior_2Blk$blocks_per_pattern[3] <- 2
Ctl23_slx_Prior_2Blk$Block_Design[[3]] <- c(2003, 2010, 2011, 2022) 


# Add the specification of the time block and function in the
# selex matrix
tmp <- Ctl23_slx_Prior_2Blk$size_selex_parms
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block_Fxn"] <- 3
Ctl23_slx_Prior_2Blk$size_selex_parms <- tmp
rm(tmp)

# Set up the time varying params
tmp <- Ctl23_slx_Prior_2Blk$size_selex_parms_tv
tmp<-rbind(c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           tmp)
Ctl23_slx_Prior_2Blk$size_selex_parms_tv <- tmp
rm(tmp)

# Save the control file for the model
SS_writectl(
ctllist =  Ctl23_slx_Prior_2Blk ,
outfile = file.path(Dir_23_slx_Prior_2Blk, 'SST_control.ss', fsep = fsep),
version = '3.30',
overwrite = TRUE
)
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_slx_Prior_2Blk')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_slx_Prior_2Blk, 'forecast.ss', fsep = fsep)
Fore23_slx_Prior_2Blk <-SS_readforecast(
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
      # mylist =  Fore23_slx_Prior_2Blk ,
      # dir = Dir_23_slx_Prior_2Blk, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_slx_Prior_2Blk, 'forecast.ss', fsep = fsep)
#  Fore23_slx_Prior_2Blk <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_slx_Prior_2Blk')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_slx_Prior_2Blk,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.slx.Prior.2Blkfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[2], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_slx_Prior_2Blk, 'run', fsep = fsep)

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

# End development for model 23.slx.Prior.2Blk 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_slx_Prior_2Blk','Dat23_slx_Prior_2Blk','Ctl23_slx_Prior_2Blk','Fore23_slx_Prior_2Blk')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.slx.Prior.3Blk  ----
# ----------------------------------------------------------- #

# Path to the 23.slx.Prior.3Blk repertory
Dir_23_slx_Prior_3Blk <- file.path(dir_SensAnal, '5.10_Prior_Selectivity_Sensitivity','3_23.slx.Prior.3Blk' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_slx_Prior_3Blk') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_slx_Prior_3Blk 
# Data file :			 Dat23_slx_Prior_3Blk 
# Control file :			 Ctl23_slx_Prior_3Blk 
# Forecast file :			 Fore23_slx_Prior_3Blk 


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
StarterFile <- file.path(Dir_23_slx_Prior_3Blk, 'starter.ss', fsep = fsep)
Start23_slx_Prior_3Blk <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_slx_Prior_3Blk ,
      # dir =  Dir_23_slx_Prior_3Blk, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_slx_Prior_3Blk, 'starter.ss')
#  Start23_slx_Prior_3Blk <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_slx_Prior_3Blk')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_slx_Prior_3Blk,Start23_slx_Prior_3Blk$datfile, fsep = fsep)
Dat23_slx_Prior_3Blk <- SS_readdat_3.30(
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
      # datlist =  Dat23_slx_Prior_3Blk ,
      # outfile = file.path(Dir_23_slx_Prior_3Blk, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_slx_Prior_3Blk, 'SST_data.ss', fsep = fsep)
#  Dat23_slx_Prior_3Blk <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_slx_Prior_3Blk')
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
Ctlfile <-file.path(Dir_23_slx_Prior_3Blk,Start23_slx_Prior_3Blk$ctlfile, fsep = fsep)
Ctl23_slx_Prior_3Blk <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_slx_Prior_3Blk, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_slx_Prior_3Blk ,
      # outfile = file.path(Dir_23_slx_Prior_3Blk, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_slx_Prior_3Blk')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_slx_Prior_3Blk, 'forecast.ss', fsep = fsep)
Fore23_slx_Prior_3Blk <-SS_readforecast(
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
      # mylist =  Fore23_slx_Prior_3Blk ,
      # dir = Dir_23_slx_Prior_3Blk, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_slx_Prior_3Blk, 'forecast.ss', fsep = fsep)
#  Fore23_slx_Prior_3Blk <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_slx_Prior_3Blk')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_slx_Prior_3Blk,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.slx.Prior.3Blkfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[3], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_slx_Prior_3Blk, 'run', fsep = fsep)

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
# This can be done using the 5.10_Prior_Sensitivity_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------
