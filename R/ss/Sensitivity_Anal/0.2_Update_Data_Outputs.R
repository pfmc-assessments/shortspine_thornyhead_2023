# ============================================================ #
# Script used to analyze and compare the model(s) considered in the 
# sensitivity analysis: Item 0.2 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  transition 
# Specific item in that topic:  Update landings Updates discard rates Update survey geostat indices Update survey length comps Update fisheries length comps Update discard mean weights Update growth Update maturity Update fecundity Update natural mortality 
# 	- Update landings 
# 	- Updates discard rates 
# 	- Update survey geostat indices 
# 	- Update survey length comps 
# 	- Update fisheries length comps 
# 	- Update discard mean weights 
# 	- Update growth 
# 	- Update maturity 
# 	- Update fecundity 
# 	- Update natural mortality 
# Author:  Team Thornyheads 
# Date: 2023-04-05 10:48:24 
# Names of the models created:
# -  23.land.update 
# -  23.disc.update 
# -  23.surv_geo.update 
# -  23.lcs_survey.update 
# -  23.lcs_fisheries.update 
# -  23.disc_weight.update 
# -  23.growth.update 
# -  23.maturity.update 
# -  23.fecundity.update 
# -  23.mortality.update 
# *** 
# 
# This analysis has been developed based on the following models: 
# New model 	 Base model
# 23.land.update 	 23.sq.floatQ 
# 23.disc.update 	 23.land.update 
# 23.surv_geo.update 	 23.disc.update 
# 23.lcs_survey.update 	 23.surv_geo.update 
# 23.lcs_fisheries.update 	 23.lcs_survey.update 
# 23.disc_weight.update 	 23.lcs_fisheries.update 
# 23.growth.update 	 23.disc_weight.update 
# 23.maturity.update 	 23.growth.update 
# 23.fecundity.update 	 23.maturity.update 
# 23.mortality.update 	 23.fecundity.update 
# 
# Results are stored in the following foler: 
#	 C:/Users/Matthieu Verson/Documents/GitHub/Forked_repos/shortspine_thornyhead_2023/model/Sensitivity_Anal/0.2_Update_Data 
# 
# General features: 
Updating the data sets from the 2013 assessment to the 2023 assessment without changing the structural assumptions. The data sets that are updated as part of this analysis include fishery landings (using the status quo four fleet structure), discards, new geostatistical indices from glmTMB, composition data, and biological parameters. The growth parameters are new and are based on Butler data. Maturity parameters are new and based on Melissa Head's data. Fecundity parameters are new and based on Cooper et al 2005. Natural mortality is new and based on Hamel and Cope 2022 longevity estimator. These updates are collectively considered "best avail science." 
# 
# Model features:
# - Model 23.land.update:
# from pacfin and new state harvest reconstructs 
# - Model 23.disc.update:
# from GEMM and Pikitch 
# - Model 23.surv_geo.update:
# from glmTMB, contact Kelli Johnson 
# - Model 23.lcs_survey.update:
# update length comps 
# - Model 23.lcs_fisheries.update:
# update length comps 
# - Model 23.disc_weight.update:
# update mean weights from WCGOP 
# - Model 23.growth.update:
# Butler 
# - Model 23.maturity.update:
# Head 
# - Model 23.fecundity.update:
# Cooper 
# - Model 23.mortality.update:
# Hamel and Cope (amax = 100) 
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


# Path to the base model (23.sq.floatQ) repertory
Dir_Base23_sq_floatQ <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.floatQ' , 'run',fsep = fsep)


# Path to the base model (23.land.update) repertory
Dir_Base23_land_update <- file.path(dir_SensAnal, '0.2_Update_Data','1_23.land.update' , 'run',fsep = fsep)


# Path to the base model (23.disc.update) repertory
Dir_Base23_disc_update <- file.path(dir_SensAnal, '0.2_Update_Data','2_23.disc.update' , 'run',fsep = fsep)


# Path to the base model (23.surv_geo.update) repertory
Dir_Base23_surv_geo_update <- file.path(dir_SensAnal, '0.2_Update_Data','3_23.surv_geo.update' , 'run',fsep = fsep)


# Path to the base model (23.lcs_survey.update) repertory
Dir_Base23_lcs_survey_update <- file.path(dir_SensAnal, '0.2_Update_Data','4_23.lcs_survey.update' , 'run',fsep = fsep)


# Path to the base model (23.lcs_fisheries.update) repertory
Dir_Base23_lcs_fisheries_update <- file.path(dir_SensAnal, '0.2_Update_Data','5_23.lcs_fisheries.update' , 'run',fsep = fsep)


# Path to the base model (23.disc_weight.update) repertory
Dir_Base23_disc_weight_update <- file.path(dir_SensAnal, '0.2_Update_Data','6_23.disc_weight.update' , 'run',fsep = fsep)


