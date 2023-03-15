# ============================================================ #
# Script used to develop the model(s) considered in the 
# sensitivity analysis: Item 0.1 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  transition 
# Specific item in that topic:  All Param fixed Floating Q All Param estimated 
# Author:  Matthieu VERON 
# Date: 2023-03-14 20:38:28 
# Names of the models created:
# -  23.sq.fix 
# -  23.sq.floatQ 
# -  23.sq.est 
# *** 
# 
# This analysis has been developed based on the following models: 
# New model 	 Base model
# 23.sq.fix 	 23.sq.fixQ 
# 23.sq.floatQ 	 23.sq.fixQ 
# 23.sq.est 	 23.sq.fixQ 
# 
# Results are stored in the following foler: 
#	 C:/Users/Matthieu Verson/Documents/GitHub/Forked_repos/shortspine_thornyhead_2023/model/Sensitivity_Anal/0.1_Bridging_models 
# 
# General features: 
# Revisiting the transition of the 2013 model. For the transition, the model created was based on the 2013 model except that the catchability parameters were set to the “estimated” value from the 2013 assessment (which used a floating approach by setting Q as a scaling factor such that the estimate is median unbiased). Three models are developed here: i) a model where all the parameters are fixed to their estimated value from the 2013 assessment, ii) a second model which consider a floating approach for Q (i.e., an analytical solution is used and Q is not estimated as an active parameter) and iii) a third model where all parameters are freely estimated (Q included). 
# 
# Model features:
# - Model 23.sq.fix:
# Model with all parameters fixed to their values as estimated in the 2013 assessment. 
# - Model 23.sq.floatQ:
# Model with floating Q (i.e., not an active parameter) – other parameters estimated. 
# - Model 23.sq.est:
# Model where all parameters are freely estimated (as in the 2013 assessment), including Q. 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package. 
# The new input files are then written in the root directory of each model and the 
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/Users/Matthieu Verson/Documents/GitHub/Forked_repos/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/0.1_Bridging_models_Outputs.R 

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
remotes::install_github('r4ss/r4ss') 
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

# Useful function
source(file=file.path(dir_script,'utils','clean_functions.R', fsep = fsep))
source(file=file.path(dir_script,'utils','ss_utils.R', fsep=fsep))
source(file=file.path(dir_script,'utils','sensistivity_analysis_utils.R', fsep=fsep))

# Save directories and function
# var.to.save <- c('dir_model', 
        # 'Exe_path',
        # 'dir_script',
        # 'dir_SensAnal') 
var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.sq.fix  ----
# ----------------------------------------------------------- #

# Path to the 23.sq.fix repertory
Dir_23_sq_fix <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.fix' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_sq_fix') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_sq_fix 
# Data file :					 Dat23_sq_fix 
# Control file :			 Ctl23_sq_fix 
# Forecast file :			 Fore23_sq_fix 


# Do you want to copy the SS input files from the base model?
# This is useful if you already write a new SS input file for you new model
# and need to modify it. It ensure to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_sq_fix, 'starter.ss', fsep = fsep)
Start23_sq_fix <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# This model consider all parameters at their estimated values from the 2013
# assessment. There is therefore no estimation phase - We need to set the 
# 'last_estimation_phase' parameter to 0 to turn off the estimation (cf user manual)

Start23_sq_fix$last_estimation_phase <- 0


# Save the starter file for the model
SS_writestarter(
mylist =  Start23_sq_fix ,
dir =  Dir_23_sq_fix,
overwrite = TRUE,
verbose = TRUE
)

# Check file structure
StarterFile <- file.path(Dir_23_sq_fix, 'starter.ss')
 Start23_sq_fix <- SS_readstarter(
file = StarterFile,
verbose = TRUE
)

