# Stock: Shortspine thornyhead
# Set up the Rdata to save the parameters and the data that will feed SS input files
# authors: Matthieu VERON, Jane Sullivan
# contact: mveron@uw.edu

rm(list = ls(all.names = TRUE))

# 1. Set up ----
# ---------------------------------------------------------- #
# load packages ----

library(r4ss)
library(readr)

source(file=file.path(here::here(), "R", "utils", "ss_utils.R"))

# Local declarations ----
fsep <- .Platform$file.sep

# Set directories ----
dir_model <- file.path(here::here(), "model", fsep = fsep)
dir_script <- file.path(here::here(), "R", fsep = fsep)
dir_SS <- file.path(dir_script, "ss", fsep = fsep)
dir_dat <- file.path(here::here(), "data", "for_ss", fsep = fsep)

# Data ----

list.files(dir_dat, '\\.csv$', full.names = FALSE)

# biological parameters
fecund <-  read_csv(file.path(dir_dat, "fecundity_2023.csv"))
growth <-  read_csv(file.path(dir_dat, "growth_2023.csv"))
allom <-  read_csv(file.path(dir_dat, "wtlen_bysex_2023.csv"))
# To do - go back and format this correctly
mature <-  read_csv(file.path(dir_dat, "maturity_alternatives_2023.csv")) %>% 
  tidyr::pivot_longer(cols = -Method, names_to = 'Param', values_to = 'Value') %>% 
  dplyr::rename(Version = Method)
natmat <-  read_csv(file.path(dir_dat, "natmat_2023.csv"))

# survey index and length comp data: alternatives include design vs glmbTMB model
# based indices and configurations which include and exclude the afsc slope
# survey
srv_db_all <-  read_csv(file.path(dir_dat, "survey_db_indices_all_2023.csv"))
srv_db_noslope <-  read_csv(file.path(dir_dat, "survey_db_indices_noslope_2023.csv"))
srv_mb_all <-  read_csv(file.path(dir_dat, "survey_mb_indices_all_2023.csv"))
srv_mb_noslope <-  read_csv(file.path(dir_dat, "survey_mb_indices_noslope_2023.csv"))
srv_len_all <- read_csv(file.path(dir_dat, "survey_length_comps_all_2023.csv"))
srv_len_noslope <- read_csv(file.path(dir_dat, "survey_length_comps_noslope_2023.csv"))

# landings catch and length comp data: alternatives include the old 4 fleet
# structure (NTrawl, NOther, STrawl, SOther) and the new 3 fleet structure
# (NTrawl, STrawl, Other)
landings3 <-  read_csv(file.path(dir_dat, "landings_3fleet_2023.csv"))
landings4 <-  read_csv(file.path(dir_dat, "landings_4fleet_2023.csv"))
landings_lencomps3 <-  read_csv(file.path(dir_dat, "landings_length_comps_3fleet_2023.csv"))
landings_lencomps4 <-  read_csv(file.path(dir_dat, "landings_length_comps_4fleet_2023.csv"))

# discard data - To do - go back and format this correctly (use read_csv so i
# don't have to use [-1] and the same naming conventions
discard_rates3 <- read_csv(file.path(dir_dat, "discardRates_3Fleets.csv"))[-1]
discard_rates4 <- read_csv(file.path(dir_dat, "discardRates_4Fleets.csv"))[-1]
discard_weights3 <- read_csv(file.path(dir_dat, "discardWeights_ss_3Fleets.csv"))[-1]
discard_weights4 <- read_csv(file.path(dir_dat, "discardWeights_ss_4Fleets.csv"))[-1]
discard_weights4 <- read_csv(file.path(dir_dat, "discardWeights_ss_4Fleets.csv"))[-1]
discard_lencomps3 <- read_csv(file.path(dir_dat, "discardLenComp_ss_3Fleets.csv"))[-1]
discard_lencomps4 <- read_csv(file.path(dir_dat, "discardLenComp_ss_4Fleets.csv"))[-1]

# Stuff needed ----

# Colnames from SS
lng_par_colnames <- c(
  "LO", "HI", "INIT", "PRIOR", "PR_SD", "PR_type", "PHASE",
  "env_var&link", "dev_link", "dev_minyr", "dev_maxyr",
  "dev_PH", "Block", "Block_Fxn"
)
srt_par_colnames <- c("LO", "HI", "INIT", "PRIOR", "PR_SD", "PR_type", "PHASE")

