# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 5.9 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic: 
# 	- blk Trawl 89 
# 	- blk Trawl mid10 
# 	- blk Trawl 89-mid10 
# 	- blk Trawl 89-mid10-19 
# 	- blk Trawl 89-mid10 NonTrawl 05-13 
# 	- blk Trawl 89-mid10 NonTrawl 05-13-17 
# Author:  Pierre-Yves Hernvann 
# Date: 2023-05-05 22:00:11 
# Names of the models created:
# 	-  23.blkret.T1 
# 	-  23.blkret.T2 
# 	-  23.blkret.T3 
# 	-  23.blkret.T4 
# 	-  23.blkret.T3.NT1 
# 	-  23.blkret.T3.NT2 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.blkret.T1 				 23.model.francis_2 
# 23.blkret.T2 				 23.model.francis_2 
# 23.blkret.T3 				 23.model.francis_2 
# 23.blkret.T4 				 23.model.francis_2 
# 23.blkret.T3.NT1 				 23.model.francis_2 
# 23.blkret.T3.NT2 				 23.model.francis_2 
# 
# Results are stored in the following foler: 
#	 C:/Users/pyher/Documents/shortspine_thornyhead_2023/model/Sensitivity_Anal/5.9_Retention_Selectivity_Sensitivity 
# 
# General features: 
# Sensitivity analysis to the time blocks in the retention parameters of trawl and non trawl fleets 
# 
# Model features:
# - Model 23.blkret.T1:
# base blocks for Trawl + break in 1989 
# - Model 23.blkret.T2:
# base blocks for Trawl + break in mid-2010s 
# - Model 23.blkret.T3:
# base blocks for Trawl + break in 1989 + mid-2010s 
# - Model 23.blkret.T4:
# base blocks for Trawl + break in 1989 + mid-2010s + 2019 
# - Model 23.blkret.T3.NT1:
# base blocks for Trawl + break in 1989 + mid-2010s & nonTrawl break in 2005 + 2013 
# - Model 23.blkret.T3.NT2:
# base blocks for Trawl + break in 1989 + mid-2010s & nonTrawl break in 2005 + 2013 + 2017 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/Users/pyher/Documents/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/5.9_Retention_Sensitivity_Outputs.R 

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
# Reminder - The following models are considered:# 	-  23.blkret.T1 
# 	-  23.blkret.T2 
# 	-  23.blkret.T3 
# 	-  23.blkret.T4 
# 	-  23.blkret.T3.NT1 
# 	-  23.blkret.T3.NT2 
#noHess <- c(TRUE,TRUE,TRUE,TRUE,TRUE,TRUE)
noHess <- c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.blkret.T1  ----
# ----------------------------------------------------------- #

# Path to the 23.blkret.T1 repertory
Dir_23_blkret_T1 <- file.path(dir_SensAnal, '5.9_Retention_Selectivity_Sensitivity','1_23.blkret.T1' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blkret_T1') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blkret_T1 
# Data file :			 Dat23_blkret_T1 
# Control file :			 Ctl23_blkret_T1 
# Forecast file :			 Fore23_blkret_T1 


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
StarterFile <- file.path(Dir_23_blkret_T1, 'starter.ss', fsep = fsep)
Start23_blkret_T1 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blkret_T1 ,
      # dir =  Dir_23_blkret_T1, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blkret_T1, 'starter.ss')
#  Start23_blkret_T1 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blkret_T1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blkret_T1,Start23_blkret_T1$datfile, fsep = fsep)
Dat23_blkret_T1 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blkret_T1 ,
      # outfile = file.path(Dir_23_blkret_T1, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blkret_T1, 'SST_data.ss', fsep = fsep)
#  Dat23_blkret_T1 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blkret_T1')
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
Ctlfile <-file.path(Dir_23_blkret_T1,Start23_blkret_T1$ctlfile, fsep = fsep)
Ctl23_blkret_T1 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blkret_T1, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blkret_T1$blocks_per_pattern[1] <- 3
Ctl23_blkret_T1$blocks_per_pattern[2] <- 3

Ctl23_blkret_T1$Block_Design[[1]] <- c(1989, 2006, 2007, 2010, 2011, 2022)
Ctl23_blkret_T1$Block_Design[[2]] <- c(1989, 2006, 2007, 2010, 2011, 2022)

toadd_reten_names <- grep(2011, rownames(Ctl23_blkret_T1$size_selex_parms_tv), value=T)
toadd_reten <- Ctl23_blkret_T1$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T1$size_selex_parms_tv)),]
toadd_reten_names <- gsub("2011", "1989", toadd_reten_names)
rownames(toadd_reten) <- toadd_reten_names
Ctl23_blkret_T1$size_selex_parms_tv <- rbind(Ctl23_blkret_T1$size_selex_parms_tv, toadd_reten)

