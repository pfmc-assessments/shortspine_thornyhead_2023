# ============================================================ #
# Script used to analyze and compare the model(s) considered in the
# sensitivity analysis: Item 4.3 
# ============================================================ #
# 
# Sensitivity analysis summary
# 
# *** 
# Topic of the sensitivity analysis:  biological_Info 
# Specific item in that topic: 
# 	- Sensitivity to fecundity 
# 	- biological_Info 
# 	- biological_Info 
# 	- biological_Info 
# 	- biological_Info 
# 	- biological_Info 
# Author:  Sabrina Beyer 
# Date: 2023-05-31 20:47:42 
# Names of the models created:
# 	- 23.biology.no_fecundity 
# 	- 23.SummaryBioAge30 
# 	- 23.SummaryBioAge30.nofec 
# 	- 23.fec.units.eggsperfemale 
# 	- 23.no.fec.SSO.onethird 
# 	- 23.no.fec.SSO.0.2198 
# *** 
# 
# This analysis has been developed based on the following model(s): 
# New model 					 Base model
# 23.biology.no_fecundity 				 23.model.francis_2 
# 23.SummaryBioAge30 				 23.model.francis_2 
# 23.SummaryBioAge30.nofec 				 23.model.francis_2 
# 23.fec.units.eggsperfemale 				 23.model.francis_2 
# 23.no.fec.SSO.onethird 				 23.model.francis_2 
# 23.no.fec.SSO.0.2198 				 23.model.francis_2 
# 
# Results are stored in the following foler: 
#	 C:/Users/sgbey/Documents/Github/shortspine_thornyhead_2023/model/Sensitivity_Anal/4.3_Fecundity_Sensitivity 
# 
# General features: 
# Try again convert weight to scale of millions of eggs with a.fec/a.weight 
# 
# Model features:
# - Model 23.biology.no_fecundity:
# remove the fecundity relationship, 2013 assumptions
# - Model 23.SummaryBioAge30:
# - Model 23.SummaryBioAge30.nofec:
# summary biomass at 30 years (mostly spawning females) and no fecundity
# - Model 23.fec.units.eggsperfemale:
# base model with fec on original scale
# - Model 23.no.fec.SSO.onethird:
# fecundity option 1 (no fecundity), but set alpha to 1/3
# - Model 23.no.fec.SSO.0.2198:
# convert no fec alpha by a.fec/a.weight=0.2198
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
SA_path <- file.path('model','Sensitivity_Anal','4.3_Fecundity_Sensitivity',fsep = fsep)
# Path to the 23.biology.no_fecundity repertory
Dir_23_biology_no_fecundity <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','1_23.biology.no_fecundity' , 'run',fsep = fsep)

# Path to the 23.SummaryBioAge30 repertory
Dir_23_SummaryBioAge30 <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','2_23.SummaryBioAge30' , 'run',fsep = fsep)

# Path to the 23.SummaryBioAge30.nofec repertory
Dir_23_SummaryBioAge30_nofec <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','3_23.SummaryBioAge30.nofec' , 'run',fsep = fsep)

# Path to the 23.fec.units.eggsperfemale repertory
Dir_23_fec_units_eggsperfemale <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','4_23.fec.units.eggsperfemale' , 'run',fsep = fsep)

# Path to the 23.no.fec.SSO.onethird repertory
Dir_23_no_fec_SSO_onethird <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','5_23.no.fec.SSO.onethird' , 'run',fsep = fsep)

# Path to the 23.no.fec.SSO.0.2198 repertory
Dir_23_no_fec_SSO_0_2198 <- file.path(dir_SensAnal, '4.3_Fecundity_Sensitivity','6_23.no.fec.SSO.0.2198' , 'run',fsep = fsep)

# Extract the outputs for all models
SensiMod <- SSgetoutput(dirvec = c(
	Dir_23_model_francis_2,
	Dir_23_biology_no_fecundity,
	Dir_23_SummaryBioAge30,
	Dir_23_SummaryBioAge30_nofec,
	Dir_23_fec_units_eggsperfemale,
	Dir_23_no_fec_SSO_onethird,
	Dir_23_no_fec_SSO_0_2198))

# Rename the list holding the report files from each model
names(SensiMod)
names(SensiMod) <- c(
	'23.model.francis_2',
	'23.biology.no_fecundity',
	'23.SummaryBioAge30',
	'23.SummaryBioAge30.nofec',
	'23.fec.units.eggsperfemale',
	'23.no.fec.SSO.onethird',
	'23.no.fec.SSO.0.2198')

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
	'23.biology.no_fecundity',
	'23.SummaryBioAge30',
	'23.SummaryBioAge30.nofec',
	'23.fec.units.eggsperfemale',
	'23.no.fec.SSO.onethird',
	'23.no.fec.SSO.0.2198')
    )

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Compare spawning output (maturity*fecundity)-at-length
# base model (no fecundity) vs fecundity in original units
No_fec_replist <- SS_output(dir = c(
  Dir_23_no_fec_SSO_0_2198))
names(No_fec_replist)


Yes_fec_replist <- SS_output(dir = c(
  Dir_23_model_francis_2))
names(Yes_fec_replist)

# spawning output at length (maturity*fecundity)
#plotdir = file.path(SA_path, 'SA_plots', fsep = fsep)
#filename5<-paste(plotdir,"SpawningOutput_at_Length_Compare_base_a.w_a.fec.png", sep="/")
#png(filename5, width=4, height=4, units="in", res=300)
SSplotBiology(
  replist= No_fec_replist,
  subplots = 10,
  plotdir = file.path(SA_path, 'SA_plots', fsep = fsep)
)
SSplotBiology(
  replist= Yes_fec_replist,
  add = TRUE,
  subplots = 10,
  colvec = c("blue"),
  plotdir = file.path(SA_path, 'SA_plots', fsep = fsep)
)
#add legend
SSplotBiology(
  replist= Yes_fec_replist,
  add = TRUE,
  subplots = 10,
  colvec = c("white"),
  legend("topleft", legend=c("Base", "No Fecundity- a.w/a.fec"), col=c("blue","red"), lty=1, bty="n", cex=0.8),
  plotdir = file.path(here::here(), "doc", "FinalFigs", "Sensitivities", "Fecundity", fsep = fsep)
)
#dev.off()

?SSplotNumbers()
SSplotNumbers(
  replist= Yes_fec_replist,
  subplots = 6,
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
