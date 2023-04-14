# Stock: Shortspine thornyhead
# Set up the Rdata to save the parameters and the data that will feed SS input files
# authors: Matthieu VERON, Jane Sullivan, Josh Zahner
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

# survey index and length comp data: alternatives include design vs glmbTMB
# model based indices, configurations which include and exclude the afsc slope,
# and also a version with the triennial survey combined into two indices (it was
# previous split by shallow/deep due to sampling issues in the early years
srv_db_all <-  read_csv(file.path(dir_dat, "survey_db_indices_all_2023.csv"))
srv_db_noslope <-  read_csv(file.path(dir_dat, "survey_db_indices_noslope_2023.csv"))
srv_mb_all <-  read_csv(file.path(dir_dat, "survey_mb_indices_all_2023.csv"))
srv_mb_noslope <-  read_csv(file.path(dir_dat, "survey_mb_indices_noslope_2023.csv"))
srv_len_all <- read_csv(file.path(dir_dat, "survey_length_comps_all_2023.csv"))
srv_len_noslope <- read_csv(file.path(dir_dat, "survey_length_comps_noslope_2023.csv"))
#srv_combined_triennial <- read_csv(file.path(dir_dat, "survey_length_comps_single_triennial_2023.csv"))
#srv_noslope_combined_triennial <- read_csv(file.path(dir_dat, "survey_length_comps_no_slope_combined_triennial_2023.csv"))

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
# using 2013 "offset" approach
# SS_Param2023$MG_params$M$base_2023$Value <- c(natmat$initM, 0, 0, 0)
# 2023 approach - just use the actual value
SS_Param2023$MG_params$M$base_2023$Value <- rep(natmat$initM, 4)

# 2013 sensitivity
SS_Param2023$MG_params$M$assess_2013 <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_M)
SS_Param2023$MG_params$M$assess_2013$Value <- rep(0.0505, 4) 

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

# Number of Fleets ----
SS_Param2023$Nfleets$Content <- "Number of fleets - fisheries + surveys. The FourFleets_UseSlope_SplitTriennial was used in 2013. The ThreeFleets_NoSlope_CombineTriennial is our goal for 2023. The rest are intermediate."
SS_Param2023$Nfleets$data$FourFleets_UseSlope_SplitTriennial <- 9 # this is where 
SS_Param2023$Nfleets$data$ThreeFleets_NoSlope_CombineTriennial <- 6 # this is where we're headed
SS_Param2023$Nfleets$data$ThreeFleets_NoSlope_SplitTriennial <- 6 # these are intermediates
SS_Param2023$Nfleets$data$ThreeFleets_UseSlope_CombineTriennial <- 8
SS_Param2023$Nfleets$data$FourFleets_UseSlope_CombineTriennial <- 9
SS_Param2023$Nfleets$data$FourFleets_NoSlope_CombineTriennial <- 7

# Number of fleet (fisheries!!) ----
SS_Param2023$Nfleet$Content <- "Number of fisheries "
SS_Param2023$Nfleet$data$FourFleets_UseSlope_SplitTriennial <- 4 # this is where 
SS_Param2023$Nfleet$data$ThreeFleets_NoSlope_CombineTriennial <- 3 # this is where we're headed
SS_Param2023$Nfleet$data$ThreeFleets_NoSlope_SplitTriennial <- 3 # these are intermediates
SS_Param2023$Nfleet$data$ThreeFleets_UseSlope_CombineTriennial <- 3
SS_Param2023$Nfleet$data$FourFleets_UseSlope_CombineTriennial <- 4
SS_Param2023$Nfleet$data$FourFleets_NoSlope_CombineTriennial <- 4

# Number of surveys ----
SS_Param2023$Nsurveys$Content <- "Number of surveys "
SS_Param2023$Nsurveys$data$FourFleets_UseSlope_SplitTriennial <- 5 # this is where 
SS_Param2023$Nsurveys$data$ThreeFleets_NoSlope_CombineTriennial <- 3 # this is where we're headed
SS_Param2023$Nsurveys$data$ThreeFleets_NoSlope_SplitTriennial <- 3 # these are intermediates
SS_Param2023$Nsurveys$data$ThreeFleets_UseSlope_CombineTriennial <- 5
SS_Param2023$Nsurveys$data$FourFleets_UseSlope_CombineTriennial <- 5
SS_Param2023$Nsurveys$data$FourFleets_NoSlope_CombineTriennial <- 3

# Areas -----

SS_Param2023$areas$Content <- "Define the areas vectors to the length of Nfleets. Note we only have one areas for all fleet structure options."
SS_Param2023$areas$data$FourFleets_UseSlope_SplitTriennial <- rep(1, SS_Param2023$Nfleets$data$FourFleets_UseSlope_SplitTriennial) 
SS_Param2023$areas$data$ThreeFleets_NoSlope_CombineTriennial <- rep(1, SS_Param2023$Nfleets$data$ThreeFleets_NoSlope_CombineTriennial)
SS_Param2023$areas$data$ThreeFleets_NoSlope_SplitTriennial <- rep(1, SS_Param2023$Nfleets$data$ThreeFleets_NoSlope_SplitTriennial)
SS_Param2023$areas$data$ThreeFleets_UseSlope_CombineTriennial <- rep(1, SS_Param2023$Nfleets$data$ThreeFleets_UseSlope_CombineTriennial)
SS_Param2023$areas$data$FourFleets_UseSlope_CombineTriennial <- rep(1, SS_Param2023$Nfleets$data$FourFleets_UseSlope_CombineTriennial)
SS_Param2023$areas$data$FourFleets_NoSlope_CombineTriennial <- rep(1, SS_Param2023$Nfleets$data$FourFleets_NoSlope_CombineTriennial)

