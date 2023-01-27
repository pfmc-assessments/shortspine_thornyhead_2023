# Fishery landings
# Contact: (POCs)
# Last updated: January 2023

# devtools::session_info()
# R version 4.2.0
# Platform: x86_64-w64-mingw32/x64 (64-bit)

# set up ----

# install.packages("dplyr")
# install.packages("remotes")
# remotes::install_github("pfmc-assessments/PacFIN.Utilities")
library(PacFIN.Utilities)
library(dplyr)

# IMPORTANT:  everything in this folder is not tracked on github. this includes
# raw catch, data that identifies fishing locations, fishing trips, individual
# vessels, processors, or individuals. If you are uncertain of where
# fishery-dependent data should go, put it here!
dir.create('data/fishery_confidential') 

# everything in this folder is processed (aggregated to >= 3 vessels,
# processors, etc.). Ideally, this folder would only include fishery landings,
# length comps, and discard information that has already been processed and is
# ready for input to SS3
dir.create('data/fishery_processed')

# "catch" refers to landed catch
confidential_catch_path <- 'data/fishery_confidential/landed_catch'; dir.create(confidential_catch_path)
processed_catch_path <- 'data/fishery_processed/landed_catch'; dir.create(processed_catch_path)
