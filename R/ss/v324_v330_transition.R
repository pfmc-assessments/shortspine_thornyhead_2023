# Transitioning Shortspine Thornyhead 2013 model from SS V3.24 to SS V3.30.21
# Matthieu VERON - @: mveron@uw.edu
# Last updated: February 2013

# The transition is realized based on an existing working model (download from
# the user-examples repository for stock synthesis
# [https://github.com/nmfs-stock-synthesis/user-examples]). I used the
# selex_length_example which seems to be close enough to the configuration
# of Shortspine Thornyhead model.

# The script goes through each model file needed to run SS (Starter, dataFile,
# ControlFile and Forecast) and use the values from the 2013 model files.
# I used the r4ss package to fill in and write each model file.

rm(list = ls(all.names = TRUE))

# 1. Update r4ss ----

update <- FALSE

if (update) {
  # Indicate the library directory to remove the r4ss package from
  mylib <- "~/R/win-library/4.1"
  remove.packages("r4ss", lib = mylib)
  # Install r4ss from GitHub
  remotes::install_github("r4ss/r4ss")
}
# -----------------------------------------------------------

# 2. Set up ----

# packages
library(r4ss)
library(dplyr)
library(reshape2)
library(stringr)

# Directories
dirBase <- getwd()
# Path to the Executable folder
Exe_path <- file.path(dirBase, "Executables")
# Path to the model example to modify
BaseMod_path <-
  file.path(dirBase, "model/2013_SST_SSV3_30_21/base_model_example")
# Path to the old SST model (i.e. the 2013 model using SS V3.24)
oldSST_path <- file.path(dirBase, "model/2013_SST/")
# Path to the new SST model (i.e. the 2013 model using SS V3.30.21)
SST_path <- file.path(dirBase, "model/2013_SST_SSV3_30_21")

save.dir <- c('dirBase',
              'Exe_path',
              'BaseMod_path',
              'oldSST_path',
              'SST_path')
# -----------------------------------------------------------

# 3. Work on Starter file ----

StarterFile <- file.path(BaseMod_path, "starter.ss")
Starter <- SS_readstarter(file = StarterFile, verbose = TRUE)
# names(Starter)

# Names of the data and control files
Starter$datfile <- "SST_data.ss"
Starter$ctlfile <- "SST_control.ss"
# Initial values in control file
Starter$init_values_src <- 0
# run display detail (0,1,2)
Starter$run_display_detail <- 1
# detailed output (0=minimal for data-limited, 1=high (w/ wtatage.ss_new), 2=brief, 3=custom)
# custom report options: -100 to start with minimal; -101 to start with all; -number to remove, +number to add, -999 to end
Starter$detailed_age_structure <- 1
# write 1st iteration details to echoinput.sso file (0,1)
Starter$checkup <- 0
# write parm values to ParmTrace.sso (0=no,1=good,active; 2=good,all; 3=every_iter,all_parms; 4=every,active)
Starter$parmtrace <- 0
# write to cumreport.sso (0=no,1=like&timeseries; 2=add survey fits)
Starter$cumreport <- 0
# Include prior_like for non-estimated parameters (0,1)
Starter$prior_like <- 1
# Use Soft Boundaries to aid convergence (0,1) (recommended)
Starter$soft_bounds <- 0

# Number of datafiles to produce:  0 turns off all *.ss_new; 1st is data_echo.ss_new, 2nd is data_expval.ss, 3rd and higher are data_boot_**N.ss,
Starter$N_bootstraps <- 3
# Turn off estimation for parameters entering after this phase
Starter$last_estimation_phase <- 25

# MCeval burn interval
Starter$MCMCburn <- 0
# MCeval thin interval
Starter$MCMCthin <- 1
# jitter initial parm value by this fraction
Starter$jitter_fraction <- 0

# min yr for sdreport outputs (-1 for styr); #_1999
Starter$minyr_sdreport <- -1
# max yr for sdreport outputs (-1 for endyr+1; -2 for endyr+Nforecastyrs); #_2013
Starter$maxyr_sdreport <- -2
# N individual STD years
Starter$N_STD_yrs <- 0
#vector of year values

# final convergence criteria (e.g. 1.0e-04)
Starter$converge_criterion <- 0.0001
# retrospective year relative to end year (e.g. -4)
Starter$retro_yr <- 0
# min age for calc of summary biomass
Starter$min_age_summary_bio <- 1
# Depletion basis:  denom is: 0=skip; 1=rel X*SPBvirgin; 2=rel SPBmsy; 3=rel X*SPB_styr; 4=rel X*SPB_endyr; values; >=11 invoke N multiyr (up to 9!) with 10's digit; >100 invokes log(ratio)
Starter$depl_basis <- 1
# Fraction (X) for Depletion denominator (e.g. 0.4)
Starter$depl_denom_frac <- 1
# SPR_report_basis:  0=skip; 1=(1-SPR)/(1-SPR_tgt); 2=(1-SPR)/(1-SPR_MSY); 3=(1-SPR)/(1-SPR_Btarget); 4=rawSPR
Starter$SPR_basis <- 1
# F_reporting_units: 0=skip; 1=exploitation(Bio); 2=exploitation(Num); 3=sum(Apical_F's); 4=true F for range of ages; 5=unweighted avg. F for range of ages
Starter$F_report_units <- 1
#COND 10 15 #_min and max age over which average F will be calculated with F_reporting=4 or 5
# Starter$F_age_range
# F_std_basis: 0=raw_annual_F; 1=F/Fspr; 2=F/Fmsy; 3=F/Fbtgt; where F means annual_F; values >=11 invoke N multiyr (up to 9!) with 10's digit; >100 invokes log(ratio)
Starter$F_report_basis <- 0
# MCMC output detail: integer part (0=default; 1=adds obj func components; 2= +write_report_for_each_mceval); and decimal part (added to SR_LN(R0) on first call to mcmc)
Starter$MCMC_output_detail <- 0
# ALK tolerance ***disabled in code (example 0.0001)
Starter$ALK_tolerance <- 0
# random number seed for bootstrap data (-1 to use long(time) as seed): # 1664576398
Starter$seed <- -1
# check value for end of file and for version contro
Starter$final <- 3.30

# Save the new starter file for SST
SS_writestarter(
  mylist = Starter,
  dir = SST_path,
  overwrite = TRUE,
  verbose = TRUE
)

# Check file structure
StarterFile <- file.path(SST_path, "starter.ss")
Starter <- SS_readstarter(file = StarterFile, verbose = TRUE)
# -----------------------------------------------------------

# clean environment
rm(list = setdiff(ls(), save.dir))
save.dir <- ls()


# 4. Work on data file ----
# ----------------------------------------------------------- #
# Read in files ----
# ************************************************* #

# Read the V3.24 data file
oldFile <- file.path(oldSST_path, "SST_data.SS")
oldData <- SS_readdat_3.24(file = oldFile, verbose = TRUE)

# Read the model example data file
list.files(BaseMod_path)
DatFile <- file.path(BaseMod_path, "selex_length_example_data.ss")
dat <-
  SS_readdat_3.30(file = DatFile,
                  verbose = TRUE,
                  section = TRUE)

# Named section of the Data file
# =============================== #
# Read general model dimensions.
# Read Fleet information.
# Read catches.
# Read CPUE data.
# Read Length composition data.
# Read age composition data.
# =============================== #

# Names of the list components of data file
# =============================== #
names(dat)
# [1] "sourcefile"              "type"                    "ReadVersion"             "Comments"
# [5] "styr"                    "endyr"                   "nseas"                   "months_per_seas"
# [9] "Nsubseasons"             "spawn_month"             "Nsexes"                  "Nages"
# [13] "N_areas"                 "Nfleets"                 "fleetinfo"               "fleetnames"
# [17] "surveytiming"            "units_of_catch"          "areas"                   "catch"
# [21] "CPUEinfo"                "CPUE"                    "N_discard_fleets"        "use_meanbodywt"
# [25] "lbin_method"             "binwidth"                "minimum_size"            "maximum_size"
# [29] "use_lencomp"             "len_info"                "N_lbins"                 "lbin_vector"
# [33] "lencomp"                 "N_agebins"               "agebin_vector"           "N_ageerror_definitions"
# [37] "ageerror"                "age_info"                "Lbin_method"             "agecomp"
# [41] "use_MeanSize_at_Age_obs" "N_environ_variables"     "N_sizefreq_methods_rd"   "N_sizefreq_methods"
# [45] "do_tags"                 "morphcomp_data"          "use_selectivity_priors"  "eof"
# [49] "spawn_seas"              "Nfleet"                  "Nsurveys"                "fleetinfo1"
# [53] "fleetinfo2"              "N_meanbodywt"            "comp_tail_compression"   "add_to_comp"
# [57] "max_combined_lbin"       "N_MeanSize_at_Age_obs"   "N_lbinspop"              "lbin_vector_pop"

# Potential new variables (compared to V3.24)
# =============================== #
names(dat)[!names(dat) %in% names(oldData)]
# [1] "ReadVersion"             "Comments"                "Nsubseasons"
# [4] "spawn_month"             "Nfleets"                 "use_meanbodywt"
# [7] "use_lencomp"             "len_info"                "agebin_vector"
# [10] "ageerror"                "age_info"                "agecomp"
# [13] "use_MeanSize_at_Age_obs" "N_sizefreq_methods_rd"   "use_selectivity_priors"
# [16] "eof"