# Survey timing -----

SS_Param2023$surveytiming$Content <- "Define the survey timing vector for the length of Nfleets. Note all the surveys happen in the middle of the year, 0.5"
SS_Param2023$surveytiming$data$FourFleets_UseSlope_SplitTriennial <- rep(0.5, SS_Param2023$Nfleets$data$FourFleets_UseSlope_SplitTriennial) 
SS_Param2023$surveytiming$data$ThreeFleets_NoSlope_CombineTriennial <- rep(0.5, SS_Param2023$Nfleets$data$ThreeFleets_NoSlope_CombineTriennial)
SS_Param2023$surveytiming$data$ThreeFleets_NoSlope_SplitTriennial <- rep(0.5, SS_Param2023$Nfleets$data$ThreeFleets_NoSlope_SplitTriennial)
SS_Param2023$surveytiming$data$ThreeFleets_UseSlope_CombineTriennial <- rep(0.5, SS_Param2023$Nfleets$data$ThreeFleets_UseSlope_CombineTriennial)
SS_Param2023$surveytiming$data$FourFleets_UseSlope_CombineTriennial <- rep(0.5, SS_Param2023$Nfleets$data$FourFleets_UseSlope_CombineTriennial)
SS_Param2023$surveytiming$data$FourFleets_NoSlope_CombineTriennial <- rep(0.5, SS_Param2023$Nfleets$data$FourFleets_NoSlope_CombineTriennial)

# Fleet names ----

SS_Param2023$fleetnames$Content <- "Fleet (fishery + survey) names for each fleet structure"
SS_Param2023$fleetnames$data$FourFleets_UseSlope_SplitTriennial <- c("Trawl_N", "Trawl_S", "Non-trawl_N", "Non-trawl_S", 
                                                                     "Triennial1", "Triennial2", "AFSCslope", "NWFSCslope", "NWFSCcombo") # this is where we were in 2013
SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_CombineTriennial <- c("Trawl_N", "Trawl_S", "Non-trawl", 
                                                                       "Triennial1", "Triennial2", "NWFSCcombo") # this is where we're headed in 2023
SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_SplitTriennial <- c("Trawl_N", "Trawl_S", "Non-trawl", 
                                                                     "Triennial1", "Triennial2", "NWFSCcombo") 
SS_Param2023$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial <- c("Trawl_N", "Trawl_S", "Non-trawl", 
                                                                        "Triennial1", "Triennial2", "AFSCslope", "NWFSCslope", "NWFSCcombo")
SS_Param2023$fleetnames$data$FourFleets_UseSlope_CombineTriennial <- c("Trawl_N", "Trawl_S", "Non-trawl_N", "Non-trawl_S",
                                                                       "Triennial1", "Triennial2", "AFSCslope", "NWFSCslope", "NWFSCcombo")
SS_Param2023$fleetnames$data$FourFleets_NoSlope_CombineTriennial <- c("Trawl_N", "Trawl_S", "Non-trawl_N", "Non-trawl_S",
                                                                      "Triennial1", "Triennial2", "NWFSCcombo")
# Fleet info ----

SS_Param2023$fleet_info$Content <- "Our fleet structure - fisheries + surveys"
Fleet_colnames <- c("type", "surveytiming", "area", "units", "need_catch_mult", "fleetname")
make_fleet_info <- function(nfsh, nsrv, fleetnames) {
  
  if(nfsh + nsrv != length(fleetnames)) stop('your fleetnames input vector must equal the number of fisheries and surveys combined nfsh + nsrv')
  
  data.frame(type = c(rep(1, nfsh), rep(3, nsrv)), # 1=input catches, 3=survey
             surveytiming = 0.5,
             area = 1,
             units = c(rep(1, nfsh), rep(1, nsrv)), # both fisheries and surveys in units of biomass
             need_catch_mult = 0,
             fleetname = fleetnames) 
}

# this is where we were in 2013
SS_Param2023$fleet_info$data$FourFleets_UseSlope_SplitTriennial <- make_fleet_info(
  nfsh = 4, nsrv = 5, fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_SplitTriennial)

# this is where we're headed in 2023
SS_Param2023$fleet_info$data$ThreeFleets_NoSlope_CombineTriennial <- make_fleet_info(
  nfsh = 3, nsrv = 3, fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_CombineTriennial)

SS_Param2023$fleet_info$data$ThreeFleets_NoSlope_SplitTriennial <- make_fleet_info(
  nfsh = 3, nsrv = 3, fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_SplitTriennial)

SS_Param2023$fleet_info$data$ThreeFleets_UseSlope_CombineTriennial <- make_fleet_info(
  nfsh = 3, nsrv = 5, fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial)

SS_Param2023$fleet_info$data$FourFleets_UseSlope_CombineTriennial <- make_fleet_info(
  nfsh = 4, nsrv = 5, fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_CombineTriennial)

SS_Param2023$fleet_info$data$FourFleets_NoSlope_CombineTriennial <- make_fleet_info(
  nfsh = 4, nsrv = 3, fleetnames = SS_Param2023$fleetnames$data$FourFleets_NoSlope_CombineTriennial)

# units of catch ----

