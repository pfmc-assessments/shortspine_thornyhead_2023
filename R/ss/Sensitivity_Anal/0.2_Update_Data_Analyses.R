# ============================================================ #
# Script used to develop the model(s) considered in the 
# sensitivity analysis: Item 0.2 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  transition 
# Specific item in that topic:  Update landings Updates discard rates Update survey geostat indices Update survey length comps Update fisheries length comps Update discard mean weights Update growth Update maturity Update fecundity Update natural mortality 
# 	- Update landings 
# 	- Updates discard rates 
# 	- Update survey geostat indices 
# 	- Update survey length comps 
# 	- Update fisheries length comps 
# 	- Update discard mean weights 
# 	- Update growth 
# 	- Update maturity 
# 	- Update fecundity 
# 	- Update natural mortality 
# Author:  Team Thornyheads 
# Date: 2023-04-05 10:48:24 
# Names of the models created:
# -  23.land.update 
# -  23.disc.update 
# -  23.surv_geo.update 
# -  23.lcs_survey.update 
# -  23.lcs_fisheries.update 
# -  23.disc_weight.update 
# -  23.growth.update 
# -  23.maturity.update 
# -  23.fecundity.update 
# -  23.mortality.update 
# *** 
# 
# This analysis has been developed based on the following models: 
# New model 	 Base model
# 23.land.update 	 23.sq.floatQ 
# 23.disc.update 	 23.land.update 
# 23.surv_geo.update 	 23.disc.update 
# 23.lcs_survey.update 	 23.surv_geo.update 
# 23.lcs_fisheries.update 	 23.lcs_survey.update 
# 23.disc_weight.update 	 23.lcs_fisheries.update 
# 23.growth.update 	 23.disc_weight.update 
# 23.maturity.update 	 23.growth.update 
# 23.fecundity.update 	 23.maturity.update 
# 23.mortality.update 	 23.fecundity.update 
# 
# Results are stored in the following foler: 
#	 C:/Users/Matthieu Verson/Documents/GitHub/Forked_repos/shortspine_thornyhead_2023/model/Sensitivity_Anal/0.2_Update_Data 
# 
# General features: 
Updating the data sets from the 2013 assessment to the 2023 assessment without changing the structural assumptions. The data sets that are updated as part of this analysis include fishery landings (using the status quo four fleet structure), discards, new geostatistical indices from glmTMB, composition data, and biological parameters. The growth parameters are new and are based on Butler data. Maturity parameters are new and based on Melissa Head's data. Fecundity parameters are new and based on Cooper et al 2005. Natural mortality is new and based on Hamel and Cope 2022 longevity estimator. These updates are collectively considered "best avail science." 
# 
# Model features:
# - Model 23.land.update:
# from pacfin and new state harvest reconstructs 
# - Model 23.disc.update:
# from GEMM and Pikitch 
# - Model 23.surv_geo.update:
# from glmTMB, contact Kelli Johnson 
# - Model 23.lcs_survey.update:
# update length comps 
# - Model 23.lcs_fisheries.update:
# update length comps 
# - Model 23.disc_weight.update:
# update mean weights from WCGOP 
# - Model 23.growth.update:
# Butler 
# - Model 23.maturity.update:
# Head 
# - Model 23.fecundity.update:
# Cooper 
# - Model 23.mortality.update:
# Hamel and Cope (amax = 100) 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package. 
# The new input files are then written in the root directory of each model and the 
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/Users/Matthieu Verson/Documents/GitHub/Forked_repos/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/0.2_Update_Data_Outputs.R 

# *************************************
# ---           WARNINGS            ---
# *************************************
# 
# => The base model(s) you specified for the following new model(s):
# 	 23.disc.update, 23.surv_geo.update, 23.lcs_survey.update, 23.lcs_fisheries.update, 23.disc_weight.update, 23.growth.update, 23.maturity.update, 23.fecundity.update, 23.mortality.update 
# do(es) not exist yet. This means you'll have to start by developping its/their own base model before creating your new model !!!!
# Specifically, you must first develop the following model(s):
# 	 23.land.update, 23.disc.update, 23.surv_geo.update, 23.lcs_survey.update, 23.lcs_fisheries.update, 23.disc_weight.update, 23.growth.update, 23.maturity.update, 23.fecundity.update 
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

