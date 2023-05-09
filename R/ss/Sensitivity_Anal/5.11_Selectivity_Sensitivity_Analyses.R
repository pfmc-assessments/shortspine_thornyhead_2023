# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 5.11 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic: 
# 	- base blksel 2003 
# 	- base blksel 2011 
# 	- base blksel 2003+2011 
# 	- base blksel 2003+2011+2019 
# 	- blkretT3 blksel 2003 
# 	- blkretT3 blksel 2011 
# 	- blkretT3 blksel 2003+2011 
# 	- blkretT3 blksel 2003+2011+2019 
# Author:  Pierre-Yves Hernvann 
# Date: 2023-05-08 23:59:23 
# Names of the models created:
# 	- 23.blksel.T1 
# 	- 23.blksel.T2 
# 	- 23.blksel.T3 
# 	- 23.blksel.T4 
# 	- 23.blkret.T3.blksel.T1 
# 	- 23.blkret.T3.blksel.T2 
# 	- 23.blkret.T3.blksel.T3 
# 	- 23.blkret.T3.blksel.T4 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.blksel.T1 				 23.model.francis_2 
# 23.blksel.T2 				 23.model.francis_2 
# 23.blksel.T3 				 23.model.francis_2 
# 23.blksel.T4 				 23.model.francis_2 
# 23.blkret.T3.blksel.T1 				 23.blkret.T3 
# 23.blkret.T3.blksel.T2 				 23.blkret.T3 
# 23.blkret.T3.blksel.T3 				 23.blkret.T3 
# 23.blkret.T3.blksel.T4 				 23.blkret.T3 
# 
# Results are stored in the following foler: 
#	 C:/Users/pyher/Documents/shortspine_thornyhead_2023/model/Sensitivity_Anal/5.11_Selectivity_Sensitivity 
# 
# General features: 
# Sensitivity analysis for the time blocks on selectivity 
# 
# Model features:
# - Model 23.blksel.T1:
# base model with selectivity time block in 2003 (trawl) 
# - Model 23.blksel.T2:
# base model with selectivity time block in 2011 (trawl) 
# - Model 23.blksel.T3:
# base model with selectivity time block in 2003+2011 (trawl) 
# - Model 23.blksel.T4:
# base model with selectivity time block in 2003+2011+2019 (trawl) 
# - Model 23.blkret.T3.blksel.T1:
# Retention time blocks version T3 with selectivity time block in 2003 
# - Model 23.blkret.T3.blksel.T2:
# Retention time blocks version T3 with selectivity time block in 2011 
# - Model 23.blkret.T3.blksel.T3:
# Retention time blocks version T3 with selectivity time block in 2003+2011 
# - Model 23.blkret.T3.blksel.T4:
# Retention time blocks version T3 with selectivity time block in 2003+2011+2019 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/Users/pyher/Documents/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/5.11_Selectivity_Sensitivity_Outputs.R 

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
# Reminder - The following models are considered:# 	-  23.blksel.T1 
# 	-  23.blksel.T2 
# 	-  23.blksel.T3 
# 	-  23.blksel.T4 
# 	-  23.blkret.T3.blksel.T1 
# 	-  23.blkret.T3.blksel.T2 
# 	-  23.blkret.T3.blksel.T3 
# 	-  23.blkret.T3.blksel.T4 
noHess <- c(TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.blksel.T1  ----
# ----------------------------------------------------------- #

# Path to the 23.blksel.T1 repertory
Dir_23_blksel_T1 <- file.path(dir_SensAnal, '5.11_Selectivity_Sensitivity','1_23.blksel.T1' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blksel_T1') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blksel_T1 
# Data file :			 Dat23_blksel_T1 
# Control file :			 Ctl23_blksel_T1 
# Forecast file :			 Fore23_blksel_T1 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
# Restart_SA_modeldvpt()
Restart_SA_modeldvpt(base.model = "23.model.francis_2",
                     curr.model = "23.blksel.T1",
                     files = "all")

# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_blksel_T1, 'starter.ss', fsep = fsep)
Start23_blksel_T1 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blksel_T1 ,
      # dir =  Dir_23_blksel_T1, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blksel_T1, 'starter.ss')
#  Start23_blksel_T1 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blksel_T1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blksel_T1,Start23_blksel_T1$datfile, fsep = fsep)
Dat23_blksel_T1 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blksel_T1 ,
      # outfile = file.path(Dir_23_blksel_T1, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blksel_T1, 'SST_data.ss', fsep = fsep)
#  Dat23_blksel_T1 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blksel_T1')
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
Ctlfile <-file.path(Dir_23_blksel_T1,Start23_blksel_T1$ctlfile, fsep = fsep)
Ctl23_blksel_T1 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blksel_T1, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blksel_T1$Block_Design[[3]][1] <- 2003 
tmp <- Ctl23_blksel_T1$size_selex_parms
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block_Fxn"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block_Fxn"] <- 3
Ctl23_blksel_T1$size_selex_parms <- tmp
rm(tmp)

tmp <- Ctl23_blksel_T1$size_selex_parms_tv
tmp<-rbind(c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           tmp)
Ctl23_blksel_T1$size_selex_parms_tv <- tmp
rm(tmp)

# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_blksel_T1 ,
      outfile = file.path(Dir_23_blksel_T1, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blksel_T1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blksel_T1, 'forecast.ss', fsep = fsep)
Fore23_blksel_T1 <-SS_readforecast(
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
      # mylist =  Fore23_blksel_T1 ,
      # dir = Dir_23_blksel_T1, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blksel_T1, 'forecast.ss', fsep = fsep)
#  Fore23_blksel_T1 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blksel_T1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blksel_T1,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blksel.T1folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blksel_T1, 'run', fsep = fsep)

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

# End development for model 23.blksel.T1 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blksel_T1','Dat23_blksel_T1','Ctl23_blksel_T1','Fore23_blksel_T1')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.blksel.T2  ----
# ----------------------------------------------------------- #

# Path to the 23.blksel.T2 repertory
Dir_23_blksel_T2 <- file.path(dir_SensAnal, '5.11_Selectivity_Sensitivity','2_23.blksel.T2' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blksel_T2') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_blksel_T2 
# Data file :					 Dat23_blksel_T2 
# Control file :					 Ctl23_blksel_T2 
# Forecast file :					 Fore23_blksel_T2 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
# Restart_SA_modeldvpt()
Restart_SA_modeldvpt(base.model = "23.model.francis_2",
                     curr.model = "23.blksel.T2",
                     files = "all")

# 4.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_blksel_T2, 'starter.ss', fsep = fsep)
Start23_blksel_T2 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blksel_T2 ,
      # dir =  Dir_23_blksel_T2, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blksel_T2, 'starter.ss')
#  Start23_blksel_T2 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blksel_T2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blksel_T2,Start23_blksel_T2$datfile, fsep = fsep)
Dat23_blksel_T2 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blksel_T2 ,
      # outfile = file.path(Dir_23_blksel_T2, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blksel_T2, 'SST_data.ss', fsep = fsep)
#  Dat23_blksel_T2 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blksel_T2')
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
Ctlfile <-file.path(Dir_23_blksel_T2,Start23_blksel_T2$ctlfile, fsep = fsep)
Ctl23_blksel_T2 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blksel_T2, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blksel_T2$Block_Design[[3]][1] <- 2011 
tmp <- Ctl23_blksel_T2$size_selex_parms
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block_Fxn"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block_Fxn"] <- 3
Ctl23_blksel_T2$size_selex_parms <- tmp
rm(tmp)

tmp <- Ctl23_blksel_T2$size_selex_parms_tv
tmp<-rbind(c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           tmp)
Ctl23_blksel_T2$size_selex_parms_tv <- tmp
rm(tmp)


# Save the control file for the model
SS_writectl(
    ctllist =  Ctl23_blksel_T2 ,
    outfile = file.path(Dir_23_blksel_T2, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blksel_T2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blksel_T2, 'forecast.ss', fsep = fsep)
Fore23_blksel_T2 <-SS_readforecast(
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
      # mylist =  Fore23_blksel_T2 ,
      # dir = Dir_23_blksel_T2, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blksel_T2, 'forecast.ss', fsep = fsep)
#  Fore23_blksel_T2 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blksel_T2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blksel_T2,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blksel.T2folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[2], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blksel_T2, 'run', fsep = fsep)

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

# End development for model 23.blksel.T2 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blksel_T2','Dat23_blksel_T2','Ctl23_blksel_T2','Fore23_blksel_T2')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.blksel.T3  ----
# ----------------------------------------------------------- #

# Path to the 23.blksel.T3 repertory
Dir_23_blksel_T3 <- file.path(dir_SensAnal, '5.11_Selectivity_Sensitivity','3_23.blksel.T3' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blksel_T3') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blksel_T3 
# Data file :			 Dat23_blksel_T3 
# Control file :			 Ctl23_blksel_T3 
# Forecast file :			 Fore23_blksel_T3 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
# Restart_SA_modeldvpt()
Restart_SA_modeldvpt(base.model = "23.model.francis_2",
                     curr.model = "23.blksel.T3",
                     files = "all")

# 5.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_blksel_T3, 'starter.ss', fsep = fsep)
Start23_blksel_T3 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blksel_T3 ,
      # dir =  Dir_23_blksel_T3, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blksel_T3, 'starter.ss')
#  Start23_blksel_T3 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blksel_T3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blksel_T3,Start23_blksel_T3$datfile, fsep = fsep)
Dat23_blksel_T3 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blksel_T3 ,
      # outfile = file.path(Dir_23_blksel_T3, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blksel_T3, 'SST_data.ss', fsep = fsep)
#  Dat23_blksel_T3 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blksel_T3')
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
Ctlfile <-file.path(Dir_23_blksel_T3,Start23_blksel_T3$ctlfile, fsep = fsep)
Ctl23_blksel_T3 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blksel_T3, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blksel_T3$Block_Design[[3]] <- c(2003, 2010, 2011, 2022)


Ctl23_blksel_T3$blocks_per_pattern[3] <- 2

tmp <- Ctl23_blksel_T3$size_selex_parms
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block_Fxn"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block_Fxn"] <- 3
Ctl23_blksel_T3$size_selex_parms <- tmp
rm(tmp)

tmp <- Ctl23_blksel_T3$size_selex_parms_tv
tmp<-rbind(c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           tmp)
Ctl23_blksel_T3$size_selex_parms_tv <- tmp
rm(tmp)


# Save the control file for the model
 SS_writectl(
       ctllist =  Ctl23_blksel_T3 ,
       outfile = file.path(Dir_23_blksel_T3, 'SST_control.ss', fsep = fsep),
       version = '3.30',
       overwrite = TRUE
       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blksel_T3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blksel_T3, 'forecast.ss', fsep = fsep)
Fore23_blksel_T3 <-SS_readforecast(
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
      # mylist =  Fore23_blksel_T3 ,
      # dir = Dir_23_blksel_T3, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blksel_T3, 'forecast.ss', fsep = fsep)
#  Fore23_blksel_T3 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blksel_T3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blksel_T3,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blksel.T3folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[3], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blksel_T3, 'run', fsep = fsep)

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

# End development for model 23.blksel.T3 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blksel_T3','Dat23_blksel_T3','Ctl23_blksel_T3','Fore23_blksel_T3')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  6. Developing model 23.blksel.T4  ----
# ----------------------------------------------------------- #

# Path to the 23.blksel.T4 repertory
Dir_23_blksel_T4 <- file.path(dir_SensAnal, '5.11_Selectivity_Sensitivity','4_23.blksel.T4' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blksel_T4') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blksel_T4 
# Data file :			 Dat23_blksel_T4 
# Control file :			 Ctl23_blksel_T4 
# Forecast file :			 Fore23_blksel_T4 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
# Restart_SA_modeldvpt()
Restart_SA_modeldvpt(base.model = "23.model.francis_2",
                     curr.model = "23.blksel.T4",
                     files = "all")

# 6.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_blksel_T4, 'starter.ss', fsep = fsep)
Start23_blksel_T4 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blksel_T4 ,
      # dir =  Dir_23_blksel_T4, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blksel_T4, 'starter.ss')
#  Start23_blksel_T4 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blksel_T4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blksel_T4,Start23_blksel_T4$datfile, fsep = fsep)
Dat23_blksel_T4 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blksel_T4 ,
      # outfile = file.path(Dir_23_blksel_T4, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blksel_T4, 'SST_data.ss', fsep = fsep)
#  Dat23_blksel_T4 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blksel_T4')
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
Ctlfile <-file.path(Dir_23_blksel_T4,Start23_blksel_T4$ctlfile, fsep = fsep)
Ctl23_blksel_T4 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blksel_T4, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blksel_T4$Block_Design[[3]] <- c(2003, 2010, 2011, 2018, 2019, 2022)

Ctl23_blksel_T4$blocks_per_pattern[3] <- 3

tmp <- Ctl23_blksel_T4$size_selex_parms
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block_Fxn"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block_Fxn"] <- 3
Ctl23_blksel_T4$size_selex_parms <- tmp
rm(tmp)

tmp <- Ctl23_blksel_T4$size_selex_parms_tv
tmp<-rbind(c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           tmp)
Ctl23_blksel_T4$size_selex_parms_tv <- tmp
rm(tmp) 


# Save the control file for the model
SS_writectl(
ctllist =  Ctl23_blksel_T4 ,
outfile = file.path(Dir_23_blksel_T4, 'SST_control.ss', fsep = fsep),
version = '3.30',
overwrite = TRUE
)
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blksel_T4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blksel_T4, 'forecast.ss', fsep = fsep)
Fore23_blksel_T4 <-SS_readforecast(
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
      # mylist =  Fore23_blksel_T4 ,
      # dir = Dir_23_blksel_T4, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blksel_T4, 'forecast.ss', fsep = fsep)
#  Fore23_blksel_T4 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blksel_T4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 6.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blksel_T4,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blksel.T4folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[4], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 6.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blksel_T4, 'run', fsep = fsep)

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

# End development for model 23.blksel.T4 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blksel_T4','Dat23_blksel_T4','Ctl23_blksel_T4','Fore23_blksel_T4')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  7. Developing model 23.blkret.T3.blksel.T1  ----
# ----------------------------------------------------------- #

# Path to the 23.blkret.T3.blksel.T1 repertory
Dir_23_blkret_T3_blksel_T1 <- file.path(dir_SensAnal, '5.11_Selectivity_Sensitivity','5_23.blkret.T3.blksel.T1' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blkret_T3_blksel_T1') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blkret_T3_blksel_T1 
# Data file :			 Dat23_blkret_T3_blksel_T1 
# Control file :			 Ctl23_blkret_T3_blksel_T1 
# Forecast file :			 Fore23_blkret_T3_blksel_T1 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
# Restart_SA_modeldvpt()
Restart_SA_modeldvpt(base.model = "23.blkret.T3",
                     curr.model = "23.blkret.T3.blksel.T1",
                     files = "all")

# 7.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_blkret_T3_blksel_T1, 'starter.ss', fsep = fsep)
Start23_blkret_T3_blksel_T1 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blkret_T3_blksel_T1 ,
      # dir =  Dir_23_blkret_T3_blksel_T1, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blkret_T3_blksel_T1, 'starter.ss')
#  Start23_blkret_T3_blksel_T1 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blkret_T3_blksel_T1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blkret_T3_blksel_T1,Start23_blkret_T3_blksel_T1$datfile, fsep = fsep)
Dat23_blkret_T3_blksel_T1 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blkret_T3_blksel_T1 ,
      # outfile = file.path(Dir_23_blkret_T3_blksel_T1, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blkret_T3_blksel_T1, 'SST_data.ss', fsep = fsep)
#  Dat23_blkret_T3_blksel_T1 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blkret_T3_blksel_T1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS
# in a designated file.

# Read in the file
Ctlfile <-file.path(Dir_23_blkret_T3_blksel_T1,Start23_blkret_T3_blksel_T1$ctlfile, fsep = fsep)
Ctl23_blkret_T3_blksel_T1 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blkret_T3_blksel_T1, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blkret_T3_blksel_T1$Block_Design[[3]][1] <- 2003 
tmp <- Ctl23_blkret_T3_blksel_T1$size_selex_parms
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block_Fxn"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block_Fxn"] <- 3
Ctl23_blkret_T3_blksel_T1$size_selex_parms <- tmp
rm(tmp)

tmp <- Ctl23_blkret_T3_blksel_T1$size_selex_parms_tv
tmp<-rbind(c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           tmp)
Ctl23_blkret_T3_blksel_T1$size_selex_parms_tv <- tmp
rm(tmp)


# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_blkret_T3_blksel_T1 ,
      outfile = file.path(Dir_23_blkret_T3_blksel_T1, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blkret_T3_blksel_T1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blkret_T3_blksel_T1, 'forecast.ss', fsep = fsep)
Fore23_blkret_T3_blksel_T1 <-SS_readforecast(
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
      # mylist =  Fore23_blkret_T3_blksel_T1 ,
      # dir = Dir_23_blkret_T3_blksel_T1, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blkret_T3_blksel_T1, 'forecast.ss', fsep = fsep)
#  Fore23_blkret_T3_blksel_T1 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blkret_T3_blksel_T1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 7.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blkret_T3_blksel_T1,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blkret.T3.blksel.T1folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[5], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 7.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blkret_T3_blksel_T1, 'run', fsep = fsep)

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

# End development for model 23.blkret.T3.blksel.T1 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blkret_T3_blksel_T1','Dat23_blkret_T3_blksel_T1','Ctl23_blkret_T3_blksel_T1','Fore23_blkret_T3_blksel_T1')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  8. Developing model 23.blkret.T3.blksel.T2  ----
# ----------------------------------------------------------- #

# Path to the 23.blkret.T3.blksel.T2 repertory
Dir_23_blkret_T3_blksel_T2 <- file.path(dir_SensAnal, '5.11_Selectivity_Sensitivity','6_23.blkret.T3.blksel.T2' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blkret_T3_blksel_T2') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blkret_T3_blksel_T2 
# Data file :			 Dat23_blkret_T3_blksel_T2 
# Control file :			 Ctl23_blkret_T3_blksel_T2 
# Forecast file :			 Fore23_blkret_T3_blksel_T2 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
# Restart_SA_modeldvpt()
Restart_SA_modeldvpt(base.model = "23.blkret.T3",
                     curr.model = "23.blkret.T3.blksel.T2",
                     files = "all")

# 8.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_blkret_T3_blksel_T2, 'starter.ss', fsep = fsep)
Start23_blkret_T3_blksel_T2 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blkret_T3_blksel_T2 ,
      # dir =  Dir_23_blkret_T3_blksel_T2, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blkret_T3_blksel_T2, 'starter.ss')
#  Start23_blkret_T3_blksel_T2 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blkret_T3_blksel_T2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 8.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blkret_T3_blksel_T2,Start23_blkret_T3_blksel_T2$datfile, fsep = fsep)
Dat23_blkret_T3_blksel_T2 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blkret_T3_blksel_T2 ,
      # outfile = file.path(Dir_23_blkret_T3_blksel_T2, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blkret_T3_blksel_T2, 'SST_data.ss', fsep = fsep)
#  Dat23_blkret_T3_blksel_T2 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blkret_T3_blksel_T2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 8.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS
# in a designated file.

# Read in the file
Ctlfile <-file.path(Dir_23_blkret_T3_blksel_T2,Start23_blkret_T3_blksel_T2$ctlfile, fsep = fsep)
Ctl23_blkret_T3_blksel_T2 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blkret_T3_blksel_T2, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blkret_T3_blksel_T2$Block_Design[[3]][1] <- 2011 
tmp <- Ctl23_blkret_T3_blksel_T2$size_selex_parms
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block_Fxn"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block_Fxn"] <- 3
Ctl23_blkret_T3_blksel_T2$size_selex_parms <- tmp
rm(tmp)

tmp <- Ctl23_blkret_T3_blksel_T2$size_selex_parms_tv
tmp<-rbind(c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           tmp)
Ctl23_blkret_T3_blksel_T2$size_selex_parms_tv <- tmp
rm(tmp)


# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_blkret_T3_blksel_T2 ,
      outfile = file.path(Dir_23_blkret_T3_blksel_T2, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blkret_T3_blksel_T2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 8.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blkret_T3_blksel_T2, 'forecast.ss', fsep = fsep)
Fore23_blkret_T3_blksel_T2 <-SS_readforecast(
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
      # mylist =  Fore23_blkret_T3_blksel_T2 ,
      # dir = Dir_23_blkret_T3_blksel_T2, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blkret_T3_blksel_T2, 'forecast.ss', fsep = fsep)
#  Fore23_blkret_T3_blksel_T2 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blkret_T3_blksel_T2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 8.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blkret_T3_blksel_T2,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blkret.T3.blksel.T2folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[6], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 8.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blkret_T3_blksel_T2, 'run', fsep = fsep)

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

# End development for model 23.blkret.T3.blksel.T2 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blkret_T3_blksel_T2','Dat23_blkret_T3_blksel_T2','Ctl23_blkret_T3_blksel_T2','Fore23_blkret_T3_blksel_T2')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  9. Developing model 23.blkret.T3.blksel.T3  ----
# ----------------------------------------------------------- #

# Path to the 23.blkret.T3.blksel.T3 repertory
Dir_23_blkret_T3_blksel_T3 <- file.path(dir_SensAnal, '5.11_Selectivity_Sensitivity','7_23.blkret.T3.blksel.T3' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blkret_T3_blksel_T3') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blkret_T3_blksel_T3 
# Data file :			 Dat23_blkret_T3_blksel_T3 
# Control file :			 Ctl23_blkret_T3_blksel_T3 
# Forecast file :			 Fore23_blkret_T3_blksel_T3 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
# Restart_SA_modeldvpt()
Restart_SA_modeldvpt(base.model = "23.blkret.T3",
                     curr.model = "23.blkret.T3.blksel.T3",
                     files = "all")

# 9.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_blkret_T3_blksel_T3, 'starter.ss', fsep = fsep)
Start23_blkret_T3_blksel_T3 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blkret_T3_blksel_T3 ,
      # dir =  Dir_23_blkret_T3_blksel_T3, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blkret_T3_blksel_T3, 'starter.ss')
#  Start23_blkret_T3_blksel_T3 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blkret_T3_blksel_T3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 9.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blkret_T3_blksel_T3,Start23_blkret_T3_blksel_T3$datfile, fsep = fsep)
Dat23_blkret_T3_blksel_T3 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blkret_T3_blksel_T3 ,
      # outfile = file.path(Dir_23_blkret_T3_blksel_T3, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blkret_T3_blksel_T3, 'SST_data.ss', fsep = fsep)
#  Dat23_blkret_T3_blksel_T3 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blkret_T3_blksel_T3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 9.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS
# in a designated file.

# Read in the file
Ctlfile <-file.path(Dir_23_blkret_T3_blksel_T3,Start23_blkret_T3_blksel_T3$ctlfile, fsep = fsep)
Ctl23_blkret_T3_blksel_T3 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blkret_T3_blksel_T3, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blkret_T3_blksel_T3$Block_Design[[3]] <- c(2003, 2010, 2011, 2022)


Ctl23_blkret_T3_blksel_T3$blocks_per_pattern[3] <- 2

tmp <- Ctl23_blkret_T3_blksel_T3$size_selex_parms
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block_Fxn"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block_Fxn"] <- 3
Ctl23_blkret_T3_blksel_T3$size_selex_parms <- tmp
rm(tmp)

tmp <- Ctl23_blkret_T3_blksel_T3$size_selex_parms_tv
tmp<-rbind(c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           tmp)
Ctl23_blkret_T3_blksel_T3$size_selex_parms_tv <- tmp
rm(tmp)


# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_blkret_T3_blksel_T3 ,
      outfile = file.path(Dir_23_blkret_T3_blksel_T3, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blkret_T3_blksel_T3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 9.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blkret_T3_blksel_T3, 'forecast.ss', fsep = fsep)
Fore23_blkret_T3_blksel_T3 <-SS_readforecast(
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
      # mylist =  Fore23_blkret_T3_blksel_T3 ,
      # dir = Dir_23_blkret_T3_blksel_T3, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blkret_T3_blksel_T3, 'forecast.ss', fsep = fsep)
#  Fore23_blkret_T3_blksel_T3 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blkret_T3_blksel_T3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 9.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blkret_T3_blksel_T3,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blkret.T3.blksel.T3folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[7], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 9.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blkret_T3_blksel_T3, 'run', fsep = fsep)

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

# End development for model 23.blkret.T3.blksel.T3 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blkret_T3_blksel_T3','Dat23_blkret_T3_blksel_T3','Ctl23_blkret_T3_blksel_T3','Fore23_blkret_T3_blksel_T3')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  10. Developing model 23.blkret.T3.blksel.T4  ----
# ----------------------------------------------------------- #

# Path to the 23.blkret.T3.blksel.T4 repertory
Dir_23_blkret_T3_blksel_T4 <- file.path(dir_SensAnal, '5.11_Selectivity_Sensitivity','8_23.blkret.T3.blksel.T4' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blkret_T3_blksel_T4') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blkret_T3_blksel_T4 
# Data file :			 Dat23_blkret_T3_blksel_T4 
# Control file :			 Ctl23_blkret_T3_blksel_T4 
# Forecast file :			 Fore23_blkret_T3_blksel_T4 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
# Restart_SA_modeldvpt()
Restart_SA_modeldvpt(base.model = "23.blkret.T3",
                     curr.model = "23.blkret.T3.blksel.T4",
                     files = "all")

# 10.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_blkret_T3_blksel_T4, 'starter.ss', fsep = fsep)
Start23_blkret_T3_blksel_T4 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blkret_T3_blksel_T4 ,
      # dir =  Dir_23_blkret_T3_blksel_T4, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blkret_T3_blksel_T4, 'starter.ss')
#  Start23_blkret_T3_blksel_T4 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blkret_T3_blksel_T4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 10.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blkret_T3_blksel_T4,Start23_blkret_T3_blksel_T4$datfile, fsep = fsep)
Dat23_blkret_T3_blksel_T4 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blkret_T3_blksel_T4 ,
      # outfile = file.path(Dir_23_blkret_T3_blksel_T4, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blkret_T3_blksel_T4, 'SST_data.ss', fsep = fsep)
#  Dat23_blkret_T3_blksel_T4 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blkret_T3_blksel_T4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 10.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS
# in a designated file.

# Read in the file
Ctlfile <-file.path(Dir_23_blkret_T3_blksel_T4,Start23_blkret_T3_blksel_T4$ctlfile, fsep = fsep)
Ctl23_blkret_T3_blksel_T4 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blkret_T3_blksel_T4, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blkret_T3_blksel_T4$Block_Design[[3]] <- c(2003, 2010, 2011, 2018, 2019, 2022)

Ctl23_blkret_T3_blksel_T4$blocks_per_pattern[3] <- 3

tmp <- Ctl23_blkret_T3_blksel_T4$size_selex_parms
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_N(1)","Block_Fxn"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block"] <- 3
tmp[rownames(tmp) %in% "SizeSel_P_1_Trawl_S(2)","Block_Fxn"] <- 3
Ctl23_blkret_T3_blksel_T4$size_selex_parms <- tmp
rm(tmp)

tmp <- Ctl23_blkret_T3_blksel_T4$size_selex_parms_tv
tmp<-rbind(c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           c(-10, 10, 0,0,5,6,2),
           tmp)
Ctl23_blkret_T3_blksel_T4$size_selex_parms_tv <- tmp
rm(tmp) 


# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_blkret_T3_blksel_T4 ,
      outfile = file.path(Dir_23_blkret_T3_blksel_T4, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blkret_T3_blksel_T4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 10.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blkret_T3_blksel_T4, 'forecast.ss', fsep = fsep)
Fore23_blkret_T3_blksel_T4 <-SS_readforecast(
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
      # mylist =  Fore23_blkret_T3_blksel_T4 ,
      # dir = Dir_23_blkret_T3_blksel_T4, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blkret_T3_blksel_T4, 'forecast.ss', fsep = fsep)
#  Fore23_blkret_T3_blksel_T4 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blkret_T3_blksel_T4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 10.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blkret_T3_blksel_T4,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blkret.T3.blksel.T4folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[8], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 10.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blkret_T3_blksel_T4, 'run', fsep = fsep)

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
# This can be done using the 5.11_Selectivity_Sensitivity_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------