SS_Param2023$units_of_catch$Content <- "units of catch, numbers or biomass"
SS_Param2023$units_of_catch$data$FourFleets_UseSlope_SplitTriennial <- SS_Param2023$fleet_info$data$FourFleets_UseSlope_SplitTriennial$units
SS_Param2023$units_of_catch$data$ThreeFleets_NoSlope_CombineTriennial <- SS_Param2023$fleet_info$data$ThreeFleets_NoSlope_CombineTriennial$units
SS_Param2023$units_of_catch$data$ThreeFleets_NoSlope_SplitTriennial <- SS_Param2023$fleet_info$data$ThreeFleets_NoSlope_SplitTriennial$units
SS_Param2023$units_of_catch$data$ThreeFleets_UseSlope_CombineTriennial <- SS_Param2023$fleet_info$data$ThreeFleets_UseSlope_CombineTriennial$units
SS_Param2023$units_of_catch$data$FourFleets_UseSlope_CombineTriennial <- SS_Param2023$fleet_info$data$FourFleets_UseSlope_CombineTriennial$units
SS_Param2023$units_of_catch$data$FourFleets_NoSlope_CombineTriennial <- SS_Param2023$fleet_info$data$FourFleets_NoSlope_CombineTriennial$units

# CPUE info ----

SS_Param2023$CPUE_info$Content <- "Our CPUE info for all fleets"

make_CPUEinfo <- function(fleet_info) {
  # fleet_info <- SS_Param2023$fleet_info$data$FourFleets_UseSlope_SplitTriennial
  # Dat23_land_update$CPUEinfo
  tmp <- data.frame(Fleet = rownames(fleet_info),
             Units = fleet_info$units,
             ErrType = 0, # flag!! check which error distribution we should use for MB Indices
             SD_Report = 0)
  rownames(tmp) <- fleet_info$fleetname
  return(tmp)
}

# this is where we were in 2013
SS_Param2023$CPUEinfo$data$FourFleets_UseSlope_SplitTriennial <- make_CPUEinfo(fleet_info = SS_Param2023$fleet_info$data$FourFleets_UseSlope_SplitTriennial)
# this is where we're headed in 2023
SS_Param2023$CPUEinfo$data$ThreeFleets_NoSlope_CombineTriennial <- make_CPUEinfo(fleet_info = SS_Param2023$fleet_info$data$ThreeFleets_NoSlope_CombineTriennial)
SS_Param2023$CPUEinfo$data$ThreeFleets_NoSlope_SplitTriennial <- make_CPUEinfo(fleet_info = SS_Param2023$fleet_info$data$ThreeFleets_NoSlope_SplitTriennial)
SS_Param2023$CPUEinfo$data$ThreeFleets_UseSlope_CombineTriennial <- make_CPUEinfo(fleet_info = SS_Param2023$fleet_info$data$ThreeFleets_UseSlope_CombineTriennial)
SS_Param2023$CPUEinfo$data$FourFleets_UseSlope_CombineTriennial <- make_CPUEinfo(fleet_info = SS_Param2023$fleet_info$data$FourFleets_UseSlope_CombineTriennial)
SS_Param2023$CPUEinfo$data$FourFleets_NoSlope_CombineTriennial <- make_CPUEinfo(fleet_info = SS_Param2023$fleet_info$data$FourFleets_NoSlope_CombineTriennial)

# N_discard_fleets ----
SS_Param2023$N_discard_fleets$Content <- "Number of discard fleets"
SS_Param2023$N_discard_fleets$data$FourFleets_UseSlope_SplitTriennial <- 4 # this is where 
SS_Param2023$N_discard_fleets$data$ThreeFleets_NoSlope_CombineTriennial <- 3 # this is where we're headed
SS_Param2023$N_discard_fleets$data$ThreeFleets_NoSlope_SplitTriennial <- 3 # these are intermediates
SS_Param2023$N_discard_fleets$data$ThreeFleets_UseSlope_CombineTriennial <- 3
SS_Param2023$N_discard_fleets$data$FourFleets_UseSlope_CombineTriennial <- 4
SS_Param2023$N_discard_fleets$data$FourFleets_NoSlope_CombineTriennial <- 4

# discard_fleet_info
make_discard_fleet_info <- function(fleetnames) {
  tmp <- data.frame(Fleet = 1:length(fleetnames),
             units = 2,
             errtype = 30 # CV 
             )
  rownames(tmp) <- fleetnames
  return(tmp)
}

SS_Param2023$discard_fleet_info$Content <- "Discard fleet info"
SS_Param2023$discard_fleet_info$data$FourFleets_UseSlope_SplitTriennial <- make_discard_fleet_info(fleetnames =  c("Trawl_N", "Trawl_S", "Non-trawl_N", "Non-trawl_S"))# this is where 
SS_Param2023$discard_fleet_info$data$ThreeFleets_NoSlope_CombineTriennial <- make_discard_fleet_info(fleetnames =  c("Trawl_N", "Trawl_S", "Non-trawl")) # this is where we're headed
SS_Param2023$discard_fleet_info$data$ThreeFleets_NoSlope_SplitTriennial <- make_discard_fleet_info(fleetnames =  c("Trawl_N", "Trawl_S", "Non-trawl")) # these are intermediates
SS_Param2023$discard_fleet_info$data$ThreeFleets_UseSlope_CombineTriennial <- make_discard_fleet_info(fleetnames =  c("Trawl_N", "Trawl_S", "Non-trawl"))
SS_Param2023$discard_fleet_info$data$FourFleets_UseSlope_CombineTriennial <- make_discard_fleet_info(fleetnames =  c("Trawl_N", "Trawl_S", "Non-trawl_N", "Non-trawl_S"))
SS_Param2023$discard_fleet_info$data$FourFleets_NoSlope_CombineTriennial <- make_discard_fleet_info(fleetnames =  c("Trawl_N", "Trawl_S", "Non-trawl_N", "Non-trawl_S"))

# len info ----

make_len_info <- function(fleetnames) {
  tmp <- data.frame(mintailcomp = rep(-1, length(fleetnames)),
             addtocomp = 0.001,
             combine_M_F = 0,
             CompressBins = 0,
             CompError = 0,
             ParmSelect = 0,
             minsamplesize = 1)
  rownames(tmp) <- fleetnames
  return(tmp)
}

