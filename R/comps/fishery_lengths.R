# PacFIN fishery length data expansion
# Contact: (POCs)
# Last updated: January 2023

# devtools::session_info()
# R version 4.2.0
# Platform: x86_64-w64-mingw32/x64 (64-bit)

# see Assessment_Class/code/process_pacfin_bds_example.R

# PacFIN.Utilities::cleanPacFIN() function converts fishery lengths from mm to
# cm, so when converting lengths to weights, use allometric parameters that are
# estimated using length in cm

# set up ----

libs <- c('readr', 'dplyr', 'tidyr', 'ggplot2', 'ggthemes', 'ggridges', 'cowplot')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

# remotes::install_github('pfmc-assessments/PacFIN.Utilities')
# remotes::install_github('pfmc-assessments/nwfscSurvey')
library(PacFIN.Utilities)
library(nwfscSurvey)

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

confidential_fshlen_path <- 'data/fishery_confidential/lengths'; dir.create(confidential_fshlen_path)
processed_fshlen_path <- 'data/fishery_processed/lencomps'; dir.create(processed_fshlen_path)

# This file will be updated in-season. Best practice is to save previous
# versions and date the files accordingly
bds_file <- 'data/fishery_confidential/PacFIN.SSPN.bds.17.Jan.2023.Rdata'

load(bds_file)
bds <- bds.pacfin
rm(bds.pacfin)

# The cleanPacFIN function retains records that are
# randomly collected based on sampling protocols, removes
# any age reads that don't align with the keep_age_methods
# (e.g., sets the ages to NA), retains only records in the 
# U.S., and other various data factors
Pdata <- cleanPacFIN(Pdata = bds,
                     keep_age_method = NULL, # c("B", "BB", 1),
                     CLEAN = TRUE, 
                     verbose = TRUE)

# N SAMPLE_TYPEs changed from M to S for special samples from OR: 0
# N not in keep_sample_type (SAMPLE_TYPE): 2444
# N with SAMPLE_TYPE of NA: 0
# N not in keep_sample_method (SAMPLE_METHOD): 32
# N with SAMPLE_NO of NA: 0
# N without length: 2403
# N without Age: 158238
# N without length and Age: 158238
# N sample weights not available for OR: 903
# N records: 158268
# N remaining if CLEAN: 155507
# N removed if CLEAN: 2761