Ctl23_blkret_T1$size_selex_parms_tv <- Ctl23_blkret_T1$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T1$size_selex_parms_tv), paste(seq(1985, 2022), collapse="|")))),]
Ctl23_blkret_T1$size_selex_parms_tv <- Ctl23_blkret_T1$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T1$size_selex_parms_tv),"_1_|_3_"))),]
Ctl23_blkret_T1$size_selex_parms_tv <- Ctl23_blkret_T1$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T1$size_selex_parms_tv),"BLK1delta|BLK2delta|BLK3delta"))),]

# Save the control file for the model
#SS_writectl(
#      ctllist =  Ctl23_blkret_T1 ,
#      outfile = file.path(Dir_23_blkret_T1, 'SST_control.ss', fsep = fsep),
#      version = '3.30',
#      overwrite = TRUE
#      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blkret_T1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blkret_T1, 'forecast.ss', fsep = fsep)
Fore23_blkret_T1 <-SS_readforecast(
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
      # mylist =  Fore23_blkret_T1 ,
      # dir = Dir_23_blkret_T1, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blkret_T1, 'forecast.ss', fsep = fsep)
#  Fore23_blkret_T1 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blkret_T1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blkret_T1,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blkret.T1folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blkret_T1, 'run', fsep = fsep)

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

# End development for model 23.blkret.T1 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blkret_T1','Dat23_blkret_T1','Ctl23_blkret_T1','Fore23_blkret_T1')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.blkret.T2  ----
# ----------------------------------------------------------- #

# Path to the 23.blkret.T2 repertory
Dir_23_blkret_T2 <- file.path(dir_SensAnal, '5.9_Retention_Selectivity_Sensitivity','2_23.blkret.T2' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blkret_T2') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_blkret_T2 
# Data file :					 Dat23_blkret_T2 
# Control file :					 Ctl23_blkret_T2 
# Forecast file :					 Fore23_blkret_T2 


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
StarterFile <- file.path(Dir_23_blkret_T2, 'starter.ss', fsep = fsep)
Start23_blkret_T2 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blkret_T2 ,
      # dir =  Dir_23_blkret_T2, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blkret_T2, 'starter.ss')
#  Start23_blkret_T2 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blkret_T2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blkret_T2,Start23_blkret_T2$datfile, fsep = fsep)
Dat23_blkret_T2 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blkret_T2 ,
      # outfile = file.path(Dir_23_blkret_T2, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blkret_T2, 'SST_data.ss', fsep = fsep)
#  Dat23_blkret_T2 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blkret_T2')
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
Ctlfile <-file.path(Dir_23_blkret_T2,Start23_blkret_T2$ctlfile, fsep = fsep)
Ctl23_blkret_T2 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blkret_T2, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blkret_T2$blocks_per_pattern[1] <- 3
Ctl23_blkret_T2$blocks_per_pattern[2] <- 3

Ctl23_blkret_T2$Block_Design[[1]] <- c(2007, 2010, 2011, 2014, 2015, 2022)
Ctl23_blkret_T2$Block_Design[[2]] <- c(2007, 2010, 2011, 2016, 2017, 2022)

toadd_reten_names <- grep(2011, rownames(Ctl23_blkret_T2$size_selex_parms_tv), value=T)
toadd_reten <- Ctl23_blkret_T2$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T2$size_selex_parms_tv)),]
toadd_reten_names <- gsub("BLK1delta_2011", "BLK1delta_2015", gsub("BLK2delta_2011", "BLK2delta_2017", toadd_reten_names))
rownames(toadd_reten) <- toadd_reten_names
Ctl23_blkret_T2$size_selex_parms_tv <- rbind(Ctl23_blkret_T2$size_selex_parms_tv, toadd_reten)