SS_Param2023$len_info$Content <- "Assumptions for length comps"

SS_Param2023$len_info$data$FourFleets_UseSlope_SplitTriennial <- make_len_info(fleetnames = c("Trawl_N", "Trawl_S", "Non-trawl_N", "Non-trawl_S", 
                                                                     "Triennial1", "Triennial2", "AFSCslope", "NWFSCslope", "NWFSCcombo")) # this is where we were in 2013
SS_Param2023$len_info$data$ThreeFleets_NoSlope_CombineTriennial <- make_len_info(fleetnames = c("Trawl_N", "Trawl_S", "Non-trawl", 
                                                                      "Triennial1", "Triennial2", "NWFSCcombo")) # this is where we're headed in 2023
SS_Param2023$len_info$data$ThreeFleets_NoSlope_SplitTriennial <- make_len_info(fleetnames = c("Trawl_N", "Trawl_S", "Non-trawl", 
                                                                     "Triennial1", "Triennial2", "NWFSCcombo") )
SS_Param2023$len_info$data$ThreeFleets_UseSlope_CombineTriennial <- make_len_info(fleetnames = c("Trawl_N", "Trawl_S", "Non-trawl", 
                                                                        "Triennial1", "Triennial2", "AFSCslope", "NWFSCslope", "NWFSCcombo"))
SS_Param2023$len_info$data$FourFleets_UseSlope_CombineTriennial <- make_len_info(fleetnames = c("Trawl_N", "Trawl_S", "Non-trawl_N", "Non-trawl_S",
                                                                       "Triennial1", "Triennial2", "AFSCslope", "NWFSCslope", "NWFSCcombo"))
SS_Param2023$len_info$data$FourFleets_NoSlope_CombineTriennial <- make_len_info(fleetnames = c("Trawl_N", "Trawl_S", "Non-trawl_N", "Non-trawl_S",
                                                                      "Triennial1", "Triennial2", "NWFSCcombo"))
# Dynamically modified fleet indexing for when the number
# of fishery fleets changes.
fix.fleet.indexing <- function(data, start.index){
  data %>%
    mutate(fleet=fleet-(min(fleet)-start.index))
}


fix.fleet.indexing.lc <- function(data, start.index){
  data %>%
    mutate(FltSvy=FltSvy-(min(FltSvy)-start.index))
}

# Catch data ----
SS_Param2023$Catch$Content <- "These are the catch data"
Catch_colnames <- c("year", "seas", "fleet", "catch", "catch_se")
# doDat(Data_colnames = Catch_colnames, RowNam = NULL)
names(landings3) <- Catch_colnames
names(landings4) <- Catch_colnames

SS_Param2023$Catch$data$FourFleets_UseSlope_SplitTriennial <- as.data.frame(landings4)
SS_Param2023$Catch$data$FourFleets_UseSlope_CombineTriennial <- as.data.frame(landings4)
SS_Param2023$Catch$data$FourFleets_NoSlope_CombineTriennial <- as.data.frame(landings4)
SS_Param2023$Catch$data$ThreeFleets_NoSlope_CombineTriennial <- as.data.frame(landings3)
SS_Param2023$Catch$data$ThreeFleets_NoSlope_SplitTriennial <- as.data.frame(landings3)
SS_Param2023$Catch$data$ThreeFleets_UseSlope_CombineTriennial <- as.data.frame(landings3)

# Survey data ----
SS_Param2023$Indices$Content <- "These are the survey data"
Srv_colnames <- c("year", "season", "index", "obs", "se_log")
# doDat(Data_colnames = Srv_colnames, RowNam = NULL)
names(srv_db_all) <- Srv_colnames
SS_Param2023$Indices$data$FourFleets_UseSlope_SplitTriennial <- as.data.frame(srv_db_all)
SS_Param2023$Indices$data$FourFleets_UseSlope_CombineTriennial <- as.data.frame(srv_mb_all)
SS_Param2023$Indices$data$FourFleets_NoSlope_CombineTriennial <- as.data.frame(srv_mb_noslope)
SS_Param2023$Indices$data$ThreeFleets_NoSlope_CombineTriennial <- as.data.frame(fix.fleet.indexing(srv_mb_noslope, start.index=4))
SS_Param2023$Indices$data$ThreeFleets_NoSlope_SplitTriennial <- as.data.frame(fix.fleet.indexing(srv_db_noslope, start.index=4))
SS_Param2023$Indices$data$ThreeFleets_UseSlope_CombineTriennial <- as.data.frame(fix.fleet.indexing(srv_mb_all, start.index=4))

# Discard data ----
SS_Param2023$discard_rates$Content <- "These are the discards data"
Dscd_colnames <- c("year", "season", "fleet", "discard", "std_in")
# doDat(Data_colnames = Dscd_colnames, RowNam = NULL)
names(discard_rates4) <- Dscd_colnames
names(discard_rates3) <- Dscd_colnames
SS_Param2023$discard_rates$data$FourFleets_UseSlope_SplitTriennial <- as.data.frame(discard_rates4)
SS_Param2023$discard_rates$data$FourFleets_UseSlope_CombineTriennial <- as.data.frame(discard_rates4)
SS_Param2023$discard_rates$data$FourFleets_NoSlope_CombineTriennial <- as.data.frame(discard_rates4)
SS_Param2023$discard_rates$data$ThreeFleets_NoSlope_CombineTriennial <- as.data.frame(discard_rates3)
SS_Param2023$discard_rates$data$ThreeFleets_NoSlope_SplitTriennial <- as.data.frame(discard_rates3)
SS_Param2023$discard_rates$data$ThreeFleets_UseSlope_CombineTriennial <- as.data.frame(discard_rates3)

