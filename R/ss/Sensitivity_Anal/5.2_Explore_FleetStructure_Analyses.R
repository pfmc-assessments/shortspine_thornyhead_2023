# ============================================================ #
# Script used to develop the model(s) considered in the 
# sensitivity analysis: Item 5.2 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic:  ThreeFleets_NoSlope_SplitTriennial ThreeFleets_UseSlope_CombineTriennial FourFleets_UseSlope_CombineTriennial FourFleets_NoSlope_CombineTriennial ThreeFleets_NoSlope_CombineTriennial 
# 	- ThreeFleets_NoSlope_SplitTriennial 
# 	- ThreeFleets_UseSlope_CombineTriennial 
# 	- FourFleets_UseSlope_CombineTriennial 
# 	- FourFleets_NoSlope_CombineTriennial 
# 	- ThreeFleets_NoSlope_CombineTriennial 
# Author:  Team Thornyheads 
# Date: 2023-04-13 13:36:07 
# Names of the models created:
# -  23.model.fleetstruct_1 
# -  23.model.fleetstruct_2 
# -  23.model.fleetstruct_3 
# -  23.model.fleetstruct_4 
# -  23.model.fleetstruct_5 
# *** 
# 
# This analysis has been developed based on the following models: 
# New model 	 Base model
# 23.model.fleetstruct_1 	 23.model.recdevs_bias 
# 23.model.fleetstruct_2 	 23.model.recdevs_bias 
# 23.model.fleetstruct_3 	 23.model.recdevs_bias 
# 23.model.fleetstruct_4 	 23.model.recdevs_bias 
# 23.model.fleetstruct_5 	 23.model.recdevs_bias 
# 
# Results are stored in the following foler: 
#	 /Users/andrea/Library/CloudStorage/Box-Box/StockSynthesis Course/shortspine_thornyhead_2023/model/Sensitivity_Anal/5.2_Explore_FleetStructure 
# 
# General features: 
# We are testing different possible combinations of fisheries fleet and surveys to potentially reduce model complexity 
# 
# Model features:
# - Model 23.model.fleetstruct_1:
# 23.model.recdevs_bias + Three fleets, no slope surveys, and model-based indices 
# - Model 23.model.fleetstruct_2:
# 23.model.recdevs_bias + Three fleets, use slope surveys, and model-based indices 
# - Model 23.model.fleetstruct_3:
# 23.model.recdevs_bias + Four fleets, use slope survey, and model-based indices 
# - Model 23.model.fleetstruct_4:
# 23.model.recdevs_bias + Four fleets, no slope surveys, and model-based indices 
# - Model 23.model.fleetstruct_5:
# 23.model.recdevs_bias + Three fleets, no slope survey, and model-based indices 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package. 
# The new input files are then written in the root directory of each model and the 
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# /Users/andrea/Library/CloudStorage/Box-Box/StockSynthesis Course/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/5.2_Explore_FleetStructure_Outputs.R 

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

#  3. Developing model 23.model.fleetstruct_1  ----
# ----------------------------------------------------------- #