# Local definition ----
# ************************************************* #
Nfleet <- oldData$Nfleet
Nsurveys <- oldData$Nsurveys
Nyear <- oldData$endyr - oldData$styr + 1
# ************************************************* #

# 4.1 File & SS version info ----
# ************************************************* #
dat$sourcefile
dat$type
dat$ReadVersion
# Add comments to specify the update
com <- "#C Data file for Shortspine Thornyhead - 2023 Assessment
#C These data are the one from the 2013 model and updated for
#C transitionning the 2013 (SS V3.24) model to SS V3.30 format
#
#C Matthieu VERON - February 2023"
dat$Comments <- com

# 4.2 General model dimensions ----
# ************************************************* #
# Start year
dat$styr <- oldData$styr #1901
# End year
dat$endyr <- oldData$endyr #2012
# Number of season
dat$nseas <- oldData$nseas #1
# Number of month per season
dat$months_per_seas <- oldData$months_per_seas #12
# Number of subseasons per season
# (minimum = 2) - Two subseasons mimics V3.24
dat$Nsubseasons <- 2
# Number of spawning month
dat$spawn_month <- oldData$spawn_seas #1
# Number of sex: 1, 2, -1
# (use -1 for 1 sex setup with SSB multiplied by female_frac parameter)
dat$Nsexes <- oldData$Nsexes #2
# Number of ages
# accumulator age, first age is always age 0
dat$Nages <- oldData$Nages #100
#Number of areas
dat$N_areas <- oldData$N_areas #1
# Number of fleets (including surveys)
dat$Nfleets <-
  oldData$Nfleet + oldData$Nsurveys #9 (4 fleets; 5 surveys)

# 4.3 Fleet information -----
# ************************************************* #
#_fleet_type: 1=catch fleet; 2=bycatch only fleet; 3=survey; 4=predator(M2)
#_sample_timing: -1 for fishing fleet to use season-long catch-at-age for observations, or 1 to use observation month;  (always 1 for surveys)
#_fleet_area:  area the fleet/survey operates in
#_units of catch:  1=bio; 2=num (ignored for surveys; their units read later)
#_catch_mult: 0=no; 1=yes
#_rows are fleets
#_fleet_type fishery_timing area catch_units need_catch_mult fleetname
colnames(dat$fleetinfo)
# [1] "type"            "surveytiming"    "area"            "units"           "need_catch_mult"
# [6] "fleetname"

dat$fleetinfo <- data.frame(
  row.names = 1:dat$Nfleets,
  "type" = oldData$fleetinfo$type,
  "surveytiming" = oldData$fleetinfo$surveytiming,
  "area" = oldData$fleetinfo$areas,
  "units" = oldData$fleetinfo$units,
  "need_catch_mult" = rep(0, dat$Nfleets),
  "fleetname" = rownames(oldData$fleetinfo)
)

# 4.4 Bycatch and Catches -----
# ************************************************* #

# Bycatch data - (only added for fleets with type = 2)
#Bycatch_fleet_input_goes_next
#a:  fleet index
#b:  1=include dead bycatch in total dead catch for F0.1 and MSY optimizations and forecast ABC; 2=omit from total catch for these purposes (but still include the mortality)
#c:  1=Fmult scales with other fleets; 2=bycatch F constant at input value; 3=bycatch F from range of years
#d:  F or first year of range
#e:  last year of range
#f:  not used
# a   b   c   d   e   f
#
# No by catch data for Shortspine Thornyhead

# ########################## #
# ########################## #

#_Catch data: yr, seas, fleet, catch, catch_se
#_catch_se:  standard error of log(catch)
#_NOTE:  catch data is ignored for survey fleets
names(dat$catch)
# [1] "year"     "seas"     "fleet"    "catch"    "catch_se"
tmpCatch <- NULL
for (f in 1:Nfleet) {
  namf <- dat$fleetinfo$fleetname[f]
  tmpCatch <- rbind(
    tmpCatch,
    data.frame(
      "year" = oldData$catch$year,
      "seas" = oldData$catch$seas,
      "fleet" = rownames(dat$fleetinfo)[f],
      "catch" = oldData$catch[namf][, 1],
      "catch_se" = oldData$se_log_catch[f]
    )
  )
}
dat$catch <- tmpCatch
rm(tmpCatch)

# 4.5 CPUE data ----
# ************************************************* #

#_CPUE_and_surveyabundance_observations
#_Units:  0=numbers; 1=biomass; 2=F; 30=spawnbio; 31=recdev; 32=spawnbio*recdev; 33=recruitment; 34=depletion(&see Qsetup); 35=parm_dev(&see Qsetup)
#_Errtype:  -1=normal; 0=lognormal; >0=T
#_SD_Report: 0=no sdreport; 1=enable sdreport - Indices with SD report will have
# the expected values of their historical values appear in the ss.std and ss.cor
# files - Default is 0.
#_Fleet Units Errtype SD_Report
colnames(dat$CPUEinfo)
# "Fleet"     "Units"     "Errtype"   "SD_Report"
# Extract the names of fleets
FleetName <- dat$fleetinfo$fleetname
dat$CPUEinfo <- data.frame(
  "Fleet" = oldData$CPUEinfo$Fleet,
  "Units" = oldData$CPUEinfo$Units,
  "Errtype" = oldData$CPUEinfo$Errtype,
  "SD_Report" = rep(0, dat$Nfleets)
)

rownames(dat$CPUEinfo) <- FleetName
rm(FleetName)

# CPUE data
#_yr month fleet obs stderr
dat$CPUE <- oldData$CPUE

# 4.6 Fleets with discards ----
# ************************************************* #

#_N_fleets_with_discard
dat$N_discard_fleets <- oldData$N_discard_fleets

#_discard_units (1=same_as_catchunits(bio/num); 2=fraction; 3=numbers)
#_discard_errtype:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal; -3 for trunc normal with CV
# note: only enter units and errtype for fleets with discard

# Fleet information for discard data
# Note: Discard data are not available in the model example - I created the
# variable "discard_fleet_info" && "discard_data" based on the SS_readdat_3.30()
# and SS_writedat_3.30() functions
dat[["discard_fleet_info"]] <- oldData$discard_fleet_info
rownames(dat$discard_fleet_info) <- dat$discard_fleet_info$Fleet

# note: discard data is the total for an entire season, so input of month here must be to a month in that season
#_Fleet units errtype
# WARNING: Notes from the user manual
# The use of CV as the measure of variance can cause a small discard value to appear to be
# overly precise, even with the minimum standard error of the discard observation set to
# 0.001. In the control file, there is an option to add an extra amount of variance. This
# amount is added to the standard error, not to the CV, to help correct this problem of
# underestimated variance.
dat[["discard_data"]] <- oldData$discard_data

# 4.7 Mean Body Weight or Length ----
# ************************************************* #
# Number of observation for overall mean body weight
oldData$N_meanbodywt #40
# we therefore need to turn on the use of mean body size data
dat$use_meanbodywt <- 1

# Note: Mean body size data are not used in the model example
# I created the following arguments in the dat list "DF_for_meanbodywt"
# and "meanbodywt" based on the SS_readdat_3.30() and SS_writedat_3.30()
# functions

#_COND_0 #_DF_for_meanbodysize_T-distribution_like
# Degrees of freedom for Student’s t-distribution used to evaluate mean body weight
# deviation
dat[["DF_for_meanbodywt"]] <- oldData$DF_for_meanbodywt # 30

# Mean body size data
#_yr month fleet part type obs stderr
# Need to modify the initial data to add the type variable
names(oldData$meanbodywt)
# note:  type=1 for mean length; type=2 for mean body weight
# All data here are mean weight, i.e. type=2
dat[["meanbodywt"]] <- data.frame(
  "Year" = oldData$meanbodywt$Year,
  "Seas" = oldData$meanbodywt$Seas,
  "Fleet" = oldData$meanbodywt$Type,
  # set as Type in the SS_readdat_3.24() function
  "Partition" = oldData$meanbodywt$Partition,
  "Type" = 2,
  # weight data
  "Value" = oldData$meanbodywt$Value,
  "Std_in" = oldData$meanbodywt$CV
)

# 4.8 Population size structure - Length ----
# ************************************************* #

# set up population length bin structure (note - irrelevant if not using size data and using empirical wtatage
# length bin method: 1=use databins; 2=generate from binwidth,min,max below; 3=read vector
dat$lbin_method <- oldData$lbin_method #2
# binwidth for population size comp
dat$binwidth <- oldData$binwidth #2
# minimum size in the population (lower edge of first bin and size at age 0.00)
dat$minimum_size <- oldData$minimum_size #4
# maximum size in the population (lower edge of last bin)
dat$maximum_size <- oldData$maximum_size #90


# use length composition data (0/1/2)
dat$use_lencomp <- 1

