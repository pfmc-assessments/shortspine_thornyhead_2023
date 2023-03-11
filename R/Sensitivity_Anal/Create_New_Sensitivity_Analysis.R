# Create a new Sensitivity analysis
# Author: Matthieu VERON
# Contact: mveron@uw.edu

# This script can be used to create a new sensitivity analysis.
# Functions used are hold in the script "R/utils/sensistivity_analysis_utils.R"
# The NewSensAnal() function is the main function to use when creating a new sensitivity
# analysis.
# ============================================================================ #
# ============================================================================ #
#'
#' The function creates:
#' 1. one folder named as specified in the folder_name argument. This folder is
#'    stored in the "shortspine_thornyhead_2023/model/Sensitivity_Anal" repertory. 
#'    It will house the model input and output files,
#' 2. the "Sensitivity_Analysis_Features.txt" file (in the previously created folder).
#'    This file summaryzes the features of the sensitivity analysis
#'    (\code{topic}, \code{object}, \code{author}, ...)
#' 3. Update the "Sensitivity_analysis.pdf" file housed in the root folder 
#'    ("shortspine_thornyhead_2023/model/Sensitivity_Anal")
#'    
#' @param topic (character string)- Indicates the main topic of the sensitivity 
#' analysis. This HAS to be either "landings", "discards", "surveys",
#' "biological_Info", or "model".
#' @param object (character string)- Indicates a specific item of 
#' the main topic. For example, "Length_Comp", "Age_comp", "Growth", "Fecundity",...
#' @param author (character string)- Who leads the sensitivity analysis and runs
#' the model.
#' @param folder_name (character string)- name of the folder to create for that 
#' particular sensitivity analysis. This folder will be housed in the root folder 
#' 'Sensitivity_Anal' and will hold the scipts  used to set up the model and both 
#' models input and output files for this analysis.
#' @param script_model (character string)- Name of the script used to create the 
#' model.
#' @param script_results (character string)- Name of the script used to analyze 
#' the results from that sensitivty analysis.
#' @param base_model (character string)- which model has been used as the basis 
#' of this analysis (before any modification).
#' @param new_model (character string)- name of the model you're gonna develop for
#' this analysis.
#' 
# ============================================================================ #
# ============================================================================ #


rm(list = ls(all.names = TRUE))

# 1. Set up ----
# ---------------------------------------------------------- #
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

# load functions ----
source(file.path(dir_script, "utils", "sensistivity_analysis_utils.R", fsep = fsep))

# ----------------------------------------------------------


# 2. Set up a new sensitivity analysis ----
# ---------------------------------------------------------- #

NewSensAnal(topic = "model",
            object = "Bridging analysis",
            author = "Matthieu VERON",
            folder_name = "Bridging_models",
            script_model = "Bridging_models_Analyses",
            script_results = "Bridging_models_Outputs",
            base_model = "SST_M0",
            new_model = "SST_M1")