#  3. Developing model 23.land.update  ----
# ----------------------------------------------------------- #

# Path to the 23.land.update repertory
Dir_23_land_update <- file.path(dir_SensAnal, '0.2_Update_Data','1_23.land.update' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_land_update') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_land_update 
# Data file :			 Dat23_land_update 
# Control file :			 Ctl23_land_update 
# Forecast file :			 Fore23_land_update 


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
StarterFile <- file.path(Dir_23_land_update, 'starter.ss', fsep = fsep)
Start23_land_update <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file


# ~~~ We do not want to make changes to the input file!


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_land_update ,
      # dir =  Dir_23_land_update, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_land_update, 'starter.ss')
#  Start23_land_update <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_land_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_land_update,Start23_land_update$datfile, fsep = fsep)
Dat23_land_update <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
names(SS_Param2023)
names(Dat23_land_update)
Dat23_land_update$endyr <- 2022
# fleet4 = four fleets (2013 fleet structure)
Dat23_land_update$catch <- as.data.frame(SS_Param2023$Catch$data$fleet4)


# Save the data file for the model
 SS_writedat(
       datlist =  Dat23_land_update ,
       outfile = file.path(Dir_23_land_update, 'SST_data.ss', fsep = fsep),
       version = '3.30',
       overwrite = TRUE
       )

# Check file structure
# DatFile <- file.path(Dir_23_land_update, 'SST_data.ss', fsep = fsep)
  Dat23_land_update <-
       SS_readdat_3.30(
       file = DatFile,
       verbose = TRUE,
       section = TRUE
       )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_land_update')
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
Ctlfile <-file.path(Dir_23_land_update,Start23_land_update$ctlfile, fsep = fsep)
Ctl23_land_update <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_land_update, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

# None needed

# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_land_update ,
      # outfile = file.path(Dir_23_land_update, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_land_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_land_update, 'forecast.ss', fsep = fsep)
Fore23_land_update <-SS_readforecast(
      file = ForeFile,
      version = '3.30',
      verbose = T,
      readAll = T
      )

# Make your modification if applicable
# Code modifying the forecast file 

# None

# Save the forecast file for the model
# SS_writeforecast(
      # mylist =  Fore23_land_update ,
      # dir = Dir_23_land_update, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_land_update, 'forecast.ss', fsep = fsep)
#  Fore23_land_update <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_land_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_land_update, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.land.update folder
      cleanRun = TRUE
      # clean the folder after the run
      extras = "-nohess"
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_land_update, 'run', fsep = fsep)

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

# End development for model 23.land.update 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_land_update','Dat23_land_update','Ctl23_land_update','Fore23_land_update')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.disc.update  ----
# ----------------------------------------------------------- #