Ctl23_blkret_T2$size_selex_parms_tv <- Ctl23_blkret_T2$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T2$size_selex_parms_tv), paste(seq(1985, 2022), collapse="|")))),]
Ctl23_blkret_T2$size_selex_parms_tv <- Ctl23_blkret_T2$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T2$size_selex_parms_tv),"_1_|_3_"))),]
Ctl23_blkret_T2$size_selex_parms_tv <- Ctl23_blkret_T2$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T2$size_selex_parms_tv),"BLK1delta|BLK2delta|BLK3delta"))),]

# Save the control file for the model
#SS_writectl(
#      ctllist =  Ctl23_blkret_T2 ,
#      outfile = file.path(Dir_23_blkret_T2, 'SST_control.ss', fsep = fsep),
#      version = '3.30',
#      overwrite = TRUE
#      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blkret_T2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blkret_T2, 'forecast.ss', fsep = fsep)
Fore23_blkret_T2 <-SS_readforecast(
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
      # mylist =  Fore23_blkret_T2 ,
      # dir = Dir_23_blkret_T2, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blkret_T2, 'forecast.ss', fsep = fsep)
#  Fore23_blkret_T2 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blkret_T2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blkret_T2,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blkret.T2folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[2], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blkret_T2, 'run', fsep = fsep)

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

# End development for model 23.blkret.T2 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blkret_T2','Dat23_blkret_T2','Ctl23_blkret_T2','Fore23_blkret_T2')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.blkret.T3  ----
# ----------------------------------------------------------- #

# Path to the 23.blkret.T3 repertory
Dir_23_blkret_T3 <- file.path(dir_SensAnal, '5.9_Retention_Selectivity_Sensitivity','3_23.blkret.T3' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blkret_T3') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blkret_T3 
# Data file :			 Dat23_blkret_T3 
# Control file :			 Ctl23_blkret_T3 
# Forecast file :			 Fore23_blkret_T3 


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
StarterFile <- file.path(Dir_23_blkret_T3, 'starter.ss', fsep = fsep)
Start23_blkret_T3 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blkret_T3 ,
      # dir =  Dir_23_blkret_T3, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blkret_T3, 'starter.ss')
#  Start23_blkret_T3 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blkret_T3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blkret_T3,Start23_blkret_T3$datfile, fsep = fsep)
Dat23_blkret_T3 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blkret_T3 ,
      # outfile = file.path(Dir_23_blkret_T3, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blkret_T3, 'SST_data.ss', fsep = fsep)
#  Dat23_blkret_T3 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blkret_T3')
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
Ctlfile <-file.path(Dir_23_blkret_T3,Start23_blkret_T3$ctlfile, fsep = fsep)
Ctl23_blkret_T3 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blkret_T3, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blkret_T3$blocks_per_pattern[1] <- 4
Ctl23_blkret_T3$blocks_per_pattern[2] <- 4

Ctl23_blkret_T3$Block_Design[[1]] <- c(1989, 2006, 2007, 2010, 2011, 2014, 2015, 2022)
Ctl23_blkret_T3$Block_Design[[2]] <- c(1989, 2006, 2007, 2010, 2011, 2016, 2017, 2022)

toadd_reten_names <- grep(2011, rownames(Ctl23_blkret_T3$size_selex_parms_tv), value=T)
toadd_reten <- Ctl23_blkret_T3$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T3$size_selex_parms_tv)),]
toadd_reten_names <- gsub("BLK1delta_2011", "BLK1delta_2015", gsub("BLK2delta_2011", "BLK2delta_2017", toadd_reten_names))
rownames(toadd_reten) <- toadd_reten_names