# Meanbodywt data ----
SS_Param2023$Meanbodywt$Content <- "These are the Meanbodywt (weight/length) data"
MeanBody_colnames <- c("year", "season", "fleet", "partition", "type", "obs", "std_in")
names(discard_weights4) <- MeanBody_colnames
names(discard_weights3) <- MeanBody_colnames
# doDat(Data_colnames = MeanBody_colnames, RowNam = NULL)
SS_Param2023$Meanbodywt$data$FourFleets_UseSlope_SplitTriennial <- as.data.frame(discard_weights4)
SS_Param2023$Meanbodywt$data$FourFleets_UseSlope_CombineTriennial <- as.data.frame(discard_weights4)
SS_Param2023$Meanbodywt$data$FourFleets_NoSlope_CombineTriennial <- as.data.frame(discard_weights4)
SS_Param2023$Meanbodywt$data$ThreeFleets_NoSlope_CombineTriennial <- as.data.frame(discard_weights3)
SS_Param2023$Meanbodywt$data$ThreeFleets_NoSlope_SplitTriennial <- as.data.frame(discard_weights3)
SS_Param2023$Meanbodywt$data$ThreeFleets_UseSlope_CombineTriennial <- as.data.frame(discard_weights3)

#  fishery lencomps data ----
SS_Param2023$Fishery_LengthComp$Content <- "These are the fishery length composition data"
Lcomp_colnames <- c("year","season","fleet","sex","partition","Nsamp", paste0("f", Lbin_vect),paste0("m", Lbin_vect))
# doDat(Data_colnames = Lcomp_colnames, RowNam = NULL)
names(landings_lencomps4) <- Lcomp_colnames
names(landings_lencomps3) <- Lcomp_colnames
names(discard_lencomps4) <- Lcomp_colnames
names(discard_lencomps3) <- Lcomp_colnames
fshcomps4 <- as.data.frame(rbind(landings_lencomps4, discard_lencomps4))
fshcomps3 <- as.data.frame(rbind(landings_lencomps3, discard_lencomps3))

SS_Param2023$Fishery_LengthComp$data$FourFleets_UseSlope_SplitTriennial <- fshcomps4
SS_Param2023$Fishery_LengthComp$data$FourFleets_UseSlope_CombineTriennial <- fshcomps4
SS_Param2023$Fishery_LengthComp$data$FourFleets_NoSlope_CombineTriennial <- fshcomps4
SS_Param2023$Fishery_LengthComp$data$ThreeFleets_NoSlope_CombineTriennial <- fshcomps3
SS_Param2023$Fishery_LengthComp$data$ThreeFleets_NoSlope_SplitTriennial <- fshcomps3
SS_Param2023$Fishery_LengthComp$data$ThreeFleets_UseSlope_CombineTriennial <- fshcomps3

#  survey length comps ----
SS_Param2023$Survey_LengthComp$Content <- "These are the survey length composition data"
Lcomp_colnames <- c("year","season","fleet","sex","partition","Nsamp", paste0("f", Lbin_vect),paste0("m", Lbin_vect))
names(srv_len_all) <- Lcomp_colnames
names(srv_len_noslope) <- Lcomp_colnames

# doDat(Data_colnames = Lcomp_colnames, RowNam = NULL)
SS_Param2023$Survey_LengthComp$data$FourFleets_UseSlope_SplitTriennial <- as.data.frame(srv_len_all %>% replace(is.na(.), 0)) 
SS_Param2023$Survey_LengthComp$data$FourFleets_UseSlope_CombineTriennial <- as.data.frame(srv_len_all %>% replace(is.na(.), 0))
SS_Param2023$Survey_LengthComp$data$FourFleets_NoSlope_CombineTriennial <- as.data.frame(srv_len_noslope %>% replace(is.na(.), 0))
SS_Param2023$Survey_LengthComp$data$ThreeFleets_NoSlope_CombineTriennial <- as.data.frame(fix.fleet.indexing.lc(srv_len_noslope %>% rename(FltSvy=fleet), start.index=4) %>% replace(is.na(.), 0))
SS_Param2023$Survey_LengthComp$data$ThreeFleets_NoSlope_SplitTriennial <- as.data.frame(fix.fleet.indexing(srv_len_noslope, start.index=4) %>% replace(is.na(.), 0))
SS_Param2023$Survey_LengthComp$data$ThreeFleets_UseSlope_CombineTriennial <- as.data.frame(fix.fleet.indexing.lc(srv_len_all %>% rename(FltSvy=fleet), start.index=4) %>% replace(is.na(.), 0))

# all length comps ----

SS_Param2023$All_LengthComp$data$FourFleets_UseSlope_SplitTriennial <- as.data.frame(rbind(SS_Param2023$Fishery_LengthComp$data$FourFleets_UseSlope_SplitTriennial, 
                                                                                           setNames(SS_Param2023$Survey_LengthComp$data$FourFleets_UseSlope_SplitTriennial,
                                                                                                    names(SS_Param2023$Fishery_LengthComp$data$FourFleets_UseSlope_SplitTriennial))))
SS_Param2023$All_LengthComp$data$FourFleets_UseSlope_CombineTriennial <- as.data.frame(rbind(SS_Param2023$Fishery_LengthComp$data$FourFleets_UseSlope_CombineTriennial, 
                                                                                             setNames(SS_Param2023$Survey_LengthComp$data$FourFleets_UseSlope_CombineTriennial,
                                                                                                      names(SS_Param2023$Fishery_LengthComp$data$FourFleets_UseSlope_CombineTriennial))))
