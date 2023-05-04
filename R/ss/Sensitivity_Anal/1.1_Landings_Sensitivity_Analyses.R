# ============================================================ #
# Script used to develop the model(s) considered in the
# sensitivity analysis: Item 1.1 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  landings 
# Specific item in that topic: 
# 	- Imputed historical landings 
# 	- 2013 assessment landings 
# Author:  Adam Hayes 
# Date: 2023-05-01 13:44:12 
# Names of the models created:
# 	-  23.land.hist_impute 
# 	-  23.land.2013 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.land.hist_impute 				 23.model.francis_2 
# 23.land.2013 				 23.model.francis_2 
# 
# Results are stored in the following foler: 
#	 C:/Users/adam.hayes/Work/GitHub/shortspine_thornyhead_2023/model/Sensitivity_Anal/1.1_Landings_Sensitivity 
# 
# General features: 
# Replace the landings with values from the 2013 assessment 
# 
# Model features:
# - Model 23.land.hist_impute:
# Replace the historical landings before 1962 with the imputed values from sablefish landings used in the 2013 assessment 
# - Model 23.land.2013:
# Replace all landings until before 2013 with the values used in the 2013 assessment 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/Users/adam.hayes/Work/GitHub/shortspine_thornyhead_2023/R/ss/Sensitivity_Anal/1.1_Landings_Sensitivity_Outputs.R 

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
# Reminder - The following models are considered:# 	-  23.land.hist_impute 
# 	-  23.land.2013 
noHess <- c(TRUE,TRUE)


var.to.save <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.land.hist_impute  ----
# ----------------------------------------------------------- #

