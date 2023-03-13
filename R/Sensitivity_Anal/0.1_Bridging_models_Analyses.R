# ============================================================ #
# Script used to develop the model(s) considered in the 
# sensitivity analysis: Item 0.1 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  transition 
# Specific item in that topic:  Param fixed Param estimated 
# Author:  Matthieu VERON 
# Date: 2023-03-13 12:49:00 
# Names of the models created:
# -  23.sq.fix 
# -  23.sq.est 
# *** 
# 
# This analysis has been developped based on the following models: 
# New model 	 Base model
# 23.sq.fix 	 23.sq.fixQ 
# 23.sq.est 	 23.sq.fixQ 
# 
# Results are stored in the following foler: 
#	 C:/Users/Matthieu Verson/Documents/GitHub/Forked_repos/shortspine_thornyhead_2023/model/Sensitivity_Anal/0.1_Bridging_models 
# 
# General features: 
# Revisiting the transition of the 2013 model considering i) a model where all the parameters are fixed to their estimated value from the 2013 assessment and ii) a second model where these parameters are freely estimated (those that were estimated in the 2013 assessment). 
# 
# Model features:
# - Model 23.sq.fix:
# Model with all parameters fixed to their values as estimated in the 2013 assessment. 
# - Model 23.sq.est:
# Model where parameters that were estimated in the 2013 assessment are freely estimated, using the same initial values, bounds and prior. 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# This script holds the code used to develop the models considered in this sensitivity analysis.
# For each model, the base model is modified using the r4ss package. 
# The new input files are then written in the root directory of each model and the 
# model outputs are stored in the '/run/' folder housed in that directory.
# The results of this sensitivity analysis are analyzed using the following script:
# C:/Users/Matthieu Verson/Documents/GitHub/Forked_repos/shortspine_thornyhead_2023/R/Sensitivity_Anal/0.1_Bridging_models_Outputs.R 

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

# Save directories and function
# save.dir <- c('dir_model', 
        # 'Exe_path',
        # 'dir_script',
        # 'dir_SensAnal') 
save.dir <- ls()
# ----------------------------------------------------------- 

#  3. Developing model 23.sq.fix  ----
# ----------------------------------------------------------- #

# Path to the 23.sq.fix repertory
Dir_23_sq_fix <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.fix' ,fsep = fsep)
# Add the model directory to the saved variables
save.dir <- c(save.dir, 'Dir_23_sq_fix') 


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_sq_fix, 'starter.ss', fsep = fsep)
Starter <- SS_readstarter(file = StarterFile,
          verbose = TRUE)

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
        mylist = Starter,
        dir =  Dir_23_sq_fix, 
        overwrite = TRUE,
        verbose = TRUE
      )

# Check file structure
StarterFile <- file.path(Dir_23_sq_fix, , 'starter.ss')
Starter <- SS_readstarter(file = StarterFile, verbose = TRUE)

# clean environment
var.to.save <- c(save.dir, 'Starter')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <- file.path(Dir_23_sq_fix, Starter$datfile, fsep = fsep)

      dat <-
        SS_readdat_3.30(file = DatFile,
                        verbose = TRUE,
                        section = TRUE)

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 


# Save the data file for the model
SS_writedat(
        datlist = dat,
        outfile = file.path(Dir_23_sq_fix, 'SST_data.ss', fsep = fsep),
        version = '3.30',
        overwrite = TRUE
      )
# Check file structure ----
DatFile <- file.path(Dir_23_sq_fix, 'SST_data.ss', fsep = fsep)
SSTdat_V330 <-
        SS_readdat_3.30(file = DatFile,
                        verbose = TRUE,
                        section = TRUE)
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existance of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.

# Read in the file
Ctlfile <- file.path(Dir_23_sq_fix, Starter$ctlfile, fsep = fsep)
ctl <- SS_readctl_3.30(
        file = Ctlfile,
        use_datlist = TRUE,
        datlist = file.path(Dir_23_sq_fix, 'run','data_echo.ss_new', fsep = fsep),
        verbose = TRUE
      )

# Make your modification if applicable
# Code modifying the control file 
# ..... 
# ..... 


# Save the control file for the model
SS_writectl(
        ctllist = ctl,
        outfile = file.path(Dir_23_sq_fix, 'SST_control.ss'),
        version = '3.30',
        overwrite = TRUE
      )
# Check file structure ----
# We actually need to run the model to check the file structure
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_sq_fix, 'forecast.ss', fsep = fsep)
Forec <-
        SS_readforecast(
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
        mylist = Forec,
        dir = Dir_23_sq_fix, 
        file = 'forecast.ss',
        writeAll = TRUE,
        verbose = TRUE,
        overwrite = TRUE
      )
# Check file structure ----
ForeFile <- file.path(Dir_23_sq_fix, 'forecast.ss', fsep = fsep)
Forec <-
        SS_readforecast(
          file = ForeFile,
          version = '3.30',
          verbose = T,
          readAll = T
        )
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# You are now ready to run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(
        SS_version = '3.30.21',
        # version of SS
        base_path = file.path(Dir_23_sq_fix, 
        # root directory where the input file are housed
        pathRun = NULL,
        # A 'run' folder is created if needed (where output files will be stored)
        copy_files = TRUE,
        # copy the input files from the 23.sq.fix folder
        cleanRun = TRUE
        # clean the folder after the run
      )