# If we just want the parameter and the value
ParVal_colnames <- c("Parameter", "Value")

# Internal functions
# Build empty data frame
doDat <- function(Data_colnames = NULL,
                  RowNam = NULL) {
  if(is.null(RowNam))
    RowNam <- 1
  
  nrowdat = length(RowNam)
  dat <-
    data.frame(matrix(NA, nrow = nrowdat, ncol = length(Data_colnames)))
  colnames(dat) <- Data_colnames
  
  if(!unique(Data_colnames %in% c("Parameter", "Value"))){
    row.names(dat) <- RowNam
  } else {
    dat[,"Parameter"] <- RowNam
  }
  
  return(dat)
}

# Get the name of the parameters
getName <- function(string = NULL , pattern = NULL){
  # out <- string[which(stringr::str_detect(string = string, pattern = pattern))]
  out <- string[which(grepl(paste(pattern, collapse = "|"), MG_row, perl = TRUE))]
  return(out)
}
# ===========================================================================


# Load control file ----
# Path to the base model (23.sq.0) repertory
Dir_Base23_sq_fixQ <- file.path(dir_model,'2013_SST_SSV3_30_21', fsep = fsep)

# First read the starter to get the name of the control file
StarterFile <- file.path(Dir_Base23_sq_fixQ, 'starter.ss', fsep = fsep)
Start23_sq_0 <- SS_readstarter(
  file = StarterFile,
  verbose = TRUE
)

# Read in the file

# Path to the Executable folder 
# dir_model <- file.path(here::here(), 'model', fsep = fsep)
# Exe_path <- file.path(dir_model, 'ss_executables') 
# 
# run_SS(SS_version = "3.30.21",
#        Exe_extra = "",
#        base_path = "",
#        pathRun = file.path(Dir_Base23_sq_fixQ, 'run'),
#        copy_files = TRUE,
#        extras = NULL,
#        show_in_console = TRUE,
#        cleanRun = TRUE)

Ctlfile <- file.path(Dir_Base23_sq_fixQ,Start23_sq_0$ctlfile, fsep = fsep)

Ctl23_sq_fixQ <- SS_readctl_3.30(
  file = Ctlfile,
  use_datlist = TRUE,
  datlist = file.path(Dir_Base23_sq_fixQ, 'run','data_echo.ss_new', fsep = fsep),
  verbose = TRUE
)

# Length bin for the size comp if any
Lbin_vect <- seq(6, 72, 2)
# ===========================================================================

# Get the rownames from the control file
MG_row <- rownames(Ctl23_sq_fixQ$MG_parms)
SR_row <- rownames(Ctl23_sq_fixQ$SR_parms)
Q_row <- rownames(Ctl23_sq_fixQ$Q_parms)
Slx_row <- rownames(Ctl23_sq_fixQ$size_selex_parms)
InitF_row <- rownames(Ctl23_sq_fixQ$init_F)

# Set up the list 
SS_Param2023 <- list()
SS_Param2023$Comments$Content <- "This is a Rdata to save the parameters and data used in the 2023 assessment model"

# Parameter ----

# MG Parameters ----
SS_Param2023$MG_params$Content <- "These are the mortality_growth parameters"

# Natural mortality ----

rowNam_M <- getName(string = MG_row, pattern = "NatM")

# Base 2023 (Hamel and Cope 2022 method)
SS_Param2023$MG_params$M$base_2023 <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_M)
SS_Param2023$MG_params$M$base_2023$Value <- c(natmat$initM, 0, 0, 0)

# 2013 sensitivity
SS_Param2023$MG_params$M$assess_2013 <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_M)
SS_Param2023$MG_params$M$assess_2013$Value <- c(0.0505, 0, 0, 0) 

# Growth ----
rowNam_G <- getName(string = MG_row, pattern = c("L_at", "VonBert_K", "CV_"))
# SS_Param2023$MG_params$Growth <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_G)

unique(growth$Version)

# Base 2023 (Schnute fit to Butler data set, lognormal distribution)
SS_Param2023$MG_params$Growth$base_2023 <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_G)
SS_Param2023$MG_params$Growth$base_2023$Value <- growth$Value[growth$Version == 'Butler_Base_2023']

# Upper sensitivity
SS_Param2023$MG_params$Growth$upper_sensitivity <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_G)
SS_Param2023$MG_params$Growth$upper_sensitivity$Value <- growth$Value[growth$Version == 'Increase_L_at_Amin_and_Amax_25perc']