# Path to the 23.land.hist_impute repertory
Dir_23_land_hist_impute <- file.path(dir_SensAnal, '1.1_Landings_Sensitivity','1_23.land.hist_impute' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_land_hist_impute') 


# For each SS input file, the following variable names will be used:
# Starter file :			 Start23_land_hist_impute 
# Data file :			 Dat23_land_hist_impute 
# Control file :			 Ctl23_land_hist_impute 
# Forecast file :			 Fore23_land_hist_impute 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.land.hist_impute", files="all")



# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_land_hist_impute, 'starter.ss', fsep = fsep)
Start23_land_hist_impute <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_land_hist_impute ,
      # dir =  Dir_23_land_hist_impute, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_land_hist_impute, 'starter.ss')
#  Start23_land_hist_impute <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_land_hist_impute')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_land_hist_impute,Start23_land_hist_impute$datfile, fsep = fsep)
Dat23_land_hist_impute <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# Trawl_N = 1
# Trawl_S = 2
# Non-trawl = 3
dat_land_hist_impute <- read.csv(here::here("data","processed","SST_catch_2013assessment.csv")) %>% 
  filter(Year < 1962) %>%
  tidyr::gather(key="fleet",value="catch",NTrawl:SOther) %>%
  mutate(seas=1,
         fleet = ifelse(fleet %in% "NTrawl",1,fleet), 
         fleet = ifelse(fleet %in% "STrawl",2,fleet), 
         fleet = ifelse(fleet %in% c("NOther","SOther"),3,fleet), 
         fleet=as.numeric(fleet)) %>%
  group_by(year=Year, seas, fleet) %>%
  summarize(catch = sum(catch),catch_se = 0.01)

Dat23_land_hist_impute$catch <- dplyr::bind_rows(dat_land_hist_impute, 
                                                 Dat23_land_hist_impute$catch %>% filter(year >= 1962)) %>%
  arrange(fleet,year) %>%
  data.frame()


# Save the data file for the model
SS_writedat(
datlist =  Dat23_land_hist_impute ,
outfile = file.path(Dir_23_land_hist_impute, 'SST_data.ss', fsep = fsep),
version = '3.30',
overwrite = TRUE
)

# Check file structure
DatFile <- file.path(Dir_23_land_hist_impute, 'SST_data.ss', fsep = fsep)
 Dat23_land_hist_impute <-
SS_readdat_3.30(
file = DatFile,
verbose = TRUE,
section = TRUE
)

# clean environment
var.to.save <- c(var.to.save, 'Dat23_land_hist_impute')
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
Ctlfile <-file.path(Dir_23_land_hist_impute,Start23_land_hist_impute$ctlfile, fsep = fsep)
Ctl23_land_hist_impute <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_land_hist_impute, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_land_hist_impute ,
      # outfile = file.path(Dir_23_land_hist_impute, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_land_hist_impute')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_land_hist_impute, 'forecast.ss', fsep = fsep)
Fore23_land_hist_impute <-SS_readforecast(
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
      # mylist =  Fore23_land_hist_impute ,
      # dir = Dir_23_land_hist_impute, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_land_hist_impute, 'forecast.ss', fsep = fsep)
#  Fore23_land_hist_impute <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_land_hist_impute')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_land_hist_impute,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.land.hist_imputefolder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[1], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 3.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_land_hist_impute, 'run', fsep = fsep)

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

# End development for model 23.land.hist_impute 
# You can now develop the next 'new model'.
# Let's remove the input files for this from the 'var.to.save' variable
var.to.save <- var.to.save[!var.to.save %in% c('Start23_land_hist_impute','Dat23_land_hist_impute','Ctl23_land_hist_impute','Fore23_land_hist_impute')]
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# -----------------------------------------------------------
# -----------------------------------------------------------


#  4. Developing model 23.land.2013  ----
# ----------------------------------------------------------- #

# Path to the 23.land.2013 repertory
Dir_23_land_2013 <- file.path(dir_SensAnal, '1.1_Landings_Sensitivity','2_23.land.2013' ,fsep = fsep)

# Add the model directory to the saved variables
var.to.save <- c(var.to.save, 'Dir_23_land_2013') 


# For each SS input file, the following variable names will be used:
# Starter file :					 Start23_land_2013 
# Data file :					 Dat23_land_2013 
# Control file :					 Ctl23_land_2013 
# Forecast file :					 Fore23_land_2013 


# Do you want to copy the SS input files from the base model?
# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same
# basis of comparison.
Restart_SA_modeldvpt(base.model="23.model.francis_2", curr.model="23.land.2013", files="all")


# 4.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_land_2013, 'starter.ss', fsep = fsep)
Start23_land_2013 <- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
# SS_writestarter(
      # mylist =  Start23_land_2013 ,
      # dir =  Dir_23_land_2013, 
      # overwrite = TRUE,
      # verbose = TRUE
      # )

# Check file structure
# StarterFile <- file.path(Dir_23_land_2013, 'starter.ss')
#  Start23_land_2013 <- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )

# clean environment
var.to.save <- c(var.to.save, 'Start23_land_2013')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <-file.path(Dir_23_land_2013,Start23_land_2013$datfile, fsep = fsep)
Dat23_land_2013 <- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )

# Make your modification if applicable
# Code modifying the data file 
# Trawl_N = 1
# Trawl_S = 2
# Non-trawl = 3
dat_land_2013 <- read.csv(here::here("data","processed","SST_catch_2013assessment.csv")) %>% 
  tidyr::gather(key="fleet",value="catch",NTrawl:SOther) %>%
  mutate(seas=1,
         fleet = ifelse(fleet %in% "NTrawl",1,fleet), 
         fleet = ifelse(fleet %in% "STrawl",2,fleet), 
         fleet = ifelse(fleet %in% c("NOther","SOther"),3,fleet), 
         fleet=as.numeric(fleet)) %>%
  group_by(year=Year, seas, fleet) %>%
  summarize(catch = sum(catch),catch_se = 0.01)

Dat23_land_2013$catch <- dplyr::bind_rows(dat_land_2013, 
                                          Dat23_land_2013$catch %>% filter(year > 2012)) %>%
  arrange(fleet,year) %>%
  data.frame()



# Save the data file for the model
SS_writedat(
datlist =  Dat23_land_2013 ,
outfile = file.path(Dir_23_land_2013, 'SST_data.ss', fsep = fsep),
version = '3.30',
overwrite = TRUE
)

# Check file structure
DatFile <- file.path(Dir_23_land_2013, 'SST_data.ss', fsep = fsep)
 Dat23_land_2013 <-
SS_readdat_3.30(
file = DatFile,
verbose = TRUE,
section = TRUE
)

# clean environment
var.to.save <- c(var.to.save, 'Dat23_land_2013')
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
Ctlfile <-file.path(Dir_23_land_2013,Start23_land_2013$ctlfile, fsep = fsep)
Ctl23_land_2013 <- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist = file.path(Dir_23_land_2013, 'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
# SS_writectl(
      # ctllist =  Ctl23_land_2013 ,
      # outfile = file.path(Dir_23_land_2013, 'SST_control.ss', fsep = fsep),
      # version = '3.30',
      # overwrite = TRUE
      # )
# Check file structure
# We actually need to run the model to check the file structure

# clean environment
var.to.save <- c(var.to.save, 'Ctl23_land_2013')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 4.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_land_2013, 'forecast.ss', fsep = fsep)
Fore23_land_2013 <-SS_readforecast(
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
      # mylist =  Fore23_land_2013 ,
      # dir = Dir_23_land_2013, 
      # file = 'forecast.ss',
      # writeAll = TRUE,
      # verbose = TRUE,
      # overwrite = TRUE
      # )

# Check file structure
# ForeFile <- file.path(Dir_23_land_2013, 'forecast.ss', fsep = fsep)
#  Fore23_land_2013 <-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )

# clean environment
var.to.save <- c(var.to.save, 'Fore23_land_2013')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# If you are done with your implementations, you can now run this new model

# *********************************************************** #
# 4.5  Run the new model using the new input files ----
# ======================= #
run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =Dir_23_land_2013,
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the23.land.2013folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[2], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )

# 4.6  Let's plot the outputs from this model ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_land_2013, 'run', fsep = fsep)

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
# This can be done using the 1.1_Landings_Sensitivity_Outputs.R script.


# -----------------------------------------------------------
# -----------------------------------------------------------


