# ============================================================ #
# Script used to develop the model(s) considered in the 
# sensitivity analysis: Item 5.5 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic:  Remove small sample size LCs Sex-Specific Survey Selectivity Improve Trawl_N LC Fit Improve Other LC Fits 
# 	- Remove small sample size LCs 
# 	- Sex-Specific Survey Selectivity 
# 	- Improve Trawl_N LC Fit 
# 	- Improve Other LC Fits 
# Author:  Team Thornyheads 
# Date: 2023-04-20 13:16:01 
# Names of the models created:
# -  23.model.sample_sizes 
# -  23.model.sexed_survey_selectivity 
# -  23.model.improve_trawln 
# -  23.model.improve_other 
# *** 
# 
# This analysis has been developed based on the following models: 
# New model 	 Base model
# 23.model.sample_sizes 	 23.model.settlement_events 
# 23.model.sexed_survey_selectivity 	 23.model.sample_sizes 
# 23.model.improve_trawln 	 23.model.sexed_survey_selectivity 
# 23.model.improve_other 	 23.model.improve_trawln 
# 
# Results are stored in the following foler: 
#	 /Users/jzahner/Desktop/Projects/shortspine_thornyhead_2023/model/Sensitivity_Anal/5.5_Improve_LC_Fits 
# 
# General features: 
# Improve fits to length composition data by modifying estimated selectivity parameters and remove poor data. This includes removing LCs where sample sizes are <11.5, using sex-specific selectivities for survey length comps, and modifying selectivity pars for the fisheries fleets. 
# 
# Model features:
# - Model 23.model.sample_sizes:
# 23.model.settlement_events + remove small sample size LCs 
# - Model 23.model.sexed_survey_selectivity:
# 23.model.sample_sizes + use sex-specific survey selectivities 
# - Model 23.model.improve_trawln:
# 23.model.sexed_survey_selectivity + improve Trawl_N fits 
# - Model 23.model.improve_other:
# 23.model.improve_trawln + improve fits to other fleet LCs 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package. 
# The new input files are then written in the root directory of each model and the 
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# /Users/jzahner/Desktop/Projects/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/5.5_Improve_LC_Fits_Outputs.R 

# *************************************
# ---           WARNINGS            ---
# *************************************
# 
# => The base model(s) you specified for the following new model(s):
# 	 23.model.sexed_survey_selectivity, 23.model.improve_trawln, 23.model.improve_other 
# do(es) not exist yet. This means you'll have to start by developping its/their own base model before creating your new model !!!!
# Specifically, you must first develop the following model(s):
# 	 23.model.sample_sizes, 23.model.sexed_survey_selectivity, 23.model.improve_trawln 
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

#  3. Developing model 23.model.sample_sizes  ----
# ----------------------------------------------------------- #

# Path to the 23.model.sample_sizes repertory
Dir_23_model_sample_sizes <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','1_23.model.sample_sizes' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_sample_sizes') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_sample_sizes 
# Data file :			 Dat23_model_sample_sizes 
# Control file :			 Ctl23_model_sample_sizes 
# Forecast file :			 Fore23_model_sample_sizes 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already 
# wrote a new SS input file for your new model and need to modify it (It ensure 
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()

#23.model.sample_sizes 	 23.model.settlement_events 

# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_model_sample_sizes, 'starter.ss', fsep = fsep)
Start23_model_sample_sizes <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_sample_sizes ,
      # dir =  Dir_23_model_sample_sizes, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_sample_sizes, 'starter.ss')
#  Start23_model_sample_sizes <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_sample_sizes')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_sample_sizes,Start23_model_sample_sizes$datfile, fsep = fsep)
Dat23_model_sample_sizes <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 
Dat23_model_sample_sizes$lencomp <- SS_Param2023$All_LengthComp$data$ThreeFleets_NoSlope_CombineTriennial %>% filter(Nsamp > 10.5)

# Save the data file for the model
SS_writedat(
  datlist =  Dat23_model_sample_sizes ,
  outfile = file.path(Dir_23_model_sample_sizes, 'SST_data.ss', fsep = fsep),
  version = '3.30',
  overwrite = TRUE
)