toadd_reten_names2 <- grep(2011, rownames(Ctl23_blkret_T3$size_selex_parms_tv), value=T)
toadd_reten2 <- Ctl23_blkret_T3$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T3$size_selex_parms_tv)),]
toadd_reten_names2 <- gsub("2011", "1989", toadd_reten_names2)
rownames(toadd_reten2) <- toadd_reten_names2

Ctl23_blkret_T3$size_selex_parms_tv <- rbind(Ctl23_blkret_T3$size_selex_parms_tv, toadd_reten, toadd_reten2)

Ctl23_blkret_T3$size_selex_parms_tv <- Ctl23_blkret_T3$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T3$size_selex_parms_tv), paste(seq(1985, 2022), collapse="|")))),]
Ctl23_blkret_T3$size_selex_parms_tv <- Ctl23_blkret_T3$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T3$size_selex_parms_tv),"_1_|_3_"))),]
Ctl23_blkret_T3$size_selex_parms_tv <- Ctl23_blkret_T3$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T3$size_selex_parms_tv),"BLK1delta|BLK2delta|BLK3delta"))),]

# Save the control file for the model
# SS_writectl(
#       ctllist =  Ctl23_blkret_T3 ,
#       outfile = file.path(Dir_23_blkret_T3, 'SST_control.ss', fsep = fsep),
#       version = '3.30',
#       overwrite = TRUE
#       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blkret_T3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blkret_T3, 'forecast.ss', fsep = fsep)
Fore23_blkret_T3 <-SS_readforecast(
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
      # mylist =  Fore23_blkret_T3 ,
      # dir = Dir_23_blkret_T3, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blkret_T3, 'forecast.ss', fsep = fsep)
#  Fore23_blkret_T3 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blkret_T3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blkret_T3,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blkret.T3folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[3], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blkret_T3, 'run', fsep = fsep)

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

# End development for model 23.blkret.T3 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blkret_T3','Dat23_blkret_T3','Ctl23_blkret_T3','Fore23_blkret_T3')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  6. Developing model 23.blkret.T4  ----
# ----------------------------------------------------------- #

# Path to the 23.blkret.T4 repertory
Dir_23_blkret_T4 <- file.path(dir_SensAnal, '5.9_Retention_Selectivity_Sensitivity','4_23.blkret.T4' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blkret_T4') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blkret_T4 
# Data file :			 Dat23_blkret_T4 
# Control file :			 Ctl23_blkret_T4 
# Forecast file :			 Fore23_blkret_T4 


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
StarterFile <- file.path(Dir_23_blkret_T4, 'starter.ss', fsep = fsep)
Start23_blkret_T4 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blkret_T4 ,
      # dir =  Dir_23_blkret_T4, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blkret_T4, 'starter.ss')
#  Start23_blkret_T4 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blkret_T4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blkret_T4,Start23_blkret_T4$datfile, fsep = fsep)
Dat23_blkret_T4 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blkret_T4 ,
      # outfile = file.path(Dir_23_blkret_T4, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blkret_T4, 'SST_data.ss', fsep = fsep)
#  Dat23_blkret_T4 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blkret_T4')
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
Ctlfile <-file.path(Dir_23_blkret_T4,Start23_blkret_T4$ctlfile, fsep = fsep)
Ctl23_blkret_T4 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blkret_T4, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blkret_T4$blocks_per_pattern[1] <- 5
Ctl23_blkret_T4$blocks_per_pattern[2] <- 5

Ctl23_blkret_T4$Block_Design[[1]] <- c(1989, 2006, 2007, 2010, 2011, 2014, 2015, 2018, 2019, 2022)
Ctl23_blkret_T4$Block_Design[[2]] <- c(1989, 2006, 2007, 2010, 2011, 2016, 2017, 2018, 2019, 2022)

toadd_reten_names <- grep(2011, rownames(Ctl23_blkret_T4$size_selex_parms_tv), value=T)
toadd_reten <- Ctl23_blkret_T4$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T4$size_selex_parms_tv)),]
toadd_reten_names <- gsub("BLK1delta_2011", "BLK1delta_2015", gsub("BLK2delta_2011", "BLK2delta_2017", toadd_reten_names))
rownames(toadd_reten) <- toadd_reten_names