# 3.  Let's plot the outputs from this model ----
# Making the default plots ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_sq_fix,  'run', fsep = fsep)

replist <- SS_output(
        dir = Dirplot,
        verbose = TRUE,
        printstats = TRUE
      )

# plots the results (store in the 'plots' sub-directory)
SS_plots(replist,
               dir = Dirplot,
               printfolder = 'plots')

# *********************************************************** #


# -----------------------------------------------------------
# -----------------------------------------------------------

# You can now develop the next 'new model'.

# -----------------------------------------------------------
# -----------------------------------------------------------
#  3. Developing model 23.sq.est  ----
# ----------------------------------------------------------- #

# Path to the 23.sq.est repertory
Dir_23_sq_est <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.est' ,fsep = fsep)
# Add the model directory to the saved variables
save.dir <- c(save.dir, 'Dir_23_sq_est') 


# 3.1  Work on the Starter file ----
# ======================= #
# Read in the file
StarterFile <- file.path(Dir_23_sq_est, 'starter.ss', fsep = fsep)
Starter <- SS_readstarter(file = StarterFile,
          verbose = TRUE)

# Make your modification if applicable
# Code modifying the starter file
# ..... 
# ..... 


# Save the starter file for the model
SS_writestarter(
        mylist = Starter,
        dir =  Dir_23_sq_est, 
        overwrite = TRUE,
        verbose = TRUE
      )

# Check file structure
StarterFile <- file.path(Dir_23_sq_est, , 'starter.ss')
Starter <- SS_readstarter(file = StarterFile, verbose = TRUE)

# clean environment
var.to.save <- c(save.dir, 'Starter')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.2  Work on the data file ----
# ======================= #
# Read in the file
DatFile <- file.path(Dir_23_sq_est, Starter$datfile, fsep = fsep)

      dat <-
        SS_readdat_3.30(file = DatFile,
                        verbose = TRUE,
                        section = TRUE)

# Make your modification if applicable
# Code modifying the data file 
# ..... 
# ..... 


# Save the data file for the model
SS_writedat(
        datlist = dat,
        outfile = file.path(Dir_23_sq_est, 'SST_data.ss', fsep = fsep),
        version = '3.30',
        overwrite = TRUE
      )
# Check file structure ----
DatFile <- file.path(Dir_23_sq_est, 'SST_data.ss', fsep = fsep)
SSTdat_V330 <-
        SS_readdat_3.30(file = DatFile,
                        verbose = TRUE,
                        section = TRUE)
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.3  Work on the control file ----
# ======================= #
# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existance of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.

# Read in the file
Ctlfile <- file.path(Dir_23_sq_est, Starter$ctlfile, fsep = fsep)
ctl <- SS_readctl_3.30(
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
SS_writectl(
        ctllist = ctl,
        outfile = file.path(Dir_23_sq_est, 'SST_control.ss'),
        version = '3.30',
        overwrite = TRUE
      )
# Check file structure ----
# We actually need to run the model to check the file structure
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# 3.4  Work on the forecast file ----
# ======================= #

# Read in the file
ForeFile <- file.path(Dir_23_sq_est, 'forecast.ss', fsep = fsep)
Forec <-
        SS_readforecast(
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
        mylist = Forec,
        dir = Dir_23_sq_est, 
        file = 'forecast.ss',
        writeAll = TRUE,
        verbose = TRUE,
        overwrite = TRUE
      )
# Check file structure ----
ForeFile <- file.path(Dir_23_sq_est, 'forecast.ss', fsep = fsep)
Forec <-
        SS_readforecast(
          file = ForeFile,
          version = '3.30',
          verbose = T,
          readAll = T
        )
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()
# =======================

# You are now ready to run this new model

# *********************************************************** #
# 3.5  Run the new model using the new input files ----
# ======================= #
run_SS(
        SS_version = '3.30.21',
        # version of SS
        base_path = file.path(Dir_23_sq_est, 
        # root directory where the input file are housed
        pathRun = NULL,
        # A 'run' folder is created if needed (where output files will be stored)
        copy_files = TRUE,
        # copy the input files from the 23.sq.est folder
        cleanRun = TRUE
        # clean the folder after the run
      )

# 3.  Let's plot the outputs from this model ----
# Making the default plots ----
# ======================= #
# read the model output and print diagnostic messages
Dirplot <- file.path(Dir_23_sq_est,  'run', fsep = fsep)

replist <- SS_output(
        dir = Dirplot,
        verbose = TRUE,
        printstats = TRUE
      )

# plots the results (store in the 'plots' sub-directory)
SS_plots(replist,
               dir = Dirplot,
               printfolder = 'plots')

# *********************************************************** #


# -----------------------------------------------------------
# -----------------------------------------------------------

# You are ready to analyze differences between the models 
# considered in this sensitivity analysis.

# -----------------------------------------------------------
# -----------------------------------------------------------
