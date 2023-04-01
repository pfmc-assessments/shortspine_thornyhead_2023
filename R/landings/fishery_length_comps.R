# Length compositions and	PacFIN Data Expansion for 
# Shortspine thornyhead 2023
# Contact: Haley Oleynik, Jane Sullivan
# Last updated March 2023

# This is the final analysis! Use eda_fishery_length_comps.R for initial
# analysis

# Set up ----
libs <- c('tidyverse', 'patchwork', 'ggthemes', 'ggridges')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

# pak::pkg_install('pfmc-assessments/PacFIN.Utilities',upgrade = TRUE)
# pak::pkg_install('pfmc-assessments/nwfscSurvey',upgrade = TRUE)
library(PacFIN.Utilities)
library(nwfscSurvey)

source(file=file.path("R", "utils", "colors.R"))

# we're not using any length comps from unidentified thornyheads because
# longspine and shortspine grow differently.

# Pull Data -----
# PacFIN biological (bds) data 
bds_file_short = "PacFIN.SSPN.bds.17.Jan.2023"
bds_file = paste0("data/raw/", bds_file_short, ".RData") # not hosted on github -- confidential
load(bds_file)

# Clean data 
Pdata <- cleanPacFIN(
  Pdata = bds.pacfin,
  keep_age_method = c("B", "BB", 1),
  CLEAN = TRUE, 
  verbose = TRUE)

# Fleet structure ------

# Create fleet structure in Pdata: the stratification for
# expansion, and calculate expansions
Pdata <- Pdata %>% 
  dplyr::mutate(geargroup = ifelse(geargroup == 'TWL', 'TWL', 'NONTWL'),
                fleet = paste0(state, "_", geargroup))

# Load in sex specific growth estimates from survey data 
LWsurvey <- read.csv("outputs/length-weight/lw_parameters_NWFSCcombo.csv")
fa <- LWsurvey$alpha[LWsurvey$sex=="Female"]
fb <- LWsurvey$beta[LWsurvey$sex=="Female"]
ma <- LWsurvey$alpha[LWsurvey$sex=="Male"]
mb <- LWsurvey$beta[LWsurvey$sex=="Male"]
ua = LWsurvey$alpha[LWsurvey$sex=="Sexes_combined"]
ub = LWsurvey$beta[LWsurvey$sex=="Sexes_combined"]

# Data cleaning -----

# see fishery_length_comps_eda.R for more info on these.

# in early iterations of the analysis, we identified 3 fish from 1981 caught in
# in California that are skewing the expansion (sample id = 1981223128134).
# Filter out these 3 weird fish (tiny proportion of fish sampled).
Pdata <- Pdata %>% filter(AGENCY_SAMPLE_NUMBER != 1981223128134)

# In early iternations of this analysis, we identified some specimens with
# errors in the conversion between lb and kg, mainly recent data (2020) from
# Washington state. fix here
Pdata <- Pdata %>%
  dplyr::mutate(weightkg=ifelse(lengthcm > 39 & weightkg < 0.05, 
                                weightkg*0.453592*1000, weightkg)) 

# First stage expansion ----

# expand comps to the trip level
Pdata_exp <- getExpansion_1(
  Pdata = Pdata,
  plot = file.path("outputs/fishery_data"),
  fa = fa, fb = fb, ma = ma, mb = mb, ua = ua, ub = ub) # weight-length params

# check expansion factors (want them to be < 500)
hist(Pdata_exp$Expansion_Factor_1_L)

# Second stage expansion ----

# expand comps up to the state and fleet (gear group)

# Read in processed PacFIN catch data - Each state should be kept seperate for
# state based expansions for each gear fleet within that state. Landings
# reported data from pacfin - separate for each state because different sampling
# and coverage
catch <- read.csv("data/processed/SST_PacFIN_length-comp-landings_2023.csv")

# The stratification.col input below needs to be the same as in the catch csv
# file
Pdata_exp <- getExpansion_2(
  Pdata = Pdata_exp, 
  Catch = catch, # catch file - needs to match state and fleet 
  Units = "MT", 
  stratification.cols = c("state", "geargroup"),
  savedir = file.path("outputs/fishery_data"))

# look expansion factors and caps: multiply expansion factors together cap
# values applies 0.95 quantile (anything outside gets capped)
Pdata_exp$Final_Sample_Size <- capValues(Pdata_exp$Expansion_Factor_1_L * Pdata_exp$Expansion_Factor_2)

# Calculate the final expansion size -----

Pdata_exp <- Pdata_exp %>% 
  dplyr::mutate(fleet = case_when(fleet %in% c('OR_TWL', 'WA_TWL') ~ 'NTrawl',
                                  fleet %in% c('CA_TWL') ~ 'STrawl',
                                  fleet %in% c('OR_NONTWL', 'WA_NONTWL') ~ 'NOther',
                                  fleet %in% c('CA_NONTWL') ~ 'SOther'))

# Make comps ----

# now that the expansions complete, summarise fishery landings as annual
# proportions-at-length. following 2013 assessment, make comps unsexed 

# Final_Sample_Size_L = the output of the expansion
# FREQ = used to sum of individual samples
# SAMPLE_NO = unique id for each tow or sampling event