# Check file structure
# DatFile <- file.path(Dir_23_model_sample_sizes, 'SST_data.ss', fsep = fsep)
#  Dat23_model_sample_sizes <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_sample_sizes')
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
Ctlfile <-file.path(Dir_23_model_sample_sizes,Start23_model_sample_sizes$ctlfile, fsep = fsep)
Ctl23_model_sample_sizes <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_sample_sizes, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_sample_sizes ,
      # outfile = file.path(Dir_23_model_sample_sizes, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_sample_sizes')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_sample_sizes, 'forecast.ss', fsep = fsep)
Fore23_model_sample_sizes <-SS_readforecast(
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
      # mylist =  Fore23_model_sample_sizes ,
      # dir = Dir_23_model_sample_sizes, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_sample_sizes, 'forecast.ss', fsep = fsep)
#  Fore23_model_sample_sizes <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_sample_sizes')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_sample_sizes, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.sample_sizes folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = "-nohess"
      # this is if we want to use '-nohess' 
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_sample_sizes, 'run', fsep = fsep)

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

# End development for model 23.model.sample_sizes 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_sample_sizes','Dat23_model_sample_sizes','Ctl23_model_sample_sizes','Fore23_model_sample_sizes')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.model.sexed_survey_selectivity  ----
# ----------------------------------------------------------- #

# Path to the 23.model.sexed_survey_selectivity repertory
Dir_23_model_sexed_survey_selectivity <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','2_23.model.sexed_survey_selectivity' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_sexed_survey_selectivity') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_model_sexed_survey_selectivity 
# Data file :					 Dat23_model_sexed_survey_selectivity 
# Control file :					 Ctl23_model_sexed_survey_selectivity 
# Forecast file :					 Fore23_model_sexed_survey_selectivity 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already 
# wrote a new SS input file for your new model and need to modify it (It ensure 
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()

#23.model.sexed_survey_selectivity 	 23.model.sample_sizes 

# 4.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_model_sexed_survey_selectivity, 'starter.ss', fsep = fsep)
Start23_model_sexed_survey_selectivity <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_sexed_survey_selectivity ,
      # dir =  Dir_23_model_sexed_survey_selectivity, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_sexed_survey_selectivity, 'starter.ss')
#  Start23_model_sexed_survey_selectivity <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_sexed_survey_selectivity')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_sexed_survey_selectivity,Start23_model_sexed_survey_selectivity$datfile, fsep = fsep)
Dat23_model_sexed_survey_selectivity <- SS_readdat_3.30(
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
      # datlist =  Dat23_model_sexed_survey_selectivity ,
      # outfile = file.path(Dir_23_model_sexed_survey_selectivity, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_sexed_survey_selectivity, 'SST_data.ss', fsep = fsep)
#  Dat23_model_sexed_survey_selectivity <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_sexed_survey_selectivity')
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
Ctlfile <-file.path(Dir_23_model_sexed_survey_selectivity,Start23_model_sexed_survey_selectivity$ctlfile, fsep = fsep)
Ctl23_model_sexed_survey_selectivity <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_sexed_survey_selectivity, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

#These too, correct? 
Ctl23_model_sexed_survey_selectivity$Q_parms

Ctl23_model_sexed_survey_selectivity$size_selex_types<-SS_Param2023$size_selex_types$data$ThreeFleets_NoSlope_SplitTriennial_two_sexes
Ctl23_model_sexed_survey_selectivity$age_selex_types<-SS_Param2023$age_selex_types$data$ThreeFleets_NoSlope_SplitTriennial_two_sexes
Ctl23_model_sexed_survey_selectivity$size_selex_parms <- SS_Param2023$size_selex_parms$data$ThreeFleets_NoSlope_SplitTriennial_TwoSexes



# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_sexed_survey_selectivity ,
      # outfile = file.path(Dir_23_model_sexed_survey_selectivity, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_sexed_survey_selectivity')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_sexed_survey_selectivity, 'forecast.ss', fsep = fsep)
Fore23_model_sexed_survey_selectivity <-SS_readforecast(
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
      # mylist =  Fore23_model_sexed_survey_selectivity ,
      # dir = Dir_23_model_sexed_survey_selectivity, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_sexed_survey_selectivity, 'forecast.ss', fsep = fsep)
#  Fore23_model_sexed_survey_selectivity <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_sexed_survey_selectivity')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_sexed_survey_selectivity, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.sexed_survey_selectivity folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = '-nohess' 
      # this is if we want to use '-nohess' 
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_sexed_survey_selectivity, 'run', fsep = fsep)

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

# End development for model 23.model.sexed_survey_selectivity 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_sexed_survey_selectivity','Dat23_model_sexed_survey_selectivity','Ctl23_model_sexed_survey_selectivity','Fore23_model_sexed_survey_selectivity')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.model.improve_trawln  ----
# ----------------------------------------------------------- #

# Path to the 23.model.improve_trawln repertory
Dir_23_model_improve_trawln <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','3_23.model.improve_trawln' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_improve_trawln') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_improve_trawln 
# Data file :			 Dat23_model_improve_trawln 
# Control file :			 Ctl23_model_improve_trawln 
# Forecast file :			 Fore23_model_improve_trawln 


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
StarterFile <- file.path(Dir_23_model_improve_trawln, 'starter.ss', fsep = fsep)
Start23_model_improve_trawln <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_improve_trawln ,
      # dir =  Dir_23_model_improve_trawln, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_improve_trawln, 'starter.ss')
