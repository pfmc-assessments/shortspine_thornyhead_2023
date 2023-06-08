# ============================================================ #
# Script used to analyze and compare the model(s) considered in the
# sensitivity analysis: Item 5.21 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic: 
# 	- Low-State 040 
# 	- Base Case 040 
# 	- High-State 040 
# Author:  Team Thornyhead 
# Date: 2023-06-08 15:40:22 
# Names of the models created:
# 	- 23.dt.low 
# 	- 23.dt.base 
# 	- 23.dt.high 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.dt.low 				 23.STAR.base 
# 23.dt.base 				 23.STAR.base 
# 23.dt.high 				 23.STAR.base 
# 
# Results are stored in the following foler: 
#	 /Users/jzahner/Desktop/Projects/shortspine_thornyhead_2023/model/Sensitivity_Anal/STAR_Panel/5.21_STAR_decision_table_040 
# 
# General features: 
# Decision table models for STAR Panel. Axes of uncertainty are the value of natural mortality. 
# 
# Model features:
# - Model 23.dt.low:
# Low state of nature M=0.0373 
# - Model 23.dt.base:
# Base case M=0.040 
# - Model 23.dt.high:
# High state of nature M=0.0461 
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
dir_SensAnal <- file.path(dir_model, 'Sensitivity_Anal', 'STAR_Panel', fsep = fsep)

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


# Path to the base model (23.STAR.base) repertory
Dir_23_STAR_base <- file.path(dirname(dir_SensAnal), 'STAR_Panel', '5.20_STAR_base/1_23.STAR.base', 'run', fsep = fsep)

# Root directory for this sensitivity analysis
SA_path <- file.path('model','Sensitivity_Anal','STAR_Panel','5.21_STAR_decision_table_040',fsep = fsep)

# Path to the 23.dt.low repertory
Dir_23_dt_low <- file.path(dir_SensAnal, '5.21_STAR_decision_table_040','1_23.dt.low' , 'run',fsep = fsep)

# Path to the 23.dt.base repertory
Dir_23_dt_base <- file.path(dir_SensAnal, '5.21_STAR_decision_table_040','2_23.dt.base' , 'run',fsep = fsep)

# Path to the 23.dt.high repertory
Dir_23_dt_high <- file.path(dir_SensAnal, '5.21_STAR_decision_table_040','3_23.dt.high' , 'run',fsep = fsep)

# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = c(
	Dir_23_STAR_base,
	Dir_23_dt_low,
	Dir_23_dt_base,
	Dir_23_dt_high))

# Rename the list holding the report files from each model
names(SensiMod)
names(SensiMod) <- c(
	'23.STAR.base',
	'23.dt.low',
	'23.dt.base',
	'23.dt.high')

# summarize the results
Version_Summary <- SSsummarize(SensiMod)

# make plots comparing the models
SSplotComparisons(
      Version_Summary,
      # print = TRUE,
      pdf = TRUE,
      plotdir = file.path(SA_path, 'SA_plots', fsep = fsep),
      legendlabels = c(
	'23.STAR.base',
	'23.dt.low',
	'23.dt.base',
	'23.dt.high')
    )

# Create comparison table for this analisys
# ####################################### #

SStableComparisons(Version_Summary)

tmp <- purrr::transpose(SensiMod)$parameters %>%
  purrr::map_df(~dplyr::as_tibble(.x), .id = 'Model') %>%
  dplyr::select(Model, Label, Value, Phase, Min, Max, Init,
                Gradient, Pr_type, Prior, Pr_SD, Pr_Like,
                LCI95 = `Value-1.96*SD`, UCI95 = `Value+1.96*SD`)

tmp %>%
    readr::write_csv(paste(SA_path, 'Update_Data_comparison_table_all_params.csv', sep = fsep))

tmp %>%
  dplyr::filter(grepl('LnQ|R0', Label)) %>%
  tidyr::pivot_wider(id_cols = c(Label, Phase), names_from = Model, values_from = Value) %>%
  readr::write_csv(paste(SA_path, 'Update_Data_comparison_table_lnQ_SRlnR0.csv', sep = fsep))

out <- SStableComparisons(Version_Summary)
names(out) <- c('Label', unique(tmp$Model))

out %>%
  readr::write_csv(paste(SA_path, 'Update_Data_comparison_table_likelihoods_and_brps.csv', sep = fsep))