SS_Param2023$All_LengthComp$data$FourFleets_NoSlope_CombineTriennial <- as.data.frame(rbind(SS_Param2023$Fishery_LengthComp$data$FourFleets_NoSlope_CombineTriennial, 
                                                                                           setNames(SS_Param2023$Survey_LengthComp$data$FourFleets_NoSlope_CombineTriennial,
                                                                                                    names(SS_Param2023$Fishery_LengthComp$data$FourFleets_NoSlope_CombineTriennial))))
SS_Param2023$All_LengthComp$data$ThreeFleets_NoSlope_CombineTriennial <- as.data.frame(rbind(SS_Param2023$Fishery_LengthComp$data$ThreeFleets_NoSlope_CombineTriennial, 
                                                                                           setNames(SS_Param2023$Survey_LengthComp$data$ThreeFleets_NoSlope_CombineTriennial,
                                                                                                    names(SS_Param2023$Fishery_LengthComp$data$ThreeFleets_NoSlope_CombineTriennial))))
SS_Param2023$All_LengthComp$data$ThreeFleets_NoSlope_SplitTriennial <- as.data.frame(rbind(SS_Param2023$Fishery_LengthComp$data$ThreeFleets_NoSlope_SplitTriennial, 
                                                                                           setNames(SS_Param2023$Survey_LengthComp$data$ThreeFleets_NoSlope_SplitTriennial,
                                                                                                    names(SS_Param2023$Fishery_LengthComp$data$ThreeFleets_NoSlope_SplitTriennial))))
SS_Param2023$All_LengthComp$data$ThreeFleets_UseSlope_CombineTriennial <- as.data.frame(rbind(SS_Param2023$Fishery_LengthComp$data$ThreeFleets_UseSlope_CombineTriennial, 
                                                                                           setNames(SS_Param2023$Survey_LengthComp$data$ThreeFleets_UseSlope_CombineTriennial,
                                                                                                    names(SS_Param2023$Fishery_LengthComp$data$ThreeFleets_UseSlope_CombineTriennial))))
# Q params ----

make_Q_parms <- function(fleetnames) {
 
  tmp <- Ctl23_sq_fixQ$Q_parms %>% 
    tibble::rownames_to_column()
  
  # get rid of slope surveys if not used
  if(all(!grepl('slope', fleetnames))) {
    tmp <- tmp %>% filter(!grepl('slope', rowname))
  }
  
  # deal with combined Triennial survey and the special case from previous
  # assessment where Triennial1 had an extra SD estimated
  if(all(!grepl('Triennial1', fleetnames))) {
    tmp <- tmp %>% filter(!grepl('Triennial1', rowname))
    tmp <- tmp %>% 
      mutate(new_rowname = paste0('LnQ_base_', fleetnames[!grepl('trawl|Trawl', fleetnames)], 
                                  '(', (length(grep('trawl|Trawl', fleetnames)) + 1):length(fleetnames), ')')) %>% 
      select(-rowname) %>% 
      tibble::column_to_rownames(var = 'new_rowname')
    
  } else {
   
    new_fleetnames <- c(fleetnames[!grepl('trawl|Trawl', fleetnames)][1], fleetnames[!grepl('trawl|Trawl', fleetnames)])
    new_index <- c(((length(grep('trawl|Trawl', fleetnames)) + 1):length(fleetnames))[1], (length(grep('trawl|Trawl', fleetnames)) + 1):length(fleetnames))
    parnames <- c('LnQ_base_', 'Q_extraSD_', rep('LnQ_base_', length(unique(new_fleetnames))-1))
     
    tmp <- tmp %>% 
      mutate(new_rowname = paste0(parnames, new_fleetnames, '(', new_index, ')')) %>% 
      select(-rowname) %>% 
      tibble::column_to_rownames(var = 'new_rowname')
    
  }
  return(tmp)
}

SS_Param2023$Q_parms$Content <- "Survey catchability parameters including estimating extra SE"
SS_Param2023$Q_parms$data$FourFleets_UseSlope_SplitTriennial <- make_Q_parms(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_SplitTriennial)
SS_Param2023$Q_parms$data$FourFleets_UseSlope_CombineTriennial <-  make_Q_parms(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_CombineTriennial)
SS_Param2023$Q_parms$data$FourFleets_NoSlope_CombineTriennial <-  make_Q_parms(fleetnames = SS_Param2023$fleetnames$data$FourFleets_NoSlope_CombineTriennial)
SS_Param2023$Q_parms$data$ThreeFleets_NoSlope_CombineTriennial <-  make_Q_parms(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_CombineTriennial)
SS_Param2023$Q_parms$data$ThreeFleets_NoSlope_SplitTriennial <-  make_Q_parms(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_SplitTriennial)
SS_Param2023$Q_parms$data$ThreeFleets_UseSlope_CombineTriennial <-  make_Q_parms(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial)

# Q options ----

make_Q_options <- function(fleetnames) {

    tmp <- data.frame(fleet = (length(grep('trawl|Trawl', fleetnames)) + 1):length(fleetnames),
                      link = 1,
                      link_info = 0,
                      extra_se = 0,
                      biasadj = 0,
                      float = 1)
  rownames(tmp) <- fleetnames[!grepl('trawl|Trawl', fleetnames)]
  if(any(rownames(tmp) %in% c('Triennial1'))){
    tmp[rownames(tmp) %in% c('Triennial1'),]$extra_se <- 1
  }
  return(tmp)
}
SS_Param2023$Q_options$Content <- "Options for survey catchability parameters like floating or estimating extra SE"
SS_Param2023$Q_options$data$FourFleets_UseSlope_SplitTriennial <- make_Q_options(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_SplitTriennial)
SS_Param2023$Q_options$data$FourFleets_UseSlope_CombineTriennial <-  make_Q_options(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_CombineTriennial)
SS_Param2023$Q_options$data$FourFleets_NoSlope_CombineTriennial <-  make_Q_options(fleetnames = SS_Param2023$fleetnames$data$FourFleets_NoSlope_CombineTriennial)
SS_Param2023$Q_options$data$ThreeFleets_NoSlope_CombineTriennial <-  make_Q_options(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_CombineTriennial)
SS_Param2023$Q_options$data$ThreeFleets_NoSlope_SplitTriennial <-  make_Q_options(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_SplitTriennial)
SS_Param2023$Q_options$data$ThreeFleets_UseSlope_CombineTriennial <-  make_Q_options(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial)