# Path to the 23.model.fleetstruct_1 repertory
Dir_23_model_fleetstruct_1 <- file.path(dir_SensAnal, '5.2_Explore_FleetStructure','1_23.model.fleetstruct_1' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_fleetstruct_1') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_fleetstruct_1 
# Data file :			 Dat23_model_fleetstruct_1 
# Control file :			 Ctl23_model_fleetstruct_1 
# Forecast file :			 Fore23_model_fleetstruct_1 


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
StarterFile <- file.path(Dir_23_model_fleetstruct_1, 'starter.ss', fsep = fsep)
Start23_model_fleetstruct_1 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_fleetstruct_1 ,
      # dir =  Dir_23_model_fleetstruct_1, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_fleetstruct_1, 'starter.ss')
#  Start23_model_fleetstruct_1 <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_fleetstruct_1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_fleetstruct_1,Start23_model_fleetstruct_1$datfile, fsep = fsep)
Dat23_model_fleetstruct_1 <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 

all_data_parm <-get(load(paste0(dir_data,"/","SST_SS_2023_Data_Parameters.RData")))

Dat23_model_fleetstruct_1_save <- Dat23_model_fleetstruct_1

names(Dat23_model_fleetstruct_1)

#Fleet Number (Nfleets!=Nfleet; Nfleets=Nfleet+NSurvey)
Dat23_model_fleetstruct_1$Nfleets <- all_data_parm$Nfleets$data$ThreeFleets_NoSlope_SplitTriennial

#Fleets Info
Dat23_model_fleetstruct_1$fleetinfo <- all_data_parm$fleet_info$data$ThreeFleets_NoSlope_SplitTriennial
  
#Fleet names
Dat23_model_fleetstruct_1$fleetnames <- all_data_parm$fleetnames$data$ThreeFleets_NoSlope_SplitTriennial

#Survey timing
Dat23_model_fleetstruct_1$surveytiming <- all_data_parm$surveytiming$data$ThreeFleets_NoSlope_SplitTriennial

#catch units
Dat23_model_fleetstruct_1$units_of_catch <- all_data_parm$units_of_catch$data$ThreeFleets_NoSlope_SplitTriennial

#Areas 
Dat23_model_fleetstruct_1$areas <- all_data_parm$areas$data$ThreeFleets_NoSlope_SplitTriennial

#catch /!\ Mismatch in the name of this variable - Upper vs Lower case
Dat23_model_fleetstruct_1$catch <- all_data_parm$Catch$data$ThreeFleets_NoSlope_SplitTriennial

#CPUE info
Dat23_model_fleetstruct_1$CPUEinfo <- all_data_parm$CPUEinfo$data$ThreeFleets_NoSlope_SplitTriennial

#CPUE
Dat23_model_fleetstruct_1$CPUE <- all_data_parm$CPUE$data$ThreeFleets_NoSlope_SplitTriennial

#NB DISCARD FLEETS
Dat23_model_fleetstruct_1$N_discard_fleets <- all_data_parm$N_discard_fleets$data$ThreeFleets_NoSlope_SplitTriennial

# DISCARD info
Dat23_model_fleetstruct_1$discard_fleet_info <- all_data_parm$discard_fleet_info$data$ThreeFleets_NoSlope_SplitTriennial

# Discard rates /!\ Mismatch in the name of this variable - discard_data vs discard_rates
Dat23_model_fleetstruct_1$discard_data <- all_data_parm$discard_rates$data$ThreeFleets_NoSlope_SplitTriennial


# Discard mean indiv weight /!\ Mismatch in the name of this variable - Upper vs Lower case
Dat23_model_fleetstruct_1$meanbodywt <- all_data_parm$Meanbodywt$data$ThreeFleets_NoSlope_SplitTriennial


# Info on length composition
Dat23_model_fleetstruct_1$len_info <- all_data_parm$len_info$data$ThreeFleets_NoSlope_SplitTriennial

# Length composition - includes fisheries, surveys, landings, discards
Dat23_model_fleetstruct_1$lencomp <- all_data_parm$All_LengthComp$data$ThreeFleets_NoSlope_SplitTriennial

# Number of Fishing fleets
Dat23_model_fleetstruct_1$Nfleet <- all_data_parm$Nfleet$data$ThreeFleets_NoSlope_SplitTriennial

# Number of Surveys
Dat23_model_fleetstruct_1$Nsurveys <- all_data_parm$Nsurveys$data$ThreeFleets_NoSlope_SplitTriennial

# Fishing fleet info 1 # Not present in "SST_SS_2023_Data_Parameters.RData" unless I am wrong --> generated by SS_readdat_3.30? 
new_fleetinfo1 <- Dat23_model_fleetstruct_1$fleetinfo1
new_fleetinfo1 <- new_fleetinfo1[, -grep("slope", colnames(new_fleetinfo1))]
new_fleetinfo1 <- new_fleetinfo1[, -grep("Non.trawl_S", colnames(new_fleetinfo1))]
colnames(new_fleetinfo1)[grep("Non.trawl_N", colnames(new_fleetinfo1))] <- gsub("_N", "", colnames(new_fleetinfo1)[grep("Non.trawl_N", colnames(new_fleetinfo1))])
Dat23_model_fleetstruct_1$fleetinfo1 <- new_fleetinfo1

# Fishing fleet info 2 # Not present in "SST_SS_2023_Data_Parameters.RData" unless I am wrong --> generated by SS_readdat_3.30? 
new_fleetinfo2 <- Dat23_model_fleetstruct_1$fleetinfo2
new_fleetinfo2 <- new_fleetinfo2[, -grep("slope", colnames(new_fleetinfo2))]
new_fleetinfo2 <- new_fleetinfo2[, -grep("Non.trawl_S", colnames(new_fleetinfo2))]
colnames(new_fleetinfo2)[grep("Non.trawl_N", colnames(new_fleetinfo2))] <- gsub("_N", "", colnames(new_fleetinfo2)[grep("Non.trawl_N", colnames(new_fleetinfo2))])
Dat23_model_fleetstruct_1$fleetinfo2 <- new_fleetinfo2

#comp_tail_compression
Dat23_model_fleetstruct_1$comp_tail_compression <- Dat23_model_fleetstruct_1$comp_tail_compression[-grep("slope|Non.trawl_S", colnames(Dat23_model_fleetstruct_1_save$fleetinfo1))]

#add_to_comp
Dat23_model_fleetstruct_1$add_to_comp <- Dat23_model_fleetstruct_1$add_to_comp[-grep("slope|Non.trawl_S", colnames(Dat23_model_fleetstruct_1_save$fleetinfo1))]

#max_combined_lbin
Dat23_model_fleetstruct_1$max_combined_lbin <- Dat23_model_fleetstruct_1$max_combined_lbin[-grep("slope|Non.trawl_S", colnames(Dat23_model_fleetstruct_1_save$fleetinfo1))]


# Save the data file for the model
# SS_writedat(
      # datlist =  Dat23_model_fleetstruct_1 ,
      # outfile = file.path(Dir_23_model_fleetstruct_1, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_fleetstruct_1, 'SST_data.ss', fsep = fsep)
#  Dat23_model_fleetstruct_1 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_fleetstruct_1')
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
Ctlfile <-file.path(Dir_23_model_fleetstruct_1,Start23_model_fleetstruct_1$ctlfile, fsep = fsep)
Ctl23_model_fleetstruct_1 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_fleetstruct_1, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 

# PY doesn't see anything to modify here

# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_fleetstruct_1 ,
      # outfile = file.path(Dir_23_model_fleetstruct_1, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_fleetstruct_1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_fleetstruct_1, 'forecast.ss', fsep = fsep)
Fore23_model_fleetstruct_1 <- SS_readforecast(
      file = ForeFile,
      version = '3.30',
      verbose = T,
      readAll = T
      )

# Make your modification if applicable
# Code modifying the forecast file 

# PY just see new_max_totalcatch to be modified

new_max_totalcatch <- Fore23_model_fleetstruct_1$max_totalcatch_by_fleet
new_max_totalcatch[which(new_max_totalcatch$Fleet==3), "Max Catch"] <- sum(new_max_totalcatch[which(new_max_totalcatch$Fleet%in%c(3,4)), "Max Catch"])
new_max_totalcatch <- new_max_totalcatch[-which(new_max_totalcatch$Fleet==4),]
Fore23_model_fleetstruct_1$max_totalcatch_by_fleet <- new_max_totalcatch

# Save the forecast file for the model
# SS_writeforecast(
      # mylist =  Fore23_model_fleetstruct_1 ,
      # dir = Dir_23_model_fleetstruct_1, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_fleetstruct_1, 'forecast.ss', fsep = fsep)
#  Fore23_model_fleetstruct_1 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_fleetstruct_1')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_fleetstruct_1, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.fleetstruct_1 folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_fleetstruct_1, 'run', fsep = fsep)

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

# End development for model 23.model.fleetstruct_1 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_fleetstruct_1','Dat23_model_fleetstruct_1','Ctl23_model_fleetstruct_1','Fore23_model_fleetstruct_1')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.model.fleetstruct_2  ----
# ----------------------------------------------------------- #

# Path to the 23.model.fleetstruct_2 repertory
Dir_23_model_fleetstruct_2 <- file.path(dir_SensAnal, '5.2_Explore_FleetStructure','2_23.model.fleetstruct_2' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_fleetstruct_2') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_model_fleetstruct_2 
# Data file :					 Dat23_model_fleetstruct_2 
# Control file :					 Ctl23_model_fleetstruct_2 
# Forecast file :					 Fore23_model_fleetstruct_2 


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
StarterFile <- file.path(Dir_23_model_fleetstruct_2, 'starter.ss', fsep = fsep)
Start23_model_fleetstruct_2 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_fleetstruct_2 ,
      # dir =  Dir_23_model_fleetstruct_2, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_fleetstruct_2, 'starter.ss')
#  Start23_model_fleetstruct_2 <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_fleetstruct_2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_fleetstruct_2,Start23_model_fleetstruct_2$datfile, fsep = fsep)
Dat23_model_fleetstruct_2 <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 

all_data_parm <-get(load(paste0(dir_data,"/","SST_SS_2023_Data_Parameters.RData")))

names(Dat23_model_fleetstruct_2)

#Fleet Number (Nfleets!=Nfleet; Nfleets=Nfleet+NSurvey)
Dat23_model_fleetstruct_2$Nfleets <- all_data_parm$Nfleets$data$ThreeFleets_UseSlope_CombineTriennial

#Fleets Info
Dat23_model_fleetstruct_2$fleetinfo <- all_data_parm$fleet_info$data$ThreeFleets_UseSlope_CombineTriennial

#Fleet names
Dat23_model_fleetstruct_2$fleetnames <- all_data_parm$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial

#Survey timing
Dat23_model_fleetstruct_2$surveytiming <- all_data_parm$surveytiming$data$ThreeFleets_UseSlope_CombineTriennial

#catch units
Dat23_model_fleetstruct_2$units_of_catch <- all_data_parm$units_of_catch$data$ThreeFleets_UseSlope_CombineTriennial

#Areas 
Dat23_model_fleetstruct_2$areas <- all_data_parm$areas$data$ThreeFleets_UseSlope_CombineTriennial

#catch /!\ Mismatch in the name of this variable - Upper vs Lower case
Dat23_model_fleetstruct_2$catch <- all_data_parm$Catch$data$ThreeFleets_UseSlope_CombineTriennial

#CPUE info
Dat23_model_fleetstruct_2$CPUEinfo <- all_data_parm$CPUEinfo$data$ThreeFleets_UseSlope_CombineTriennial

#CPUE
Dat23_model_fleetstruct_2$CPUE <- all_data_parm$CPUE$data$ThreeFleets_UseSlope_CombineTriennial

#NB DISCARD FLEETS
Dat23_model_fleetstruct_2$N_discard_fleets <- all_data_parm$N_discard_fleets$data$ThreeFleets_UseSlope_CombineTriennial

# DISCARD info
Dat23_model_fleetstruct_2$discard_fleet_info <- all_data_parm$discard_fleet_info$data$ThreeFleets_UseSlope_CombineTriennial

# Discard rates /!\ Mismatch in the name of this variable - discard_data vs discard_rates
Dat23_model_fleetstruct_2$discard_data <- all_data_parm$discard_rates$data$ThreeFleets_UseSlope_CombineTriennial


# Discard mean indiv weight /!\ Mismatch in the name of this variable - Upper vs Lower case
Dat23_model_fleetstruct_2$meanbodywt <- all_data_parm$Meanbodywt$data$ThreeFleets_UseSlope_CombineTriennial


# Info on length composition
Dat23_model_fleetstruct_2$len_info <- all_data_parm$len_info$data$ThreeFleets_UseSlope_CombineTriennial

# Length composition - includes fisheries, surveys, landings, discards
Dat23_model_fleetstruct_2$lencomp <- all_data_parm$All_LengthComp$data$ThreeFleets_UseSlope_CombineTriennial

# Number of Fishing fleets
Dat23_model_fleetstruct_2$Nfleet <- all_data_parm$Nfleet$data$ThreeFleets_UseSlope_CombineTriennial

# Number of Surveys
Dat23_model_fleetstruct_2$Nsurveys <- all_data_parm$Nsurveys$data$ThreeFleets_UseSlope_CombineTriennial

# Fishing fleet info 1 # Not present in "SST_SS_2023_Data_Parameters.RData" unless I am wrong --> generated by SS_readdat_3.30? 
new_fleetinfo1 <- Dat23_model_fleetstruct_2$fleetinfo1
new_fleetinfo1 <- new_fleetinfo1[, -grep("Non.trawl_S", colnames(new_fleetinfo1))]
colnames(new_fleetinfo1)[grep("Non.trawl_N", colnames(new_fleetinfo1))] <- gsub("_N", "", colnames(new_fleetinfo1)[grep("Non.trawl_N", colnames(new_fleetinfo1))])
new_fleetinfo1 <- new_fleetinfo1[, -grep("Triennial2", colnames(new_fleetinfo1))]
colnames(new_fleetinfo1)[grep("Triennial1", colnames(new_fleetinfo1))] <- gsub("1", "", colnames(new_fleetinfo1)[grep("Triennial1", colnames(new_fleetinfo1))])
Dat23_model_fleetstruct_2$fleetinfo1 <- new_fleetinfo1

# Fishing fleet info 2 # Not present in "SST_SS_2023_Data_Parameters.RData" unless I am wrong --> generated by SS_readdat_3.30? 
new_fleetinfo2 <- Dat23_model_fleetstruct_2$fleetinfo2
new_fleetinfo2 <- new_fleetinfo2[, -grep("Non.trawl_S", colnames(new_fleetinfo2))]
colnames(new_fleetinfo2)[grep("Non.trawl_N", colnames(new_fleetinfo2))] <- gsub("_N", "", colnames(new_fleetinfo2)[grep("Non.trawl_N", colnames(new_fleetinfo2))])
new_fleetinfo2 <- new_fleetinfo2[, -grep("Triennial2", colnames(new_fleetinfo2))]
colnames(new_fleetinfo2)[grep("Triennial1", colnames(new_fleetinfo2))] <- gsub("1", "", colnames(new_fleetinfo2)[grep("Triennial1", colnames(new_fleetinfo2))])
Dat23_model_fleetstruct_2$fleetinfo1 <- new_fleetinfo2

#comp_tail_compression
Dat23_model_fleetstruct_2$comp_tail_compression <- Dat23_model_fleetstruct_2$comp_tail_compression[-grep("Triennial2|Non.trawl_S", colnames(Dat23_model_fleetstruct_2_save$fleetinfo1))]

#add_to_comp
Dat23_model_fleetstruct_2$add_to_comp <- Dat23_model_fleetstruct_2$add_to_comp[-grep("slope|Non.trawl_S", colnames(Dat23_model_fleetstruct_2_save$fleetinfo1))]

#max_combined_lbin
Dat23_model_fleetstruct_2$max_combined_lbin <- Dat23_model_fleetstruct_2$max_combined_lbin[-grep("slope|Non.trawl_S", colnames(Dat23_model_fleetstruct_2_save$fleetinfo1))]




# Save the data file for the model
# SS_writedat(
      # datlist =  Dat23_model_fleetstruct_2 ,
      # outfile = file.path(Dir_23_model_fleetstruct_2, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_fleetstruct_2, 'SST_data.ss', fsep = fsep)
#  Dat23_model_fleetstruct_2 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_fleetstruct_2')
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
Ctlfile <-file.path(Dir_23_model_fleetstruct_2,Start23_model_fleetstruct_2$ctlfile, fsep = fsep)
Ctl23_model_fleetstruct_2 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_fleetstruct_2, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_fleetstruct_2 ,
      # outfile = file.path(Dir_23_model_fleetstruct_2, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_fleetstruct_2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_fleetstruct_2, 'forecast.ss', fsep = fsep)
Fore23_model_fleetstruct_2 <-SS_readforecast(
      file = ForeFile,
      version = '3.30',
      verbose = T,
      readAll = T
      )

# Make your modification if applicable
# Code modifying the forecast file 
# ..... 
# ..... 

new_max_totalcatch <- Fore23_model_fleetstruct_2$max_totalcatch_by_fleet
new_max_totalcatch[which(new_max_totalcatch$Fleet==3), "Max Catch"] <- sum(new_max_totalcatch[which(new_max_totalcatch$Fleet%in%c(3,4)), "Max Catch"])
new_max_totalcatch <- new_max_totalcatch[-which(new_max_totalcatch$Fleet==4),]
Fore23_model_fleetstruct_2$max_totalcatch_by_fleet <- new_max_totalcatch

# Save the forecast file for the model
# SS_writeforecast(
      # mylist =  Fore23_model_fleetstruct_2 ,
      # dir = Dir_23_model_fleetstruct_2, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_fleetstruct_2, 'forecast.ss', fsep = fsep)
#  Fore23_model_fleetstruct_2 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_fleetstruct_2')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_fleetstruct_2, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.fleetstruct_2 folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_fleetstruct_2, 'run', fsep = fsep)

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

# End development for model 23.model.fleetstruct_2 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_fleetstruct_2','Dat23_model_fleetstruct_2','Ctl23_model_fleetstruct_2','Fore23_model_fleetstruct_2')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.model.fleetstruct_3  ----
# ----------------------------------------------------------- #

# Path to the 23.model.fleetstruct_3 repertory
Dir_23_model_fleetstruct_3 <- file.path(dir_SensAnal, '5.2_Explore_FleetStructure','3_23.model.fleetstruct_3' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_fleetstruct_3') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_fleetstruct_3 
# Data file :			 Dat23_model_fleetstruct_3 
# Control file :			 Ctl23_model_fleetstruct_3 
# Forecast file :			 Fore23_model_fleetstruct_3 


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
StarterFile <- file.path(Dir_23_model_fleetstruct_3, 'starter.ss', fsep = fsep)
Start23_model_fleetstruct_3 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_fleetstruct_3 ,
      # dir =  Dir_23_model_fleetstruct_3, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_fleetstruct_3, 'starter.ss')
#  Start23_model_fleetstruct_3 <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_fleetstruct_3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_fleetstruct_3,Start23_model_fleetstruct_3$datfile, fsep = fsep)
Dat23_model_fleetstruct_3 <- SS_readdat_3.30(
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
      # datlist =  Dat23_model_fleetstruct_3 ,
      # outfile = file.path(Dir_23_model_fleetstruct_3, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_fleetstruct_3, 'SST_data.ss', fsep = fsep)
#  Dat23_model_fleetstruct_3 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_fleetstruct_3')
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
Ctlfile <-file.path(Dir_23_model_fleetstruct_3,Start23_model_fleetstruct_3$ctlfile, fsep = fsep)
Ctl23_model_fleetstruct_3 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_fleetstruct_3, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_fleetstruct_3 ,
      # outfile = file.path(Dir_23_model_fleetstruct_3, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_fleetstruct_3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_fleetstruct_3, 'forecast.ss', fsep = fsep)
Fore23_model_fleetstruct_3 <-SS_readforecast(
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
      # mylist =  Fore23_model_fleetstruct_3 ,
      # dir = Dir_23_model_fleetstruct_3, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_fleetstruct_3, 'forecast.ss', fsep = fsep)
#  Fore23_model_fleetstruct_3 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_fleetstruct_3')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_fleetstruct_3, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.fleetstruct_3 folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_fleetstruct_3, 'run', fsep = fsep)

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

# End development for model 23.model.fleetstruct_3 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_fleetstruct_3','Dat23_model_fleetstruct_3','Ctl23_model_fleetstruct_3','Fore23_model_fleetstruct_3')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  6. Developing model 23.model.fleetstruct_4  ----
# ----------------------------------------------------------- #

# Path to the 23.model.fleetstruct_4 repertory
Dir_23_model_fleetstruct_4 <- file.path(dir_SensAnal, '5.2_Explore_FleetStructure','4_23.model.fleetstruct_4' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_fleetstruct_4') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_fleetstruct_4 
# Data file :			 Dat23_model_fleetstruct_4 
# Control file :			 Ctl23_model_fleetstruct_4 
# Forecast file :			 Fore23_model_fleetstruct_4 


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
StarterFile <- file.path(Dir_23_model_fleetstruct_4, 'starter.ss', fsep = fsep)
Start23_model_fleetstruct_4 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_fleetstruct_4 ,
      # dir =  Dir_23_model_fleetstruct_4, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_fleetstruct_4, 'starter.ss')
#  Start23_model_fleetstruct_4 <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_fleetstruct_4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_fleetstruct_4,Start23_model_fleetstruct_4$datfile, fsep = fsep)
Dat23_model_fleetstruct_4 <- SS_readdat_3.30(
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
      # datlist =  Dat23_model_fleetstruct_4 ,
      # outfile = file.path(Dir_23_model_fleetstruct_4, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_fleetstruct_4, 'SST_data.ss', fsep = fsep)
#  Dat23_model_fleetstruct_4 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_fleetstruct_4')
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
Ctlfile <-file.path(Dir_23_model_fleetstruct_4,Start23_model_fleetstruct_4$ctlfile, fsep = fsep)
Ctl23_model_fleetstruct_4 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_fleetstruct_4, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_fleetstruct_4 ,
      # outfile = file.path(Dir_23_model_fleetstruct_4, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_fleetstruct_4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_fleetstruct_4, 'forecast.ss', fsep = fsep)
Fore23_model_fleetstruct_4 <-SS_readforecast(
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
      # mylist =  Fore23_model_fleetstruct_4 ,
      # dir = Dir_23_model_fleetstruct_4, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_fleetstruct_4, 'forecast.ss', fsep = fsep)
#  Fore23_model_fleetstruct_4 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_fleetstruct_4')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 6.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_fleetstruct_4, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.fleetstruct_4 folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 6.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_fleetstruct_4, 'run', fsep = fsep)

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

# End development for model 23.model.fleetstruct_4 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_fleetstruct_4','Dat23_model_fleetstruct_4','Ctl23_model_fleetstruct_4','Fore23_model_fleetstruct_4')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  7. Developing model 23.model.fleetstruct_5  ----
# ----------------------------------------------------------- #

# Path to the 23.model.fleetstruct_5 repertory
Dir_23_model_fleetstruct_5 <- file.path(dir_SensAnal, '5.2_Explore_FleetStructure','5_23.model.fleetstruct_5' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_fleetstruct_5') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_fleetstruct_5 
# Data file :			 Dat23_model_fleetstruct_5 
# Control file :			 Ctl23_model_fleetstruct_5 
# Forecast file :			 Fore23_model_fleetstruct_5 


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
StarterFile <- file.path(Dir_23_model_fleetstruct_5, 'starter.ss', fsep = fsep)
Start23_model_fleetstruct_5 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_fleetstruct_5 ,
      # dir =  Dir_23_model_fleetstruct_5, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_fleetstruct_5, 'starter.ss')
#  Start23_model_fleetstruct_5 <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_fleetstruct_5')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_fleetstruct_5,Start23_model_fleetstruct_5$datfile, fsep = fsep)
Dat23_model_fleetstruct_5 <- SS_readdat_3.30(
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
      # datlist =  Dat23_model_fleetstruct_5 ,
      # outfile = file.path(Dir_23_model_fleetstruct_5, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_fleetstruct_5, 'SST_data.ss', fsep = fsep)
#  Dat23_model_fleetstruct_5 <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_fleetstruct_5')
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
Ctlfile <-file.path(Dir_23_model_fleetstruct_5,Start23_model_fleetstruct_5$ctlfile, fsep = fsep)
Ctl23_model_fleetstruct_5 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_fleetstruct_5, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_fleetstruct_5 ,
      # outfile = file.path(Dir_23_model_fleetstruct_5, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_fleetstruct_5')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_fleetstruct_5, 'forecast.ss', fsep = fsep)
Fore23_model_fleetstruct_5 <-SS_readforecast(
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
      # mylist =  Fore23_model_fleetstruct_5 ,
      # dir = Dir_23_model_fleetstruct_5, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_fleetstruct_5, 'forecast.ss', fsep = fsep)
#  Fore23_model_fleetstruct_5 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_fleetstruct_5')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 7.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_fleetstruct_5, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.fleetstruct_5 folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 7.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_fleetstruct_5, 'run', fsep = fsep)

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
# This can be done using the 5.2_Explore_FleetStructure_Outputs.R script.


# -----------------------------------------------------------
# -----------------------------------------------------------


