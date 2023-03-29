# Stock: Rex Sole
# Set up the Rdata to save the parameters and the data that will feed SS input files
# author: Matthieu VERON
# contact: mveron@uw.edu

rm(list = ls(all.names = TRUE))

# 1. Set up ----
# ---------------------------------------------------------- #
# load packages ----
library(r4ss)

# Local declarations ----
fsep <- .Platform$file.sep

# Set directories ----
dir_model <- file.path(here::here(), "model", fsep = fsep)
dir_script <- file.path(here::here(), "R", fsep = fsep)
dir_SS <- file.path(dir_script, "ss", fsep = fsep)



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
Dir_Base23_sq_fixQ <- file.path(dir_model,'2013_SST_SSV3_30_21' , fsep = fsep)

# First read the starter to get the name of the control file
StarterFile <- file.path(Dir_Base23_sq_fixQ, 'starter.ss', fsep = fsep)
Start23_sq_0 <- SS_readstarter(
  file = StarterFile,
  verbose = TRUE
)

# Read in the file
Ctlfile <-file.path(Dir_Base23_sq_fixQ,Start23_sq_0$ctlfile, fsep = fsep)
Ctl23_sq_fixQ <- SS_readctl_3.30(
  file = Ctlfile,
  use_datlist = TRUE,
  datlist = file.path(Dir_Base23_sq_fixQ, 'run','data_echo.ss_new', fsep = fsep),
  verbose = TRUE
)

# Length bin for the soze comp if any
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

# Natural mortality
rowNam_M <- getName(string = MG_row, pattern = "NatM")
# SS_Param2023$MG_params$M <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_M)
SS_Param2023$MG_params$M <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_M)

# Growth
rowNam_G <- getName(string = MG_row, pattern = c("L_at", "VonBert_K", "CV_"))
# SS_Param2023$MG_params$Growth <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_G)
SS_Param2023$MG_params$Growth <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_G)

# Weight-Length relationship
rowNam_WL <- getName(string = MG_row, pattern = c("Wtlen_"))
# SS_Param2023$MG_params$WL <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_WL)
SS_Param2023$MG_params$WL <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_WL)

# Maturity
rowNam_Mat <- getName(string = MG_row, pattern = c("Mat_", "Mat50"))
# SS_Param2023$MG_params$Mat <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_Mat)
SS_Param2023$MG_params$Mat <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_Mat)

# Fecundity
rowNam_Fec <- getName(string = MG_row, pattern = c("Eggs_"))
# SS_Param2023$MG_params$Fec <- doDat(Data_colnames = lng_par_colnames, RowNam = rowNam_Fec)
SS_Param2023$MG_params$Fec <- doDat(Data_colnames = ParVal_colnames, RowNam = rowNam_Fec)

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
SS_Param2023$Catch$data <- doDat(Data_colnames = Catch_colnames, RowNam = NULL)
# ********************************

# Survey data ----
SS_Param2023$Indices$Content <- "These are the survey data"
Srv_colnames <- c("year", "season", "index", "obs", "se_log")
SS_Param2023$Indices$data <- doDat(Data_colnames = Srv_colnames, RowNam = NULL)
# ********************************

# Discard data ----
SS_Param2023$discard_fleets$Content <- "These are the discards data"
Dscd_colnames <- c("year", "season", "fleet", "discard", "std_in")
SS_Param2023$discard_fleets$data <- doDat(Data_colnames = Dscd_colnames, RowNam = NULL)
# ********************************

# Meanbodywt data ----
SS_Param2023$Meanbodywt$Content <- "These are the Meanbodywt (weight/length) data"
MeanBody_colnames <- c("year", "season", "fleet", "partition", "type", "obs", "std_in")
SS_Param2023$Meanbodywt$data <- doDat(Data_colnames = MeanBody_colnames, RowNam = NULL)
# ********************************

#  data ----
SS_Param2023$Fishery_LengthComp$Content <- "These are the fishery length composition data"
Lcomp_colnames <- c("year","season","fleet","sex","partition","Nsamp", paste0("f", Lbin_vect),paste0("m", Lbin_vect))
SS_Param2023$Fishery_LengthComp$data <- doDat(Data_colnames = Lcomp_colnames, RowNam = NULL)
# ********************************

#  data ----
SS_Param2023$Survey_LengthComp$Content <- "These are the survey length composition data"
Lcomp_colnames <- c("year","season","fleet","sex","partition","Nsamp", paste0("f", Lbin_vect),paste0("m", Lbin_vect))
SS_Param2023$Survey_LengthComp$data <- doDat(Data_colnames = Lcomp_colnames, RowNam = NULL)

# ********************************

# ===========================================================================

save(SS_Param2023,
     file = file.path(dir_SS, "SS_2023_Data_Parameters.RData", fsep = fsep))
