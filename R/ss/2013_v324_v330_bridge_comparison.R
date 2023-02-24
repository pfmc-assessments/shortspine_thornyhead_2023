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

fsep <- .Platform$file.sep #easy for file.path() function

# packages
library(r4ss)

# Useful function
source(file=file.path(here::here(), "R/utils/clean_functions.R", fsep = fsep))
source(file=file.path(here::here(), "R/utils/ss_utils.R", fsep=fsep))

# Directories
dirBase <- here::here()
# Path to the old SST model (i.e. the 2013 model using SS V3.24)
oldSST_path <- file.path(dirBase, "model/2013_SST")
# Path to the new SST model (i.e. the 2013 model using SS V3.30.21)
SST_path <- file.path(dirBase, "model/2013_SST_SSV3_30_21")
SST_pathRUN <- file.path(SST_path, "run", fsep = fsep)

save.dir <- c('dirBase',
              'oldSST_path',
              'SST_path')

# Local declaration


# -----------------------------------------------------------

# 1. Run the models ----
# ----------------------------------------------------------- #

# ==================================================== #
# Reminder: All executables are stored in the
# "model/ss_executables" folder.
# The choice of the .exe to use depends on:
# i. the version of SS you want to work with
# ii. the OS you are working on
# Here this script is set up for a windows machine
# ==================================================== #

# Run the SS V3.24 version of the SST 2013 model

# Directory where the executable is stored
ss_exe_324 <- get.ss.exe.path(ss_version="3.24.U", fname.extra = "safe")

r4ss::run(
  dir = oldSST_path,
  exe = ss_exe_324,
  verbose = TRUE,
  show_in_console = TRUE,
  skipfinished = FALSE
)
clean_bat(oldSST_path)


# Run the SS V3.30.21 version of the SST 2013 model
ss_exe_330 <- get.ss.exe.path(ss_version="3.30.21")

# Let's copy the file from the transition to the run folder
if (!dir.exists(SST_pathRUN)){
  dir.create(SST_pathRUN)
}

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
  dir = SST_path,
  exe = ss_exe_330,
  verbose = TRUE,
  skipfinished = FALSE,
  show_in_console = TRUE
)
clean_bat(SST_path)

# -----------------------------------------------------------


# 2. Establish comparisons ----
# ----------------------------------------------------------- #

# Use the SSgetoutput() function that apply the SS_output()
# to get the outputs from the two versions
SST_Vs <- SSgetoutput(dirvec = c(oldSST_path, SST_pathRUN))
# SST_Vs is a named list with the report files from each version
names(SST_Vs)
names(SST_Vs) <- c('V3.24', 'V3.30')

# summarize the version results
Version_Summary <- SSsummarize(SST_Vs)

# make plots comparing the 2 versions
SSplotComparisons(
  Version_Summary,
  print = TRUE,
  plotdir = SST_path,
  legendlabels = c('V3_24', 'V3.30')
)
