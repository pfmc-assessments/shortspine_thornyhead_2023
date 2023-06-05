# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 4.3
# ============================================================ #
#
# Sensitivity analysis summary
#
# *** 
# Topic of the sensitivity analysis:  biological_Info 
# Specific item in that topic: 
# 	- Sensitivity to fecundity 
# 	- biological_Info
# 	- biological_Info
# 	- biological_Info
# 	- biological_Info
# 	- biological_Info
# Author:  Sabrina Beyer 
# Date: 2023-05-31 20:47:42
# Name of the model created:
# 	- 23.biology.no_fecundity 
# 	- 23.SummaryBioAge30
# 	- 23.SummaryBioAge30.nofec
# 	- 23.fec.units.eggsperfemale
# 	- 23.no.fec.SSO.onethird
# 	- 23.no.fec.SSO.0.2198
# *** 
# 
# This analysis has been developped based on the following model: 
# New model 					 Base model
# 23.biology.no_fecundity				23.model.francis_2
# 23.SummaryBioAge30 				 23.model.francis_2
# 23.SummaryBioAge30.nofec 				 23.model.francis_2
# 23.fec.units.eggsperfemale 				 23.model.francis_2
# 23.no.fec.SSO.onethird 				 23.model.francis_2
# 23.no.fec.SSO.0.2198 				 23.model.francis_2
# 
# Results are stored in the following foler: 
#	 C:/Users/sgbey/Documents/Github/shortspine_thornyhead_2023/model/Sensitivity_Anal/4.3_Fecundity_Sensitivity 
# 
# General features: 
#  Try again convert weight to scale of millions of eggs with a.fec/a.weight
#  Explore setting summary biomass to A50, which is around 30 years old
# Model features:
# - Model 23.biology.no_fecundity:
# remove the fecundity relationship, 2013 assumptions
# - Model 23.SummaryBioAge30:
# - Model 23.SummaryBioAge30.nofec:
# summary biomass at 30 years (mostly spawning females) and no fecundity
# - Model 23.fec.units.eggsperfemale:
# base model with fec on original scale
# - Model 23.no.fec.SSO.onethird:
# fecundity option 1 (no fecundity), but set alpha to 1/3
# - Model 23.no.fec.SSO.0.2198:
# convert no fec alpha by a.fec/a.weight=0.2198
# base.model, Summary Biomass Age 30
# ============================================================ #

# ----------------------------------------------------------- #
# ----------------------------------------------------------- #

# ----------------------------------------------------------- #
# ----------------------------------------------------------- #

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
# Reminder - The following models are considered:# 	-  23.biology.no_fecundity 
noHess <- c(FALSE,FALSE,FALSE,FALSE,FALSE,FALSE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.biology.no_fecundity  ----
# ----------------------------------------------------------- #

# Path to the 23.biology.no_fecundity repertory
Dir_23_biology_no_fecundity <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','1_23.biology.no_fecundity' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_biology_no_fecundity') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_biology_no_fecundity 
# Data file :			 Dat23_biology_no_fecundity 
# Control file :			 Ctl23_biology_no_fecundity 
# Forecast file :			 Fore23_biology_no_fecundity 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.biology.no_fecundity", files="all")


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_biology_no_fecundity, 'starter.ss', fsep = fsep)
Start23_biology_no_fecundity <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_biology_no_fecundity ,
      # dir =  Dir_23_biology_no_fecundity, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_biology_no_fecundity, 'starter.ss')