# Path to the base model (23.growth.update) repertory
Dir_Base23_growth_update <- file.path(dir_SensAnal, '0.2_Update_Data','7_23.growth.update' , 'run',fsep = fsep)


# Path to the base model (23.maturity.update) repertory
Dir_Base23_maturity_update <- file.path(dir_SensAnal, '0.2_Update_Data','8_23.maturity.update' , 'run',fsep = fsep)


# Path to the base model (23.fecundity.update) repertory
Dir_Base23_fecundity_update <- file.path(dir_SensAnal, '0.2_Update_Data','9_23.fecundity.update' , 'run',fsep = fsep)


# Root directory for this sensitivity analysis
SA_path <- .
# Path to the 23.land.update repertory
Dir_23_land_update <- file.path(dir_SensAnal, '0.2_Update_Data','1_23.land.update' , 'run',fsep = fsep)

# Path to the 23.disc.update repertory
Dir_23_disc_update <- file.path(dir_SensAnal, '0.2_Update_Data','2_23.disc.update' , 'run',fsep = fsep)

# Path to the 23.surv_geo.update repertory
Dir_23_surv_geo_update <- file.path(dir_SensAnal, '0.2_Update_Data','3_23.surv_geo.update' , 'run',fsep = fsep)

# Path to the 23.lcs_survey.update repertory
Dir_23_lcs_survey_update <- file.path(dir_SensAnal, '0.2_Update_Data','4_23.lcs_survey.update' , 'run',fsep = fsep)

# Path to the 23.lcs_fisheries.update repertory
Dir_23_lcs_fisheries_update <- file.path(dir_SensAnal, '0.2_Update_Data','5_23.lcs_fisheries.update' , 'run',fsep = fsep)

# Path to the 23.disc_weight.update repertory
Dir_23_disc_weight_update <- file.path(dir_SensAnal, '0.2_Update_Data','6_23.disc_weight.update' , 'run',fsep = fsep)

# Path to the 23.growth.update repertory
Dir_23_growth_update <- file.path(dir_SensAnal, '0.2_Update_Data','7_23.growth.update' , 'run',fsep = fsep)

# Path to the 23.maturity.update repertory
Dir_23_maturity_update <- file.path(dir_SensAnal, '0.2_Update_Data','8_23.maturity.update' , 'run',fsep = fsep)

# Path to the 23.fecundity.update repertory
Dir_23_fecundity_update <- file.path(dir_SensAnal, '0.2_Update_Data','9_23.fecundity.update' , 'run',fsep = fsep)

# Path to the 23.mortality.update repertory
Dir_23_mortality_update <- file.path(dir_SensAnal, '0.2_Update_Data','10_23.mortality.update' , 'run',fsep = fsep)

# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = c(Dir_Base23_sq_floatQ,Dir_Base23_land_update,Dir_Base23_disc_update,Dir_Base23_surv_geo_update,Dir_Base23_lcs_survey_update,Dir_Base23_lcs_fisheries_update,Dir_Base23_disc_weight_update,Dir_Base23_growth_update,Dir_Base23_maturity_update,Dir_Base23_fecundity_update,Dir_23_land_update,Dir_23_disc_update,Dir_23_surv_geo_update,Dir_23_lcs_survey_update,Dir_23_lcs_fisheries_update,Dir_23_disc_weight_update,Dir_23_growth_update,Dir_23_maturity_update,Dir_23_fecundity_update,Dir_23_mortality_update))

# Rename the list holding the report files from each model
names(SensiMod)
names(SensiMod) <- c('23.sq.floatQ','23.land.update','23.disc.update','23.surv_geo.update','23.lcs_survey.update','23.lcs_fisheries.update','23.disc_weight.update','23.growth.update','23.maturity.update','23.fecundity.update','23.land.update','23.disc.update','23.surv_geo.update','23.lcs_survey.update','23.lcs_fisheries.update','23.disc_weight.update','23.growth.update','23.maturity.update','23.fecundity.update','23.mortality.update')

# summarize the results
Version_Summary <- SSsummarize(SensiMod)

# make plots comparing the models
SSplotComparisons(
      Version_Summary,
      # print = TRUE,
      pdf = TRUE,
      plotdir = file.path(SA_path, 'SA_plots', fsep = fsep),
      legendlabels = c('23.sq.floatQ','23.land.update','23.disc.update','23.surv_geo.update','23.lcs_survey.update','23.lcs_fisheries.update','23.disc_weight.update','23.growth.update','23.maturity.update','23.fecundity.update','23.land.update','23.disc.update','23.surv_geo.update','23.lcs_survey.update','23.lcs_fisheries.update','23.disc_weight.update','23.growth.update','23.maturity.update','23.fecundity.update','23.mortality.update')
    )