#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level.
#_addtocomp:  after accumulation of tails; this value added to all bins
#_combM+F: males and females treated as combined gender below this bin number
#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation
#_Comp_Error:  0=multinomial, 1=dirichlet using Theta*n, 2=dirichlet using beta, 3=MV_Tweedie
#_ParmSelect:  consecutive index for dirichlet or MV_Tweedie
#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001
#
#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize
names(dat$len_info)
# [1] "mintailcomp"   "addtocomp"     "combine_M_F"   "CompressBins"  "CompError"     "ParmSelect"
# [7] "minsamplesize"
dat$len_info <- data.frame(
  # no compression (similar to 2013 model)
  "mintailcomp" = rep(-1, dat$Nfleets),
  #0.001; Constant added to observed and expected proportions at length and age to make logL calculations more robust
  "addtocomp" = rep(oldData$add_to_comp, dat$Nfleets),
  #0: Combine males into females at or below this bin number
  "combine_M_F" = rep(oldData$max_combined_lbin, dat$Nfleets),
  # allows for the compression of length or age bins beyond a specific length or age by each data source
  "CompressBins" = rep(0, dat$Nfleets),
  # multinomial error distribution
  "CompError" = rep(0, dat$Nfleets),
  # No parameter here because multinomial error distribution
  "ParmSelect" = rep(0, dat$Nfleets),
  "minsamplesize" = rep(1, dat$Nfleets) # Mimic SS v3.24
)

# Number of length bins for data
dat$N_lbins <- oldData$N_lbins #34
# Vector of length bins associated with the length data
dat$lbin_vector <- oldData$lbin_vector

# Length composition data
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution
# partition codes:  (0=combined; 1=discard; 2=retained
#_yr month fleet sex part Nsamp datavector(female-male)
names(dat$lencomp)[1:6]
# "Yr"     "Seas"   "FltSvy" "Gender" "Part"   "Nsamp"
dat$lencomp <- oldData$lencomp

# 4.9 Population size structure - Age ----
# ************************************************* #
# Number of age bins
dat$N_agebins <- oldData$N_agebins # 0

# ************************************************* #
# Change the set up of Population age structure from the model example
# ************************************************* #
# Vector of ages - Unused so set to NULL
dat$agebin_vector <- NULL
# Number of ageing error matrices to generate
dat$N_ageerror_definitions <- oldData$N_ageerror_definitions #0
# Matrix of age error
dat$ageerror <- NULL

# Age composition specification
#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level.
#_addtocomp:  after accumulation of tails; this value added to all bins
#_combM+F: males and females treated as combined gender below this bin number
#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation
#_Comp_Error:  0=multinomial, 1=dirichlet using Theta*n, 2=dirichlet using beta, 3=MV_Tweedie
#_ParmSelect:  consecutive index for dirichlet or MV_Tweedie
#_minsamplesize: minimum sample size; set to 1 to match 3.24, minimum value is 0.001
#
#_mintailcomp addtocomp combM+F CompressBins CompError ParmSelect minsamplesize
dat$age_info <- NULL

# Method by which length bin range for age obs
#_Lbin_method_for_Age_Data: 1=poplenbins; 2=datalenbins; 3=lengths
# WARNING: should be set to 0 since no age data are used
dat$Lbin_method <- oldData$Lbin_method #2
# Age composition observations
# sex codes:  0=combined; 1=use female only; 2=use male only; 3=use both as joint sexxlength distribution
# partition codes:  (0=combined; 1=discard; 2=retained
#_yr month fleet sex part ageerr Lbin_lo Lbin_hi Nsamp datavector(female-male)
dat$agecomp <- oldData$N_agecomp #0
# ************************************************* #

# 4.10 Mean Length or Body Weight-at-Age ----
# ************************************************* #
#_Use_MeanSize-at-Age_obs (0/1)
# No conditional age at length
print(oldData$N_MeanSize_at_Age_obs)
dat$use_MeanSize_at_Age_obs <- 0


# 4.11 Environmental data  ----
# ************************************************* #
#_N_environ_variables
# -2 in yr will subtract mean for that env_var; -1 will subtract mean and divide by stddev (e.g. Z-score)
#Yr Variable Value
dat$N_environ_variables <- oldData$N_environ_obs #0

# 4.12 Generalized size composition data  ----
# ************************************************* #
# Number of size frequency methods to read
# Sizefreq data. Defined by method because a fleet can use multiple methods
# N sizefreq methods to read (or -1 for expanded options)
dat$N_sizefreq_methods_rd <- oldData$N_sizefreq_methods #0

# 4.13 Tag recapture data  ----
# ************************************************* #
# do tags (0/1/2); where 2 allows entry of TG_min_recap
# No tagging data in the assessment
dat$do_tags <- oldData$do_tags #0


# 4.14 Stock (Morph) Composition Data  ----
# ************************************************* #
# Morph data(0/1)
# Nobs, Nmorphs, mincomp
# yr, seas, type, partition, Nsamp, datavector_by_Nmorphs
#
dat$morphcomp_data <- oldData$morphcomp_data #0

# 4.15 Selectivity empirical data ----
# ************************************************* #
# Do data read for selectivity priors(0/1)
# Yr, Seas, Fleet,  Age/Size,  Bin,  selex_prior,  prior_sd
# feature not yet implemented
dat$use_selectivity_priors <- 0

#
# 4.16 End of data file ----
# ************************************************* #
dat$eof <- 999

# Save the new data file for SST
SS_writedat(
  datlist = dat,
  outfile = file.path(SST_path, "SST_data.ss"),
  version = "3.30",
  overwrite = TRUE
)

# 4.17 Check file structure ----
DatFile <- file.path(SST_path, "SST_data.ss")
SSTdat_V330 <-
  SS_readdat_3.30(file = DatFile,
                  verbose = TRUE,
                  section = TRUE)
# => Everything looks good :)
# -----------------------------------------------------------

# clean environment
var.to.save <- c(save.dir, 'SSTdat_V330')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()



# 5. Work on control file ----
# ----------------------------------------------------------- #

# Internal function to run SS if needed to read control files ----
# ************************************************* #

#' @title RunSS_CtlFile
#' @description Function that runs SS to get the file needed to read in the control
#' file. This depends on the version of SS considered (see below).
#'
#' @param pathRun (character string)- Directory containing the model input files.
#' @param pathExe (character string)- Directory containing the executable you want
#' to use. Only needed if the executable (\code{nameExe}) is not available in the
#' \code{pathRun} directory or has not been declared in your PATH.
#' @param SS_version (character string)- SS version number. "3.24" or "3.30" are the
#' supported versions here. This allows to determine the file needed to read in
#' the control file (SS V3.24 needs the "data.ss_new" file / SS V3.30 needs the
#' "data_echo.ss_new" file).
#' @param isSSinPATH (logical)- If \code{TRUE}, the \code{nameExe} SS executable
#' has to be declared in your PATH. If \code{FALSE}, the function will use the
#' executable available in the \code{pathExe} directory.
#' @param nameExe (character string)- The name of the executable you want to use
#' and that is either declared in your PATH or available in the \code{pathRun} or
#' \code{pathExe} directory.

RunSS_CtlFile <- function(pathRun = NULL,
                          pathExe = NULL,
                          SS_version = NULL,
                          isSSinPATH = NULL,
                          nameExe = NULL) {
  fileneeded <- ifelse(test = SS_version == "3.24",
                       yes = "data.ss_new",
                       no = "data_echo.ss_new")
  if (!file.exists(file.path(pathRun, fileneeded, fsep = .Platform$file.sep))) {
    if (is.null(nameExe)) {
      cat("you need to provide the name of the executable you want to use.")
      stop()
    }
    
    if (isSSinPATH ||
        file.exists(file.path(pathRun, nameExe, fsep = .Platform$file.sep))) {
      r4ss::run(dir = pathRun, exe = nameExe)
    } else {
      path_exe <- file.path(pathExe, nameExe, fsep = .Platform$file.sep)
      r4ss::run(dir = pathRun,
                exe = path_exe,
                skipfinished = FALSE)
    }
  } else {
    cat("The ",
        fileneeded,
        " file is already available in the run directory (",
        pathRun,
        ")")
  }
}


# Read in files ----
# ************************************************* #

# Read the V3.24 control file

# The SS_readctl_3.24() needs the data.ss_new file to read the control file
# Let's first check if the data.ss_new is available. If no, we need to run the model
# to get it (This can be done using the following command which should work for
# every OS).
RunSS_CtlFile(
  pathRun = oldSST_path,
  # the SST 2013 directory where the input files are stored
  SS_version = "3.24",
  # we use SS V3.30
  isSSinPATH = FALSE,
  # the .exe is not declared in the PATH (for my machine)
  nameExe = "ss_win64_opt",
  # the .exe is in the oldSST_path directory
  pathExe = file.path(Exe_path, "SS_V3_24_U", fsep = .Platform$file.sep)
) # Run the model which create the "data.ss_new" file

# Now read the control file using the "data.ss_new" file as input of the
# SS_readctl_3.24() function.
oldFile <- file.path(oldSST_path, "SST_control.SS")
oldCtl <- SS_readctl_3.24(
  file = oldFile,
  verbose = TRUE,
  use_datlist = TRUE,
  datlist = file.path(oldSST_path, "data.ss_new"),
  Do_AgeKey = FALSE # Shouldn't be needed here - bug function?
)
# Other solution - Read in the data file and fill in the function arguments
# First we need to read the data file as a list
# oldData <- file.path(oldSST_path, "SST_data.SS")
# oldData <- SS_readdat_3.24(file = oldData, verbose = TRUE)

