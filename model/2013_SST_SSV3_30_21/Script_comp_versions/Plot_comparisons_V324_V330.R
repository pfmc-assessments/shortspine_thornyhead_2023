# Comparing Shortspine Thornyhead 2013 model (SS V3.24) with SS V3.30.21
# Matthieu VERON - @: mveron@uw.edu
# Last updated: February 2013

# The transition has been realized using the "Transition_SST_From_V324_To_V330.R"
# script.

# This script  realized the comparison between the two version of the 2013 model
# It uses functions from the r4ss package.

rm(list = ls(all.names = TRUE))

# 1. Update r4ss ----

update <- FALSE

if (update) {
  # Indicate the library directory to remove the r4ss package from
  mylib <- "~/R/win-library/4.1"
  remove.packages("r4ss", lib = mylib)
  # Install r4ss from GitHub
  remotes::install_github("r4ss/r4ss")
}
# -----------------------------------------------------------

# 2. Set up ----

# packages
library(r4ss)

# Directories
dirBase <- getwd()
# Path to the Executable folder
Exe_path <- file.path(dirBase, "Executables")
# Path to the old SST model (i.e. the 2013 model using SS V3.24)
oldSST_path <- file.path(dirBase, "model/2013_SST/base_model_files")
# Path to the new SST model (i.e. the 2013 model using SS V3.30.21)
SST_path <- file.path(dirBase, "model/2013_SST_SSV3_30_21")

save.dir <- c('dirBase',
              'Exe_path',
              'oldSST_path',
              'SST_path')

# Local declaration
fsep <- .Platform$file.sep #easy for file.path() function

# Useful function
source(file.path(getwd(), "R/utils/clean_functions.R", fsep = fsep))

# -----------------------------------------------------------



# 1. Run the models ----
# ----------------------------------------------------------- #

# ==================================================== #
# Reminder: All executables are stored in the
# "Executables" folder.
# The choice of the .exe to use depends on:
# i. the version of SS you want to work with
# ii. the OS you are working on
# Here this script is set up for a windows machine
# ==================================================== #

# Run the SS V3.24 version of the SST 2013 model

# Directory where the executable is stored
pathExeV324 <-
  file.path(Exe_path, "SS_V3_24_U/SSv3.24U_Win64", fsep = fsep)
# Name of the executable to work with
nameExeV324 <- "ss3_opt_win64.exe"
# run SS
r4ss::run(
  dir = oldSST_path,
  exe = file.path(pathExeV324, nameExeV324, fsep = fsep),
  verbose = TRUE,
  skipfinished = FALSE
)


# Run the SS V3.30.21 version of the SST 2013 model

# Directory where the executable is stored
pathExeV330 <- file.path(Exe_path, "SS_V3_30_21", fsep = fsep)
# Name of the executable to work with
nameExeV330 <- "ss_win.exe"

# Let's copy the file from the transition to the run folder
SST_pathRUN <- file.path(SST_path, "run", fsep = fsep)
if (!dir.exists(SST_pathRUN))
  dir.create(SST_pathRUN)

# Find the SS input files
SS.files <- list.files(path = SST_path,
                       pattern = glob2rx("*.ss"),
                       full.names = FALSE)
file.copy(
  from = file.path(SST_path, SS.files, fsep = fsep),
  to = file.path(SST_pathRUN, SS.files, fsep = fsep),
  overwrite = TRUE
)

# run SS
r4ss::run(
  dir = SST_pathRUN,
  exe = file.path(pathExeV330, nameExeV330, fsep = fsep),
  verbose = TRUE,
  skipfinished = FALSE
)

# -----------------------------------------------------------


# 2. Establish comparisons ----
# ----------------------------------------------------------- #

# Use the SSgetoutput() function that apply the SS_output()
# to get the outputs from the two versions
SST_Vs <- SSgetoutput(dirvec = c(oldSST_path, SST_pathRUN))
# SST_Vs is a named list with the report files from each version
names(SST_Vs)
names(SST_Vs) <- c('V3_24', 'V3.30')

# summarize the version results
Version_Summary <- SSsummarize(SST_Vs)

# make plots comparing the 2 versions
SSplotComparisons(
  Version_Summary,
  pdf = TRUE,
  plotdir = SST_path,
  legendlabels = c('V3_24', 'V3.30')
)
