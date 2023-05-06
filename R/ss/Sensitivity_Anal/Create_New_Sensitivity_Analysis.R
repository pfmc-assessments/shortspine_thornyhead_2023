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
#NewSensAnal(topic = "model",
#            # names are based on new model 
#            object = c("Update Terminal RecDev Year", "Update Initial RecDev Year", "S-R Steepness", "Bias Adjustment Years" ),
#            author = "Team Thornyheads",
#            folder_name = "Explore_RecDevs",
#            script_model = "Explore_RecDevs_Analyses",
#            script_results = "Explore_RecDevs_Outputs",
#            base_model = c("23.mortality.update", "23.model.recdevs_termYear", "23.model.recdevs_initYear", 
#                           "23.model.recdevs_steep"),
#            new_model = c("23.model.recdevs_termYear", "23.model.recdevs_initYear", "23.model.recdevs_steep",
#                          "23.model.recdevs_bias"))

# Fleet Structure models
# NewSensAnal(topic = "model",
#             # names are based on new model 
#             object = c("ThreeFleets_NoSlope_SplitTriennial", "ThreeFleets_UseSlope_CombineTriennial", "FourFleets_UseSlope_CombineTriennial", "FourFleets_NoSlope_CombineTriennial", "ThreeFleets_NoSlope_CombineTriennial" ),
#             author = "Team Thornyheads",
#             folder_name = "Explore_FleetStructure",
#             script_model = "Explore_FleetStructure_Analyses",
#             script_results = "Explore_FleetStructure_Outputs",
#             base_model = c("23.model.recdevs_bias", "23.model.recdevs_bias", "23.model.recdevs_bias", 
#                            "23.model.recdevs_bias", "23.model.recdevs_bias"),
#             new_model = c("23.model.fleetstruct_1", "23.model.fleetstruct_2", "23.model.fleetstruct_3",
#                           "23.model.fleetstruct_4", "23.model.fleetstruct_5"))

# Francis Reweighting
# NewSensAnal(topic = "model",
#             # names are based on new model 
#             object = c("Francis Reweighting"),
#             author = "Team Thornyheads",
#             folder_name = "Francis_Reweighting",
#             script_model = "Francis_Reweighting_Analyses",
#             script_results = "Francis_Reweighting_Outputs",
#             base_model = c("23.model.fleetstruct_5"),
#             new_model = c("23.model.francis"))


# NewSensAnal(topic = "model",
#             # names are based on new model
#             object = c("Survey Timing", "Settlement Events"),
#             author = "Team Thornyheads",
#             folder_name = "SS_Model_Warnings",
#             script_model = "SS_Model_Warnings_Analyses",
#             script_results = "SS_Model_Warnings_Outputs",
#             base_model = c("23.model.francis", "23.model.survey_timing"),
#             new_model = c("23.model.survey_timing", "23.model.settlement_events"))

#NewSensAnal(topic = "model",
#            # names are based on new model
#            object = c("Remove small sample size LCs", "Sex-Specific Survey Selectivity", "Improve Trawl_N LC Fit", "Improve Other LC Fits"),
#            author = "Team Thornyheads",
##            folder_name = "Improve_LC_Fits",
#            script_model = "Improve_LC_Fits_Analyses",
#            script_results = "Improve_LC_Fits_Outputs",
#            base_model = c("23.model.settlement_events", "23.model.sample_sizes", "23.model.sexed_survey_selectivity", "23.model.improve_trawln"),
#            new_model = c("23.model.sample_sizes", "23.model.sexed_survey_selectivity", "23.model.improve_trawln", "23.model.improve_other"))

# NewSensAnal(topic = "model",
#             # names are based on new model
#             object = c("Modify recdev init year"),
#             author = "Team Thornyheads",
#             folder_name = "Update_Recdevs_Inityear",
#             script_model = "Update_Recdevs_Inityear_Analyses",
#             script_results = "Update_Recdevs_Inityear_Outputs",
#             base_model = c("23.model.sexed_survey_selectivity"),
#             new_model = c("23.model.recdevs_inityear_1996"))

#NewSensAnal(topic = "model",
#            # names are based on new model
#            object = c("Fix warnings"),
#            author = "Team Thornyheads",
#            folder_name = "Fix_Warnings",
#            script_model = "Fix_Warnings_Analyses",
#            script_results = "Fix_Warnings_Outputs",
#            base_model = c("23.model.recdevs_inityear_1996"),
#            new_model = c("23.fix_warnings"))

#Growth sensitivity
#NewSensAnal(topic = "biological_Info",
            # names are based on new model
#            object = c("Growth Sensitivity High","Growth Sensitivity Low"),
#            author = "Sabrina Beyer and Jane Sullivan",
#            folder_name = "Growth_Sensitivity",
#            script_model = "Growth_Sensitivity_Analyses",
#            script_results = "Growth_Sensitivity_Outputs",
#            base_model = c("23.model.francis_2", "23.model.francis_2"),
#            new_model = c("23.growth.high", "23.growth.low"))

# #maturity sensitivity
# NewSensAnal(topic = "biological_Info",
#             # names are based on new model
#             object = c("PG maturity","Intermediate maturity curve"),
#             author = "Sabrina Beyer and Jane Sullivan",
#             folder_name = "Maturity_Sensitivity",
#             script_model = "Maturity_Sensitivity_Analyses",
#             script_results = "Maturity_Sensitivity_Outputs",
#             base_model = c("23.model.francis_2", "23.model.francis_2"),
#             new_model = c("23.maturity.pgcurve", "23.maturity.mix_curve"))


#landings sensitivity
#NewSensAnal(topic = "landings",
#            # names are based on new model
#            object = c("Imputed historical landings","2013 assessment landings"),
#            author = "Adam Hayes",
#            folder_name = "Landings_Sensitivity",
#            script_model = "Landings_Sensitivity_Analyses",
#            script_results = "Landings_Sensitivity_Outputs",
#            base_model = c("23.model.francis_2","23.model.francis_2"),
#            new_model = c("23.land.hist_impute","23.land.2013"))

#gamma vs ln error geostat indices sensitivity
#NewSensAnal(topic = "surveys",
#            # names are based on new model
#            object = c("gamma vs ln error"),
#            author = "Andrea Odell",
#            folder_name = "surveys_Sensitivity",
#            script_model = "surveys_Sensitivity_Analyses",
#            script_results = "surveys_Sensitivity_Outputs",
#            base_model = c("23.model.francis_2"),
#            new_model = c("23.surveys.gamvln"))

# Sensitivity analysis 
NewSensAnal(topic = "model",
            # names are based on new model
            object = c("blk Trawl 89", "blk Trawl mid10",
                       "blk Trawl 89-mid10", "blk Trawl 89-mid10-19",
                       "blk Trawl 89-mid10 NonTrawl 05-13", "blk Trawl 89-mid10 NonTrawl 05-13-17"),
            author = "Pierre-Yves Hernvann",
            folder_name = "Retention_Selectivity_Sensitivity",
            script_model = "Retention_Sensitivity_Analyses",
            script_results = "Retention_Sensitivity_Outputs",
            base_model = c("23.model.francis_2", "23.model.francis_2",
                           "23.model.francis_2", "23.model.francis_2",
                           "23.model.francis_2", "23.model.francis_2"),
            new_model = c("23.blkret.T1", "23.blkret.T2",
                          "23.blkret.T3","23.blkret.T4",
                          "23.blkret.T3.NT1", "23.blkret.T3.NT2"))








