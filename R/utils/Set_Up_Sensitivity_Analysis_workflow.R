# Sensitivity analysis workflow
# Author: Matthieu VERON
# Contact: mveron@uw.edu

# This script houses the material needed for the sensitivity analysis
# workflow when running different model of SS.


rm(list = ls(all.names = TRUE))

# 1. Set up ----

# load packages ----
library(kableExtra)

# Local declarations ----
fsep <- .Platform$file.sep

# Set directories ----
dir_model <- file.path(here::here(), "model", fsep = fsep)
dir_script <- file.path(here::here(), "R", fsep = fsep)


# Set up the Sensitivity Analysis root folders ----
dir_SensAnal <- file.path(dir_model, "Sensitivity_Anal", fsep = fsep)
dirScript_SensAnal  <- file.path(dir_script, "Sensitivity_Anal", fsep = fsep)

if(!dir.exists(dir_SensAnal))
  dir.create(dir_SensAnal)
if(!dir.exists(dirScript_SensAnal))
  dir.create(dirScript_SensAnal)

# load functions ----
source(file.path(dir_script, "utils", "sensistivity_analysis_utils.R", fsep = fsep))
# ----------------------------------------------------------

# 2. Create pdf file that summarize the SA already done ----
# ---------------------------------------------------------- #

if(!file.exists(file.path(dir_SensAnal, "Sensitivity_analysis.pdf", fsep = fsep))){
  Topic <- data.frame(
    Topic = c("landings", "discards", "surveys", "biological_Info", "model"),
    Nam = c("1. Landings", "2. Discards", "3. Surveys", "4. Biological Info", "5. Model"),
    ID = 1:5) 
  
  SA_info <- data.frame(matrix("", nrow = length(Topic$Topic), ncol = 10))
  colnames(SA_info) <- c("Topic","Object",'Author',"Date",
                         "Folder","Script model","Script results",
                         "Base model","New model", "Features")
  SA_info$Topic <- Topic$Topic
  SA_info$Object <- c("Item 1.1", "Item 2.1","Item 3.1","Item 4.1","Item 5.1")
  
  
  SA_info <- update_SA_table(SA_info = SA_info, dir_SensAnal = dir_SensAnal)
  SA_info <- SA_info[1,]
  SA_info[1,] <- c("")
  
  if(!file.exists(file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep)))
    save(SA_info, file = file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
}
# ----------------------------------------------------------