# clean environment
var.to.save <- c(var.to.save, 'Start23_sq_fix')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_sq_fix,Start23_sq_fix$datfile, fsep = fsep)
Dat23_sq_fix <- SS_readdat_3.30(
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
      # datlist =  Dat23_sq_fix ,
      # outfile = file.path(Dir_23_sq_fix, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure
# DatFile <- file.path(Dir_23_sq_fix, 'SST_data.ss', fsep = fsep)
#  Dat23_sq_fix <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_sq_fix')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.

# Read in the file
Ctlfile <-file.path(Dir_23_sq_fix,Start23_sq_fix$ctlfile, fsep = fsep)
Ctl23_sq_fix <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_sq_fix, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# In this model we need to fix all parameters to their estimates from the 2013 
# assessment model. This implies:
# 1. loading the results from the 2013 assessment
# 2. Find the estimated parameters
# 3. fill in the estimated values in the new control file and turn off the 
# estimation, i.e., phase < 0

# 3.3.1 Read in the results of the 2013 assessment ----
# ============================================================================ #
# Path to the old SST model (i.e. the 2013 model using SS V3.24)
Dir_13_sq <- file.path(dir_model, "2013_SST")

# The results from the last assessment are stored in the .rep file.
# The estimates of parameters are hold in the 'estimated_non_dev_parameters'
# object of the replist list
replist <- SS_output(dir = file.path(Dir_13_sq, "run", fsep = fsep),
                     verbose = TRUE,
                     printstats = TRUE)
# Those are all pameters that have been estimated (outside from recruitment deviations)
rownames(replist$estimated_non_dev_parameters)

# Let's create a function that change the parameter label, and create a dataframe
# with all we need to get the estimated values
# ***************** 
# WARNING
# The label of the parameters in this version of SS do not match with the ones
# used in the 3.30.21 version (when reading the results with the r4ss function)
# ***************** 
New_par <- replist$estimated_non_dev_parameters
New_par <- dplyr::select(New_par, Value, Phase, Min, Max, Init)
New_par <- New_par %>%
  tibble::rownames_to_column(var= "Label")


# ============================================================================

# 3.3.2 Find the estimated parameters ----
# ============================================================================ #

# The estimated parameters are stored in the '' object of the Ctl13_sq list
names(Ctl13_sq$)





# ============================================================================







































# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_sq_fix ,
      # outfile = file.path(Dir_23_sq_fix, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure ----
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_sq_fix')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_sq_fix, 'forecast.ss', fsep = fsep)
Fore23_sq_fix <-SS_readforecast(
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
      # mylist =  Fore23_sq_fix ,
      # dir = Dir_23_sq_fix, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure ----
ForeFile <- file.path(Dir_23_sq_fix, 'forecast.ss', fsep = fsep)
#  Fore23_sq_fix <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_sq_fix')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_sq_fix, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.sq.fix folder
      cleanRun = TRUE
      # clean the folder after the run
      )

# 3.6  Let's plot the outputs from this model ----
# Making the default plots ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_sq_fix, 'run', fsep = fsep)

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

# *********************************************************** #


# -----------------------------------------------------------
# -----------------------------------------------------------

# End development for model 23.sq.fix 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_sq_fix','Dat23_sq_fix','Ctl23_sq_fix','Fore23_sq_fix')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.sq.floatQ  ----
# ----------------------------------------------------------- #

# Path to the 23.sq.floatQ repertory
Dir_23_sq_floatQ <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.floatQ' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_sq_floatQ') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_sq_floatQ 
# Data file :					 Dat23_sq_floatQ 
# Control file :			 Ctl23_sq_floatQ 
# Forecast file :			 Fore23_sq_floatQ 


# Do you want to copy the SS input files from the base model?
# This is useful if you already write a new SS input file for you new model
# and need to modify it. It ensure to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 4.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_sq_floatQ, 'starter.ss', fsep = fsep)
Start23_sq_floatQ <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_sq_floatQ ,
      # dir =  Dir_23_sq_floatQ, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_sq_floatQ, 'starter.ss')