# Lower sensitivity
SS_Param2023$MG_params$Growth$lwr_sensitivity <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_G)
SS_Param2023$MG_params$Growth$lwr_sensitivity$Value <- growth$Value[growth$Version == 'Decrease_L_at_Amin_and_Amax_10perc']

# 2013 assessment sensitivity
SS_Param2023$MG_params$Growth$assess_2013 <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_G)
SS_Param2023$MG_params$Growth$assess_2013$Value <- growth$Value[growth$Version == '2013_assessment']

# Weight-Length relationship -----
rowNam_WL <- getName(string = MG_row, pattern = c("Wtlen_"))
# SS_Param2023$MG_params$WL <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_WL)
unique(allom$Version)

# Base 2023 (updated using WCBTS data)
SS_Param2023$MG_params$WL$base_2023 <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_WL)
SS_Param2023$MG_params$WL$base_2023$Value <- allom$Value[allom$Version == 'WCBTS_Base_2023']

# 2013 assessment sensitivity
SS_Param2023$MG_params$WL$assess_2013 <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_WL)
SS_Param2023$MG_params$WL$assess_2013$Value <- allom$Value[allom$Version == '2013_assessment']

# Maturity ----
rowNam_Mat <- getName(string = MG_row, pattern = c("Mat_", "Mat50"))
# SS_Param2023$MG_params$Mat <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_Mat)
unique(mature$Version)

# Base 2023 (GLM with quadratics on latitude and depth fit to M Head 2023 data set)
SS_Param2023$MG_params$Mat$base_2023 <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_Mat)
SS_Param2023$MG_params$Mat$base_2023$Value <- mature$Value[mature$Version == 'Head_2023']

# Pearson and Gunderson 2003 (used in 2013 assessment) - use as sensitivity
SS_Param2023$MG_params$Mat$assess_2013 <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_Mat)
SS_Param2023$MG_params$Mat$assess_2013$Value <- mature$Value[mature$Version == 'Pearson_and_Gunderson_2003']

# Intermediate sensitivity - average of Head 2023 and Pearson and Gunderson 2003 
SS_Param2023$MG_params$Mat$interm_sensitivity <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_Mat)
SS_Param2023$MG_params$Mat$interm_sensitivity$Value <- mature$Value[mature$Version == 'Intermediate_sensitivity']

# Fecundity----
rowNam_Fec <- getName(string = MG_row, pattern = c("Eggs_"))
# SS_Param2023$MG_params$Fec <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_Fec)
unique(fecund)

# Base 2023 - use Cooper 2005 TODO - check scale!
SS_Param2023$MG_params$Fec$base_2023 <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_Fec)
SS_Param2023$MG_params$Fec$base_2023$Value <- fecund$Value

# TODO - sensitivity to 2013 assessment assumptions spawning output = spawning biomass 
# not sure how to add this using this structure

# Deviations
rowNam_Dev <- getName(string = MG_row, pattern = c("Dev"))
# SS_Param2023$MG_params$Dev <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_Dev)
SS_Param2023$MG_params$Dev <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_Dev)

# Female fraction
rowNam_FracFem <- getName(string = MG_row, pattern = c("FracFem"))
# SS_Param2023$MG_params$FracFem <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_FracFem)
SS_Param2023$MG_params$FracFem <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_FracFem)

# ********************************

# SR parameters ----
SS_Param2023$SR_params$Content <- "These are the Stock-recruitment relationship parameters"
SS_Param2023$SR_params$param <- doDat(Data_colnames = ParVal_colnames, RowNam = SR_row)
# ********************************

# Q parameters ----
SS_Param2023$Q_params$Content <- "These are the Catchability parameters"
SS_Param2023$Q_params$param <- doDat(Data_colnames = ParVal_colnames, RowNam = Q_row)
# ********************************

# Selectivity parameters ----
SS_Param2023$Selex_params$Content <- "These are the Vulnerability (selectivity and retention) parameters"
SS_Param2023$Selex_params$param <- doDat(Data_colnames = ParVal_colnames, RowNam = Slx_row)
# ********************************

# Initial Fishing mortality parameters ----
SS_Param2023$init_F$Content <- "These are the initial fishing mortality parameters"
SS_Param2023$init_F$param <- doDat(Data_colnames = ParVal_colnames, RowNam = InitF_row)
# ********************************

# ===========================================================================


# Data ----