# # Selectivity ----
# 
# names(Ctl23_sq_fixQ)
# Ctl23_sq_fixQ$size_selex_types
# Ctl23_sq_fixQ$size_selex_parms
# Ctl23_sq_fixQ$age_selex_types
# Ctl23_sq_fixQ$size_selex_parms_tv
# 
make_selex_types <- function(fleetnames, type="size") {

  #fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_SplitTriennial
  cname <- ifelse(type == "size", "size_selex_types", "age_selex_types")

  tmp <- Ctl23_sq_fixQ[[cname]] %>%
    tibble::rownames_to_column()

  # get rid of slope surveys if not used
  if(all(!grepl('slope', fleetnames))) {
    tmp <- tmp %>% filter(!grepl('slope', rowname))
  }
  
  # Condense non-trawl fleets if necesarry
  n.nontrawl.fleets <- sum(grepl("Non-trawl", fleetnames))
  if(n.nontrawl.fleets == 1){
    tmp <- tmp %>% filter(rowname != "Non-trawl_S") %>%
      mutate(rowname = case_when(rowname == "Non-trawl_N" ~ "Non-trawl",
                                 .default = rowname))
  }

  tmp <- tmp %>% tibble::column_to_rownames()
  
  return(tmp)
}

SS_Param2023$size_selex_types$Content <- "Size Selectivity type information"
SS_Param2023$size_selex_types$data$FourFleets_UseSlope_SplitTriennial <- make_selex_types(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_SplitTriennial, type="size")
SS_Param2023$size_selex_types$data$FourFleets_UseSlope_CombineTriennial <-  make_selex_types(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_CombineTriennial, type="size")
SS_Param2023$size_selex_types$data$FourFleets_NoSlope_CombineTriennial <-  make_selex_types(fleetnames = SS_Param2023$fleetnames$data$FourFleets_NoSlope_CombineTriennial, type="size")
SS_Param2023$size_selex_types$data$ThreeFleets_NoSlope_CombineTriennial <-  make_selex_types(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_CombineTriennial, type="size")
SS_Param2023$size_selex_types$data$ThreeFleets_NoSlope_SplitTriennial <-  make_selex_types(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_SplitTriennial, type="size")
SS_Param2023$size_selex_types$data$ThreeFleets_UseSlope_CombineTriennial <-  make_selex_types(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial, type="size")

SS_Param2023$age_selex_types$Content <- "Age Selectivity type information"
SS_Param2023$age_selex_types$data$FourFleets_UseSlope_SplitTriennial <- make_selex_types(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_SplitTriennial, type="age")
SS_Param2023$age_selex_types$data$FourFleets_UseSlope_CombineTriennial <-  make_selex_types(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_CombineTriennial, type="age")
SS_Param2023$age_selex_types$data$FourFleets_NoSlope_CombineTriennial <-  make_selex_types(fleetnames = SS_Param2023$fleetnames$data$FourFleets_NoSlope_CombineTriennial, type="age")
SS_Param2023$age_selex_types$data$ThreeFleets_NoSlope_CombineTriennial <-  make_selex_types(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_CombineTriennial, type="age")
SS_Param2023$age_selex_types$data$ThreeFleets_NoSlope_SplitTriennial <-  make_selex_types(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_SplitTriennial, type="age")
SS_Param2023$age_selex_types$data$ThreeFleets_UseSlope_CombineTriennial <-  make_selex_types(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial, type="age")


make_size_selex_parms <- function(fleetnames){
  
  tmp <- Ctl23_sq_fixQ$size_selex_parms %>%
    tibble::rownames_to_column()
  
  # get rid of slope surveys if not used
  if(all(!grepl('slope', fleetnames))) {
    tmp <- tmp %>% filter(!grepl('slope', rowname))
  }
  
  # Condense non-trawl fleets if necesarry
  n.nontrawl.fleets <- sum(grepl("Non-trawl", fleetnames))
  if(n.nontrawl.fleets == 1){
    tmp <- tmp %>% filter(!(grepl("Non-trawl_S", tmp$rowname)))
  }
  
  tri.idx <- which(fleetnames %in% c("Triennial", "Triennial1", "Triennial2"))
  num.tri <- length(tri.idx)
  tri.idx <- tri.idx[1]
  new.fleetnames <- c(fleetnames[1:(tri.idx-1)], "Triennial1", "Triennial2", fleetnames[(tri.idx+num.tri):length(fleetnames)])
  fleet.nums <- seq(1, length(new.fleetnames))
  full.fleetnames <- paste0(new.fleetnames, "(", fleet.nums, ")")
  
  n.fisheries <- sum(grepl("trawl|Trawl", new.fleetnames))
  n.surveys <- length(new.fleetnames)-n.fisheries
  
  par.names <- rep(NA, (10*n.fisheries + 6*n.surveys))
  i=1
  for(f in 1:length(new.fleetnames)){
    for(j in 1:6){
      par.name <- paste0("SizeSel_P_", j, "_", full.fleetnames[f])
      par.names[i] <- par.name
      i = i+1
    }
    if(f <= n.fisheries){
      for(j in 1:4){
        par.name <- paste0("SizeSel_PRet_", j, "_", full.fleetnames[f])
        par.names[i] <- par.name
        i = i+1
      }
    }
  }
  
  tmp <- tmp %>% mutate(rowname = par.names) %>% tibble::column_to_rownames()
  
  return(tmp)
  
}