# The SS_readctl_3.24() function needs the number of data points of each CPUE time series
# This needs to be a vector of length=Nfleet+Nsurveys
# No observations for the fishing fleets => rep(0,oldData$Nfleet)
# N_CPUE_obs <- paste('c(',paste0(c(rep(0,oldData$Nfleet), table(oldData$CPUE$index)),collapse = ','), ')', sep='')
# oldFile <- file.path(oldSST_path, "SST_control.SS")
# oldCtl <- SS_readctl_3.24(file = oldFile,
#                           verbose = TRUE,
#                           use_datlist = FALSE,
#                           nseas = oldData$nseas,
#                           N_areas = oldData$N_areas,
#                           Nages = oldData$Nages,
#                           Nsexes = oldData$Nsexes,
#                           Npopbins = oldData$N_lbinspop,
#                           Nfleet = oldData$Nfleet,
#                           Nsurveys = oldData$Nsurveys,
#                           Do_AgeKey = FALSE,
#                           N_tag_groups = oldData$do_tags,
#                           N_CPUE_obs = N_CPUE_obs)
# rm(oldData, N_CPUE_obs)


# Read the model example control file
# Similarly the SS_readctl_3.30() function needs the "data_echo.ss_new" file which
# is created while running SS.
# Let's run the model (if applicable)
RunSS_CtlFile(
  pathRun = BaseMod_path,
  # the model example input files are in this directory
  pathExe = file.path(Exe_path, "SS_V3_30_21"),
  # directory where to find the .exe
  SS_version = "3.30",
  # we use SS V3.30
  isSSinPATH = FALSE,
  # the .exe is not declared in the PATH (for my machine)
  nameExe = "ss_osx" # I want to use this exe (windows OS)
)
# Read the model example control file
list.files(BaseMod_path)
Ctlfile <-
  file.path(BaseMod_path, "selex_length_example_control.ss")
ctl <- SS_readctl_3.30(
  file = Ctlfile,
  use_datlist = TRUE,
  datlist = file.path(BaseMod_path, "data_echo.ss_new"),
  verbose = TRUE
)

# Names of the list components of control file
# =============================== #
names(ctl)
# [1] "warnings"                  "Comments"                  "nseas"
# [4] "N_areas"                   "Nages"                     "Nsexes"
# [7] "Npopbins"                  "Nfleets"                   "Do_AgeKey"
# [10] "fleetnames"                "sourcefile"                "type"
# [13] "ReadVersion"               "eof"                       "EmpiricalWAA"
# [16] "N_GP"                      "N_platoon"                 "recr_dist_method"
# [19] "recr_global_area"          "recr_dist_read"            "recr_dist_inx"
# [22] "recr_dist_pattern"         "N_Block_Designs"           "blocks_per_pattern"
# [25] "Block_Design"              "time_vary_adjust_method"   "time_vary_auto_generation"
# [28] "natM_type"                 "GrowthModel"               "Growth_Age_for_L1"
# [31] "Growth_Age_for_L2"         "Exp_Decay"                 "Growth_Placeholder"
# [34] "N_natMparms"               "SD_add_to_LAA"             "CV_Growth_Pattern"
# [37] "maturity_option"           "First_Mature_Age"          "fecundity_option"
# [40] "hermaphroditism_option"    "parameter_offset_approach" "MG_parms"
# [43] "MGparm_seas_effects"       "SR_function"               "Use_steep_init_equi"
# [46] "Sigma_R_FofCurvature"      "SR_parms"                  "do_recdev"
# [49] "MainRdevYrFirst"           "MainRdevYrLast"            "recdev_phase"
# [52] "recdev_adv"                "F_ballpark"                "F_ballpark_year"
# [55] "F_Method"                  "maxF"                      "F_iter"
# [58] "Q_options"                 "Q_parms"                   "size_selex_types"
# [61] "age_selex_types"           "size_selex_parms"          "Use_2D_AR1_selectivity"
# [64] "TG_custom"                 "DoVar_adjust"              "maxlambdaphase"
# [67] "sd_offset"                 "N_lambdas"                 "more_stddev_reporting"
# [70] "stddev_reporting_specs"    "stddev_reporting_selex"    "stddev_reporting_growth"
# [73] "stddev_reporting_N_at_A"

# Potential new variables (compared to V3.24)
# =============================== #
names(ctl)[!names(ctl) %in% names(oldCtl)]
# [1] "Comments"                "Nfleets"                 "Do_AgeKey"
# [4] "recr_global_area"        "recr_dist_read"          "recr_dist_pattern"
# [7] "Growth_Placeholder"      "Use_steep_init_equi"     "Sigma_R_FofCurvature"
# [10] "F_iter"                  "Q_options"               "Use_2D_AR1_selectivity"
# [13] "stddev_reporting_specs"  "stddev_reporting_selex"  "stddev_reporting_growth"
# [16] "stddev_reporting_N_at_A"



# 5.1 File & SS version info ----
# ************************************************* #
# warnings
ctl$warnings
# Add comments to specify the update
com <- "#C Controle file for Shortspine Thornyhead - 2023 Assessment
#C This is the the 2013 model updated control file for
#C transitionning the 2013 (SS V3.24) model to SS V3.30 format
#
#C Matthieu VERON - February 2023"
ctl$Comments <- com
rm(com)

# Sourcefile - We do not need to modify it. That will be done automatically.
ctl$sourcefile
# type
ctl$type #"Stock_Synthesis_control_file"
# SS version
ctl$ReadVersion # 3.30

# 5.2 Number of growth patterns and platoons ----
# ************************************************* #
# Read empirical weight at age
# 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
ctl$EmpiricalWAA <-
  oldCtl$EmpiricalWAA #0: SST does not have empirical WAA in the 2013 assessment
# Number of growth patters (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS3)
ctl$N_GP <- oldCtl$N_GP

# Number of platoons within a growth pattern/morph
#_Cond 1 #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)
#_Cond  1 #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)
ctl$N_platoon <- oldCtl$N_platoon

# 5.3 Settlement Timing for Recruits and Distribution ----
# ************************************************* #
# Recruitment distribution method
# 1=no longer available; 2=main effects for GP, Area, Settle timing; 3=each Settle entity; 4=none (only when N_GP*Nsettle*pop==1)
# oldCtl$nseas * oldCtl$N_GP * oldCtl$N_areas = 2
ctl$recr_dist_method <- 2
# Spawner-recruitment - not yet implemented
ctl$recr_global_area <- 1
#  number of recruitment settlement assignments
ctl$recr_dist_read <- 1 # Must be at least 1
# Future feature
ctl$recr_dist_inx <- 0 # unused option
# GPattern month  area  age (for each settlement assignment)
# The timing of the settlement must be specified
# SST assessment 2013
# => Juveniles settle at around 1 year of age so we consider that settlement
# is in the year after spawning, i.e. calendar age = 1
# => Shortspine thornyheads along the West Coast spawn pelagic, gelatinous masses
# between December and May so we assume the average timing of settlement is
# between January and May (model simplification due to December) so end February
ctl$recr_dist_pattern <- ctl$recr_dist_pattern %>%
  filter(GPattern == 1) %>%
  mutate(month = 3, # settlement end February
         age = 1) # settlement is in the year after spawning

# 5.4 Design matrix for movement between areas ----
# ************************************************* #
#_Cond 0 # N_movement_definitions goes here if Nareas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10

# No movement in the assessment because 1 area
oldCtl$N_areas

# 5.5 Definition of time blocks ----
# ************************************************* #
# Number of block patterns
ctl$N_Block_Designs <- oldCtl$N_Block_Designs #3
# Number of blocks per pattern
ctl$blocks_per_pattern <- oldCtl$blocks_per_pattern
# begin and end years of blocks
ctl$Block_Design <- oldCtl$Block_Design

# 5.6 Controls for all time-varying parameterss ----
# ************************************************* #
# Environmental/Block/Deviation adjust method for all time-varying param
# (1=warn relative to base parm bounds; 3=no bound check)
# Also see env (3) and dev (5) options to constrain with base bounds
ctl$time_vary_adjust_method <-
  oldCtl$time_vary_adjust_method #3 compatible with V3.30
# Logistic bound check form from previous SS3 versions is no longer an option.
# See oldCtl$DoAdjust & oldCtl$selex_adjust_method for selectivity TV param

# Autogeneration of time-varying parameter lines
# autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen time-varying parms of this category; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
ctl$time_vary_auto_generation <-
  oldCtl$time_vary_auto_generation


# 5.7 Biology ----
# ************************************************* #

#_Available timevary codes
#_Block types: 0: P_block=P_base*exp(TVP); 1: P_block=P_base+TVP; 2: P_block=TVP; 3: P_block=P_block(-1) + TVP
#_Block_trends: -1: trend bounded by base parm min-max and parms in transformed units (beware); -2: endtrend and infl_year direct values; -3: end and infl as fraction of base range
#_EnvLinks:  1: P(y)=P_base*exp(TVP*env(y));  2: P(y)=P_base+TVP*env(y);  3: P(y)=f(TVP,env_Zscore) w/ logit to stay in min-max;  4: P(y)=2.0/(1.0+exp(-TVP1*env(y) - TVP2))
#_DevLinks:  1: P(y)*=exp(dev(y)*dev_se;  2: P(y)+=dev(y)*dev_se;  3: random walk;  4: zero-reverting random walk with rho;  5: like 4 with logit transform to stay in base min-max
#_DevLinks(more):  21-25 keep last dev for rest of years
#
#_Prior_codes:  0=none; 6=normal; 1=symmetric beta; 2=CASAL's beta; 3=lognormal; 4=lognormal with biascorr; 5=gamma
#
# setup for M, growth, wt-len, maturity, fecundity, (hermaphro), recr_distr, cohort_grow, (movement), (age error), (catch_mult), sex ratio