# Catch data ----
SS_Param2023$Catch$Content <- "These are the catch data"
Catch_colnames <- c("year", "season", "fleet", "catch", "catch_se")
# doDat(Data_colnames = Catch_colnames, RowNam = NULL)
names(landings3) == Catch_colnames
names(landings4) == Catch_colnames

SS_Param2023$Catch$data$fleet4 <- landings4
SS_Param2023$Catch$data$fleet3 <- landings3

# Survey data ----
SS_Param2023$Indices$Content <- "These are the survey data"
Srv_colnames <- c("year", "season", "index", "obs", "se_log")
# doDat(Data_colnames = Srv_colnames, RowNam = NULL)
names(srv_db_all) == Srv_colnames
SS_Param2023$Indices$data$mb_all <- srv_mb_all
SS_Param2023$Indices$data$mb_noslope <- srv_mb_noslope
SS_Param2023$Indices$data$db_all <- srv_db_all
SS_Param2023$Indices$data$db_noslope <- srv_db_noslope

# Discard data ----
SS_Param2023$discard_fleets$Content <- "These are the discards data"
Dscd_colnames <- c("year", "season", "fleet", "discard", "std_in")
# doDat(Data_colnames = Dscd_colnames, RowNam = NULL)
names(discard_rates4) <- Dscd_colnames
names(discard_rates3) <- Dscd_colnames
SS_Param2023$discard_fleets$data$fleet4 <- discard_rates4
SS_Param2023$discard_fleets$data$fleet3 <- discard_rates3

discard_

# Meanbodywt data ----
SS_Param2023$Meanbodywt$Content <- "These are the Meanbodywt (weight/length) data"
MeanBody_colnames <- c("year", "season", "fleet", "partition", "type", "obs", "std_in")
names(discard_weights4) <- MeanBody_colnames
names(discard_weights3) <- MeanBody_colnames
# doDat(Data_colnames = MeanBody_colnames, RowNam = NULL)
SS_Param2023$Meanbodywt$data$fleet4 <- discard_weights4
SS_Param2023$Meanbodywt$data$fleet3 <- discard_weights3

#  fishery lencomps data ----
SS_Param2023$Fishery_LengthComp$Content <- "These are the fishery length composition data"
Lcomp_colnames <- c("year","season","fleet","sex","partition","Nsamp", paste0("f", Lbin_vect),paste0("m", Lbin_vect))
# doDat(Data_colnames = Lcomp_colnames, RowNam = NULL)
names(landings_lencomps4) <- Lcomp_colnames
names(landings_lencomps3) <- Lcomp_colnames
names(discard_lencomps4) <- Lcomp_colnames
names(discard_lencomps3) <- Lcomp_colnames
fshcomps4 <- rbind(landings_lencomps4, discard_lencomps4)
fshcomps3 <- rbind(landings_lencomps3, discard_lencomps3)

SS_Param2023$Fishery_LengthComp$data$fleet4 <- fshcomps4
SS_Param2023$Fishery_LengthComp$data$fleet3 <- fshcomps3
  
#  survey length comps ----
SS_Param2023$Survey_LengthComp$Content <- "These are the survey length composition data"
Lcomp_colnames <- c("year","season","fleet","sex","partition","Nsamp", paste0("f", Lbin_vect),paste0("m", Lbin_vect))
names(srv_len_all) <- Lcomp_colnames
names(srv_len_noslope) <- Lcomp_colnames
# doDat(Data_colnames = Lcomp_colnames, RowNam = NULL)
SS_Param2023$Survey_LengthComp$data$all <- srv_len_all
SS_Param2023$Survey_LengthComp$data$noslope <- srv_len_noslope

#  survey length comps ----
SS_Param2023$Survey_LengthComp$Content <- "These are the survey length composition data"
Lcomp_colnames <- c("year","season","fleet","sex","partition","Nsamp", paste0("f", Lbin_vect),paste0("m", Lbin_vect))
names(srv_len_all) <- Lcomp_colnames
names(srv_len_noslope) <- Lcomp_colnames
# doDat(Data_colnames = Lcomp_colnames, RowNam = NULL)
SS_Param2023$Survey_LengthComp$data$all <- srv_len_all
SS_Param2023$Survey_LengthComp$data$noslope <- srv_len_noslope


# ===========================================================================

save(SS_Param2023,
     file = file.path(dir_SS, "SST_SS_2023_Data_Parameters.RData", fsep = fsep))