Pdata_new <- Pdata_exp %>%
  dplyr::filter(year >= 1981 & !is.na(lengthcm)) %>%
  dplyr::mutate(length2 = ifelse(lengthcm < 6, 6,
                          ifelse(lengthcm > 72, 72, lengthcm)),
         lenbin = cut(length2, breaks = seq(4.9, 72.9, 2),
                      labels = paste(seq(6, 72, 2)))) %>%
  dplyr::mutate(month = 7,
                sex = 0, # 0 means combined male and female (must already be combined and information placed in the female portion of the data vector) (male entries must exist for correct data reading, then will be ignored).
                partition = 2, # retained
                lenbin = as.numeric(as.character(lenbin)),
                fleet_new = ifelse(fleet %in% c('SOther', 'NOther'),
                                   'NonTrawl', fleet)) %>%
  dplyr::select(year, month, fleet, fleet_new, sex, partition, lenbin,
                expansion_n = Final_Sample_Size_L, towid = SAMPLE_NO,
                state, gear = geargroup)

# function to get length comps in long format
get_comps_l <- function(data){
  
  tidyr::expand_grid(year = unique(data$year),
                     fleet = unique(data$fleet),
                     month = unique(data$month),
                     sex = unique(data$sex),
                     partition = unique(data$partition),
                     lenbin = c(seq(6, 72, 2))) %>%
    dplyr::left_join(data) %>% 
    dplyr::group_by(year, month, fleet, sex, partition, lenbin) %>%
    dplyr::summarise(n = sum(expansion_n, na.rm = TRUE),
                     nsamps = sum(!is.na(towid)),
                     ntows = length(unique(towid)))  %>%
    dplyr::group_by(year, month, fleet, sex, partition) %>%
    dplyr::mutate(totn = sum(n)) %>%
    dplyr::mutate(p = ifelse(totn == 0, 0, n / totn),
                  # The initial input sample sizes (Ninput) for length frequency
                  # distributions by year were calculated as a function of the
                  # number of trips and number of fish via the Stewart Method
                  # (Stewart, pers.com) The method is based on analysis of the
                  # input and model derived effective sample sizes from west
                  # coast groundfish stock assessments. A piece-wise linear
                  # regression was used to estimate the increase in effective
                  # sample size per sample based on fish-per-sample and the
                  # maximum effective sample size for large numbers of
                  # individual fish.
                  Nsamp = ifelse(nsamps / ntows < 44,
                                 ntows + 0.138 * nsamps,
                                 ifelse(nsamps / ntows >= 44,
                                        7.06 * ntows,
                                        # deal with NA -> 0 case
                                        0))) %>% 
    dplyr::arrange(fleet, year, lenbin) %>% 
    dplyr::ungroup()
}

fleet_str1 <- get_comps_l(data = Pdata_new)
fleet_str2 <- get_comps_l(data = Pdata_new %>% dplyr::select(-fleet) %>% dplyr::rename(fleet = fleet_new))

# function to get length comps into wide format for SS, uses output from
# get_comps_l()
get_comps_SS <- function(data) {
  
  data %>% 
    dplyr::mutate(lenbin = paste0('F', lenbin)) %>% 
    tidyr::pivot_wider(id_cols = c(year, month, fleet, sex, partition, Nsamp),
                names_from = lenbin, values_from = p, values_fill = 0) %>% 
    dplyr::left_join(data %>% 
                       dplyr::mutate(lenbin = paste0('M', lenbin)) %>% 
                       tidyr::pivot_wider(id_cols = c(year, month, fleet, sex, partition, Nsamp),
                                          names_from = lenbin, values_from = p, values_fill = 0),
                     by = join_by(year, month, fleet, sex, partition, Nsamp)) %>% 
    dplyr::mutate_at(vars(-c('year', 'month', 'fleet', 'sex', 'partition', 'Nsamp')), 
                     round, 4) %>% 
    dplyr::mutate_at(vars(-c('year', 'month', 'fleet', 'sex', 'partition', 'Nsamp')), 
                     format, nsmall = 4) 
  
}

ss_fleet_str1 = get_comps_SS(fleet_str1) %>%
  dplyr::mutate(
      fleet=case_when(fleet == "NTrawl" ~ 1,
                      fleet == "STrawl" ~ 2,
                      fleet == "NOther" ~ 3,
                      fleet == "SOther" ~ 4,
      )
  ) %>%
  dplyr::arrange(fleet, year)
  
ss_fleet_str2 = get_comps_SS(fleet_str2) %>% 
  dplyr::mutate(
      fleet=case_when(fleet == "NTrawl" ~ 1,
                      fleet == "STrawl" ~ 2,
                      fleet == "NonTrawl" ~ 3
      )
  ) %>%
  dplyr::arrange(fleet, year)

write_csv(ss_fleet_str1, 'data/for_ss/landings_length_comps_4fleet_2023.csv')
write_csv(ss_fleet_str2, 'data/for_ss/landings_length_comps_3fleet_2023.csv')

# get tow and sample summaries ----

samplesizes <- Pdata_new %>% 
  group_by(state, gear, year) %>% 
  dplyr::summarise(nsamps = n(),
                   ntows = length(unique(towid)))

write_csv(samplesizes, 'outputs/fishery_landings/lencomps_samplesizes.csv')