# Path to the 23.disc.update repertory
Dir_23_disc_update <- file.path(dir_SensAnal, '0.2_Update_Data','2_23.disc.update' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_disc_update') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_disc_update 
# Data file :					 Dat23_disc_update 
# Control file :					 Ctl23_disc_update 
# Forecast file :					 Fore23_disc_update 


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
StarterFile <- file.path(Dir_23_disc_update, 'starter.ss', fsep = fsep)
Start23_disc_update <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file

# none needed.

# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_disc_update ,
      # dir =  Dir_23_disc_update, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_disc_update, 'starter.ss')
#  Start23_disc_update <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_disc_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_disc_update,Start23_disc_update$datfile, fsep = fsep)
Dat23_disc_update <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
unique(Dat23_disc_update$catch$year)
names(Dat23_disc_update)
Dat23_disc_update$discard_fleet_info
# fleet4 = four fleet structure (not fleet #4)
Dat23_disc_update$discard_data <- as.data.frame(SS_Param2023$discard_fleets$data$fleet4)

# Save the data file for the model
SS_writedat(
  datlist =  Dat23_disc_update ,
  outfile = file.path(Dir_23_disc_update, 'SST_data.ss', fsep = fsep),
  version = '3.30',
  overwrite = TRUE
)

# Check file structure
DatFile <- file.path(Dir_23_disc_update, 'SST_data.ss', fsep = fsep)
Dat23_disc_update <-
  SS_readdat_3.30(
    file = DatFile,
    verbose = TRUE,
    section = TRUE
  )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_disc_update')
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
Ctlfile <-file.path(Dir_23_disc_update,Start23_disc_update$ctlfile, fsep = fsep)
Ctl23_disc_update <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_disc_update, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

# none needed

# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_disc_update ,
      # outfile = file.path(Dir_23_disc_update, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_disc_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_disc_update, 'forecast.ss', fsep = fsep)
Fore23_disc_update <-SS_readforecast(
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
      # mylist =  Fore23_disc_update ,
      # dir = Dir_23_disc_update, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_disc_update, 'forecast.ss', fsep = fsep)
#  Fore23_disc_update <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_disc_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_disc_update, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.disc.update folder
      cleanRun = TRUE
      # clean the folder after the run
      extras = "-nohess"
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_disc_update, 'run', fsep = fsep)

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

# End development for model 23.disc.update 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_disc_update','Dat23_disc_update','Ctl23_disc_update','Fore23_disc_update')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.surv_geo.update  ----
# ----------------------------------------------------------- #

# Path to the 23.surv_geo.update repertory
Dir_23_surv_geo_update <- file.path(dir_SensAnal, '0.2_Update_Data','3_23.surv_geo.update' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_surv_geo_update') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_surv_geo_update 
# Data file :			 Dat23_surv_geo_update 
# Control file :			 Ctl23_surv_geo_update 
# Forecast file :			 Fore23_surv_geo_update 


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
StarterFile <- file.path(Dir_23_surv_geo_update, 'starter.ss', fsep = fsep)
Start23_surv_geo_update <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# None needed.



# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_surv_geo_update ,
      # dir =  Dir_23_surv_geo_update, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_surv_geo_update, 'starter.ss')
#  Start23_surv_geo_update <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_surv_geo_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_surv_geo_update,Start23_surv_geo_update$datfile, fsep = fsep)
Dat23_surv_geo_update <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
Dat23_surv_geo_update$CPUE <- as.data.frame(SS_Param2023$Indices$data$mb_all)
Dat23_surv_geo_update$CPUEinfo 
unique(SS_Param2023$Survey_LengthComp$data$all$fleet)

# Save the data file for the model
SS_writedat(
datlist =  Dat23_surv_geo_update ,
outfile = file.path(Dir_23_surv_geo_update, 'SST_data.ss', fsep = fsep),
version = '3.30',
overwrite = TRUE
)

# Check file structure
DatFile <- file.path(Dir_23_surv_geo_update, 'SST_data.ss', fsep = fsep)
 Dat23_surv_geo_update <-
SS_readdat_3.30(
file = DatFile,
verbose = TRUE,
section = TRUE
)

# clean environment
var.to.save <- c(var.to.save, 'Dat23_surv_geo_update')
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
Ctlfile <-file.path(Dir_23_surv_geo_update,Start23_surv_geo_update$ctlfile, fsep = fsep)
Ctl23_surv_geo_update <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_surv_geo_update, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# None needed


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_surv_geo_update ,
      # outfile = file.path(Dir_23_surv_geo_update, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_surv_geo_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_surv_geo_update, 'forecast.ss', fsep = fsep)
Fore23_surv_geo_update <-SS_readforecast(
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
      # mylist =  Fore23_surv_geo_update ,
      # dir = Dir_23_surv_geo_update, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_surv_geo_update, 'forecast.ss', fsep = fsep)
#  Fore23_surv_geo_update <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_surv_geo_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_surv_geo_update, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.surv_geo.update folder
      cleanRun = TRUE
      # clean the folder after the run
      extras = "-nohess"
)

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_surv_geo_update, 'run', fsep = fsep)

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

# End development for model 23.surv_geo.update 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_surv_geo_update','Dat23_surv_geo_update','Ctl23_surv_geo_update','Fore23_surv_geo_update')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  6. Developing model 23.lcs_survey.update  ----
# ----------------------------------------------------------- #

# Path to the 23.lcs_survey.update repertory
Dir_23_lcs_survey_update <- file.path(dir_SensAnal, '0.2_Update_Data','4_23.lcs_survey.update' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_lcs_survey_update') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_lcs_survey_update 
# Data file :			 Dat23_lcs_survey_update 
# Control file :			 Ctl23_lcs_survey_update 
# Forecast file :			 Fore23_lcs_survey_update 


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
StarterFile <- file.path(Dir_23_lcs_survey_update, 'starter.ss', fsep = fsep)
Start23_lcs_survey_update <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_lcs_survey_update ,
      # dir =  Dir_23_lcs_survey_update, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_lcs_survey_update, 'starter.ss')
#  Start23_lcs_survey_update <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_lcs_survey_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_lcs_survey_update,Start23_lcs_survey_update$datfile, fsep = fsep)
Dat23_lcs_survey_update <- SS_readdat_3.30(
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
      # datlist =  Dat23_lcs_survey_update ,
      # outfile = file.path(Dir_23_lcs_survey_update, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_lcs_survey_update, 'SST_data.ss', fsep = fsep)
#  Dat23_lcs_survey_update <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_lcs_survey_update')
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
Ctlfile <-file.path(Dir_23_lcs_survey_update,Start23_lcs_survey_update$ctlfile, fsep = fsep)
Ctl23_lcs_survey_update <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_lcs_survey_update, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_lcs_survey_update ,
      # outfile = file.path(Dir_23_lcs_survey_update, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_lcs_survey_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_lcs_survey_update, 'forecast.ss', fsep = fsep)
Fore23_lcs_survey_update <-SS_readforecast(
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
      # mylist =  Fore23_lcs_survey_update ,
      # dir = Dir_23_lcs_survey_update, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_lcs_survey_update, 'forecast.ss', fsep = fsep)
#  Fore23_lcs_survey_update <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_lcs_survey_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 6.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_lcs_survey_update, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.lcs_survey.update folder
      cleanRun = TRUE
      # clean the folder after the run
      )

# 6.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_lcs_survey_update, 'run', fsep = fsep)

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

# End development for model 23.lcs_survey.update 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_lcs_survey_update','Dat23_lcs_survey_update','Ctl23_lcs_survey_update','Fore23_lcs_survey_update')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  7. Developing model 23.lcs_fisheries.update  ----
# ----------------------------------------------------------- #

# Path to the 23.lcs_fisheries.update repertory
Dir_23_lcs_fisheries_update <- file.path(dir_SensAnal, '0.2_Update_Data','5_23.lcs_fisheries.update' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_lcs_fisheries_update') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_lcs_fisheries_update 
# Data file :			 Dat23_lcs_fisheries_update 
# Control file :			 Ctl23_lcs_fisheries_update 
# Forecast file :			 Fore23_lcs_fisheries_update 


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
StarterFile <- file.path(Dir_23_lcs_fisheries_update, 'starter.ss', fsep = fsep)
Start23_lcs_fisheries_update <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_lcs_fisheries_update ,
      # dir =  Dir_23_lcs_fisheries_update, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_lcs_fisheries_update, 'starter.ss')
#  Start23_lcs_fisheries_update <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_lcs_fisheries_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_lcs_fisheries_update,Start23_lcs_fisheries_update$datfile, fsep = fsep)
Dat23_lcs_fisheries_update <- SS_readdat_3.30(
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
      # datlist =  Dat23_lcs_fisheries_update ,
      # outfile = file.path(Dir_23_lcs_fisheries_update, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_lcs_fisheries_update, 'SST_data.ss', fsep = fsep)
#  Dat23_lcs_fisheries_update <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_lcs_fisheries_update')
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
Ctlfile <-file.path(Dir_23_lcs_fisheries_update,Start23_lcs_fisheries_update$ctlfile, fsep = fsep)
Ctl23_lcs_fisheries_update <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_lcs_fisheries_update, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_lcs_fisheries_update ,
      # outfile = file.path(Dir_23_lcs_fisheries_update, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_lcs_fisheries_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_lcs_fisheries_update, 'forecast.ss', fsep = fsep)
Fore23_lcs_fisheries_update <-SS_readforecast(
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
      # mylist =  Fore23_lcs_fisheries_update ,
      # dir = Dir_23_lcs_fisheries_update, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_lcs_fisheries_update, 'forecast.ss', fsep = fsep)
#  Fore23_lcs_fisheries_update <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_lcs_fisheries_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 7.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_lcs_fisheries_update, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.lcs_fisheries.update folder
      cleanRun = TRUE
      # clean the folder after the run
      )

# 7.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_lcs_fisheries_update, 'run', fsep = fsep)

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

# End development for model 23.lcs_fisheries.update 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_lcs_fisheries_update','Dat23_lcs_fisheries_update','Ctl23_lcs_fisheries_update','Fore23_lcs_fisheries_update')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  8. Developing model 23.disc_weight.update  ----
# ----------------------------------------------------------- #

# Path to the 23.disc_weight.update repertory
Dir_23_disc_weight_update <- file.path(dir_SensAnal, '0.2_Update_Data','6_23.disc_weight.update' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_disc_weight_update') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_disc_weight_update 
# Data file :			 Dat23_disc_weight_update 
# Control file :			 Ctl23_disc_weight_update 
# Forecast file :			 Fore23_disc_weight_update 


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
StarterFile <- file.path(Dir_23_disc_weight_update, 'starter.ss', fsep = fsep)
Start23_disc_weight_update <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_disc_weight_update ,
      # dir =  Dir_23_disc_weight_update, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_disc_weight_update, 'starter.ss')
#  Start23_disc_weight_update <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_disc_weight_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 8.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_disc_weight_update,Start23_disc_weight_update$datfile, fsep = fsep)
Dat23_disc_weight_update <- SS_readdat_3.30(
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
      # datlist =  Dat23_disc_weight_update ,
      # outfile = file.path(Dir_23_disc_weight_update, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_disc_weight_update, 'SST_data.ss', fsep = fsep)
#  Dat23_disc_weight_update <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_disc_weight_update')
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
Ctlfile <-file.path(Dir_23_disc_weight_update,Start23_disc_weight_update$ctlfile, fsep = fsep)
Ctl23_disc_weight_update <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_disc_weight_update, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_disc_weight_update ,
      # outfile = file.path(Dir_23_disc_weight_update, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_disc_weight_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 8.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_disc_weight_update, 'forecast.ss', fsep = fsep)
Fore23_disc_weight_update <-SS_readforecast(
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
      # mylist =  Fore23_disc_weight_update ,
      # dir = Dir_23_disc_weight_update, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_disc_weight_update, 'forecast.ss', fsep = fsep)
#  Fore23_disc_weight_update <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_disc_weight_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 8.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_disc_weight_update, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.disc_weight.update folder
      cleanRun = TRUE
      # clean the folder after the run
      )

# 8.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_disc_weight_update, 'run', fsep = fsep)

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

# End development for model 23.disc_weight.update 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_disc_weight_update','Dat23_disc_weight_update','Ctl23_disc_weight_update','Fore23_disc_weight_update')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  9. Developing model 23.growth.update  ----
# ----------------------------------------------------------- #

# Path to the 23.growth.update repertory
Dir_23_growth_update <- file.path(dir_SensAnal, '0.2_Update_Data','7_23.growth.update' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_growth_update') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_growth_update 
# Data file :			 Dat23_growth_update 
# Control file :			 Ctl23_growth_update 
# Forecast file :			 Fore23_growth_update 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already 
# wrote a new SS input file for your new model and need to modify it (It ensure 
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 9.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_growth_update, 'starter.ss', fsep = fsep)
Start23_growth_update <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_growth_update ,
      # dir =  Dir_23_growth_update, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_growth_update, 'starter.ss')
#  Start23_growth_update <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_growth_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 9.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_growth_update,Start23_growth_update$datfile, fsep = fsep)
Dat23_growth_update <- SS_readdat_3.30(
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
      # datlist =  Dat23_growth_update ,
      # outfile = file.path(Dir_23_growth_update, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_growth_update, 'SST_data.ss', fsep = fsep)
#  Dat23_growth_update <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_growth_update')
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
Ctlfile <-file.path(Dir_23_growth_update,Start23_growth_update$ctlfile, fsep = fsep)
Ctl23_growth_update <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_growth_update, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_growth_update ,
      # outfile = file.path(Dir_23_growth_update, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_growth_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 9.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_growth_update, 'forecast.ss', fsep = fsep)
Fore23_growth_update <-SS_readforecast(
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
      # mylist =  Fore23_growth_update ,
      # dir = Dir_23_growth_update, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_growth_update, 'forecast.ss', fsep = fsep)
#  Fore23_growth_update <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_growth_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 9.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_growth_update, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.growth.update folder
      cleanRun = TRUE
      # clean the folder after the run
      )

# 9.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_growth_update, 'run', fsep = fsep)

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

# End development for model 23.growth.update 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_growth_update','Dat23_growth_update','Ctl23_growth_update','Fore23_growth_update')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  10. Developing model 23.maturity.update  ----
# ----------------------------------------------------------- #

# Path to the 23.maturity.update repertory
Dir_23_maturity_update <- file.path(dir_SensAnal, '0.2_Update_Data','8_23.maturity.update' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_maturity_update') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_maturity_update 
# Data file :			 Dat23_maturity_update 
# Control file :			 Ctl23_maturity_update 
# Forecast file :			 Fore23_maturity_update 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already 
# wrote a new SS input file for your new model and need to modify it (It ensure 
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 10.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_maturity_update, 'starter.ss', fsep = fsep)
Start23_maturity_update <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_maturity_update ,
      # dir =  Dir_23_maturity_update, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_maturity_update, 'starter.ss')
#  Start23_maturity_update <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_maturity_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 10.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_maturity_update,Start23_maturity_update$datfile, fsep = fsep)
Dat23_maturity_update <- SS_readdat_3.30(
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
      # datlist =  Dat23_maturity_update ,
      # outfile = file.path(Dir_23_maturity_update, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_maturity_update, 'SST_data.ss', fsep = fsep)
#  Dat23_maturity_update <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_maturity_update')
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
Ctlfile <-file.path(Dir_23_maturity_update,Start23_maturity_update$ctlfile, fsep = fsep)
Ctl23_maturity_update <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_maturity_update, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_maturity_update ,
      # outfile = file.path(Dir_23_maturity_update, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_maturity_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 10.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_maturity_update, 'forecast.ss', fsep = fsep)
Fore23_maturity_update <-SS_readforecast(
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
      # mylist =  Fore23_maturity_update ,
      # dir = Dir_23_maturity_update, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_maturity_update, 'forecast.ss', fsep = fsep)
#  Fore23_maturity_update <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_maturity_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 10.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_maturity_update, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.maturity.update folder
      cleanRun = TRUE
      # clean the folder after the run
      )

# 10.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_maturity_update, 'run', fsep = fsep)

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

# End development for model 23.maturity.update 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_maturity_update','Dat23_maturity_update','Ctl23_maturity_update','Fore23_maturity_update')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  11. Developing model 23.fecundity.update  ----
# ----------------------------------------------------------- #

# Path to the 23.fecundity.update repertory
Dir_23_fecundity_update <- file.path(dir_SensAnal, '0.2_Update_Data','9_23.fecundity.update' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_fecundity_update') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_fecundity_update 
# Data file :			 Dat23_fecundity_update 
# Control file :			 Ctl23_fecundity_update 
# Forecast file :			 Fore23_fecundity_update 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already 
# wrote a new SS input file for your new model and need to modify it (It ensure 
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 11.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_fecundity_update, 'starter.ss', fsep = fsep)
Start23_fecundity_update <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_fecundity_update ,
      # dir =  Dir_23_fecundity_update, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_fecundity_update, 'starter.ss')
#  Start23_fecundity_update <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_fecundity_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 11.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_fecundity_update,Start23_fecundity_update$datfile, fsep = fsep)
Dat23_fecundity_update <- SS_readdat_3.30(
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
      # datlist =  Dat23_fecundity_update ,
      # outfile = file.path(Dir_23_fecundity_update, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_fecundity_update, 'SST_data.ss', fsep = fsep)
#  Dat23_fecundity_update <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_fecundity_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 11.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS 
# in a designated file.

# Read in the file
Ctlfile <-file.path(Dir_23_fecundity_update,Start23_fecundity_update$ctlfile, fsep = fsep)
Ctl23_fecundity_update <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_fecundity_update, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_fecundity_update ,
      # outfile = file.path(Dir_23_fecundity_update, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_fecundity_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 11.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_fecundity_update, 'forecast.ss', fsep = fsep)
Fore23_fecundity_update <-SS_readforecast(
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
      # mylist =  Fore23_fecundity_update ,
      # dir = Dir_23_fecundity_update, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_fecundity_update, 'forecast.ss', fsep = fsep)
#  Fore23_fecundity_update <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_fecundity_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 11.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_fecundity_update, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.fecundity.update folder
      cleanRun = TRUE
      # clean the folder after the run
      )

# 11.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_fecundity_update, 'run', fsep = fsep)

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

# End development for model 23.fecundity.update 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_fecundity_update','Dat23_fecundity_update','Ctl23_fecundity_update','Fore23_fecundity_update')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  12. Developing model 23.mortality.update  ----
# ----------------------------------------------------------- #

# Path to the 23.mortality.update repertory
Dir_23_mortality_update <- file.path(dir_SensAnal, '0.2_Update_Data','10_23.mortality.update' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_mortality_update') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_mortality_update 
# Data file :			 Dat23_mortality_update 
# Control file :			 Ctl23_mortality_update 
# Forecast file :			 Fore23_mortality_update 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already 
# wrote a new SS input file for your new model and need to modify it (It ensure 
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 12.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_mortality_update, 'starter.ss', fsep = fsep)
Start23_mortality_update <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_mortality_update ,
      # dir =  Dir_23_mortality_update, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_mortality_update, 'starter.ss')
#  Start23_mortality_update <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_mortality_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 12.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_mortality_update,Start23_mortality_update$datfile, fsep = fsep)
Dat23_mortality_update <- SS_readdat_3.30(
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
      # datlist =  Dat23_mortality_update ,
      # outfile = file.path(Dir_23_mortality_update, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_mortality_update, 'SST_data.ss', fsep = fsep)
#  Dat23_mortality_update <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_mortality_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 12.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS 
# in a designated file.

# Read in the file
Ctlfile <-file.path(Dir_23_mortality_update,Start23_mortality_update$ctlfile, fsep = fsep)
Ctl23_mortality_update <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_mortality_update, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_mortality_update ,
      # outfile = file.path(Dir_23_mortality_update, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_mortality_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 12.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_mortality_update, 'forecast.ss', fsep = fsep)
Fore23_mortality_update <-SS_readforecast(
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
      # mylist =  Fore23_mortality_update ,
      # dir = Dir_23_mortality_update, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_mortality_update, 'forecast.ss', fsep = fsep)
#  Fore23_mortality_update <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_mortality_update')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 12.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_mortality_update, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.mortality.update folder
      cleanRun = TRUE
      # clean the folder after the run
      )

# 12.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_mortality_update, 'run', fsep = fsep)

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
# This can be done using the 0.2_Update_Data_Outputs.R script.


# -----------------------------------------------------------
# -----------------------------------------------------------