toadd_reten_names2 <- grep(2011, rownames(Ctl23_blkret_T4$size_selex_parms_tv), value=T)
toadd_reten2 <- Ctl23_blkret_T4$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T4$size_selex_parms_tv)),]
toadd_reten_names2 <- gsub("2011", "1989", toadd_reten_names2)
rownames(toadd_reten2) <- toadd_reten_names2

toadd_reten_names3 <- grep(2011, rownames(Ctl23_blkret_T4$size_selex_parms_tv), value=T)
toadd_reten3 <- Ctl23_blkret_T4$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T4$size_selex_parms_tv)),]
toadd_reten_names3 <- gsub("2011", "2019", toadd_reten_names3)
rownames(toadd_reten3) <- toadd_reten_names3

Ctl23_blkret_T4$size_selex_parms_tv <- rbind(Ctl23_blkret_T4$size_selex_parms_tv, toadd_reten, toadd_reten2, toadd_reten3)

Ctl23_blkret_T4$size_selex_parms_tv <- Ctl23_blkret_T4$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T4$size_selex_parms_tv), paste(seq(1985, 2022), collapse="|")))),]
Ctl23_blkret_T4$size_selex_parms_tv <- Ctl23_blkret_T4$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T4$size_selex_parms_tv),"_1_|_3_"))),]
Ctl23_blkret_T4$size_selex_parms_tv <- Ctl23_blkret_T4$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T4$size_selex_parms_tv),"BLK1delta|BLK2delta|BLK3delta"))),]

# Save the control file for the model
# SS_writectl(
#       ctllist =  Ctl23_blkret_T4 ,
#       outfile = file.path(Dir_23_blkret_T4, 'SST_control.ss', fsep = fsep),
#       version = '3.30',
#       overwrite = TRUE
#       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blkret_T4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blkret_T4, 'forecast.ss', fsep = fsep)
Fore23_blkret_T4 <-SS_readforecast(
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
      # mylist =  Fore23_blkret_T4 ,
      # dir = Dir_23_blkret_T4, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blkret_T4, 'forecast.ss', fsep = fsep)
#  Fore23_blkret_T4 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blkret_T4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 6.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blkret_T4,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blkret.T4folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[4], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 6.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blkret_T4, 'run', fsep = fsep)

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

# End development for model 23.blkret.T4 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blkret_T4','Dat23_blkret_T4','Ctl23_blkret_T4','Fore23_blkret_T4')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------

################################## PY STOPPED HERE - ERRORS ON 5 AND NEED TO RUN 6 LAST MODELS TO FINISH

#  7. Developing model 23.blkret.T3.NT1  ----
# ----------------------------------------------------------- #

# Path to the 23.blkret.T3.NT1 repertory
Dir_23_blkret_T3_NT1 <- file.path(dir_SensAnal, '5.9_Retention_Selectivity_Sensitivity','5_23.blkret.T3.NT1' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blkret_T3_NT1') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blkret_T3_NT1 
# Data file :			 Dat23_blkret_T3_NT1 
# Control file :			 Ctl23_blkret_T3_NT1 
# Forecast file :			 Fore23_blkret_T3_NT1 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 7.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_blkret_T3_NT1, 'starter.ss', fsep = fsep)
Start23_blkret_T3_NT1 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blkret_T3_NT1 ,
      # dir =  Dir_23_blkret_T3_NT1, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blkret_T3_NT1, 'starter.ss')
#  Start23_blkret_T3_NT1 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blkret_T3_NT1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blkret_T3_NT1,Start23_blkret_T3_NT1$datfile, fsep = fsep)
Dat23_blkret_T3_NT1 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blkret_T3_NT1 ,
      # outfile = file.path(Dir_23_blkret_T3_NT1, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blkret_T3_NT1, 'SST_data.ss', fsep = fsep)
#  Dat23_blkret_T3_NT1 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blkret_T3_NT1')
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
Ctlfile <-file.path(Dir_23_blkret_T3_NT1,Start23_blkret_T3_NT1$ctlfile, fsep = fsep)
Ctl23_blkret_T3_NT1 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blkret_T3_NT1, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blkret_T3_NT1$blocks_per_pattern[1] <- 4
Ctl23_blkret_T3_NT1$blocks_per_pattern[2] <- 4
Ctl23_blkret_T3_NT1$blocks_per_pattern[3] <- 2

Ctl23_blkret_T3_NT1$size_selex_parms[which(rownames(Ctl23_blkret_T3_NT1$size_selex_parms) %in% c("SizeSel_PRet_1_Non-trawl(3)","SizeSel_PRet_3_Non-trawl(3)")),"Block"] <- 3
Ctl23_blkret_T3_NT1$size_selex_parms[which(rownames(Ctl23_blkret_T3_NT1$size_selex_parms) %in% c("SizeSel_PRet_1_Non-trawl(3)","SizeSel_PRet_3_Non-trawl(3)")),"Block_Fxn"] <- 3

Ctl23_blkret_T3_NT1$Block_Design[[1]] <- c(1989, 2006, 2007, 2010, 2011, 2014, 2015, 2022)
Ctl23_blkret_T3_NT1$Block_Design[[2]] <- c(1989, 2006, 2007, 2010, 2011, 2016, 2017, 2022)
Ctl23_blkret_T3_NT1$Block_Design[[3]] <- c(2005, 2012, 2013, 2022)

toadd_reten_names <- grep(2011, rownames(Ctl23_blkret_T3_NT1$size_selex_parms_tv), value=T)
toadd_reten <- Ctl23_blkret_T3_NT1$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T3_NT1$size_selex_parms_tv)),]
toadd_reten_names <- gsub("BLK1delta_2011", "BLK1delta_2015", gsub("BLK2delta_2011", "BLK2delta_2017", toadd_reten_names))
rownames(toadd_reten) <- toadd_reten_names

