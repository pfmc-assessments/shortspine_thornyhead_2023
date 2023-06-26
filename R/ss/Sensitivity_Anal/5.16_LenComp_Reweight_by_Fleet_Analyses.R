# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 5.16 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic: 
# 	- lenght comp combo only 
# 	- lenght comp add triennial 
# 	- lenght comp add NonTrawl 
# 	- lenght comp add SouthTrawl 
# 	- lenght comp add NorthTrawl 
# Author:  Andrea Odell 
# Date: 2023-06-07 14:10:32 
# Names of the models created:
# 	- 23.lencomp.Combo.Only 
# 	- 23.lencomp.AddTriennial 
# 	- 23.lencomp.AddNonTrawl 
# 	- 23.lencomp.AddSouthTrawl 
# 	- 23.lencomp.AddNorthTrawl 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.lencomp.Combo.Only 				 23.model.francis_2 
# 23.lencomp.AddTriennial 				 23.model.francis_2 
# 23.lencomp.AddNonTrawl 				 23.model.francis_2 
# 23.lencomp.AddSouthTrawl 				 23.model.francis_2 
# 23.lencomp.AddNorthTrawl 				 23.model.francis_2 
# 
# Results are stored in the following foler: 
#	 /Users/andrea/Desktop/shortspine_thornyhead_2023/model/Sensitivity_Anal//5.16_LenComp_Reweight_by_Fleet 
# 
# General features: 
# Iteratively adjust length comp weighting starting with combo survey only (everything else set to 0), then add triennial, non-trawl, south trawl, then north trawl 
# 
# Model features:
# - Model 23.lencomp.Combo.Only:
# combo only with variance adjustment value, everything else set to 0 
# - Model 23.lencomp.AddTriennial:
# combo + triennial with variance adjustment value, rest set to 0 
# - Model 23.lencomp.AddNonTrawl:
# combo + triennial + Nontrawl, rest set to 0 
# - Model 23.lencomp.AddSouthTrawl:
# combo + triennial + Nontrawl + South trawl, rest set to 0 
# - Model 23.lencomp.AddNorthTrawl:
# combo + triennial + Nontrawl + South trawl + north trawl 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# /Users/andrea/Desktop/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/5.16_LenComp_Reweight_by_Fleet_Outputs.R 

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
# Reminder - The following models are considered:
# 	-  23.lencomp.Combo.Only 
# 	-  23.lencomp.AddTriennial 
# 	-  23.lencomp.AddNonTrawl 
# 	-  23.lencomp.AddSouthTrawl 
# 	-  23.lencomp.AddNorthTrawl 
noHess <- c(TRUE,TRUE,TRUE,TRUE,TRUE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.lencomp.Combo.Only  ----
# ----------------------------------------------------------- #

# Path to the 23.lencomp.Combo.Only repertory
Dir_23_lencomp_Combo_Only <- file.path(dir_SensAnal, '5.16_LenComp_Reweight_by_Fleet','1_23.lencomp.Combo.Only' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_lencomp_Combo_Only') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_lencomp_Combo_Only 
# Data file :			 Dat23_lencomp_Combo_Only 
# Control file :			 Ctl23_lencomp_Combo_Only 
# Forecast file :			 Fore23_lencomp_Combo_Only 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.model.francis_2',
      curr.model = '23.lencomp.Combo.Only',
      files = 'all')


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_lencomp_Combo_Only, 'starter.ss', fsep = fsep)
Start23_lencomp_Combo_Only <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_lencomp_Combo_Only ,
      dir =  Dir_23_lencomp_Combo_Only, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_lencomp_Combo_Only, 'starter.ss')