#  Start23_model_improve_trawln <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_improve_trawln')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_improve_trawln,Start23_model_improve_trawln$datfile, fsep = fsep)
Dat23_model_improve_trawln <- SS_readdat_3.30(
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
      # datlist =  Dat23_model_improve_trawln ,
      # outfile = file.path(Dir_23_model_improve_trawln, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_improve_trawln, 'SST_data.ss', fsep = fsep)
#  Dat23_model_improve_trawln <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_improve_trawln')
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
Ctlfile <-file.path(Dir_23_model_improve_trawln,Start23_model_improve_trawln$ctlfile, fsep = fsep)
Ctl23_model_improve_trawln <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_improve_trawln, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_improve_trawln ,
      # outfile = file.path(Dir_23_model_improve_trawln, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_improve_trawln')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_improve_trawln, 'forecast.ss', fsep = fsep)
Fore23_model_improve_trawln <-SS_readforecast(
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
      # mylist =  Fore23_model_improve_trawln ,
      # dir = Dir_23_model_improve_trawln, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_improve_trawln, 'forecast.ss', fsep = fsep)
#  Fore23_model_improve_trawln <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_improve_trawln')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_improve_trawln, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.improve_trawln folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_improve_trawln, 'run', fsep = fsep)

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

# End development for model 23.model.improve_trawln 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_model_improve_trawln','Dat23_model_improve_trawln','Ctl23_model_improve_trawln','Fore23_model_improve_trawln')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  6. Developing model 23.model.improve_other  ----
# ----------------------------------------------------------- #

# Path to the 23.model.improve_other repertory
Dir_23_model_improve_other <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','4_23.model.improve_other' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_model_improve_other') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_model_improve_other 
# Data file :			 Dat23_model_improve_other 
# Control file :			 Ctl23_model_improve_other 
# Forecast file :			 Fore23_model_improve_other 


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
StarterFile <- file.path(Dir_23_model_improve_other, 'starter.ss', fsep = fsep)
Start23_model_improve_other <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_model_improve_other ,
      # dir =  Dir_23_model_improve_other, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_model_improve_other, 'starter.ss')
#  Start23_model_improve_other <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_model_improve_other')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_model_improve_other,Start23_model_improve_other$datfile, fsep = fsep)
Dat23_model_improve_other <- SS_readdat_3.30(
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
      # datlist =  Dat23_model_improve_other ,
      # outfile = file.path(Dir_23_model_improve_other, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_model_improve_other, 'SST_data.ss', fsep = fsep)
#  Dat23_model_improve_other <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_model_improve_other')
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
Ctlfile <-file.path(Dir_23_model_improve_other,Start23_model_improve_other$ctlfile, fsep = fsep)
Ctl23_model_improve_other <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_model_improve_other, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_model_improve_other ,
      # outfile = file.path(Dir_23_model_improve_other, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_model_improve_other')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_model_improve_other, 'forecast.ss', fsep = fsep)
Fore23_model_improve_other <-SS_readforecast(
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
      # mylist =  Fore23_model_improve_other ,
      # dir = Dir_23_model_improve_other, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_model_improve_other, 'forecast.ss', fsep = fsep)
#  Fore23_model_improve_other <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_model_improve_other')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 6.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_model_improve_other, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.model.improve_other folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = NULL
      # this is if we want to use '-nohess' 
      )

# 6.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_model_improve_other, 'run', fsep = fsep)

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
# This can be done using the 5.5_Improve_LC_Fits_Outputs.R script.


# -----------------------------------------------------------
# -----------------------------------------------------------