SS_Param2023$size_selex_parms$Content <- "Size Selectivity parameter values."
SS_Param2023$size_selex_parms$data$FourFleets_UseSlope_SplitTriennial <- make_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_SplitTriennial)
SS_Param2023$size_selex_parms$data$FourFleets_UseSlope_CombineTriennial <- make_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_CombineTriennial)
SS_Param2023$size_selex_parms$data$FourFleets_NoSlope_CombineTriennial <- make_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$FourFleets_NoSlope_CombineTriennial)
SS_Param2023$size_selex_parms$data$ThreeFleets_NoSlope_CombineTriennial <- make_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_CombineTriennial)
SS_Param2023$size_selex_parms$data$ThreeFleets_NoSlope_SplitTriennial <- make_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_SplitTriennial)
SS_Param2023$size_selex_parms$data$ThreeFleets_UseSlope_CombineTriennial <- make_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial)

make_timevary_size_selex_parms <- function(fleetnames){
  
  is.three.fleet <- "Non-trawl" %in% fleetnames
  
  tmp <- Ctl23_sq_fixQ$size_selex_parms_tv %>%
    tibble::rownames_to_column()
  
  if(is.three.fleet){
    tmp <- tmp %>% filter(!(grepl("Non-trawl", tmp$rowname)))
  }
  
  tmp <- tmp %>% tibble::column_to_rownames()
  
  return(tmp)
  
}

SS_Param2023$size_selex_parms_tv$Content <- "Time Varying Size Selectivity parameter values."
SS_Param2023$size_selex_parms_tv$data$FourFleets_UseSlope_SplitTriennial <- make_timevary_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_SplitTriennial)
SS_Param2023$size_selex_parms_tv$data$FourFleets_UseSlope_CombineTriennial <- make_timevary_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_CombineTriennial)
SS_Param2023$size_selex_parms_tv$data$FourFleets_NoSlope_CombineTriennial <- make_timevary_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$FourFleets_NoSlope_CombineTriennial)
SS_Param2023$size_selex_parms_tv$data$ThreeFleets_NoSlope_CombineTriennial <- make_timevary_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_CombineTriennial)
SS_Param2023$size_selex_parms_tv$data$ThreeFleets_NoSlope_SplitTriennial <- make_timevary_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_SplitTriennial)
SS_Param2023$size_selex_parms_tv$data$ThreeFleets_UseSlope_CombineTriennial <- make_timevary_size_selex_parms(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial)


make_variance_adj_list <- function(fleetnames){
  
  tri.idx <- which(fleetnames %in% c("Triennial", "Triennial1", "Triennial2"))
  num.tri <- length(tri.idx)
  tri.idx <- tri.idx[1]
  fleetnames <- c(fleetnames[1:(tri.idx-1)], "Triennial1", "Triennial2", fleetnames[(tri.idx+num.tri):length(fleetnames)])
  
  adjust.factors = list(
    "Trawl_N" = 0.5595,
    "Trawl_S" = 0.9773,
    "Non-trawl_N" = 0.5422,
    "Non-trawl_S" = 0.4042,
    "Non-trawl" = 0.4723, # mean of the two non-trawl factors
    "Triennial1" = 0.6812,
    "Triennial2" = 0.6494,
    "AFSCslope" = 1.000,
    "NWFSCslope" = 0.5126,
    "NWFSCcombo" = 1.000
  )
  
  fleet.nums <- rep(seq(1:length(fleetnames)), 3)
  n.fleets <- max(fleet.nums)
  factors <- c(as.vector(unlist(adjust.factors[fleetnames])), rep(1.00, n.fleets*2))
  data.types <- rep(c(4, 5, 6), each=n.fleets)
  row <- paste0("Variance_adjustment_list", seq(1:length(fleet.nums)))
  
  return(data.frame(Data_type=data.types, Fleet=fleet.nums, Value=factors, row.names=row))
  
}

SS_Param2023$Variance_adjustment_list$Content <- "Variance Adjutment values."
SS_Param2023$Variance_adjustment_list$data$FourFleets_UseSlope_SplitTriennial <- make_variance_adj_list(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_SplitTriennial)
SS_Param2023$Variance_adjustment_list$data$FourFleets_UseSlope_CombineTriennial <- make_variance_adj_list(fleetnames = SS_Param2023$fleetnames$data$FourFleets_UseSlope_CombineTriennial)
SS_Param2023$Variance_adjustment_list$data$FourFleets_NoSlope_CombineTriennial <- make_variance_adj_list(fleetnames = SS_Param2023$fleetnames$data$FourFleets_NoSlope_CombineTriennial)
SS_Param2023$Variance_adjustment_list$data$ThreeFleets_NoSlope_CombineTriennial <- make_variance_adj_list(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_CombineTriennial)
SS_Param2023$Variance_adjustment_list$data$ThreeFleets_NoSlope_SplitTriennial <- make_variance_adj_list(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_NoSlope_SplitTriennial)
SS_Param2023$Variance_adjustment_list$data$ThreeFleets_UseSlope_CombineTriennial <- make_variance_adj_list(fleetnames = SS_Param2023$fleetnames$data$ThreeFleets_UseSlope_CombineTriennial)


# ===========================================================================

save(SS_Param2023,
     file = file.path(dir_dat, "SST_SS_2023_Data_Parameters.RData", fsep = fsep))