#  Start23_lencomp_Combo_Only <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_lencomp_Combo_Only')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_lencomp_Combo_Only,Start23_lencomp_Combo_Only$datfile, fsep = fsep)
Dat23_lencomp_Combo_Only <- SS_readdat_3.30(
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
      datlist =  Dat23_lencomp_Combo_Only ,
      outfile = file.path(Dir_23_lencomp_Combo_Only, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_lencomp_Combo_Only, 'SST_data.ss', fsep = fsep)
#  Dat23_lencomp_Combo_Only <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_lencomp_Combo_Only')
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
Ctlfile <-file.path(Dir_23_lencomp_Combo_Only,Start23_lencomp_Combo_Only$ctlfile, fsep = fsep)
Ctl23_lencomp_Combo_Only <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_lencomp_Combo_Only, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

#Dat23_lencomp_Combo_Only$fleetinfo

Ctl23_lencomp_Combo_Only$Variance_adjustment_list = Ctl23_lencomp_Combo_Only$Variance_adjustment_list %>% 
  mutate(Value = ifelse(Data_type == 4 & Fleet != 6, 0, Value))


# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_lencomp_Combo_Only ,
      outfile = file.path(Dir_23_lencomp_Combo_Only, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_lencomp_Combo_Only')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_lencomp_Combo_Only, 'forecast.ss', fsep = fsep)
Fore23_lencomp_Combo_Only <-SS_readforecast(
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
      mylist =  Fore23_lencomp_Combo_Only ,
      dir = Dir_23_lencomp_Combo_Only, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_lencomp_Combo_Only, 'forecast.ss', fsep = fsep)
#  Fore23_lencomp_Combo_Only <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_lencomp_Combo_Only')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_lencomp_Combo_Only,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.lencomp.Combo.Onlyfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_lencomp_Combo_Only, 'run', fsep = fsep)

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

# End development for model 23.lencomp.Combo.Only 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_lencomp_Combo_Only','Dat23_lencomp_Combo_Only','Ctl23_lencomp_Combo_Only','Fore23_lencomp_Combo_Only')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.lencomp.AddTriennial  ----
# ----------------------------------------------------------- #

# Path to the 23.lencomp.AddTriennial repertory
Dir_23_lencomp_AddTriennial <- file.path(dir_SensAnal, '5.16_LenComp_Reweight_by_Fleet','2_23.lencomp.AddTriennial' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_lencomp_AddTriennial') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_lencomp_AddTriennial 
# Data file :					 Dat23_lencomp_AddTriennial 
# Control file :					 Ctl23_lencomp_AddTriennial 
# Forecast file :					 Fore23_lencomp_AddTriennial 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.model.francis_2',
      curr.model = '23.lencomp.AddTriennial',
      files = 'all')


# 4.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_lencomp_AddTriennial, 'starter.ss', fsep = fsep)
Start23_lencomp_AddTriennial <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_lencomp_AddTriennial ,
      dir =  Dir_23_lencomp_AddTriennial, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_lencomp_AddTriennial, 'starter.ss')
#  Start23_lencomp_AddTriennial <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_lencomp_AddTriennial')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_lencomp_AddTriennial,Start23_lencomp_AddTriennial$datfile, fsep = fsep)
Dat23_lencomp_AddTriennial <- SS_readdat_3.30(
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
      datlist =  Dat23_lencomp_AddTriennial ,
      outfile = file.path(Dir_23_lencomp_AddTriennial, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_lencomp_AddTriennial, 'SST_data.ss', fsep = fsep)
#  Dat23_lencomp_AddTriennial <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_lencomp_AddTriennial')
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
Ctlfile <-file.path(Dir_23_lencomp_AddTriennial,Start23_lencomp_AddTriennial$ctlfile, fsep = fsep)
Ctl23_lencomp_AddTriennial <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_lencomp_AddTriennial, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

Ctl23_lencomp_AddTriennial$Variance_adjustment_list = Ctl23_lencomp_AddTriennial$Variance_adjustment_list %>% 
  mutate(Value = ifelse(Data_type == 4 & Fleet != c(4,5,6), 0, Value))



# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_lencomp_AddTriennial ,
      outfile = file.path(Dir_23_lencomp_AddTriennial, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_lencomp_AddTriennial')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_lencomp_AddTriennial, 'forecast.ss', fsep = fsep)
Fore23_lencomp_AddTriennial <-SS_readforecast(
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
      mylist =  Fore23_lencomp_AddTriennial ,
      dir = Dir_23_lencomp_AddTriennial, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_lencomp_AddTriennial, 'forecast.ss', fsep = fsep)
#  Fore23_lencomp_AddTriennial <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_lencomp_AddTriennial')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_lencomp_AddTriennial,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.lencomp.AddTriennialfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[2], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_lencomp_AddTriennial, 'run', fsep = fsep)

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

# End development for model 23.lencomp.AddTriennial 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_lencomp_AddTriennial','Dat23_lencomp_AddTriennial','Ctl23_lencomp_AddTriennial','Fore23_lencomp_AddTriennial')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  5. Developing model 23.lencomp.AddNonTrawl  ----
# ----------------------------------------------------------- #

# Path to the 23.lencomp.AddNonTrawl repertory
Dir_23_lencomp_AddNonTrawl <- file.path(dir_SensAnal, '5.16_LenComp_Reweight_by_Fleet','3_23.lencomp.AddNonTrawl' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_lencomp_AddNonTrawl') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_lencomp_AddNonTrawl 
# Data file :			 Dat23_lencomp_AddNonTrawl 
# Control file :			 Ctl23_lencomp_AddNonTrawl 
# Forecast file :			 Fore23_lencomp_AddNonTrawl 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.model.francis_2',
      curr.model = '23.lencomp.AddNonTrawl',
      files = 'all')


# 5.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_lencomp_AddNonTrawl, 'starter.ss', fsep = fsep)
Start23_lencomp_AddNonTrawl <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_lencomp_AddNonTrawl ,
      dir =  Dir_23_lencomp_AddNonTrawl, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_lencomp_AddNonTrawl, 'starter.ss')
#  Start23_lencomp_AddNonTrawl <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_lencomp_AddNonTrawl')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_lencomp_AddNonTrawl,Start23_lencomp_AddNonTrawl$datfile, fsep = fsep)
Dat23_lencomp_AddNonTrawl <- SS_readdat_3.30(
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
      datlist =  Dat23_lencomp_AddNonTrawl ,
      outfile = file.path(Dir_23_lencomp_AddNonTrawl, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_lencomp_AddNonTrawl, 'SST_data.ss', fsep = fsep)
#  Dat23_lencomp_AddNonTrawl <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_lencomp_AddNonTrawl')
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
Ctlfile <-file.path(Dir_23_lencomp_AddNonTrawl,Start23_lencomp_AddNonTrawl$ctlfile, fsep = fsep)
Ctl23_lencomp_AddNonTrawl <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_lencomp_AddNonTrawl, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

Ctl23_lencomp_AddNonTrawl$Variance_adjustment_list = Ctl23_lencomp_AddNonTrawl$Variance_adjustment_list %>% 
  mutate(Value = ifelse(Data_type == 4 & Fleet %in% c(1,2), 0, Value))



# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_lencomp_AddNonTrawl ,
      outfile = file.path(Dir_23_lencomp_AddNonTrawl, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_lencomp_AddNonTrawl')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 5.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_lencomp_AddNonTrawl, 'forecast.ss', fsep = fsep)
Fore23_lencomp_AddNonTrawl <-SS_readforecast(
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
      mylist =  Fore23_lencomp_AddNonTrawl ,
      dir = Dir_23_lencomp_AddNonTrawl, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_lencomp_AddNonTrawl, 'forecast.ss', fsep = fsep)
#  Fore23_lencomp_AddNonTrawl <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_lencomp_AddNonTrawl')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 5.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_lencomp_AddNonTrawl,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.lencomp.AddNonTrawlfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[3], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 5.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_lencomp_AddNonTrawl, 'run', fsep = fsep)

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

# End development for model 23.lencomp.AddNonTrawl 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_lencomp_AddNonTrawl','Dat23_lencomp_AddNonTrawl','Ctl23_lencomp_AddNonTrawl','Fore23_lencomp_AddNonTrawl')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  6. Developing model 23.lencomp.AddSouthTrawl  ----
# ----------------------------------------------------------- #

# Path to the 23.lencomp.AddSouthTrawl repertory
Dir_23_lencomp_AddSouthTrawl <- file.path(dir_SensAnal, '5.16_LenComp_Reweight_by_Fleet','4_23.lencomp.AddSouthTrawl' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_lencomp_AddSouthTrawl') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_lencomp_AddSouthTrawl 
# Data file :			 Dat23_lencomp_AddSouthTrawl 
# Control file :			 Ctl23_lencomp_AddSouthTrawl 
# Forecast file :			 Fore23_lencomp_AddSouthTrawl 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.model.francis_2',
      curr.model = '23.lencomp.AddSouthTrawl',
      files = 'all')


# 6.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_lencomp_AddSouthTrawl, 'starter.ss', fsep = fsep)
Start23_lencomp_AddSouthTrawl <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_lencomp_AddSouthTrawl ,
      dir =  Dir_23_lencomp_AddSouthTrawl, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_lencomp_AddSouthTrawl, 'starter.ss')
#  Start23_lencomp_AddSouthTrawl <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_lencomp_AddSouthTrawl')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_lencomp_AddSouthTrawl,Start23_lencomp_AddSouthTrawl$datfile, fsep = fsep)
Dat23_lencomp_AddSouthTrawl <- SS_readdat_3.30(
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
      datlist =  Dat23_lencomp_AddSouthTrawl ,
      outfile = file.path(Dir_23_lencomp_AddSouthTrawl, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_lencomp_AddSouthTrawl, 'SST_data.ss', fsep = fsep)
#  Dat23_lencomp_AddSouthTrawl <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_lencomp_AddSouthTrawl')
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
Ctlfile <-file.path(Dir_23_lencomp_AddSouthTrawl,Start23_lencomp_AddSouthTrawl$ctlfile, fsep = fsep)
Ctl23_lencomp_AddSouthTrawl <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_lencomp_AddSouthTrawl, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

Ctl23_lencomp_AddSouthTrawl$Variance_adjustment_list = Ctl23_lencomp_AddSouthTrawl$Variance_adjustment_list %>% 
  mutate(Value = ifelse(Data_type == 4 & Fleet == 1, 0, Value))



# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_lencomp_AddSouthTrawl ,
      outfile = file.path(Dir_23_lencomp_AddSouthTrawl, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_lencomp_AddSouthTrawl')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 6.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_lencomp_AddSouthTrawl, 'forecast.ss', fsep = fsep)
Fore23_lencomp_AddSouthTrawl <-SS_readforecast(
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
      mylist =  Fore23_lencomp_AddSouthTrawl ,
      dir = Dir_23_lencomp_AddSouthTrawl, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_lencomp_AddSouthTrawl, 'forecast.ss', fsep = fsep)
#  Fore23_lencomp_AddSouthTrawl <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_lencomp_AddSouthTrawl')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 6.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_lencomp_AddSouthTrawl,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.lencomp.AddSouthTrawlfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[4], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 6.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_lencomp_AddSouthTrawl, 'run', fsep = fsep)

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

# End development for model 23.lencomp.AddSouthTrawl 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_lencomp_AddSouthTrawl','Dat23_lencomp_AddSouthTrawl','Ctl23_lencomp_AddSouthTrawl','Fore23_lencomp_AddSouthTrawl')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  7. Developing model 23.lencomp.AddNorthTrawl  ----
# ----------------------------------------------------------- #

# Path to the 23.lencomp.AddNorthTrawl repertory
Dir_23_lencomp_AddNorthTrawl <- file.path(dir_SensAnal, '5.16_LenComp_Reweight_by_Fleet','5_23.lencomp.AddNorthTrawl' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_lencomp_AddNorthTrawl') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_lencomp_AddNorthTrawl 
# Data file :			 Dat23_lencomp_AddNorthTrawl 
# Control file :			 Ctl23_lencomp_AddNorthTrawl 
# Forecast file :			 Fore23_lencomp_AddNorthTrawl 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(
      base.model = '23.model.francis_2',
      curr.model = '23.lencomp.AddNorthTrawl',
      files = 'all')


# 7.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_lencomp_AddNorthTrawl, 'starter.ss', fsep = fsep)
Start23_lencomp_AddNorthTrawl <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
      mylist =  Start23_lencomp_AddNorthTrawl ,
      dir =  Dir_23_lencomp_AddNorthTrawl, 
      overwrite = TRUE,
      verbose = TRUE
      )

# Check file structure
# StarterFile <- file.path(Dir_23_lencomp_AddNorthTrawl, 'starter.ss')
#  Start23_lencomp_AddNorthTrawl <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_lencomp_AddNorthTrawl')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_lencomp_AddNorthTrawl,Start23_lencomp_AddNorthTrawl$datfile, fsep = fsep)
Dat23_lencomp_AddNorthTrawl <- SS_readdat_3.30(
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
      datlist =  Dat23_lencomp_AddNorthTrawl ,
      outfile = file.path(Dir_23_lencomp_AddNorthTrawl, 'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )

# Check file structure
# DatFile <- file.path(Dir_23_lencomp_AddNorthTrawl, 'SST_data.ss', fsep = fsep)
#  Dat23_lencomp_AddNorthTrawl <-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Dat23_lencomp_AddNorthTrawl')
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
Ctlfile <-file.path(Dir_23_lencomp_AddNorthTrawl,Start23_lencomp_AddNorthTrawl$ctlfile, fsep = fsep)
Ctl23_lencomp_AddNorthTrawl <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_lencomp_AddNorthTrawl, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 

Ctl23_lencomp_AddNorthTrawl$Variance_adjustment_list = Ctl23_lencomp_AddNorthTrawl$Variance_adjustment_list %>% 
  mutate(Value = ifelse(Data_type == 4 & Fleet %in% c(1,6), 0, Value))

# Save the control file for the model
SS_writectl(
      ctllist =  Ctl23_lencomp_AddNorthTrawl ,
      outfile = file.path(Dir_23_lencomp_AddNorthTrawl, 'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_lencomp_AddNorthTrawl')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 7.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_lencomp_AddNorthTrawl, 'forecast.ss', fsep = fsep)
Fore23_lencomp_AddNorthTrawl <-SS_readforecast(
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
      mylist =  Fore23_lencomp_AddNorthTrawl ,
      dir = Dir_23_lencomp_AddNorthTrawl, 
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )

# Check file structure
# ForeFile <- file.path(Dir_23_lencomp_AddNorthTrawl, 'forecast.ss', fsep = fsep)
#  Fore23_lencomp_AddNorthTrawl <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_lencomp_AddNorthTrawl')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 7.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_lencomp_AddNorthTrawl,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.lencomp.AddNorthTrawlfolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[5], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 7.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_lencomp_AddNorthTrawl, 'run', fsep = fsep)

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
# This can be done using the 5.16_LenComp_Reweight_by_Fleet_Outputs.R script.

# !!!!! WARNING !!!!!
# ------------------- #
# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.
# ------------------- #

## End script to develop SA models ##

# -----------------------------------------------------------
# -----------------------------------------------------------