# Natural mortality ----
# ---------------------------------------------- #
#_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity;_6=Lorenzen_range
ctl$natM_type <- oldCtl$natM_type
# Additional input for selected M option
# 1. Number of breakpoints
ctl$N_natM <- oldCtl$N_natM
# 2. vector of age breakpoints
ctl$M_ageBreakPoints <- oldCtl$M_ageBreakPoints
# ----------------------------------------------

# Growth setup ----
# ---------------------------------------------- #
# GrowthModel:
# 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr;
# 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
ctl$GrowthModel <- oldCtl$GrowthModel #1
# Growth Amin (A1)
# Age(post-settlement)_for_L1;linear growth below this
ctl$Growth_Age_for_L1 <- oldCtl$Growth_Age_for_L1 #2
# Growth Amax (A2)
# Growth_Age_for_L2 (999 to use as Linf)
ctl$Growth_Age_for_L2 <- oldCtl$Growth_Age_for_L2 #100
# Exponential decay for growth above maxage (value should approx initial Z)
# -999 replicates 3.24; -998 to not allow growth above maxage)
ctl$Exp_Decay <- -999 #0.2
# Placeholder for future growth feature
ctl$Growth_Placeholder <- 0 # default
# Standard deviation added to length-at-age
ctl$SD_add_to_LAA <- oldCtl$SD_add_to_LAA #0.1
# CV Pattern
# 0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
ctl$CV_Growth_Pattern <- oldCtl$CV_Growth_Pattern #0
# ----------------------------------------------

# Maturity-Fecundity ----
# ---------------------------------------------- #
# Maturity option
# 1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern;
# 4=read age-fecundity; 5=disabled; 6=read length-maturity
ctl$maturity_option <- oldCtl$maturity_option #1
# First Mature Age
ctl$First_Mature_Age <- oldCtl$First_Mature_Age #1
# Fecundity option
# (1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
ctl$fecundity_option <- oldCtl$fecundity_option #1

# Hermaphroditism
#  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
ctl$hermaphroditism_option <-
  oldCtl$hermaphroditism_option #0

# Natural Mortality and Growth Parameter Offset Method
# 1- direct, no offset**; 2- male=fem_parm*exp(male_parm);
# 3: male=female*exp(parm) then old=young*exp(parm)
ctl$parameter_offset_approach <-
  oldCtl$parameter_offset_approach #3
# ----------------------------------------------

# Read Biology Parameters -----
# ---------------------------------------------- #
names(oldCtl$MG_parms)
# [1] "LO"         "HI"         "INIT"       "PRIOR"      "PR_type"    "SD"         "PHASE"      "env_var"    "use_dev"
# [10] "dev_minyr"  "dev_maxyr"  "dev_stddev" "Block"      "Block_Fxn"
names(ctl$MG_parms)
# [1] "LO"           "HI"           "INIT"         "PRIOR"        "PR_SD"        "PR_type"      "PHASE"        "env_var&link"
# [9] "dev_link"     "dev_minyr"    "dev_maxyr"    "dev_PH"       "Block"        "Block_Fxn"

# WARNING: Different names and order of the columns
# Note that relative to SS3 v.3.24, the order of PRIOR SD and PRIOR TYPE have been
# switched and the PRIOR TYPE options have been renumbered.
# ===================================== #
# PRIOR TYPE
# ===================================== #
# SS V3.30                              / V3.24
# 0 = none                              / -1
# 1 = symmetric beta                    / 1
# 2 = full beta                         / 2
# 3 = lognormal without bias adjustment / 3
# 4 = lognormal with bias adjustment    / 4
# 5 = gamma                             / 5
# 6 = normal                            / 0
# ===================================== #

# Modify the old MG param table
MG_param <- oldCtl$MG_parms
# Which PRIOR Type are used
unique(MG_param$PR_type)
# 3 (lognormal without bias adjustment) => don't need to be changed
# -1 (none) => Need to be changed in 0
MG_param[MG_param[, "PR_type"] == -1, "PR_type"] <- 0

# WARNING Biological parameters needs to be reorganized because
# growth pattern >1 so females appear first and then males

MG_param$param <- rownames(MG_param)
MG_param <-
  MG_param[order(str_detect(string = MG_param$param, pattern = "Fem"),
                 decreasing = T),]


# Fill in the Biology parameters
MG_params <- data.frame(
  "LO" = MG_param$LO,
  "HI" = MG_param$HI,
  "INIT" = MG_param$INIT,
  "PRIOR" = MG_param$PRIOR,
  "PR_SD" = MG_param$SD,
  "PR_type" = MG_param$PR_type,
  "PHASE" = MG_param$PHASE,
  "env_var&link" = MG_param$env_var,
  "dev_link" = MG_param$use_dev,
  "dev_minyr" = MG_param$dev_minyr,
  "dev_maxyr" = MG_param$dev_maxyr,
  "dev_PH" = 0,
  "Block" = MG_param$Block,
  "Block_Fxn"  = MG_param$Block_Fxn
)
rnamMG_params <- rownames(MG_param)
# Need to add the fraction of female within the population
# this parameter was not in the biological parameter in the SSV3.24
# 2013 model it was fixed to 0.5
oldCtl$fracfemale

fracfemale <- data.frame(
  "LO" = 0.00000001,
  "HI" = 0.99999999,
  "INIT" = 0.5,
  "PRIOR" = 0.5,
  "PR_SD" = 0.5,
  "PR_type" = 0,
  "PHASE" = -99,
  "env_var&link" = 0,
  "dev_link" = 0,
  "dev_minyr" = 0,
  "dev_maxyr" = 0,
  "dev_PH" = 0,
  "Block" = 0,
  "Block_Fxn"  = 0
)
MG_params <- rbind(MG_params, fracfemale)
rownames(MG_params) <- c(rnamMG_params, "FracFemale_GP_1")
colnames(MG_params) <- colnames(ctl$MG_parms)
ctl$MG_parms <- MG_params
rm(MG_params)
# ----------------------------------------------

# Time-varying Growth Parameters----
# ---------------------------------------------- #
# No time varying parameters in the 2013 model
# ----------------------------------------------

# Seasonal Biology Parameters ----
# ---------------------------------------------- #
#_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
ctl$MGparm_seas_effects <- oldCtl$MGparm_seas_effects
# ----------------------------------------------

# Spawner-recruitment relationship ----
# ---------------------------------------------- #
# SR relationship
# Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop;
# 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm
ctl$SR_function <- oldCtl$SR_function #3
# Equilibrium recruitment
# 0/1 to use steepness in initial equ recruitment calculation
ctl$Use_steep_init_equi <- 0 # Mimic SS V3.24
#  future feature:
# 0/1 to make realized sigmaR a function of SR curvature
ctl$Sigma_R_FofCurvature <- 0

# Spawner-recruitment parameters
# WARNING: Different names and order of the columns
# Note that relative to SS3 v.3.24, the order of PRIOR SD and PRIOR TYPE have been
# switched and the PRIOR TYPE options have been renumbered.
# ===================================== #
# PRIOR TYPE
# ===================================== #
# SS V3.30                              / V3.24
# 0 = none                              / -1
# 1 = symmetric beta                    / 1
# 2 = full beta                         / 2
# 3 = lognormal without bias adjustment / 3
# 4 = lognormal with bias adjustment    / 4
# 5 = gamma                             / 5
# 6 = normal                            / 0
# ===================================== #

# Moreover:
# 1. these are now long parameters (the "SR_envlink" is no more used)
names(oldCtl$SR_parms)
# [1] "LO"      "HI"      "INIT"    "PRIOR"   "PR_type" "SD"      "PHASE"
names(ctl$SR_parms)
# [1] "LO"           "HI"           "INIT"         "PRIOR"        "PR_SD"        "PR_type"      "PHASE"
# [8] "env_var&link" "dev_link"     "dev_minyr"    "dev_maxyr"    "dev_PH"       "Block"        "Block_Fxn"
# 2. The "SR_R1_offset" parameter has been replaced by the "SR_regime" parameter
rownames(oldCtl$SR_parms)
rownames(ctl$SR_parms)

SR_params <- oldCtl$SR_parms

# Which PRIOR Type are used
unique(SR_params$PR_type)
# -1
# -2
# Negative values mean that no prior are used.
SR_params[SR_params[, "PR_type"] < 0, "PR_type"] <- 0
# We remove the 'SR_envlink' parameters from the parameters table
# there is no environmental link in this model so we don't need to worry that
# much about this parameter
print(oldCtl$SR_env_link)
SR_params <-
  SR_params[!rownames(SR_params) == "SR_envlink",]

# We change the row names of SR_params
# the "SR_regime" parameter is intended to have a base value of 0.0 and
# not be estimated which is the case here
rownames(SR_params) <- rownames(ctl$SR_parms)