#  Start23_biology_no_fecundity <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_biology_no_fecundity')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_biology_no_fecundity,Start23_biology_no_fecundity$datfile, fsep = fsep)
Dat23_biology_no_fecundity <- SS_readdat_3.30(
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
      # datlist =  Dat23_biology_no_fecundity ,
      # outfile = file.path(Dir_23_biology_no_fecundity, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_biology_no_fecundity, 'SST_data.ss', fsep = fsep)
#  Dat23_biology_no_fecundity <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_biology_no_fecundity')
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
Ctlfile <-file.path(Dir_23_biology_no_fecundity,Start23_biology_no_fecundity$ctlfile, fsep = fsep)
Ctl23_biology_no_fecundity <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_biology_no_fecundity, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

# Change the fecundity option from 
# (2)eggs=a*L^b to (1)eggs=Wt*(a+b*Wt)
# option 1 was used in the 2013 assessment
Ctl23_biology_no_fecundity$fecundity_option
Ctl23_biology_no_fecundity$fecundity_option <- 1

# Change the parameters for option 1

# alpha (scaling parameter)
# Set to 1 
Ctl23_biology_no_fecundity$MG_parms["Eggs_alpha_Fem_GP_1",]$INIT <- 1

# beta (slope)
# Set to 0 
Ctl23_biology_no_fecundity$MG_parms["Eggs_beta_Fem_GP_1",]$INIT <- 0

# By setting alpha to 1 and slope to 0; eggs = Wt*(1 + 0*Wt) and eggs = Wt
# This removes the length-fecundity relationship and assumes that 
# spawning biomass is equivalent to spawning output
# (aka all females, regardless of size, have the same relative fecundity and
# produce the same number of eggs per gram of their own body weight)

# check
Ctl23_biology_no_fecundity$fecundity_option                        # 1
Ctl23_biology_no_fecundity$MG_parms["Eggs_alpha_Fem_GP_1",]$INIT   # 1
Ctl23_biology_no_fecundity$MG_parms["Eggs_beta_Fem_GP_1",]$INIT    # 0


# Save the control file for the model
 SS_writectl(
       ctllist =  Ctl23_biology_no_fecundity ,
       outfile = file.path(Dir_23_biology_no_fecundity, 'SST_control.ss', fsep = fsep),
       version = '3.30',
       overwrite = TRUE
       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_biology_no_fecundity')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_biology_no_fecundity, 'forecast.ss', fsep = fsep)
Fore23_biology_no_fecundity <-SS_readforecast(
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
      # mylist =  Fore23_biology_no_fecundity ,
      # dir = Dir_23_biology_no_fecundity, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_biology_no_fecundity, 'forecast.ss', fsep = fsep)
#  Fore23_biology_no_fecundity <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_biology_no_fecundity')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_biology_no_fecundity,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.biology.no_fecundityfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_biology_no_fecundity, 'run', fsep = fsep)

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

#  4. Developing model 23.SummaryBioAge30  ----
# ----------------------------------------------------------- #

# Path to the 23.SummaryBioAge30 repertory
Dir_23_SummaryBioAge30 <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','2_23.SummaryBioAge30' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_SummaryBioAge30') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_SummaryBioAge30 
# Data file :			 Dat23_SummaryBioAge30 
# Control file :			 Ctl23_SummaryBioAge30 
# Forecast file :			 Fore23_SummaryBioAge30 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.SummaryBioAge30", files="all")


# 4.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_SummaryBioAge30, 'starter.ss', fsep = fsep)
Start23_SummaryBioAge30 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file

#change summary age to 30 (~age where 50% of females are mature)
Start23_SummaryBioAge30$min_age_summary_bio<- 30


# Save the starter file for the model
 SS_writestarter(
       mylist =  Start23_SummaryBioAge30 ,
       dir =  Dir_23_SummaryBioAge30, 
       overwrite = TRUE,
       verbose = TRUE
       )

# Check file structure
 StarterFile <- file.path(Dir_23_SummaryBioAge30, 'starter.ss')
  Start23_SummaryBioAge30 <- SS_readstarter(
       file = StarterFile,
       verbose = TRUE
       )

# clean environment
var.to.save <- c(var.to.save, 'Start23_SummaryBioAge30')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_SummaryBioAge30,Start23_SummaryBioAge30$datfile, fsep = fsep)
Dat23_SummaryBioAge30 <- SS_readdat_3.30(
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
      # datlist =  Dat23_SummaryBioAge30 ,
      # outfile = file.path(Dir_23_SummaryBioAge30, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_SummaryBioAge30, 'SST_data.ss', fsep = fsep)
#  Dat23_SummaryBioAge30 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_SummaryBioAge30')
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
Ctlfile <-file.path(Dir_23_SummaryBioAge30,Start23_SummaryBioAge30$ctlfile, fsep = fsep)
Ctl23_SummaryBioAge30 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_SummaryBioAge30, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_SummaryBioAge30 ,
      # outfile = file.path(Dir_23_SummaryBioAge30, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_SummaryBioAge30')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_SummaryBioAge30, 'forecast.ss', fsep = fsep)
Fore23_SummaryBioAge30 <-SS_readforecast(
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
      # mylist =  Fore23_SummaryBioAge30 ,
      # dir = Dir_23_SummaryBioAge30, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_SummaryBioAge30, 'forecast.ss', fsep = fsep)
#  Fore23_SummaryBioAge30 <- SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_SummaryBioAge30')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_SummaryBioAge30,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.SummaryBioAge30folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[2], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_SummaryBioAge30, 'run', fsep = fsep)

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

#  5. Developing model 23.SummaryBioAge30.nofec  ----
# ----------------------------------------------------------- #

# Path to the 23.SummaryBioAge30.nofec repertory
Dir_23_SummaryBioAge30_nofec <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','3_23.SummaryBioAge30.nofec' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_SummaryBioAge30_nofec') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_SummaryBioAge30_nofec 
# Data file :			 Dat23_SummaryBioAge30_nofec 
# Control file :			 Ctl23_SummaryBioAge30_nofec 
# Forecast file :			 Fore23_SummaryBioAge30_nofec 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.SummaryBioAge30.nofec", files="all")


# 5.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_SummaryBioAge30_nofec, 'starter.ss', fsep = fsep)
Start23_SummaryBioAge30_nofec <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file

#change summary age to 30 (age where ~50% of females are mature)
Start23_SummaryBioAge30_nofec$min_age_summary_bio <- 30


# Save the starter file for the model
 SS_writestarter(
       mylist =  Start23_SummaryBioAge30_nofec ,
       dir =  Dir_23_SummaryBioAge30_nofec, 
       overwrite = TRUE,
       verbose = TRUE
       )

# Check file structure
 StarterFile <- file.path(Dir_23_SummaryBioAge30_nofec, 'starter.ss')
  Start23_SummaryBioAge30_nofec <- SS_readstarter(
       file = StarterFile,
       verbose = TRUE
       )

# clean environment
var.to.save <- c(var.to.save, 'Start23_SummaryBioAge30_nofec')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_SummaryBioAge30_nofec,Start23_SummaryBioAge30_nofec$datfile, fsep = fsep)
Dat23_SummaryBioAge30_nofec <- SS_readdat_3.30(
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
      # datlist =  Dat23_SummaryBioAge30_nofec ,
      # outfile = file.path(Dir_23_SummaryBioAge30_nofec, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_SummaryBioAge30_nofec, 'SST_data.ss', fsep = fsep)
#  Dat23_SummaryBioAge30_nofec <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_SummaryBioAge30_nofec')
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
Ctlfile <-file.path(Dir_23_SummaryBioAge30_nofec,Start23_SummaryBioAge30_nofec$ctlfile, fsep = fsep)
Ctl23_SummaryBioAge30_nofec <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_SummaryBioAge30_nofec, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

# Change the fecundity option from 
# (2)eggs=a*L^b to (1)eggs=Wt*(a+b*Wt)
# option 1 was used in the 2013 assessment
Ctl23_SummaryBioAge30_nofec$fecundity_option
Ctl23_SummaryBioAge30_nofec$fecundity_option <- 1

# Change the parameters for option 1

# alpha (scaling parameter)
# Set to 1 
Ctl23_SummaryBioAge30_nofec$MG_parms["Eggs_alpha_Fem_GP_1",]$INIT <- 1

# beta (slope)
# Set to 0 
Ctl23_SummaryBioAge30_nofec$MG_parms["Eggs_beta_Fem_GP_1",]$INIT <- 0

# By setting alpha to 1 and slope to 0; eggs = Wt*(1 + 0*Wt) and eggs = Wt
# This removes the length-fecundity relationship and assumes that 
# spawning biomass is equivalent to spawning output
# (aka all females, regardless of size, have the same relative fecundity and
# produce the same number of eggs per gram of their own body weight)

# check
Ctl23_SummaryBioAge30_nofec$fecundity_option                        # 1
Ctl23_SummaryBioAge30_nofec$MG_parms["Eggs_alpha_Fem_GP_1",]$INIT   # 1
Ctl23_SummaryBioAge30_nofec$MG_parms["Eggs_beta_Fem_GP_1",]$INIT    # 0




# Save the control file for the model
 SS_writectl(
       ctllist =  Ctl23_SummaryBioAge30_nofec ,
       outfile = file.path(Dir_23_SummaryBioAge30_nofec, 'SST_control.ss', fsep = fsep),
       version = '3.30',
       overwrite = TRUE
       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_SummaryBioAge30_nofec')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_SummaryBioAge30_nofec, 'forecast.ss', fsep = fsep)
Fore23_SummaryBioAge30_nofec <-SS_readforecast(
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
      # mylist =  Fore23_SummaryBioAge30_nofec ,
      # dir = Dir_23_SummaryBioAge30_nofec, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_SummaryBioAge30_nofec, 'forecast.ss', fsep = fsep)
#  Fore23_SummaryBioAge30_nofec <- SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_SummaryBioAge30_nofec')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_SummaryBioAge30_nofec,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.SummaryBioAge30.nofecfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra ='-nohess' # ifelse(noHess[3], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_SummaryBioAge30_nofec, 'run', fsep = fsep)

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

#  6. Developing model 23.fec.units.eggsperfemale  ----
# ----------------------------------------------------------- #

# Path to the 23.fec.units.eggsperfemale repertory
Dir_23_fec_units_eggsperfemale <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','4_23.fec.units.eggsperfemale' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_fec_units_eggsperfemale') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_fec_units_eggsperfemale 
# Data file :			 Dat23_fec_units_eggsperfemale 
# Control file :			 Ctl23_fec_units_eggsperfemale 
# Forecast file :			 Fore23_fec_units_eggsperfemale 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.fec.units.eggsperfemale", files="all")


# 6.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_fec_units_eggsperfemale, 'starter.ss', fsep = fsep)
Start23_fec_units_eggsperfemale <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_fec_units_eggsperfemale ,
      # dir =  Dir_23_fec_units_eggsperfemale, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_fec_units_eggsperfemale, 'starter.ss')
#  Start23_fec_units_eggsperfemale <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_fec_units_eggsperfemale')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_fec_units_eggsperfemale,Start23_fec_units_eggsperfemale$datfile, fsep = fsep)
Dat23_fec_units_eggsperfemale <- SS_readdat_3.30(
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
      # datlist =  Dat23_fec_units_eggsperfemale ,
      # outfile = file.path(Dir_23_fec_units_eggsperfemale, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_fec_units_eggsperfemale, 'SST_data.ss', fsep = fsep)
#  Dat23_fec_units_eggsperfemale <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_fec_units_eggsperfemale')
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
Ctlfile <-file.path(Dir_23_fec_units_eggsperfemale,Start23_fec_units_eggsperfemale$ctlfile, fsep = fsep)
Ctl23_fec_units_eggsperfemale <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_fec_units_eggsperfemale, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

# change the fecundity units back to eggs per female
# to do this change a param of Fec=a*L^b back to 0.0544 (Cooper and Pearson 2005)
Ctl23_fec_units_eggsperfemale$fecundity_option                       # check option 2
Ctl23_fec_units_eggsperfemale$MG_parms["Eggs_beta_Fem_GP_1",]$INIT   # don't change
Ctl23_fec_units_eggsperfemale$MG_parms["Eggs_alpha_Fem_GP_1",]$INIT <-0.0544  # was set at 5.44e-08 (we had divided by 1000000 to get in the correct scale)

# check
Ctl23_fec_units_eggsperfemale$MG_parms["Eggs_alpha_Fem_GP_1",]$INIT

# Save the control file for the model
 SS_writectl(
       ctllist =  Ctl23_fec_units_eggsperfemale ,
       outfile = file.path(Dir_23_fec_units_eggsperfemale, 'SST_control.ss', fsep = fsep),
       version = '3.30',
       overwrite = TRUE
       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_fec_units_eggsperfemale')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_fec_units_eggsperfemale, 'forecast.ss', fsep = fsep)
Fore23_fec_units_eggsperfemale <-SS_readforecast(
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
      # mylist =  Fore23_fec_units_eggsperfemale ,
      # dir = Dir_23_fec_units_eggsperfemale, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_fec_units_eggsperfemale, 'forecast.ss', fsep = fsep)
#  Fore23_fec_units_eggsperfemale <- SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_fec_units_eggsperfemale')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 6.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_fec_units_eggsperfemale,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.fec.units.eggsperfemalefolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = '-nohess' #ifelse(noHess[4], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 6.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_fec_units_eggsperfemale, 'run', fsep = fsep)

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

#  7. Developing model 23.no.fec.SSO.onethird  ----
# ----------------------------------------------------------- #

# Path to the 23.no.fec.SSO.onethird repertory
Dir_23_no_fec_SSO_onethird <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','5_23.no.fec.SSO.onethird' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_no_fec_SSO_onethird') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_no_fec_SSO_onethird 
# Data file :			 Dat23_no_fec_SSO_onethird 
# Control file :			 Ctl23_no_fec_SSO_onethird 
# Forecast file :			 Fore23_no_fec_SSO_onethird 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.no.fec.SSO.onethird", files="all")


# 7.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_no_fec_SSO_onethird, 'starter.ss', fsep = fsep)
Start23_no_fec_SSO_onethird <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_no_fec_SSO_onethird ,
      # dir =  Dir_23_no_fec_SSO_onethird, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_no_fec_SSO_onethird, 'starter.ss')
#  Start23_no_fec_SSO_onethird <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_no_fec_SSO_onethird')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_no_fec_SSO_onethird,Start23_no_fec_SSO_onethird$datfile, fsep = fsep)
Dat23_no_fec_SSO_onethird <- SS_readdat_3.30(
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
      # datlist =  Dat23_no_fec_SSO_onethird ,
      # outfile = file.path(Dir_23_no_fec_SSO_onethird, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_no_fec_SSO_onethird, 'SST_data.ss', fsep = fsep)
#  Dat23_no_fec_SSO_onethird <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_no_fec_SSO_onethird')
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
Ctlfile <-file.path(Dir_23_no_fec_SSO_onethird,Start23_no_fec_SSO_onethird$ctlfile, fsep = fsep)
Ctl23_no_fec_SSO_onethird <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_no_fec_SSO_onethird, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

# change fecundity option
Ctl23_no_fec_SSO_onethird$fecundity_option <- 1 # eggs=Wt(a+b*Wt)

# multiply alpha parameter by 1/3 to see if this puts spawning output (with no fecundity)
# on the same scale as with a fecundity relationship

Ctl23_no_fec_SSO_onethird$MG_parms["Eggs_alpha_Fem_GP_1", ]$INIT <- 1*(1/3) # the multiplier of weight to get SSO
Ctl23_no_fec_SSO_onethird$MG_parms["Eggs_beta_Fem_GP_1", ]$INIT  <- 0       # zero slope, all females equal

# check
Ctl23_no_fec_SSO_onethird$MG_parms["Eggs_alpha_Fem_GP_1", ]$INIT
Ctl23_no_fec_SSO_onethird$MG_parms["Eggs_beta_Fem_GP_1", ]$INIT 

# Save the control file for the model
 SS_writectl(
       ctllist =  Ctl23_no_fec_SSO_onethird ,
       outfile = file.path(Dir_23_no_fec_SSO_onethird, 'SST_control.ss', fsep = fsep),
       version = '3.30',
       overwrite = TRUE
       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_no_fec_SSO_onethird')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_no_fec_SSO_onethird, 'forecast.ss', fsep = fsep)
Fore23_no_fec_SSO_onethird <-SS_readforecast(
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
      # mylist =  Fore23_no_fec_SSO_onethird ,
      # dir = Dir_23_no_fec_SSO_onethird, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_no_fec_SSO_onethird, 'forecast.ss', fsep = fsep)
#  Fore23_no_fec_SSO_onethird <- SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_no_fec_SSO_onethird')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 7.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_no_fec_SSO_onethird,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.no.fec.SSO.onethirdfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = '-nohess' #ifelse(noHess[5], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 7.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_no_fec_SSO_onethird, 'run', fsep = fsep)

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

#  8. Developing model 23.no.fec.SSO.0.2198  ----
# ----------------------------------------------------------- #

# Path to the 23.no.fec.SSO.0.2198 repertory
Dir_23_no_fec_SSO_0_2198 <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','6_23.no.fec.SSO.0.2198' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_no_fec_SSO_0_2198') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_no_fec_SSO_0_2198 
# Data file :			 Dat23_no_fec_SSO_0_2198 
# Control file :			 Ctl23_no_fec_SSO_0_2198 
# Forecast file :			 Fore23_no_fec_SSO_0_2198 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.no.fec.SSO.0.2198", files="all")


# 8.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_no_fec_SSO_0_2198, 'starter.ss', fsep = fsep)
Start23_no_fec_SSO_0_2198 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_no_fec_SSO_0_2198 ,
      # dir =  Dir_23_no_fec_SSO_0_2198, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_no_fec_SSO_0_2198, 'starter.ss')
#  Start23_no_fec_SSO_0_2198 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_no_fec_SSO_0_2198')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 8.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_no_fec_SSO_0_2198,Start23_no_fec_SSO_0_2198$datfile, fsep = fsep)
Dat23_no_fec_SSO_0_2198 <- SS_readdat_3.30(
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
      # datlist =  Dat23_no_fec_SSO_0_2198 ,
      # outfile = file.path(Dir_23_no_fec_SSO_0_2198, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_no_fec_SSO_0_2198, 'SST_data.ss', fsep = fsep)
#  Dat23_no_fec_SSO_0_2198 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_no_fec_SSO_0_2198')
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
Ctlfile <-file.path(Dir_23_no_fec_SSO_0_2198,Start23_no_fec_SSO_0_2198$ctlfile, fsep = fsep)
Ctl23_no_fec_SSO_0_2198 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_no_fec_SSO_0_2198, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

# change fecundity option
Ctl23_no_fec_SSO_0_2198$fecundity_option <- 1 # eggs=Wt(a+b*Wt)

# multiply alpha parameter by 1/3 to see if this puts spawning output (with no fecundity)
# on the same scale as with a fecundity relationship

Ctl23_no_fec_SSO_0_2198$MG_parms["Eggs_alpha_Fem_GP_1", ]$INIT <- 1*(0.2198) # the multiplier of weight to get SSO (a.fec(millions)/a.weight)
Ctl23_no_fec_SSO_0_2198$MG_parms["Eggs_beta_Fem_GP_1", ]$INIT  <- 0          # zero slope, all females have same relative fecundity

# check
Ctl23_no_fec_SSO_0_2198$MG_parms["Eggs_alpha_Fem_GP_1", ]$INIT
Ctl23_no_fec_SSO_0_2198$MG_parms["Eggs_beta_Fem_GP_1", ]$INIT 



# Save the control file for the model
 SS_writectl(
       ctllist =  Ctl23_no_fec_SSO_0_2198 ,
       outfile = file.path(Dir_23_no_fec_SSO_0_2198, 'SST_control.ss', fsep = fsep),
       version = '3.30',
       overwrite = TRUE
       )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_no_fec_SSO_0_2198')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 8.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_no_fec_SSO_0_2198, 'forecast.ss', fsep = fsep)
Fore23_no_fec_SSO_0_2198 <-SS_readforecast(
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
      # mylist =  Fore23_no_fec_SSO_0_2198 ,
      # dir = Dir_23_no_fec_SSO_0_2198, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_no_fec_SSO_0_2198, 'forecast.ss', fsep = fsep)
#  Fore23_no_fec_SSO_0_2198 <- SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_no_fec_SSO_0_2198')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 8.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_no_fec_SSO_0_2198,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.no.fec.SSO.0.2198folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = '-nohess' #ifelse(noHess[6], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 8.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_no_fec_SSO_0_2198, 'run', fsep = fsep)

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
# This can be done using the 4.3_Fecundity_Sensitivity_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this
# warning section - It might be overwritten in the case you add a new
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------


