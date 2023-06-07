# ============================================================ #
# Script used to analyze and compare the model(s) considered in the
# sensitivity analysis: Item 5.16 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic: 
# 	- lenght comp combo only 
# 	- lenght comp add triennial 
# 	- lenght comp add NonTrawl 
# 	- lenght comp add SouthTrawl 
# 	- lenght comp add NorthTrawl 
# Author:  Andrea Odell 
# Date: 2023-06-07 14:10:32 
# Names of the models created:
# 	- 23.lencomp.Combo.Only 
# 	- 23.lencomp.AddTriennial 
# 	- 23.lencomp.AddNonTrawl 
# 	- 23.lencomp.AddSouthTrawl 
# 	- 23.lencomp.AddNorthTrawl 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.lencomp.Combo.Only 				 23.model.francis_2 
# 23.lencomp.AddTriennial 				 23.model.francis_2 
# 23.lencomp.AddNonTrawl 				 23.model.francis_2 
# 23.lencomp.AddSouthTrawl 				 23.model.francis_2 
# 23.lencomp.AddNorthTrawl 				 23.model.francis_2 
# 
# Results are stored in the following foler: 
#	 /Users/andrea/Desktop/shortspine_thornyhead_2023/model/Sensitivity_Anal//5.16_LenComp_Reweight_by_Fleet 
# 
# General features: 
# Iteratively adjust length comp weighting starting with combo survey only (everything else set to 0), then add triennial, non-trawl, south trawl, then north trawl 
# 
# Model features:
# - Model 23.lencomp.Combo.Only:
# combo only with variance adjustment value, everything else set to 0 
# - Model 23.lencomp.AddTriennial:
# combo + triennial with variance adjustment value, rest set to 0 
# - Model 23.lencomp.AddNonTrawl:
# combo + triennial + Nontrawl, rest set to 0 
# - Model 23.lencomp.AddSouthTrawl:
# combo + triennial + Nontrawl + South trawl, rest set to 0 
# - Model 23.lencomp.AddNorthTrawl:
# combo + triennial + Nontrawl + South trawl + north trawl 
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


# Path to the base model (23.model.francis_2) repertory
Dir_23_model_francis_2 <- file.path(dir_SensAnal, '5.8_Francis_Reweighting_2', '1_23.model.francis_2', 'run', fsep = fsep)

# Root directory for this sensitivity analysis
SA_path <- file.path('model','Sensitivity_Anal','5.16_LenComp_Reweight_by_Fleet',fsep = fsep)

# Path to the 23.lencomp.Combo.Only repertory
Dir_23_lencomp_Combo_Only <- file.path(dir_SensAnal, '5.16_LenComp_Reweight_by_Fleet','1_23.lencomp.Combo.Only' , 'run',fsep = fsep)

# Path to the 23.lencomp.AddTriennial repertory
Dir_23_lencomp_AddTriennial <- file.path(dir_SensAnal, '5.16_LenComp_Reweight_by_Fleet','2_23.lencomp.AddTriennial' , 'run',fsep = fsep)

# Path to the 23.lencomp.AddNonTrawl repertory
Dir_23_lencomp_AddNonTrawl <- file.path(dir_SensAnal, '5.16_LenComp_Reweight_by_Fleet','3_23.lencomp.AddNonTrawl' , 'run',fsep = fsep)

# Path to the 23.lencomp.AddSouthTrawl repertory
Dir_23_lencomp_AddSouthTrawl <- file.path(dir_SensAnal, '5.16_LenComp_Reweight_by_Fleet','4_23.lencomp.AddSouthTrawl' , 'run',fsep = fsep)

# Path to the 23.lencomp.AddNorthTrawl repertory
Dir_23_lencomp_AddNorthTrawl <- file.path(dir_SensAnal, '5.16_LenComp_Reweight_by_Fleet','5_23.lencomp.AddNorthTrawl' , 'run',fsep = fsep)

# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = c(
	Dir_23_model_francis_2,
	Dir_23_lencomp_Combo_Only,
	Dir_23_lencomp_AddTriennial,
	Dir_23_lencomp_AddNonTrawl,
	Dir_23_lencomp_AddSouthTrawl,
	Dir_23_lencomp_AddNorthTrawl))

# Rename the list holding the report files from each model
names(SensiMod)
names(SensiMod) <- c(
	'23.model.francis_2',
	'23.lencomp.Combo.Only',
	'23.lencomp.AddTriennial',
	'23.lencomp.AddNonTrawl',
	'23.lencomp.AddSouthTrawl',
	'23.lencomp.AddNorthTrawl')

# summarize the results
Version_Summary <- SSsummarize(SensiMod)

# make plots comparing the models
SSplotComparisons(
      Version_Summary,
      # print = TRUE,
      pdf = TRUE,
      plotdir = file.path(SA_path, 'SA_plots', fsep = fsep),
      legendlabels = c(
	'23.model.francis_2',
	'23.lencomp.Combo.Only',
	'23.lencomp.AddTriennial',
	'23.lencomp.AddNonTrawl',
	'23.lencomp.AddSouthTrawl',
	'23.lencomp.AddNorthTrawl')
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
