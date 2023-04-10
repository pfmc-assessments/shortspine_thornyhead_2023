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
#' 1. one folder named as \code{folder_name} in the 
#'    "shortspine_thornyhead_2023/model/Sensitivity_Anal" repertory. This folder will
#'    house model input and output files,
#' 2. the "Sensitivity_Analysis_Features.txt" file (in the previously created folder).
#'    This file summaryzes the features of the sensitivity analysis 
#'    (\code{topic}, \code{object}, \code{author}, ...)
#' 3. Update the "Summary_Sensitivity_analysis.pdf" file housed in the root folder.
#' 4. Update the "Models_Sensitivity_analysis.pdf" file housed in the root folder.
#' 5. Generate SA-specific templates for the scripts to build and analyze the models.
#'    
#' @param topic (character string)- Indicates the main topic of the sensitivity 
#' analysis. This HAS to be either"transition",  "landings", "discards", "surveys",
#' "biological_Info", or "model".
#' @param object (character string)- Indicates a specific item of 
#' the main topic/model. For example, "Length_Comp", "Age_comp", "Growth", "Fecundity",...
#' If multiple models are built, the length of \code{object} equals the numder of
#' models with a specific input for each model.
#' @param author (character string)- Who leads the sensitivity analysis and runs
#' the model.
#' @param folder_name (character string)- name of the folder to create for that 
#' particular sensitivity analysis. This folder will be housed in the root folder 
#' 'Sensitivity_Anal' and will hold the scripts  used to set up the model and both 
#' models input and output files for this analysis.
#' @param script_model (character string)- Name of the script used to create the 
#' model (without extension).
#' @param script_results (character string)- Name of the script used to analyze 
#' the results from that sensitivity analysis  (without extension).
#' @param base_model (character string)- which model has been used as the basis 
#' of this analysis (before any modification). By default, the function considers
#' the 2013 Assessment model transitioned to the 3.30 version of SS with all
#' parameters estimated i.e., \code{"23.sq.est"}(See "Models_Sensitivity_analysis.pdf")
#' @param new_model (character string)- name of the model you're gonna develop for
#' this analysis.
#' 
# ============================================================================ #
# ============================================================================ #


rm(list = ls(all.names = TRUE))

# 1. Set up ----
# ---------------------------------------------------------- #
# load packages ----

updateKableExtra <- FALSE # Needed the first time

if(updateKableExtra)
  devtools::install_github(repo="haozhu233/kableExtra", ref="a6af5c0")
library(kableExtra)

# Local declarations ----
fsep <- .Platform$file.sep

# Set directories ----
dir_model <- file.path(here::here(), "model", fsep = fsep)
dir_script <- file.path(here::here(), "R", fsep = fsep)


# Set up the Sensitivity Analysis root folders ----
dir_SensAnal <- file.path(dir_model, "Sensitivity_Anal", fsep = fsep)
dirScript_SensAnal  <- file.path(dir_script, "ss", "Sensitivity_Anal", fsep = fsep)

# load functions ----
source(file.path(dir_script, "utils", "sensistivity_analysis_utils.R", fsep = fsep))

# ----------------------------------------------------------


# 2. Set up a new sensitivity analysis ----
# ---------------------------------------------------------- #


# NewSensAnal(topic = "transition",
#             object = c("All Param fixed","Floating Q", "All Param estimated"),
#             author = "Matthieu VERON",
#             folder_name = "Bridging_models",
#             script_model = "Bridging_models_Analyses",
#             script_results = "Bridging_models_Outputs",
#             base_model = c("23.sq.fixQ"),
#             new_model = c("23.sq.fix","23.sq.floatQ","23.sq.est"))

# we're keeping simple data updates as topic == 'transition'

# Bridging models 
# NewSensAnal(topic = "transition",
#             # names are based on new model 
#             object = c("Update landings","Updates discard rates", "Update survey indices",
#                        "Update survey length comps", "Update fisheries length comps", 
#                        "Update discard mean weights", "Update growth", "Update maturity",
#                        "Update fecundity", "Update natural mortality"),
#             author = "Team Thornyheads",
#             folder_name = "Update_Data",
#             script_model = "Update_Data_Analyses",
#             script_results = "Update_Data_Outputs",
#             base_model = c("23.sq.floatQ", "23.land.update", "23.disc.update", 
#                            "23.surv_db.update", "23.lcs_survey.update", "23.lcs_fisheries.update", 
#                            "23.disc_weight.update", "23.growth.update", "23.maturity.update", 
#                            "23.fecundity.update"),
#             new_model = c("23.land.update", "23.disc.update", "23.surv_db.update",
#                           "23.lcs_survey.update", "23.lcs_fisheries.update", "23.disc_weight.update",
#                           "23.growth.update", "23.maturity.update", "23.fecundity.update", 
#                           "23.mortality.update"))

# Begin model exploration 
NewSensAnal(topic = "model",
            # names are based on new model 
            object = c("Update Terminal RecDev Year", "Update Initial RecDev Year", "S-R Steepness", "Bias Adjustment Years" ),
            author = "Team Thornyheads",
            folder_name = "Explore_RecDevs",
            script_model = "Explore_RecDevs_Analyses",
            script_results = "Explore_RecDevs_Outputs",
            base_model = c("23.mortality.update", "23.model.recdevs_termYear", "23.model.recdevs_initYear", 
                           "23.model.recdevs_steep"),
            new_model = c("23.model.recdevs_termYear", "23.model.recdevs_initYear", "23.model.recdevs_steep",
                          "23.model.recdevs_bias"))
