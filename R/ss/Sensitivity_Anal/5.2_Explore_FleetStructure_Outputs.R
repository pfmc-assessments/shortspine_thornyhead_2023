# ============================================================ #
# Script used to analyze and compare the model(s) considered in the 
# sensitivity analysis: Item 5.2 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic:  ThreeFleets_NoSlope_SplitTriennial ThreeFleets_UseSlope_CombineTriennial FourFleets_UseSlope_CombineTriennial FourFleets_NoSlope_CombineTriennial ThreeFleets_NoSlope_CombineTriennial 
# 	- ThreeFleets_NoSlope_SplitTriennial 
# 	- ThreeFleets_UseSlope_CombineTriennial 
# 	- FourFleets_UseSlope_CombineTriennial 
# 	- FourFleets_NoSlope_CombineTriennial 
# 	- ThreeFleets_NoSlope_CombineTriennial 
# Author:  Team Thornyheads 
# Date: 2023-04-13 13:36:07 
# Names of the models created:
# -  23.model.fleetstruct_1 
# -  23.model.fleetstruct_2 
# -  23.model.fleetstruct_3 
# -  23.model.fleetstruct_4 
# -  23.model.fleetstruct_5 
# *** 
# 
# This analysis has been developed based on the following models: 
# New model 	 Base model
# 23.model.fleetstruct_1 	 23.model.recdevs_bias 
# 23.model.fleetstruct_2 	 23.model.recdevs_bias 
# 23.model.fleetstruct_3 	 23.model.recdevs_bias 
# 23.model.fleetstruct_4 	 23.model.recdevs_bias 
# 23.model.fleetstruct_5 	 23.model.recdevs_bias 
# 
# Results are stored in the following foler: 
#	 /Users/andrea/Library/CloudStorage/Box-Box/StockSynthesis Course/shortspine_thornyhead_2023/model/Sensitivity_Anal/5.2_Explore_FleetStructure 
# 
# General features: 
# We are testing different possible combinations of fisheries fleet and surveys to potentially reduce model complexity 
# 
# Model features:
# - Model 23.model.fleetstruct_1:
# 23.model.recdevs_bias + Three fleets, no slope surveys, and model-based indices 
# - Model 23.model.fleetstruct_2:
# 23.model.recdevs_bias + Three fleets, use slope surveys, and model-based indices 
# - Model 23.model.fleetstruct_3:
# 23.model.recdevs_bias + Four fleets, use slope survey, and model-based indices 
# - Model 23.model.fleetstruct_4:
# 23.model.recdevs_bias + Four fleets, no slope surveys, and model-based indices 
# - Model 23.model.fleetstruct_5:
# 23.model.recdevs_bias + Three fleets, no slope survey, and model-based indices 
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

# Path to the base model ( 23.model.recdevs_bias ) repertory
Dir_Base <- file.path(dir_SensAnal, '5.1_Explore_RecDevs','4_23.model.recdevs_bias' , 'run',fsep = fsep)

# Root directory for this sensitivity analysis
SA_path <- .
# Path to the 23.model.fleetstruct_1 repertory
Dir_23_model_fleetstruct_1 <- file.path(dir_SensAnal, '5.2_Explore_FleetStructure','1_23.model.fleetstruct_1' , 'run',fsep = fsep)

# Path to the 23.model.fleetstruct_2 repertory
Dir_23_model_fleetstruct_2 <- file.path(dir_SensAnal, '5.2_Explore_FleetStructure','2_23.model.fleetstruct_2' , 'run',fsep = fsep)

# Path to the 23.model.fleetstruct_3 repertory
Dir_23_model_fleetstruct_3 <- file.path(dir_SensAnal, '5.2_Explore_FleetStructure','3_23.model.fleetstruct_3' , 'run',fsep = fsep)

# Path to the 23.model.fleetstruct_4 repertory
Dir_23_model_fleetstruct_4 <- file.path(dir_SensAnal, '5.2_Explore_FleetStructure','4_23.model.fleetstruct_4' , 'run',fsep = fsep)

# Path to the 23.model.fleetstruct_5 repertory
Dir_23_model_fleetstruct_5 <- file.path(dir_SensAnal, '5.2_Explore_FleetStructure','5_23.model.fleetstruct_5' , 'run',fsep = fsep)

# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = c(Dir_Base,Dir_23_model_fleetstruct_1,Dir_23_model_fleetstruct_2,Dir_23_model_fleetstruct_3,Dir_23_model_fleetstruct_4,Dir_23_model_fleetstruct_5))

# Rename the list holding the report files from each model
names(SensiMod)
names(SensiMod) <- c('23.model.recdevs_bias','23.model.fleetstruct_1','23.model.fleetstruct_2','23.model.fleetstruct_3','23.model.fleetstruct_4','23.model.fleetstruct_5')

# summarize the results
Version_Summary <- SSsummarize(SensiMod)

# make plots comparing the models
SSplotComparisons(
      Version_Summary,
      # print = TRUE,
      pdf = TRUE,
      plotdir = file.path(SA_path, 'SA_plots', fsep = fsep),
      legendlabels = c('23.model.recdevs_bias','23.model.fleetstruct_1','23.model.fleetstruct_2','23.model.fleetstruct_3','23.model.fleetstruct_4','23.model.fleetstruct_5')
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
