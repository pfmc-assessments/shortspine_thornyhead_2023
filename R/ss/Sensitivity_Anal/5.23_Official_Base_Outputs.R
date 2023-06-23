# ============================================================ #
# Script used to analyze and compare the model(s) considered in the
# sensitivity analysis: Item 5.23 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  model 
# Specific item in that topic: 
# 	- Official Base 
# Author:  Team Thornyhead 
# Date: 2023-06-16 21:50:12 
# Name of the model created:
# 	- 23.base.official 
# *** 
# 
# This analysis has been developped based on the following model: 
# 23.STAR.base 
# 
# Results are stored in the following foler: 
#	 /Users/jzahner/Desktop/shortspine_thornyhead_2023/model/Sensitivity_Anal/Base_Model/5.23_Official_Base 
# 
# Features: 
#  The official base model for Shortspine Thornyhead in 2023. This model formulation was approved via the STAR Panel review process on June 9, 2023. 
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
dir_SensAnal <- file.path(dir_model, 'Sensitivity_Anal', 'Base_Model', fsep = fsep)

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

# Root directory for this sensitivity analysis
SA_path <- file.path('model','Sensitivity_Anal','Base_Model','5.23_Official_Base',fsep = fsep)

# Path to the 23.base.official repertory
Dir_23_base_official <- file.path(dir_SensAnal, '5.23_Official_Base','1_23.base.official' , 'run',fsep = fsep)

# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = Dir_23_base_official)

# Rename the list holding the report files from each model
names(SensiMod)
names(SensiMod) <-'23.base.official'

# summarize the results
Version_Summary <- SSsummarize(SensiMod)

# make plots comparing the models
# SSplotComparisons(
#       Version_Summary,
#       # print = TRUE,
#       pdf = TRUE,
#       plotdir = file.path(SA_path, 'SA_plots', fsep = fsep),
#       legendlabels = 	'23.base.official')
    

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

# Tables for executive summary
##############################

replist <- SS_output(Dir_23_base_official)
SSexecutivesummary(
  replist,
)
SSexecutivesummary(
  replist,
  tables=c('b', 'g', 'h', 'likes'),
  format=FALSE,
  match_digits = TRUE
)

file.copy(
  from=file.path(here::here(), "model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official/run/tables/"),
  to=file.path(here::here(), "doc/FinalTables/Summary/"),
  overwrite=TRUE,
  recursive = TRUE
)

# get OFL Values and compute corresponding values of M
######################################################

out <- SS_output(Dir_23_base_official)
OFL23 <- out$derived_quants["OFLCatch_2023",]$Value
OFL.sigma <- out$OFL_sigma

OFL.low <- OFL23/exp(-1.15*OFL.sigma)
OFL.high <- OFL23/exp(1.15*OFL.sigma)

m.vec <- seq(0.025, 0.055, 0.005)
mort.profile.dir <- file.path(here::here(), "model/Sensitivity_Anal/Base_model/profiles/mortality")
profile.models <- SSgetoutput(dirvec = mort.profile.dir, keyvec = 1:length(m.vec))

# Values closest to 12.5th and 87.5th percentile are 0.035 and 0.044
# Values closest to  2.5th and 97.5th percentile are 0.030 and 0.047
for(i in 1:length(m.vec)){
  replist <- profile.models[[i]]
  ofl <- replist$derived_quants["OFLCatch_2023",]$Value
  print(paste("M =", m.vec[i], ":" , ofl, ";", ofl-OFL.low, ";", ofl-OFL.high))
}