#  Start23_sq_floatQ <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_sq_floatQ')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_sq_floatQ,Start23_sq_floatQ$datfile, fsep = fsep)
Dat23_sq_floatQ <- SS_readdat_3.30(
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
      # datlist =  Dat23_sq_floatQ ,
      # outfile = file.path(Dir_23_sq_floatQ, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure ----
# DatFile <- file.path(Dir_23_sq_floatQ, 'SST_data.ss', fsep = fsep)
#  Dat23_sq_floatQ <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_sq_floatQ')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.3  Work on the control file ----
# ======================= #



























# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.

# Read in the file
Ctlfile <-file.path(Dir_23_sq_floatQ,Start23_sq_floatQ$ctlfile, fsep = fsep)
Ctl23_sq_floatQ <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_sq_floatQ, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 
# The SS_readctl_3.24() needs the data.ss_new file to read the control file
# Let's first check if the data.ss_new is available. If no, we need to run the model
# to get it. All of this can be done using the RunSS_CtlFile() function.

RunSS_CtlFile(
  SS_version = "3.24.U",
  # we use SS V3.24
  Exe_extra = "opt",
  # we use the "opt" exe
  base_path = Dir_13_sq,
  # the SST 2013 directory
  pathRun = NULL,
  # A 'run' folder will be created if it does not already exist
  copy_files = TRUE,
  # copy the input files
  cleanRun = TRUE
  # clean the folder after the run
)

# Now read the control file using the "data.ss_new" file as input of the
# SS_readctl_3.24() function.
oldCtlFile <- file.path(Dir_13_sq, "SST_control.SS", fsep = fsep)
Ctl13_sq <- SS_readctl_3.24(
  file = oldCtlFile,
  verbose = TRUE,
  use_datlist = TRUE,
  datlist = file.path(Dir_13_sq, "run","data.ss_new", fsep = fsep),
  Do_AgeKey = FALSE
)





























# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_sq_floatQ ,
      # outfile = file.path(Dir_23_sq_floatQ, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure ----
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_sq_floatQ')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_sq_floatQ, 'forecast.ss', fsep = fsep)
Fore23_sq_floatQ <-SS_readforecast(
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
      # mylist =  Fore23_sq_floatQ ,
      # dir = Dir_23_sq_floatQ, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure ----
ForeFile <- file.path(Dir_23_sq_floatQ, 'forecast.ss', fsep = fsep)
#  Fore23_sq_floatQ <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_sq_floatQ')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_sq_floatQ, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.sq.floatQ folder
      cleanRun = TRUE
      # clean the folder after the run
      )

# 4.6  Let's plot the outputs from this model ----
# Making the default plots ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_sq_floatQ, 'run', fsep = fsep)

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

# *********************************************************** #


# -----------------------------------------------------------
# -----------------------------------------------------------

# End development for model 23.sq.floatQ 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_sq_floatQ','Dat23_sq_floatQ','Ctl23_sq_floatQ','Fore23_sq_floatQ')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.sq.est  ----
# ----------------------------------------------------------- #

# Path to the 23.sq.est repertory
Dir_23_sq_est <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.est' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_sq_est') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_sq_est 
# Data file :					 Dat23_sq_est 
# Control file :			 Ctl23_sq_est 
# Forecast file :			 Fore23_sq_est 


# Do you want to copy the SS input files from the base model?
# This is useful if you already write a new SS input file for you new model
# and need to modify it. It ensure to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt()


# 5.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_sq_est, 'starter.ss', fsep = fsep)
Start23_sq_est <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_sq_est ,
      # dir =  Dir_23_sq_est, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_sq_est, 'starter.ss')
#  Start23_sq_est <- SS_readstarter(
      # file = StarterFile, 
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_sq_est')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_sq_est,Start23_sq_est$datfile, fsep = fsep)
Dat23_sq_est <- SS_readdat_3.30(
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
      # datlist =  Dat23_sq_est ,
      # outfile = file.path(Dir_23_sq_est, 'SST_data.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )

# Check file structure ----
# DatFile <- file.path(Dir_23_sq_est, 'SST_data.ss', fsep = fsep)
#  Dat23_sq_est <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_sq_est')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.

# Read in the file
Ctlfile <-file.path(Dir_23_sq_est,Start23_sq_est$ctlfile, fsep = fsep)
Ctl23_sq_est <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_sq_est, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_sq_est ,
      # outfile = file.path(Dir_23_sq_est, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure ----
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_sq_est')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_sq_est, 'forecast.ss', fsep = fsep)
Fore23_sq_est <-SS_readforecast(
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
      # mylist =  Fore23_sq_est ,
      # dir = Dir_23_sq_est, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure ----
ForeFile <- file.path(Dir_23_sq_est, 'forecast.ss', fsep = fsep)
#  Fore23_sq_est <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_sq_est')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path = Dir_23_sq_est, 
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the 23.sq.est folder
      cleanRun = TRUE
      # clean the folder after the run
      )

# 5.6  Let's plot the outputs from this model ----
# Making the default plots ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_sq_est, 'run', fsep = fsep)

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

# *********************************************************** #


# -----------------------------------------------------------
# -----------------------------------------------------------

# End development for model 23.sq.est 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_sq_est','Dat23_sq_est','Ctl23_sq_est','Fore23_sq_est')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