# Fill in the new SR_params table
SR_params <- data.frame(
  "LO" = SR_params$LO,
  "HI" = SR_params$HI,
  "INIT" = SR_params$INIT,
  "PRIOR" = SR_params$PRIOR,
  "PR_SD" = SR_params$SD,
  "PR_type" = SR_params$PR_type,
  "PHASE" = SR_params$PHASE,
  "env_var&link" = 0,
  "dev_link" = 0,
  "dev_minyr" = 0,
  "dev_maxyr" = 0,
  "dev_PH" = 0,
  "Block" = 0,
  "Block_Fxn" = 0,
  row.names = rownames(SR_params)
)
colnames(SR_params) <- colnames(ctl$SR_parms)
ctl$SR_parms <- SR_params
rm(SR_params)

# Spawner-recruitment Time-Varying Parameters
# No time varying recruitment parameters in the 2013 model

# Recruitment Deviation Setup
#do rec dev
# 0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev);
# 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
ctl$do_recdev <- oldCtl$do_recdev #1
# first year of main recr_devs; early devs can preceed this era
ctl$MainRdevYrFirst <- oldCtl$MainRdevYrFirst
# last year of main recr_devs; forecast devs start in following year
ctl$MainRdevYrLast <- oldCtl$MainRdevYrLast
# Main recruitment deviations phase
ctl$recdev_phase <- oldCtl$recdev_phase
# Advanced options
# 0: Use default values for advanced options
# 1: Read values for the 11 advances options
ctl$recdev_adv <- oldCtl$recdev_adv

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Advanced Stock recruitment options
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#_Cond #_recdev_early_start (0=none; neg value makes relative to recdev_start)
ctl$recdev_early_start <- oldCtl$recdev_early_start
#_Cond -4 #_recdev_early_phase
ctl$recdev_early_phase <- oldCtl$recdev_early_phase
#_Cond -4 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
ctl$Fcast_recr_phase <- oldCtl$Fcast_recr_phase
#_Cond 1 #_lambda for Fcast_recr_like occurring before endyr+1
ctl$lambda4Fcast_recr_like <- oldCtl$lambda4Fcast_recr_like
#_Cond 1001 #_last_yr_nobias_adj_in_MPD; begin of ramp
ctl$last_early_yr_nobias_adj <-
  oldCtl$last_early_yr_nobias_adj
#_Cond 1981 #_first_yr_fullbias_adj_in_MPD; begin of plateau
ctl$first_yr_fullbias_adj <- oldCtl$first_yr_fullbias_adj
#_Cond 2010 #_last_yr_fullbias_adj_in_MPD
ctl$last_yr_fullbias_adj <- oldCtl$last_yr_fullbias_adj
#_Cond 2013 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
ctl$first_recent_yr_nobias_adj <-
  oldCtl$first_recent_yr_nobias_adj
#_Cond 1 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
ctl$max_bias_adj <- oldCtl$max_bias_adj
#_Cond 0 #_period of cycles in recruitment (N parms read below)
ctl$period_of_cycles_in_recr <-
  oldCtl$period_of_cycles_in_recr
#_Cond -5 #min rec_dev
ctl$min_rec_dev <- oldCtl$min_rec_dev
#_Cond 5 #max rec_dev
ctl$max_rec_dev <- oldCtl$max_rec_dev
#_Cond 0 #_read_recdevs
ctl$N_Read_recdevs <- oldCtl$N_Read_recdevs
#_end of advanced SR options
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# ----------------------------------------------

# 5.8 Fishing mortality Method ----
# ---------------------------------------------- #
# F ballpark value in units of annual_F
ctl$F_ballpark <- oldCtl$F_ballpark #0.06
# F ballpark year (neg value to disable)
ctl$F_ballpark_year <- oldCtl$F_ballpark_year #1999
# F Method:
# 1=Pope midseason rate; 2=F as parameter; 3=F as hybrid;
# 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
ctl$F_Method <- oldCtl$F_Method #1
# max F (methods 2-4) or harvest fraction (method 1)
ctl$maxF <- oldCtl$maxF #0.9

# Initial Fishing mortality
# For each fleet x season that has init_catch; nest season in fleet; count = 0
# for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL

# WARNING 1: This is useful only if equilibrium catch are input in the
# catch section of the data file, which is not the case so we don't want this in
# the control file

# WARNING 2: If used, Need to change the column order and the PR_type
# (see code below)
# LO HI INIT PRIOR PR_SD  PR_type  PHASE

# init_F <- oldCtl$init_F
# init_F <- init_F[,c("LO","HI","INIT","PRIOR","SD","PR_type","PHASE")]
# Which PRIOR Type are used
# unique(init_F$PR_type) # -1
# Negative values mean that no prior are used.
# init_F[init_F[,"PR_type"]<0, "PR_type"] <- 0
# colnames(init_F)[5] <- "PR_SD"
# ctl$init_F <- init_F; rm(init_F)
# ----------------------------------------------

# 5.9 Catchability ----
# ---------------------------------------------- #

# Catchability parameters matrix for SS V3.30 is really different from the one used in V3.24.
# => In the 2013 model:
# * Each fleet was directly proportional to abundance,
# * There was no environmental impact on Q,
# * Only the `Triennial1` survey had an extra parameter that will contain an additive constant to be added to
# the input stddev of the survey variability,
# * Each fleet has a Q set as a scaling factor such that the estimate is median unbiased <=> Q "float"
#
# => For this transition and as a first step:
#   * Each fleet has a simple Q, directly proportional to abundance (i.e., `link` = 1)
# * the Extra input for link information is set to 0 to mimic the default option of previous version of SS
# * An extra standard error is estimated for the Triennial1 survey. The estimate from the 2013 model is used as input to set up this parameter
# See the additional parameter line in the `Q_parms` matrix
# * We don't incorporate priors at this stage so no bias adjustement are applied (i.e., `biasadj` = 0)
# * Q is fixed, i.e., by no floating (`float` = 0) and not estimating (`PHASE` = -1)

# 1. Set the catchability options
# Which fleets have CPUE index
Q_fleet <- c(5:9)
Q_fleetName <- oldCtl$fleetnames[Q_fleet]

# Q_options for fleets with cpue or survey data
# 1:  fleet number
# 2:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm; 4=mirror with offset, 2 parm)
# 3:  extra input for link, i.e. mirror fleet# or dev index number
# 4:  0/1 to select extra sd parameter
# 5:  0/1 for biasadj or not
# 6:  0/1 to float
#_fleet link link_info extra_se biasadj float
Q_options <- data.frame(rbind(
  #Triennial1
  c(5, 1, 0, 1, 0, 0),
  #Triennial2
  c(6, 1, 0, 0, 0, 0),
  #AFSCslope
  c(7, 1, 0, 0, 0, 0),
  #NWFSCslope
  c(8, 1, 0, 0, 0, 0),
  #NWFSCcombo
  c(9, 1, 0, 0, 0, 0)
), row.names = Q_fleetName)
colnames(Q_options) <- colnames(ctl$Q_options)
ctl$Q_options <- Q_options
rm(Q_options)

# 2. Fill in the Catchability parameters
# Load the outputs from the 2013 model to get the values for the catchability
# and the extra standard error for the Triennial1 survey
replist <- SS_output(dir = oldSST_path,
                     verbose = TRUE,
                     printstats = TRUE)
# Values of catchability for each fleet
Q_vals <- unique(replist$cpue$Calc_Q)
Q_vals <- log(Q_vals)
# Extra standard error for the Triennial1 survey
ExtraSdTriennial1 <-
  replist$parameters["Q_extraSD_5_Triennial1", c("Phase", "Min", "Max", "Init")]

# Q parameters
# Unit log(Q)
# Lines here are LnQ base/Extra SD(if applicable) for each fleet
#_LO HI INIT PRIOR PR_SD PR_type PHASE env-var use_dev dev_mnyr dev_mxyr dev_PH Block Blk_Fxn
# for all fleet: rep(0,7) corresponds to the potential time varying deviations
print(Q_vals)
# Names of the Q parameters
Q_parNam <- c(
  paste0("LnQ_base_", Q_fleetName[1]),
  paste0("ExtraSD_", Q_fleetName[1]),
  paste0("LnQ_base_", Q_fleetName[2:5])
)
Q_parms <- data.frame(rbind(
  # LnQ_base_Triennial1
  c(-5, 5, Q_vals[1], 0, 1, 0, -1, rep(0, 7)),
  #Triennial1
  c(0.01, 0.5, 0.05, 0.05, 0.1, 0, 4, rep(0, 7)),
  
  # LnQ_base_Triennial2
  c(-5, 5, Q_vals[2], 0, 1, 0, -1, rep(0, 7)),
  # LnQ_base_AFSCslope
  c(-5, 5, Q_vals[3], 0, 1, 0, -1, rep(0, 7)),
  # LnQ_base_NWFSCslope
  c(-5, 5, Q_vals[4], 0, 1, 0, -1, rep(0, 7)),
  # LnQ_base_NWFSCcombo
  c(-5, 5, Q_vals[5], 0, 1, 0, -1, rep(0, 7))
), row.names = Q_parNam)
colnames(Q_parms) <- colnames(ctl$Q_parms)
# Store the Q_parms
ctl$Q_parms <- Q_parms
rm(Q_parms)