toadd_reten_names2 <- grep(2011, rownames(Ctl23_blkret_T3_NT1$size_selex_parms_tv), value=T)
toadd_reten2 <- Ctl23_blkret_T3_NT1$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T3_NT1$size_selex_parms_tv)),]
toadd_reten_names2 <- gsub("2011", "1989", toadd_reten_names2)
rownames(toadd_reten2) <- toadd_reten_names2

toadd_reten_names3 <- grep("BLK1delta", grep("2007|2011", rownames(Ctl23_blkret_T3_NT1$size_selex_parms_tv), value=T), value=T)
toadd_reten3 <- Ctl23_blkret_T3_NT1$size_selex_parms_tv[toadd_reten_names3,]
toadd_reten_names3 <- gsub("Trawl_N", "Non-trawl", gsub("1)_BLK1delta", "3)_BLK3delta", gsub("2007", "2013", gsub("2011", "2005", toadd_reten_names3))))
rownames(toadd_reten3) <- toadd_reten_names3

Ctl23_blkret_T3_NT1$size_selex_parms_tv <- rbind(Ctl23_blkret_T3_NT1$size_selex_parms_tv, toadd_reten, toadd_reten2, toadd_reten3)

Ctl23_blkret_T3_NT1$size_selex_parms_tv <- Ctl23_blkret_T3_NT1$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T3_NT1$size_selex_parms_tv), paste(seq(1985, 2022), collapse="|")))),]
Ctl23_blkret_T3_NT1$size_selex_parms_tv <- Ctl23_blkret_T3_NT1$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T3_NT1$size_selex_parms_tv),"_1_|_3_"))),]
Ctl23_blkret_T3_NT1$size_selex_parms_tv <- Ctl23_blkret_T3_NT1$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T3_NT1$size_selex_parms_tv),"BLK1delta|BLK2delta|BLK3delta"))),]


