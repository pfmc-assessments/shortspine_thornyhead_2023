# ============================================================ #
# Script used to analyze and compare the model(s) considered in the 
# sensitivity analysis: Item 5.5 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic:  Remove small sample size LCs Sex-Specific Survey Selectivity Improve Trawl_N LC Fit Improve Other LC Fits 
# 	- Remove small sample size LCs 
# 	- Sex-Specific Survey Selectivity 
# 	- Improve Trawl_N LC Fit 
# 	- Improve Other LC Fits 
# Author:  Team Thornyheads 
# Date: 2023-04-20 13:16:01 
# Names of the models created:
# -  23.model.sample_sizes 
# -  23.model.sexed_survey_selectivity 
# -  23.model.improve_trawln 
# -  23.model.improve_other 
# *** 
# 
# This analysis has been developed based on the following models: 
# New model 	 Base model
# 23.model.sample_sizes 	 23.model.settlement_events 
# 23.model.sexed_survey_selectivity 	 23.model.sample_sizes 
# 23.model.improve_trawln 	 23.model.sexed_survey_selectivity 
# 23.model.improve_other 	 23.model.improve_trawln 
# 
# Results are stored in the following foler: 
#	 /Users/jzahner/Desktop/Projects/shortspine_thornyhead_2023/model/Sensitivity_Anal/5.5_Improve_LC_Fits 
# 
# General features: 
# Improve fits to length composition data by modifying estimated selectivity parameters and remove poor data. This includes removing LCs where sample sizes are <11.5, using sex-specific selectivities for survey length comps, and modifying selectivity pars for the fisheries fleets. 
# 
# Model features:
# - Model 23.model.sample_sizes:
# 23.model.settlement_events + remove small sample size LCs 
# - Model 23.model.sexed_survey_selectivity:
# 23.model.sample_sizes + use sex-specific survey selectivities 
# - Model 23.model.improve_trawln:
# 23.model.sexed_survey_selectivity + improve Trawl_N fits 
# - Model 23.model.improve_other:
# 23.model.improve_trawln + improve fits to other fleet LCs 
# ============================================================ #

# ------------------------------------------------------------ #
# ------------------------------------------------------------ #

# The results of the model run have been plot in the 'plots' sub-directory of 
# the 'run' folder. The comparison plots between models for the sensitivity analysis will be
# stored in the 'SA_plots' folder housed in the root directory of this sensitivity analysis.

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
var.to.save <- ls()
# ----------------------------------------------------------- 

# 3.4  Make comparison plots between models ----
# ======================= #

# Use the SSgetoutput() function that apply the SS_output()
# to get the outputs from different models


# Path to the base model (23.model.settlement_events) repertory
Dir_Base23_model_settlement_events <- file.path(dir_SensAnal, '5.4_SS_Model_Warnings','2_23.model.settlement_events' , 'run',fsep = fsep)


# Path to the base model (23.model.sample_sizes) repertory
Dir_Base23_model_sample_sizes <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','1_23.model.sample_sizes' , 'run',fsep = fsep)


# Path to the base model (23.model.sexed_survey_selectivity) repertory
Dir_Base23_model_sexed_survey_selectivity <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','2_23.model.sexed_survey_selectivity' , 'run',fsep = fsep)


# Path to the base model (23.model.improve_trawln) repertory
Dir_Base23_model_improve_trawln <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','3_23.model.improve_trawln' , 'run',fsep = fsep)


# Root directory for this sensitivity analysis
SA_path <- .
# Path to the 23.model.sample_sizes repertory
Dir_23_model_sample_sizes <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','1_23.model.sample_sizes' , 'run',fsep = fsep)

# Path to the 23.model.sexed_survey_selectivity repertory
Dir_23_model_sexed_survey_selectivity <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','2_23.model.sexed_survey_selectivity' , 'run',fsep = fsep)

# Path to the 23.model.improve_trawln repertory
Dir_23_model_improve_trawln <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','3_23.model.improve_trawln' , 'run',fsep = fsep)

# Path to the 23.model.improve_other repertory
Dir_23_model_improve_other <- file.path(dir_SensAnal, '5.5_Improve_LC_Fits','4_23.model.improve_other' , 'run',fsep = fsep)

# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = c(Dir_Base23_model_settlement_events,Dir_Base23_model_sample_sizes,Dir_Base23_model_sexed_survey_selectivity,Dir_Base23_model_improve_trawln,Dir_23_model_sample_sizes,Dir_23_model_sexed_survey_selectivity,Dir_23_model_improve_trawln,Dir_23_model_improve_other))

# Rename the list holding the report files from each model
names(SensiMod)
names(SensiMod) <- c('23.model.settlement_events','23.model.sample_sizes','23.model.sexed_survey_selectivity','23.model.improve_trawln','23.model.sample_sizes','23.model.sexed_survey_selectivity','23.model.improve_trawln','23.model.improve_other')

# summarize the results
Version_Summary <- SSsummarize(SensiMod)

# make plots comparing the models
SSplotComparisons(
      Version_Summary,
      # print = TRUE,
      pdf = TRUE,
      plotdir = file.path(SA_path, 'SA_plots', fsep = fsep),
      legendlabels = c('23.model.settlement_events','23.model.sample_sizes','23.model.sexed_survey_selectivity','23.model.improve_trawln','23.model.sample_sizes','23.model.sexed_survey_selectivity','23.model.improve_trawln','23.model.improve_other')
    )

# Create comparison table for this analisys
# ####################################### #

SStableComparisons(Version_Summary)

tmp <- purrr::transpose(SensiMod)$parameters %>% 
  purrr::map_df(~as_tibble(.x), .id = 'Model') %>% 
  dplyr::select(Model, Label, Value, Phase, Min, Max, Init, 
                Gradient, Pr_type, Prior, Pr_SD, Pr_Like, 
                LCI95 = `Value-1.96*SD`, UCI95 = `Value+1.96*SD`)

tmp %>% 
  write_csv(paste(SA_path, 'Update_Data_comparison_table_all_params.csv', sep = fsep))

tmp %>% 
  filter(grepl('LnQ|R0', Label)) %>%
  pivot_wider(id_cols = c(Label, Phase), names_from = Model, values_from = Value) %>%
  write_csv(paste(SA_path, 'Update_Data_comparison_table_lnQ_SRlnR0.csv', sep = fsep))

out <- SStableComparisons(Version_Summary)
names(out) <- c('Label', unique(tmp$Model))

out %>% 
  write_csv(paste(SA_path, 'Update_Data_comparison_table_likelihoods_and_brps.csv', sep = fsep))