#_no timevary Q parameters
# ----------------------------------------------

# 5.10 Selectivity and discards ----
# ---------------------------------------------- #

# Size selectivity patterns
#Pattern:_0;  parm=0; selex=1.0 for all sizes
#Pattern:_1;  parm=2; logistic; with 95% width specification
#Pattern:_5;  parm=2; mirror another size selex; PARMS pick the min-max bin to mirror
#Pattern:_11; parm=2; selex=1.0  for specified min-max population length bin range
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_6;  parm=2+special; non-parm len selex
#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (average over bin range)
#Pattern:_8;  parm=8; double_logistic with smooth transitions and constant above Linf option
#Pattern:_9;  parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset
#Pattern:_21; parm=2+special; non-parm len selex, read as pairs of size, then selex
#Pattern:_22; parm=4; double_normal as in CASAL
#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0
#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners
#Pattern:_2;  parm=6; double_normal with sel(minL) and sel(maxL), using joiners, back compatibile version of 24 with 3.30.18 and older
#Pattern:_25; parm=3; exponential-logistic in length
#Pattern:_27; parm=special+3; cubic spline in length; parm1==1 resets knots; parm1==2 resets all
#Pattern:_42; parm=special+3+2; cubic spline; like 27, with 2 additional param for scaling (average over bin range)
#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention
# =============================== #
# SST 2013 model
# =============================== #
# Fishery & survey pattern:
# 24 - double normal
# Fishery discard :
# 1 - define 4 retention parameters
# Survey discard:
# 0 - no discarding by fleet
# Fishery & survey sex selectivity:
# 0 - Male and female selectivity will be the same
# Fishery & survey special special :
# 0 - No special option is used
# =============================== #
#_Pattern Discard Male Special
ctl$size_selex_types <- oldCtl$size_selex_types


# Age selectivity patterns
#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage
#Pattern:_10; parm=0; selex=1.0 for ages 1 to maxage
#Pattern:_11; parm=2; selex=1.0  for specified min-max age
#Pattern:_12; parm=2; age logistic
#Pattern:_13; parm=8; age double logistic. Recommend using pattern 18 instead.
#Pattern:_14; parm=nages+1; age empirical
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_16; parm=2; Coleraine - Gaussian
#Pattern:_17; parm=nages+1; empirical as random walk  N parameters to read can be overridden by setting special to non-zero
#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (average over bin range)
#Pattern:_18; parm=8; double logistic - smooth transition
#Pattern:_19; parm=6; simple 4-parm double logistic with starting age
#Pattern:_20; parm=6; double_normal,using joiners
#Pattern:_26; parm=3; exponential-logistic in age
#Pattern:_27; parm=3+special; cubic spline in age; parm1==1 resets knots; parm1==2 resets all
#Pattern:_42; parm=2+special+3; // cubic spline; with 2 additional param for scaling (average over bin range)
#Age patterns entered with value >100 create Min_selage from first digit and pattern from remainder
# =============================== #
# SST 2013 model
# =============================== #
# Fishery & survey pattern:
# 10 - selex=1.0 for ages 1 to maxage
# Fishery & survey discard :
# 0 - no discarding by fleet
# Fishery & survey sex selectivity:
# 0 - Male and female selectivity will be the same
# Fishery & survey special special :
# 0 - No special option is used
# =============================== #
#_Pattern Discard Male Special
ctl$age_selex_types <- oldCtl$age_selex_types

# Selectivity and Retention Parameters

# WARNING: Different names and order of the columns
# Note that relative to SS3 v.3.24, the order of PRIOR SD and PRIOR TYPE have been
# switched and the PRIOR TYPE options have been renumbered.

# ===================================== #
# PRIOR TYPE
# ===================================== #
# SS V3.30                              / V3.24
# 0 = none                              / -1
# 1 = symmetric beta                    / 1
# 2 = full beta                         / 2
# 3 = lognormal without bias adjustment / 3
# 4 = lognormal with bias adjustment    / 4
# 5 = gamma                             / 5
# 6 = normal                            / 0
# ===================================== #

# Modify the old Selex-ret param table
Size_sel <- oldCtl$size_selex_parms

# Which PRIOR Type are used
unique(Size_sel$PR_type)
# -1 (none) => Need to be changed in 0
Size_sel[Size_sel[, "PR_type"] == -1, "PR_type"] <- 0

# change column order
Size_sel <-
  cbind(Size_sel[, c("LO", "HI", "INIT", "PRIOR", "SD", "PR_type", "PHASE")],
        Size_sel[,!colnames(Size_sel) %in% c("LO", "HI", "INIT", "PRIOR", "SD", "PR_type", "PHASE")])
ctl$size_selex_parms <- Size_sel

# WARNING: Some retention parameters have blocks => time varying parameters
oldCtl$DoCustom_sel_blk_setup #No more used
# Selectivity Time-Varying Parameters


# Modify the old TV Selex param table
Size_TVpar <- oldCtl$custom_sel_blk_setup

# Which PRIOR Type are used
unique(Size_sel$PR_type)
# 0 (normal) => Need to be changed in 6
Size_TVpar[Size_TVpar[, "PR_type"] == 0, "PR_type"] <- 6

# Change column order
Size_TVpar <-
  Size_TVpar[, c("LO", "HI", "INIT", "PRIOR", "SD", "PR_type", "PHASE")]

# File the ctl list with the appropriate variable name (See the SS_read_3.30())
ctl[["size_selex_parms_tv"]] <- Size_TVpar

# Two-Dimensional Auto-Regressive Selectivity (Semi-parametric selectivity)
# Experimental feature added version 3.30.03.02
ctl[["Use_2D_AR1_selectivity"]] <-
  0 # not used here - old feature didn't have this feature
# ----------------------------------------------

# 5.11 Tag recapture parameters ----
# ---------------------------------------------- #
# 0=no read and autogen if tag data exist; 1=read
ctl$TG_custom <- oldCtl$TG_custom #0

#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# ----------------------------------------------

# 5.12 Variance Adjustment Factors ----
# ---------------------------------------------- #
# Input variance adjustments factors:
#_1=add_to_survey_CV
#_2=add_to_discard_stddev
#_3=add_to_bodywt_CV
#_4=mult_by_lencomp_N
#_5=mult_by_agecomp_N
#_6=mult_by_size-at-age_N
#_7=mult_by_generalized_sizecomp

# 2013 has variance adjustments factors
ctl$DoVar_adjust <- oldCtl$DoVar_adjust

# WARNING: the format has been changed
# Factor id are similar to those used in SS3.24
Var_Adj <- oldCtl$Variance_adjustments
Var_Adj$id <- rownames(Var_Adj)
Var_Adj$Factor <- 1:dim(Var_Adj)[1]

Var_Adj <- melt(
  Var_Adj,
  measure.vars = colnames(Var_Adj)[!colnames(Var_Adj) %in% c("id", "Factor")],
  variable.name = "Fleet",
  value.name = "Value"
)
Var_Adj <- Var_Adj %>%
  filter(Value > 0)
Var_Adj$Fleet <-
  str_remove(string = Var_Adj$Fleet, pattern = "Fleet")
Var_Adj <- Var_Adj[order(Var_Adj$Factor),]
Var_Adj <- subset(Var_Adj, select = -c(id))

#_Factor  Fleet  Value
ctl[["Variance_adjustment_list"]] <- Var_Adj
# ----------------------------------------------

# 5.13 Lambdas (Emphasis Factors) ----
# ---------------------------------------------- #
# Max lambda phase
ctl$maxlambdaphase <- oldCtl$maxlambdaphase #5
# SD offset
# must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 0 changes to default Lambdas (default value is 1.0)
ctl$sd_offset <- oldCtl$sd_offset #1
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch;
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
ctl[["lambdas"]] <- oldCtl$lambdas

# To write the control file we need to modify the value of ctl$N_lambdas
# which is set when reading the control file so here to 0 because the model example
# did not consider lambdas
ctl$N_lambdas <- length(rownames(ctl[["lambdas"]]))
# ----------------------------------------------

# 5.14 Controls for Variance of Derived Quantities ----
# ---------------------------------------------- #
# Additional standard deviation reported
# (0/1/2) read specs for more stddev reporting:
# 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers,
# 2 = add options for M,Dyn. Bzero, SmryBio
ctl$more_stddev_reporting <-
  oldCtl$more_stddev_reporting #0
# ----------------------------------------------

# 5.15 End of control file ----
# ************************************************* #
ctl$eof <- 999

# Save the new control file for SST
SS_writectl(
  ctllist = ctl,
  outfile = file.path(SST_path, "SST_control.ss"),
  version = "3.30",
  overwrite = TRUE
)


# 5.16 Check file structure ----
# We actually need to run the model to check the file structure

CtlFile <- file.path(SST_path, "SST_control.ss")
# SSTctl_V330 <- SS_readctl_3.30(file = CtlFile,
#                                verbose = T,
#                                use_datlist = TRUE,
#                                datlist = SSTdat_V330)

# SSTctl_V330 <- SS_readctl_3.30(file = CtlFile,
#                                verbose = T,
#                                use_datlist = FALSE,
#                                datlist = SSTdat_V330,
#                                nseas = SSTdat_V330$nseas,
#                                N_areas = SSTdat_V330$N_areas, )
# -----------------------------------------------------------

