# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 1.3 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  landings 
# Specific item in that topic: 
# 	- 23.landings.4fleet 
# Author:  Adam Hayes 
# Date: 2023-06-05 07:30:41 
# Name of the model created:
# 	- 23.landings.4fleet 
# *** 
# 
# This analysis has been developped based on the following model: 
# 23.model.francis_2 
# 
# Results are stored in the following foler: 
#	 C:/Users/adam.hayes/Work/GitHub/shortspine_thornyhead_2023/model/Sensitivity_Anal/1.3_Landings_4fleet 
# 
# Features: 
#  Base Model + 4 commercial fleets 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/Users/adam.hayes/Work/GitHub/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/1.3_Landings_4fleet_Outputs.R 

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
# Reminder - The following models are considered:# 	-  23.landings.4fleet 
noHess <- c(FALSE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.landings.4fleet  ----
# ----------------------------------------------------------- #

# Path to the 23.landings.4fleet repertory
Dir_23_landings_4fleet <- file.path(dir_SensAnal, '1.3_Landings_4fleet','1_23.landings.4fleet' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_landings_4fleet') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_landings_4fleet 
# Data file :			 Dat23_landings_4fleet 
# Control file :			 Ctl23_landings_4fleet 
# Forecast file :			 Fore23_landings_4fleet 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.landings.4fleet", file="all")


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_landings_4fleet, 'starter.ss', fsep = fsep)
Start23_landings_4fleet <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_landings_4fleet ,
      # dir =  Dir_23_landings_4fleet, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_landings_4fleet, 'starter.ss')
#  Start23_landings_4fleet <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_landings_4fleet')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_landings_4fleet,Start23_landings_4fleet$datfile, fsep = fsep)
Dat23_landings_4fleet <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 


# use FourFleets_NoSlope_CombineTriennial data
Dat23_landings_4fleet$Nfleets <- SS_Param2023$Nfleets$data$FourFleets_NoSlope_CombineTriennial

# fleetinfo - modify survey timing
Dat23_landings_4fleet$fleetinfo <- SS_Param2023$fleet_info$data$FourFleets_NoSlope_CombineTriennial
Dat23_landings_4fleet$fleetinfo$surveytiming <- c(rep(-1,4),rep(7,3))
Dat23_landings_4fleet$areas <- rep(1,7)
Dat23_landings_4fleet$catch <- SS_Param2023$Catch$data$FourFleets_NoSlope_CombineTriennial
Dat23_landings_4fleet$CPUEinfo <- SS_Param2023$CPUEinfo$data$FourFleets_NoSlope_CombineTriennial
# CPUE - change fleet to index and index to obs
# not sure about the appropriate index - I think this matches the base model?
Dat23_landings_4fleet$CPUE <-  SS_Param2023$Indices$data$FourFleets_NoSlope_CombineTriennial %>%
  mutate(obs = index, 
         index = ifelse(fleet %in% 6, 5, fleet)) %>% 
  dplyr::select(year, seas, index, obs, se_log) %>% data.frame

# In base model: 
# Triennial1 = fleet 4. CPUE data (Triennial_Late in the SS_Param? Fleet 6)
# Triennial2 = fleet 5. No CPUE data (Triennial_Early in the SS_Param? Fleet 5)
# NWFSCCcombo = fleet 6. CPUE data (Fleet 7)

Dat23_landings_4fleet$N_discard_fleets <- SS_Param2023$N_discard_fleets$data$FourFleets_NoSlope_CombineTriennial
Dat23_landings_4fleet$discard_fleet_info <- SS_Param2023$discard_fleet_info$data$FourFleets_NoSlope_CombineTriennial
Dat23_landings_4fleet$discard_data <- SS_Param2023$discard_rates$data$FourFleets_NoSlope_CombineTriennial
Dat23_landings_4fleet$meanbodywt <- SS_Param2023$Meanbodywt$data$FourFleets_NoSlope_CombineTriennial
Dat23_landings_4fleet$len_info <- SS_Param2023$len_info$data$FourFleets_NoSlope_CombineTriennial
Dat23_landings_4fleet$lencomp <- SS_Param2023$All_LengthComp$data$FourFleets_NoSlope_CombineTriennial

Dat23_landings_4fleet$Nfleet <- SS_Param2023$Nfleet$data$FourFleets_NoSlope_CombineTriennial
Dat23_landings_4fleet$Nsurveys <- SS_Param2023$Nsurveys$data$FourFleets_NoSlope_CombineTriennial
Dat23_landings_4fleet$max_combined_lbin <- rep(0,7)

# Save the data file for the model
SS_writedat(
  datlist =  Dat23_landings_4fleet ,
  outfile = file.path(Dir_23_landings_4fleet, 'SST_data.ss', fsep = fsep),
  version = '3.30',
  overwrite = TRUE
)

# Check file structure
# DatFile <- file.path(Dir_23_landings_4fleet, 'SST_data.ss', fsep = fsep)
#  Dat23_landings_4fleet <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_landings_4fleet')
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
Ctlfile <-file.path(Dir_23_landings_4fleet,Start23_landings_4fleet$ctlfile, fsep = fsep)
Ctl23_landings_4fleet <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_landings_4fleet, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 

# use FourFleets_NoSlope_CombineTriennial data
# base this on 5.2 analyses code
Ctl23_landings_4fleet$Nfleets <- SS_Param2023$Nfleets$data$FourFleets_NoSlope_CombineTriennial
Ctl23_landings_4fleet$fleetnames <- SS_Param2023$fleetnames$data$FourFleets_NoSlope_CombineTriennial

# Doesn't look like this is in the params file
# not sure if this is correct, but when I change it, it's definitely wrong
Ctl23_landings_4fleet$F_4_Fleet_Parms <- bind_rows(Ctl23_landings_4fleet$F_4_Fleet_Parms, 
                                                   data.frame(Fleet=4,start_F=0.05,first_parm_phase=99))
row.names(Ctl23_landings_4fleet$F_4_Fleet_Parms)[4] <- "F_4_Fleet_Parms4"

Ctl23_landings_4fleet$Q_options <- as_tibble(SS_Param2023$Q_options$data$FourFleets_NoSlope_CombineTriennial) %>% 
  filter(fleet != 6) %>% as.data.frame 	
row.names(Ctl23_landings_4fleet$Q_options) <- c("Triennial_Early", "NWFSCcombo")

Ctl23_landings_4fleet$Q_parms <- SS_Param2023$Q_parms$data$FourFleets_NoSlope_CombineTriennial	 %>% tibble::rownames_to_column() %>% filter(!(grepl("Triennial_Late", rowname))) %>% tibble::column_to_rownames()


# Change 'Male' to 3 for the survey fleets
# try switching this back and see if it runs OK
Ctl23_landings_4fleet$size_selex_types <-  SS_Param2023$size_selex_types$data$FourFleets_NoSlope_CombineTriennial
Ctl23_landings_4fleet$size_selex_types$Male[5:7] <- 3

Ctl23_landings_4fleet$age_selex_types <- SS_Param2023$age_selex_types$data$FourFleets_NoSlope_CombineTriennial
# use parameters from base model - just add parameters for new fleet
# code is clunky - but couldn't make it more elegant quickly
row.names(Ctl23_landings_4fleet$size_selex_parms) <- gsub("Triennial1(4)","Triennial_Early(5)",row.names(Ctl23_landings_4fleet$size_selex_parms),fixed=TRUE)
row.names(Ctl23_landings_4fleet$size_selex_parms) <- gsub("Triennial2(5)","Triennial_Late(6)",row.names(Ctl23_landings_4fleet$size_selex_parms),fixed=TRUE)
row.names(Ctl23_landings_4fleet$size_selex_parms) <- gsub("NWFSCcombo(6)","NWFSCcombo(7)",row.names(Ctl23_landings_4fleet$size_selex_parms),fixed=TRUE)
sizeselex_ntn <- Ctl23_landings_4fleet$size_selex_parms[21:30,]
row.names(sizeselex_ntn) <- gsub("Non-trawl(3)","Non-trawl_N(3)",row.names(sizeselex_ntn),fixed=TRUE)
sizeselex_nts <- Ctl23_landings_4fleet$size_selex_parms[21:30,]
row.names(sizeselex_nts) <- gsub("Non-trawl(3)","Non-trawl_S(4)",row.names(sizeselex_nts),fixed=TRUE)
Ctl23_landings_4fleet$size_selex_parms <- bind_rows(Ctl23_landings_4fleet$size_selex_parms[1:20,], 
                      sizeselex_ntn, sizeselex_nts, 
                      Ctl23_landings_4fleet$size_selex_parms[31:63,]) %>% data.frame

#$ Ctl23_landings_4fleet$size_selex_parms <-  SS_Param2023$size_selex_parms$data$FourFleets_NoSlope_CombineTriennial
# leave time-varying selectivity the same as base model
# Ctl23_landings_4fleet$size_selex_parms_tv <- SS_Param2023$size_selex_parms_tv$data$FourFleets_NoSlope_CombineTriennial

# not sure what the variance adjustment is - the manual isn't helpful
Ctl23_landings_4fleet$Variance_adjustment_list <-  SS_Param2023$Variance_adjustment_list$data$FourFleets_NoSlope_CombineTriennial

# Looking at control file compared to base model:
# there are several size selectivity parameters that appear in the base model
# that don't appear in SS_Param2023 
# replace only the fleet size selex parms, and change the names of the survey fleets
# base model uses a male offset which SS_Param2023 doesn't use

# Save the control file for the model
SS_writectl(
ctllist =  Ctl23_landings_4fleet ,
outfile = file.path(Dir_23_landings_4fleet, 'SST_control.ss', fsep = fsep),
version = '3.30',
overwrite = TRUE
)
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_landings_4fleet')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_landings_4fleet, 'forecast.ss', fsep = fsep)
Fore23_landings_4fleet <-SS_readforecast(
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
      # mylist =  Fore23_landings_4fleet ,
      # dir = Dir_23_landings_4fleet, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_landings_4fleet, 'forecast.ss', fsep = fsep)
#  Fore23_landings_4fleet <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_landings_4fleet')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_landings_4fleet,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.landings.4fleetfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_landings_4fleet, 'run', fsep = fsep)

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
# This can be done using the 1.3_Landings_4fleet_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------