# Save the control file for the model
# SS_writectl(
#       ctllist =  Ctl23_blkret_T3_NT1 ,
#       outfile = file.path(Dir_23_blkret_T3_NT1, 'SST_control.ss', fsep = fsep),
#       version = '3.30',
#       overwrite = TRUE
#       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blkret_T3_NT1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blkret_T3_NT1, 'forecast.ss', fsep = fsep)
Fore23_blkret_T3_NT1 <-SS_readforecast(
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
      # mylist =  Fore23_blkret_T3_NT1 ,
      # dir = Dir_23_blkret_T3_NT1, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blkret_T3_NT1, 'forecast.ss', fsep = fsep)
#  Fore23_blkret_T3_NT1 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blkret_T3_NT1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 7.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blkret_T3_NT1,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blkret.T3.NT1folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[5], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 7.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blkret_T3_NT1, 'run', fsep = fsep)

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

# End development for model 23.blkret.T3.NT1 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_blkret_T3_NT1','Dat23_blkret_T3_NT1','Ctl23_blkret_T3_NT1','Fore23_blkret_T3_NT1')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  8. Developing model 23.blkret.T3.NT2  ----
# ----------------------------------------------------------- #

# Path to the 23.blkret.T3.NT2 repertory
Dir_23_blkret_T3_NT2 <- file.path(dir_SensAnal, '5.9_Retention_Selectivity_Sensitivity','6_23.blkret.T3.NT2' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_blkret_T3_NT2') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_blkret_T3_NT2 
# Data file :			 Dat23_blkret_T3_NT2 
# Control file :			 Ctl23_blkret_T3_NT2 
# Forecast file :			 Fore23_blkret_T3_NT2 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 8.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_blkret_T3_NT2, 'starter.ss', fsep = fsep)
Start23_blkret_T3_NT2 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_blkret_T3_NT2 ,
      # dir =  Dir_23_blkret_T3_NT2, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_blkret_T3_NT2, 'starter.ss')
#  Start23_blkret_T3_NT2 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_blkret_T3_NT2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 8.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_blkret_T3_NT2,Start23_blkret_T3_NT2$datfile, fsep = fsep)
Dat23_blkret_T3_NT2 <- SS_readdat_3.30(
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
      # datlist =  Dat23_blkret_T3_NT2 ,
      # outfile = file.path(Dir_23_blkret_T3_NT2, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_blkret_T3_NT2, 'SST_data.ss', fsep = fsep)
#  Dat23_blkret_T3_NT2 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_blkret_T3_NT2')
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
Ctlfile <-file.path(Dir_23_blkret_T3_NT2,Start23_blkret_T3_NT2$ctlfile, fsep = fsep)
Ctl23_blkret_T3_NT2 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_blkret_T3_NT2, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
Ctl23_blkret_T3_NT2$blocks_per_pattern[1] <- 4
Ctl23_blkret_T3_NT2$blocks_per_pattern[2] <- 4
Ctl23_blkret_T3_NT2$blocks_per_pattern[3] <- 3

Ctl23_blkret_T3_NT2$size_selex_parms[which(rownames(Ctl23_blkret_T3_NT2$size_selex_parms) %in% c("SizeSel_PRet_1_Non-trawl(3)","SizeSel_PRet_3_Non-trawl(3)")),"Block"] <- 3
Ctl23_blkret_T3_NT2$size_selex_parms[which(rownames(Ctl23_blkret_T3_NT2$size_selex_parms) %in% c("SizeSel_PRet_1_Non-trawl(3)","SizeSel_PRet_3_Non-trawl(3)")),"Block_Fxn"] <- 3

Ctl23_blkret_T3_NT2$Block_Design[[1]] <- c(1989, 2006, 2007, 2010, 2011, 2014, 2015, 2022)
Ctl23_blkret_T3_NT2$Block_Design[[2]] <- c(1989, 2006, 2007, 2010, 2011, 2016, 2017, 2022)
Ctl23_blkret_T3_NT2$Block_Design[[3]] <- c(2005, 2012, 2013, 2016, 2017, 2022)

toadd_reten_names <- grep(2011, rownames(Ctl23_blkret_T3_NT2$size_selex_parms_tv), value=T)
toadd_reten <- Ctl23_blkret_T3_NT2$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T3_NT2$size_selex_parms_tv)),]
toadd_reten_names <- gsub("BLK1delta_2011", "BLK1delta_2015", gsub("BLK2delta_2011", "BLK2delta_2017", toadd_reten_names))
rownames(toadd_reten) <- toadd_reten_names