# clean environment
# var.to.save <- c(save.dir, 'SSTctl_V330')
rm(list = setdiff(ls(), var.to.save))
var.to.save <- ls()

# 6. Work on forecast file ----
# ----------------------------------------------------------- #

# Read in files ----
# ************************************************* #

# Read the model example forecast file
list.files(BaseMod_path)
ForeFile <- file.path(BaseMod_path, "forecast.ss")
Forec <-
  SS_readforecast(
    file = ForeFile,
    version = "3.30",
    verbose = T,
    readAll = T
  )

# Names of the list components of forecast file
# =============================== #
names(Forec)

# [1] "warnings"                                        "SSversion"                                       "sourcefile"
# [4] "type"                                            "benchmarks"                                      "MSY"
# [7] "SPRtarget"                                       "Btarget"                                         "Bmark_years"
# [10] "Bmark_relF_Basis"                                "Forecast"                                        "Nforecastyrs"
# [13] "F_scalar"                                        "Fcast_years"                                     "Fcast_selex"
# [16] "ControlRuleMethod"                               "BforconstantF"                                   "BfornoF"
# [19] "Flimitfraction"                                  "N_forecast_loops"                                "First_forecast_loop_with_stochastic_recruitment"
# [22] "fcast_rec_option"                                "fcast_rec_val"                                   "Forecast_loop_control_5"
# [25] "FirstYear_for_caps_and_allocations"              "stddev_of_log_catch_ratio"                       "Do_West_Coast_gfish_rebuilder_output"
# [28] "Ydecl"                                           "Yinit"                                           "fleet_relative_F"
# [31] "basis_for_fcast_catch_tuning"                    "max_totalcatch_by_fleet"                         "max_totalcatch_by_area"
# [34] "N_allocation_groups"                             "InputBasis"                                      "eof"


# 6.1 File & SS version info ----
# ************************************************* #
Forec$SSversion
Forec$sourcefile
Forec$type

# 6.2 Benchmarks/Reference Points ----
# ----------------------------------------------------------- #
# Do Benchmark
# 0=skip; 1=calc F_spr,F_btgt,F_msy; 2=calc F_spr,F0.1,F_msy; 3=add F_Blimit;
Forec$benchmarks <- 1
# MSY method
# 1= set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt) or F0.1; 4=set to F(endyr);
# 5=calc F(MEY) with MSY_unit options
# if Do_MSY=5, enter MSY_Units; then list fleet_ID, cost/F, price/mt,
# include_in_Fmey_scaling; # -fleet_ID to fill; -9999 to terminate
Forec$MSY <- 2
# SPR target (e.g. 0.40)
Forec$SPRtarget <- 0.5
# Biomass target (e.g. 0.40)
Forec$Btarget <- 0.4
#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF, beg_recr_dist, end_recr_dist, beg_SRparm, end_SRparm
# (enter actual year, or values of 0 or -integer to be rel. endyr)
# value <0 convert to endyr-value; except -999 converts to start_yr; must be >=start_yr and <=endyr
Forec$Bmark_years <- rep(0, 10)
# Benchmark Relative F basis
# 1 = use year range; 2 = set relF same as forecast below
Forec$Bmark_relF_Basis <- 1
# -----------------------------------------------------------

# 6.3 Forecast set up ----
# ----------------------------------------------------------- #
# Do forecast
# -1=none; 0=simple_1yr; 1=F(SPR); 2=F(MSY) 3=F(Btgt) or F0.1; 4=Ave F (uses first-last relF yrs); 5=input annual F scalar
# where none and simple require no input after this line; simple sets forecast F same as end year F
Forec$Forecast <- 1
# N forecast years
Forec$Nforecastyrs <- 12
# F scalar
# Fmult (only used for Do_Forecast==5) such that apical_F(f)=Fmult*relF(f)
Forec$F_scalar <- 0.20
# Forecast Years
# beg_selex, end_selex, beg_relF, end_relF, beg_mean recruits, end_recruits
# (enter actual year, or values of 0 or -integer to be rel. endyr)
Forec$Fcast_years <- rep(0, 6)

# Forecast selectivity
# (0=fcast selex is mean from year range; 1=fcast selectivity from annual time-vary parms)
Forec$Fcast_selex <- 0
# Control rule method
# (0: none; 1: ramp does catch=f(SSB), buffer on F; 2: ramp does F=f(SSB), buffer on F;
# 3: ramp does catch=f(SSB), buffer on catch; 4: ramp does F=f(SSB), buffer on catch)
Forec$ControlRuleMethod <- 1
# values for top, bottom and buffer exist, but not used when Policy=0
# Control rule inflection for constant F (as frac of Bzero, e.g. 0.40);
# must be > control rule cutoff, or set to -1 to use Bmsy/SSB_unf
Forec$BforconstantF <- 0.40
# Control rule cutoff for no F (as frac of Bzero, e.g. 0.10)
Forec$BfornoF <- 0.10

# Buffer:
# enter Control rule target as fraction of Flimit (e.g. 0.75), negative value
# invokes list of [year, scalar] with filling from year to YrMax
Forec$Flimitfraction <- 1
# Number of forecast loops
# (1=OFL only; 2=ABC; 3=get F from forecast ABC catch with allocations applied)
Forec$N_forecast_loops <- 3
# First forecast loop with stochastic recruitment
Forec$First_forecast_loop_with_stochastic_recruitment <- 3

# Forecast recruitment
# 0= spawn_recr; 1=value*spawn_recr_fxn; 2=value*VirginRecr;
# 3=recent mean from yr range above (need to set phase to -1 in control to get constant recruitment in MCMC)

Forec$fcast_rec_option <-
  0 # ignore input and do forecast recruitment as before
Forec$fcast_rec_val <- 0 #Don't need due to previous input

#_Forecast loop control #5 (reserved for future bells&whistles)
Forec$Forecast_loop_control_5 <- 0
# -----------------------------------------------------------

# 6.4 Catch set up ----
# ----------------------------------------------------------- #
# First Year for caps and allocations (should be after years with fixed inputs)
Forec$FirstYear_for_caps_and_allocations <- 2013
# Implementation error
# stddev of log(realized catch/target catch) in forecast
# (set value>0.0 to cause active impl_error)
Forec$stddev_of_log_catch_ratio <- 0
# Do West Coast gfish rebuilder output: 0=no; 1=yes
Forec$Do_West_Coast_gfish_rebuilder_output <- 0

# Rebuilder catch
# first year catch could have been set to zero (Ydecl)(-1 to set to 1999)
Forec$Ydecl <- 2001
# Rebuilder start year
# year for current age structure (Yinit) (-1 to set to endyear+1)
Forec$Yinit <- 2011

# fleet relative F:
# 1=use first-last alloc year; 2=read seas, fleet, alloc list below
# Note that fleet allocation is used directly as average F if Do_Forecast=4
Forec$fleet_relative_F <- 1
# Basis for maximum forecast catch
# tuning and for fcast catch caps and allocation
# (2=deadbio; 3=retainbio; 5=deadnum; 6=retainnum); NOTE: same units for all fleets
Forec$basis_for_fcast_catch_tuning <- 2
# Conditional input if relative F choice = 2
# enter list of:  season,  fleet, relF; if used, terminate with season=-9999
# -9999 0 0  # terminator for list of relF

# Maximum total forecast catch by fleet
# enter list of: fleet number, max annual catch for fleets with a max
# terminate with fleet=-9999
# Based on the max catch per fleet in data
maxCatch <-
  aggregate(catch ~ year + fleet, data = SSTdat_V330$catch, sum) %>%
  group_by(fleet) %>%
  summarise(Freq = max(catch))
maxCatch$Freq <- maxCatch$Freq + 1000 # arbitrarly
maxCatch <- as.data.frame(maxCatch)
colnames(maxCatch) <- c("fleet", "Max_catch")
Forec$max_totalcatch_by_fleet <- maxCatch

# Maximum total catch by area
# enter list of area ID and max annual catch; terminate with area=-9999
# Set as no maximum
Forec$max_totalcatch_by_area[1, 2] <- -1

# enter list of fleet number and allocation group assignment, if any; terminate with fleet=-9999
#_if N allocation groups >0, list year, allocation fraction for each group
# list sequentially because read values fill to end of N forecast
# terminate with -9999 in year field
# no allocation groups

# Basis for forecast catch
# -1=read basis with each obs; 2=dead catch; 3=retained catch; 99=input apical_F;
# NOTE: bio vs num based on fleet's catchunits
Forec$InputBasis <- 2
#enter list of Fcast catches or Fa; terminate with line having year=-9999
#_Yr Seas Fleet Catch(or_F)
# -----------------------------------------------------------

# 6.5 End of forecast file ----
# ************************************************* #
Forec$eof <- 999

# Save the new forecast file for SST
SS_writeforecast(
  mylist = Forec,
  dir = SST_path,
  file = "forecast.ss",
  writeAll = TRUE,
  verbose = TRUE,
  overwrite = TRUE
)

# 6.6 Check file structure ----
ForFile <- file.path(SST_path, "forecast.ss")
SSTforec_V330 <- SS_readforecast(
  file = ForFile,
  version = "3.30",
  readAll = TRUE,
  verbose = TRUE
)
# => Everything looks good :)
