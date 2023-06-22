
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

dir_out <- file.path(here::here(),'doc','FinalFigs','bridging', fsep = fsep)
if(!dir.exists(dir_out))
  dir.create(dir_out)

# Updating Stock Synthesis version ----

# Path to the 2013 Assessment model
Dir_Base2013_SS3_24 <- file.path(here::here(), 'model','2013_SST' , 'run',fsep = fsep)

# Path to the 23.sq.fix repertory
Dir_23_sq_fix <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.fix' , 'run',fsep = fsep)

# Path to the 23.sq.floatQ repertory
Dir_23_sq_floatQ <- file.path(dir_SensAnal, '0.1_Bridging_models','23.sq.floatQ' , 'run',fsep = fsep)

# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = c(Dir_Base2013_SS3_24,Dir_23_sq_fix,Dir_23_sq_floatQ), 
                        getcovar=FALSE)

# Rename the list holding the report files from each model
names(SensiMod)
#names(SensiMod) <- c('SST_2013_V3.24','SST_2013_3.30.21_fix','SST_2013_V3.30.21')
names(SensiMod) <- c('2013 Model SS V3.24','2013 Model SS V3.30.21 Fixed Params','2013 Model SS V3.30.21')

# summarize the results
Version_Summary <- SSsummarize(SensiMod)

# make plots comparing the models
SSplotComparisons(
  Version_Summary,
  print = TRUE,
  subplots = c(2,4),
  plotdir = dir_out,
  legendlabels = names(SensiMod),
  uncertainty = TRUE
)

file.rename(from = file.path(dir_out, "compare2_spawnbio_uncertainty.png", fsep = fsep),
            to = file.path(dir_out, "Bridg_ts1_Spawning_Output.png", fsep = fsep))
file.rename(from = file.path(dir_out, "compare4_Bratio_uncertainty.png", fsep = fsep),
            to = file.path(dir_out, "Bridg_ts2_Bratio.png", fsep = fsep))
# ----------------------------------------------------------- 

# Including new data and updating model parameters ----

# Path to the base model (23.land.update) repertory
Dir_Base23_land_update <- file.path(dir_SensAnal, '0.2_Update_Data','1_23.land.update' , 'run',fsep = fsep)

# Path to the base model (23.disc.update) repertory
Dir_Base23_disc_update <- file.path(dir_SensAnal, '0.2_Update_Data','2_23.disc.update' , 'run',fsep = fsep)

# Path to the base model (23.surv_db.update) repertory
Dir_Base23_surv_db_update <- file.path(dir_SensAnal, '0.2_Update_Data','3_23.surv_db.update' , 'run',fsep = fsep)

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

# Path to the base model (23.fecundity.update) repertory
Dir_Base23_mortality_update <- file.path(dir_SensAnal, '0.2_Update_Data','10_23.mortality.update' , 'run',fsep = fsep)

# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = c(Dir_23_sq_floatQ,Dir_Base23_land_update,Dir_Base23_disc_update,Dir_Base23_surv_db_update,Dir_Base23_lcs_survey_update,Dir_Base23_lcs_fisheries_update,Dir_Base23_disc_weight_update,Dir_Base23_growth_update,Dir_Base23_maturity_update,Dir_Base23_fecundity_update,Dir_Base23_mortality_update))

# Rename the list holding the report files from each model
names(SensiMod)
#names(SensiMod) <- c('SST_2013_V3.30.21','23.land.update', '23.dic.update', '23.surv_db.update', '23.lcs_survey.update','23.lcs_fisheries.update', '23.disc_weight.update', '23.growth.update', '23.maturity.update', '23.fecundity.update', '23.mortality.update')
names(SensiMod) <- c('2013 Model SS V3.30.21','Updated Landings', 'Updated Discards', 'Updated Survey (DB)', 
                     'Updated Survey Length Comps','Updated Fishery Length Comps', 'Updated Discard Weights', 
                     'Updated Growth', 'Updated Maturity', 'Updated Fecundity', 'Updated Nat Mortality')

# summarize the results
Version_Summary <- SSsummarize(SensiMod)

# make plots comparing the models
SSplotComparisons(
  Version_Summary,
  print = TRUE,
  plotdir = dir_out,
  subplots = c(2,4),
  legendlabels = names(SensiMod),
  legendncol = 2,
  ylimAdj = 1.45,
  uncertainty = c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)
)
file.rename(from = file.path(dir_out, "compare2_spawnbio_uncertainty.png", fsep = fsep),
            to = file.path(dir_out, "Bridg_ts3_Spawning_Output.png", fsep = fsep))
file.rename(from = file.path(dir_out, "compare4_Bratio_uncertainty.png", fsep = fsep),
            to = file.path(dir_out, "Bridg_ts4_Bratio.png", fsep = fsep))
# ----------------------------------------------------------- 

# Proposed base model ----

# Path to the 23.mortality.update repertory
Dir_23_mortality_update <- file.path(dir_SensAnal, '0.2_Update_Data','10_23.mortality.update' , 'run',fsep = fsep)

# Path to the 23.model.francis repertory
Dir_23_model_francis <- file.path(dir_SensAnal, '5.3_Francis_Reweighting','1_23.model.francis' , 'run',fsep = fsep)

# Path to the 23.model.recdevs_inityear_1996 repertory
Dir_23_model_recdevs_inityear_1996 <- file.path(dir_SensAnal, '5.6_Update_Recdevs_Inityear','1_23.model.recdevs_inityear_1996' , 'run',fsep = fsep)

# Path to the official BASE Model
Dir_23_official_base <- file.path(dir_SensAnal, 'Base_Model','5.23_Official_Base', '1_23.base.official' , 'run',fsep = fsep)


# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = c(
  Dir_23_mortality_update,
  Dir_23_model_francis,
  Dir_23_official_base))

# Rename the list holding the report files from each model
names(SensiMod)
# names(SensiMod) <- c(
#   '23.mortality.update',
#   '23.model.fleetstruct_5',
#   '23.model.recdevs_Update',
#   '23.Base.model')

names(SensiMod) <- c(
  '2023 Mortality Updated',
  '2023 Fleet Struture Updated',
  '2023 Base Model')


# summarize the results
Version_Summary <- SSsummarize(SensiMod)

# make plots comparing the models
SSplotComparisons(
  Version_Summary,
  print = TRUE,
  subplots = c(2,4,11),
  plotdir = dir_out,
  legendlabels = names(SensiMod),
  uncertainty=c(FALSE, FALSE, TRUE)
)
file.rename(from = file.path(dir_out, "compare2_spawnbio_uncertainty.png", fsep = fsep),
            to = file.path(dir_out, "Bridg_ts5_Spawning_Output.png", fsep = fsep))
file.rename(from = file.path(dir_out, "compare4_Bratio_uncertainty.png", fsep = fsep),
            to = file.path(dir_out, "Bridg_ts6_Bratio.png", fsep = fsep))
file.rename(from = file.path(dir_out, "compare11_recdevs.png", fsep = fsep),
            to = file.path(dir_out, "Bridg_ts7_recdevs.png", fsep = fsep))