toadd_reten_names2 <- grep(2011, rownames(Ctl23_blkret_T3_NT2$size_selex_parms_tv), value=T)
toadd_reten2 <- Ctl23_blkret_T3_NT2$size_selex_parms_tv[grep(2011, rownames(Ctl23_blkret_T3_NT2$size_selex_parms_tv)),]
toadd_reten_names2 <- gsub("2011", "1989", toadd_reten_names2)
rownames(toadd_reten2) <- toadd_reten_names2

toadd_reten_names3 <- grep("BLK1delta", grep("2007|2011", rownames(Ctl23_blkret_T3_NT2$size_selex_parms_tv), value=T), value=T)
toadd_reten3 <- Ctl23_blkret_T3_NT2$size_selex_parms_tv[toadd_reten_names3,]
toadd_reten_names3 <- gsub("Trawl_N", "Non-trawl", gsub("1)_BLK1delta", "3)_BLK3delta", gsub("2007", "2013", gsub("2011", "2005", toadd_reten_names3))))
rownames(toadd_reten3) <- toadd_reten_names3

toadd_reten_names4 <- grep("BLK1delta", grep("2011", rownames(Ctl23_blkret_T3_NT2$size_selex_parms_tv), value=T), value=T)
toadd_reten4 <- Ctl23_blkret_T3_NT2$size_selex_parms_tv[toadd_reten_names4,]
toadd_reten_names4 <- gsub("Trawl_N", "Non-trawl", gsub("1)_BLK1delta", "3)_BLK3delta", gsub("2011", "2017", toadd_reten_names4)))
rownames(toadd_reten4) <- toadd_reten_names4

Ctl23_blkret_T3_NT2$size_selex_parms_tv <- rbind(Ctl23_blkret_T3_NT2$size_selex_parms_tv, toadd_reten, toadd_reten2, toadd_reten3, toadd_reten4)

Ctl23_blkret_T3_NT2$size_selex_parms_tv <- Ctl23_blkret_T3_NT2$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T3_NT2$size_selex_parms_tv), paste(seq(1985, 2022), collapse="|")))),]
Ctl23_blkret_T3_NT2$size_selex_parms_tv <- Ctl23_blkret_T3_NT2$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T3_NT2$size_selex_parms_tv),"_1_|_3_"))),]
Ctl23_blkret_T3_NT2$size_selex_parms_tv <- Ctl23_blkret_T3_NT2$size_selex_parms_tv[order(unlist(str_extract(rownames(Ctl23_blkret_T3_NT2$size_selex_parms_tv),"BLK1delta|BLK2delta|BLK3delta"))),]


# Save the control file for the model
# SS_writectl(
#       ctllist =  Ctl23_blkret_T3_NT2 ,
#       outfile = file.path(Dir_23_blkret_T3_NT2, 'SST_control.ss', fsep = fsep),
#       version = '3.30',
#       overwrite = TRUE
#       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_blkret_T3_NT2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 8.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_blkret_T3_NT2, 'forecast.ss', fsep = fsep)
Fore23_blkret_T3_NT2 <-SS_readforecast(
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
      # mylist =  Fore23_blkret_T3_NT2 ,
      # dir = Dir_23_blkret_T3_NT2, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_blkret_T3_NT2, 'forecast.ss', fsep = fsep)
#  Fore23_blkret_T3_NT2 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_blkret_T3_NT2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 8.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_blkret_T3_NT2,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.blkret.T3.NT2folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[6], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 8.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_blkret_T3_NT2, 'run', fsep = fsep)

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
# This can be done using the 5.9_Retention_Sensitivity_Outputs.R script.


# -----------------------------------------------------------
# -----------------------------------------------------------


