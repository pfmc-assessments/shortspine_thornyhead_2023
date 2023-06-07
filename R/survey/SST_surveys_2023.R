# Survey catch and length composition data for shortspine thornyhead
# Contact: jane.sullivan@noaa.gov, jzahner@uw.edu
# Last updated: February 2023

# devtools::session_info()
# R version 4.2.0
# Platform: x86_64-w64-mingw32/x64 (64-bit)

# * strata definitions based on 2013 assessment
# * sex-structured assessment
# * no age data

# Note about the nwfscSurvey::CreateStrataDF.fn(): 
# Available depths: 55 75 100 125 155 183 200 250 300 350 400 450 500 549 600
# 700 800 900 1000 1100 1200 1280
# Available latitudes:32 32.5 33 33.5 34 34.5 35 35.5 36 36.5 37 37.5 38 38.5 39
# 39.5 40 40.166667 40.5 41 41.5 42 42.5 43 43.5 44 44.5 45 45.5 46 46.5 47 47.5
# 48 48.5 49

# set up ----

# install.packages("dplyr")
# install.packages("remotes")
# remotes::install_github("pfmc-assessments/nwfscSurvey")
library(nwfscSurvey)
library(tidyverse)

source(file=file.path(here::here(), "R", "survey", "survey_utils.R"))
source(file=file.path(here::here(), "R", "survey", "PlotStrata.fn.R"))

outputs.dir <- here::here("outputs")

length.bins <- seq(6, 72, 2)
max.size.unsexed <- 16  # see R/unsexed_length_analysis.R

# Triennial -----------
# Get triennial data once since its shared by the triennial1 and triennial2 surveys
#out.dir <- file.path(outputs.dir, "surveys", "triennial")
#fleet.num <- 5

triennial.survey.data <- get.survey.data(survey.name = "Triennial", write=FALSE)

# t.survey.catch <- triennial.survey.data$catch
# t.survey.bio   <- triennial.survey.data$bio
# t.survey.bio$Lengths <- t.survey.bio$Lengths %>% filter(Year > 1986)

# PlotMap.fn(dir=NULL, dat=t.survey.catch)
# 
# t.survey.strata = CreateStrataDF.fn(
#   depths.shallow = 100,
#   depths.deep    = 500,
#   lats.south     = 34.5,
#   lats.north     = 49
# )
# 
# t.eff.n <-  GetN.fn(dir     = out.dir, 
#                     dat     = t.survey.bio$Lengths, 
#                     type    = "length", 
#                     species = "thorny")
# 
# 
# t.length.freq <-  SurveyLFs.fn(dir      = out.dir, 
#                                datL     = t.survey.bio$Lengths, 
#                                datTows  = t.survey.catch,
#                                strat.df = t.survey.strata,
#                                lgthBins = length.bins,
#                                nSamps   = t.eff.n,
#                                sex      = 3,
#                                maxSizeUnsexed  = max.size.unsexed, 
#                                sexRatioUnsexed = 0.5,
#                                fleet = fleet.num,
#                                month = 7)

# Triennial 1 Survey (triennial survey all years but low depth)
out.dir <- file.path(outputs.dir, "surveys", "triennial_early")
fleet.num <- 5

tri_early.survey.catch <- triennial.survey.data$catch %>% filter(Year < 1995)
tri_early.survey.bio   <- triennial.survey.data$bio
tri_early.survey.bio$Lengths <- tri_early.survey.bio$Lengths %>% filter(Year < 1995, Year > 1986)

tri_early.survey.strata = CreateStrataDF.fn(
  names          = c("south_shallow", "south_deep", "north_shallow", "north_deep"),
  depths.shallow = c(55, 200, 55, 200),
  depths.deep    = c(200, 350, 200, 350),
  lats.south     = c(36, 36, 42, 42),
  lats.north     = c(42, 42, 49, 49)
)

PlotStrata.fn(tri_early.survey.strata, strata.groups = c("A"), title="Early Triennial Survey Strata")

tri_early.index = Biomass.fn(dir = out.dir, dat = tri_early.survey.catch, strat.df = tri_early.survey.strata, fleet = fleet.num, month=7)

tri_early.eff.n <- GetN.fn(dir     = out.dir, 
                    dat     = tri_early.survey.bio$Lengths, 
                    type    = "length", 
                    species = "thorny")

tri_early.length.freq <- SurveyLFs.fn(dir      = out.dir, 
                               datL     = tri_early.survey.bio$Lengths, 
                               datTows  = tri_early.survey.catch,
                               strat.df = tri_early.survey.strata,
                               lgthBins = length.bins,
                               nSamps   = tri_early.eff.n,
                               sex      = 3,
                               maxSizeUnsexed  = max.size.unsexed, 
                               sexRatioUnsexed = 0.5,
                               fleet = fleet.num,
                               month = 7)

# Triennial 2 Survey (triennial survey al years but high depth)
out.dir <- file.path(outputs.dir, "surveys", "triennial_late")
fleet.num <- 6

tri_late.survey.catch <- triennial.survey.data$catch %>% filter(Year >= 1995)
tri_late.survey.bio   <- triennial.survey.data$bio
tri_late.survey.bio$Lengths <- tri_late.survey.bio$Lengths %>% filter(Year >= 1995)

tri_late.survey.strata = strata = CreateStrataDF.fn(
  names          = c("south_shallow", "south_deep", "north_shallow", "north_deep"),
  depths.shallow = c(55, 200, 55, 200),
  depths.deep    = c(200, 549, 200, 549),
  lats.south     = c(34.5, 34.5, 40, 40),
  lats.north     = c(40, 40, 49, 49)
)

PlotStrata.fn(tri_late.survey.strata, strata.groups = c("A"), title="Late Triennial Survey Strata")

tri_late.index = Biomass.fn(dir = out.dir, dat = tri_late.survey.catch, strat.df = tri_late.survey.strata, fleet = fleet.num, month=7)

tri_late.eff.n <- GetN.fn(dir     = out.dir, 
                    dat     = tri_late.survey.bio$Lengths, 
                    type    = "length", 
                    species = "thorny")

tri_late.length.freq <- SurveyLFs.fn(dir      = out.dir, 
                               datL     = tri_late.survey.bio$Lengths, 
                               datTows  = tri_late.survey.catch,
                               strat.df = tri_late.survey.strata,
                               lgthBins = length.bins,
                               nSamps   = tri_late.eff.n,
                               sex      = 3,
                               maxSizeUnsexed  = max.size.unsexed, 
                               sexRatioUnsexed = 0.5,
                               fleet = fleet.num,
                               month = 7)

# AFSC Slope Survey ------------------
# AFSC Slope Survey (only years 1997 an onwards due to spatial sampling trends)
out.dir <- file.path(outputs.dir, "surveys", "afsc_slope")
fleet.num <- 7

afsc.slope.survey.data <- get.survey.data(survey.name = "AFSC.Slope")
afsc.slope.catch <- afsc.slope.survey.data$catch %>% filter(Year >= 1997)
afsc.slope.bio   <- afsc.slope.survey.data$bio
afsc.slope.bio$Lengths <- afsc.slope.bio$Lengths %>% filter(Year >= 1997)

afsc.slope.strata = CreateStrataDF.fn(
  names          = c("shallow_south", "deep_south"),
  depths.shallow = c(55,    500),
  depths.deep    = c(500,  1280),
  lats.south     = c(34,     34),
  lats.north     = c(49,     49)
)

PlotStrata.fn(afsc.slope.strata, strata.groups = c("Shallow", "Deep"), title="AFSC Slope Survey Strata")

afsc.slope.index = Biomass.fn(dir = out.dir, dat = afsc.slope.catch, strat.df = afsc.slope.strata, fleet = fleet.num, month=7)

afsc.slope.eff.n <- GetN.fn(dir     = out.dir, 
                            dat     = afsc.slope.bio$Lengths, 
                            type    = "length", 
                            species = "thorny")

afsc.slope.length.freq <- SurveyLFs.fn(dir      = out.dir, 
                                       datL     = afsc.slope.bio$Lengths, 
                                       datTows  = afsc.slope.catch,
                                       strat.df = afsc.slope.strata,
                                       lgthBins = length.bins,
                                       nSamps   = afsc.slope.eff.n,
                                       sex      = 3,
                                       maxSizeUnsexed  = max.size.unsexed, 
                                       sexRatioUnsexed = 0.5,
                                       fleet = fleet.num,
                                       month = 7)


# NWFSC Slope Survey -------------
out.dir <- file.path(outputs.dir, "surveys", "nwfsc_slope")
fleet.num <- 8

nwfsc.slope.survey.data <- get.survey.data(survey.name = "NWFSC.Slope")
nwfsc.slope.catch <- nwfsc.slope.survey.data$catch
nwfsc.slope.bio   <- nwfsc.slope.survey.data$bio

nwfsc.slope.strata = CreateStrataDF.fn(
  names          = c("shallow_south", "deep_south", "shallow_cen", "deep_cen", "shallow_north", "deep_north"), 
  depths.shallow = c(55,    500,  55,   500,   55,  500),
  depths.deep    = c(500,  1280,  500,  1280, 500, 1280),
  lats.south     = c(32,     32, 40.5,  40.5,  43,   43),
  lats.north     = c(40.5, 40.5,   43 ,   43,  49, 	 49)
)

PlotStrata.fn(nwfsc.slope.strata, strata.groups = c("South", "Central", "North"), title="NWFSC Slope Survey Strata")

nwfsc.slope.index = Biomass.fn(dir = out.dir, dat = nwfsc.slope.catch, strat.df = nwfsc.slope.strata, fleet = fleet.num, month=7)

nwfsc.slope.eff.n <- GetN.fn(dir     = out.dir, 
                             dat     = nwfsc.slope.bio, 
                             type    = "length", 
                             species = "thorny")

nwfsc.slope.length.freq <- SurveyLFs.fn(dir     = out.dir, 
                                       datL     = nwfsc.slope.bio, 
                                       datTows  = nwfsc.slope.catch,
                                       strat.df = nwfsc.slope.strata,
                                       lgthBins = length.bins,
                                       nSamps   = nwfsc.slope.eff.n,
                                       sex      = 0,
                                       maxSizeUnsexed  = max.size.unsexed, 
                                       sexRatioUnsexed = 0.5,
                                       fleet = fleet.num,
                                       month = 7)

# NWFSC Combo Survey ---------------
out.dir <- file.path(outputs.dir, "surveys", "nwfsc_combo")
fleet.num <- 9

nwfsc.combo.survey.data <- get.survey.data(survey.name = "NWFSC.Combo")
nwfsc.combo.catch <- nwfsc.combo.survey.data$catch
nwfsc.combo.bio   <- nwfsc.combo.survey.data$bio

nwfsc.combo.strata = strata = CreateStrataDF.fn(
  names          = c("shallow_south", "deep_south", "shallow_cen", "deep_cen", "shallow_north", "mid_north", "deep_north"), 
  depths.shallow = c(183, 549, 183, 549, 100, 183, 549), 
  depths.deep    = c(549, 1280, 549, 1280, 183, 549, 1280),
  lats.south     = c(32, 32, 34.5, 34.5, 40.5, 40.5, 40.5),
  lats.north     = c(34.5, 34.5, 40.5, 40.5, 49, 49, 49) 
)

PlotStrata.fn(nwfsc.combo.strata, strata.groups = c("South", "Central", "North"), title="NWFSC Combo Survey Strata")

nwfsc.combo.index = Biomass.fn(dir = out.dir, dat = nwfsc.combo.catch, strat.df = nwfsc.combo.strata, fleet = fleet.num, month=7)

nwfsc.combo.eff.n <- GetN.fn(dir     = out.dir, 
                             dat     = nwfsc.combo.bio, 
                             type    = "length", 
                             species = "thorny")

nwfsc.combo.length.sexed.freq <- SurveyLFs.fn(
      dir      = out.dir, 
      datL     = nwfsc.combo.bio %>% filter(Year > 2004), 
      datTows  = nwfsc.combo.catch %>% filter(Year > 2004),
      strat.df = nwfsc.combo.strata,
      lgthBins = length.bins,
      nSamps   = nwfsc.combo.eff.n[3:length(nwfsc.combo.eff.n)],
      sex      = 3,
      maxSizeUnsexed  = max.size.unsexed, 
      sexRatioUnsexed = 0.5,
      fleet = fleet.num,
      month = 7
)

nwfsc.combo.length.unsexed.freq <- SurveyLFs.fn(
  dir      = out.dir, 
  datL     = nwfsc.combo.bio %>% filter(Year <= 2004), 
  datTows  = nwfsc.combo.catch %>% filter(Year <= 2004),
  strat.df = nwfsc.combo.strata,
  lgthBins = length.bins,
  nSamps   = nwfsc.combo.eff.n[1:2],
  sex      = 0,
  maxSizeUnsexed  = max.size.unsexed, 
  sexRatioUnsexed = 0.5,
  fleet = fleet.num,
  month = 7
)

# Format for SS ---------
#afsc.triennial1.idx <- read.index.data("triennial1")
#afsc.triennial2.idx <- read.index.data("triennial2")
afsc.triennial_early.idx <- read.index.data("triennial_early")
afsc.triennial_late.idx <- read.index.data("triennial_late")
afsc.slope.idx  <- read.index.data("afsc_slope")
nwfsc.slope.idx <- read.index.data("nwfsc_slope")
nwfsc.combo.idx <- read.index.data("nwfsc_combo")

survey.indices <- bind_rows(
  #afsc.triennial1.idx,
  #afsc.triennial2.idx,
  afsc.triennial_early.idx,
  afsc.triennial_late.idx,
  afsc.slope.idx,
  nwfsc.slope.idx,
  nwfsc.combo.idx
) %>%
  mutate(
    Value = Value/1e3,               # convert to kg
    lci = Value-1.96*Value*seLogB,  # Lower 95% CI
    uci = Value+1.96*Value*seLogB,  # Upper 95% CI
    survey = recode_factor(         # Change survey to a factor
      survey, 
      !!!c(
        triennial_early = "AFSC Triennial Shelf Survey (Early)",
        triennial_late = "AFSC Triennial Shelf Survey (Late)",
        afsc_slope = "AFSC Slope Survey",
        nwfsc_slope = "NWFSC Slope Survey",
        nwfsc_combo = "West Coast Groundfish Bottom Trawl Survey"
      )
    ),
  ) %>%
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "processed", "surveys", "survey_indices_2023.csv")
  )

survey.indices.ss.all <- survey.indices %>%
  mutate(
    Fleet=case_when(survey == "AFSC Triennial Shelf Survey (Early)" ~ 5,
                    survey == "AFSC Triennial Shelf Survey (Late)" ~ 6,
                    survey == "AFSC Slope Survey" ~ 7,
                    survey == "NWFSC Slope Survey" ~ 8,
                    survey == "West Coast Groundfish Bottom Trawl Survey" ~ 9),
  ) %>%
  select(Year, Season, Fleet, Value, seLogB) %>%
  rename(year=Year, seas=Season, fleet=Fleet, index=Value, se_log=seLogB) %>%
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "for_ss", "survey_db_indices_all_2023.csv")
  ) %>%
  print(n=100)  

survey.indices.ss.noslope <- survey.indices %>%
  filter(!(survey %in% c("AFSC Slope Survey", "NWFSC Slope Survey"))) %>%
  mutate(
    Fleet=case_when(survey == "AFSC Triennial Shelf Survey (Early)" ~ 5,
                    survey == "AFSC Triennial Shelf Survey (Late)" ~ 6,
                    survey == "West Coast Groundfish Bottom Trawl Survey" ~ 7)
  ) %>%
  select(Year, Season, Fleet, Value, seLogB) %>%
  rename(year=Year, seas=Season, fleet=Fleet, index=Value, se_log=seLogB) %>%
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "for_ss", "survey_db_indices_noslope_2023.csv")
  ) %>%
  print(n=100)  
 
survey.indices.ss.geo.all <- read_csv(file.path(here::here(), "data", "processed", "surveys", "sdm_tmb_indices_2023_depth.csv")) %>%
  filter(area == "Total", method=="delta-gamma") %>%
  mutate(
    Fleet=case_when(survey == "Triennial" ~ 6,
                    survey == "AFSC Slope Survey" ~ 7,
                    survey == "NWFSC Slope Survey" ~8,
                    survey == "WCGBTS" ~ 9),
    Season=7
  ) %>%
  select(year, Season, Fleet, est, se) %>%
  rename(year=year, seas=Season, fleet=Fleet, index=est, se_log=se) %>%
  arrange(fleet) %>%
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "for_ss", "survey_mb_indices_all_2023.csv")
  ) %>%
  print(n=100)

survey.indices.ss.geo.noslope <- read_csv(file.path(here::here(), "data", "processed", "surveys", "sdm_tmb_indices_2023_depth.csv")) %>%
  filter(area == "Total", method=="delta-gamma") %>%
  filter(!(survey %in% c("AFSC Slope Survey", "NWFSC Slope Survey"))) %>%
  mutate(
    Fleet=case_when(survey == "Triennial" ~ 6,
                    survey == "WCGBTS" ~ 7),
    Season=7
  ) %>%
  select(year, Season, Fleet, est, se) %>%
  rename(year=year, seas=Season, fleet=Fleet, index=est, se_log=se) %>%
  arrange(fleet) %>%
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "for_ss", "survey_mb_indices_noslope_2023_depth.csv")
  ) %>%
  print(n=100)


survey.indices.ss.geo.noslope.lognormal <- read_csv(file.path(here::here(), "data", "processed", "surveys", "sdm_tmb_indices_2023.csv")) %>%
  filter(area == "Total", method=="delta-lognormal") %>%
  filter(!(survey %in% c("AFSC Slope Survey", "NWFSC Slope Survey"))) %>%
  mutate(
    Fleet=case_when(survey == "Triennial" ~ 6,
                    survey == "WCGBTS" ~ 7),
    Season=7
  ) %>%
  select(year, Season, Fleet, est, se) %>%
  rename(year=year, seas=Season, fleet=Fleet, index=est, se_log=se) %>%
  arrange(fleet) %>%
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "for_ss", "survey_mb_indices_noslope_2023_lognormal.csv")
  ) %>%
  print(n=100)

# Format Survey Length Comps ------
read.survey.length.comp.data <- function(survey.name, fname="Survey_Sex3_Bins_6_72_LengthComps.csv"){
  return(
    read_csv(file.path(here::here(), "outputs", "surveys", survey.name, "forSS", fname), show_col_types = FALSE) %>%
      print()
  )
}

#triennial.lcs.raw   <- read.survey.length.comp.data("triennial") # need this specially for the model-based indices
#triennial1.lcs.raw  <- read.survey.length.comp.data("triennial1")
#triennial2.lcs.raw  <- read.survey.length.comp.data("triennial2")
triennial_early.lcs.raw <- read.survey.length.comp.data("triennial_early")
triennial_late.lcs.raw <- read.survey.length.comp.data("triennial_late")
afsc.slope.lcs.raw  <- read.survey.length.comp.data("afsc_slope")
nwfsc.combo.lcs.raw <- read.survey.length.comp.data("nwfsc_combo")

nw.slope.unsex.lcs.raw <- read.survey.length.comp.data("nwfsc_slope", "Survey_Sex0_Bins_6_72_LengthComps.csv") %>%
  rename_with(~str_replace(., "U", "F"), .cols=starts_with("U"))
nw.combo.unsex.lcs.raw <- read.survey.length.comp.data("nwfsc_combo", "Survey_Sex0_Bins_6_72_LengthComps.csv") %>%
  rename_with(~str_replace(., "U", "F"), .cols=starts_with("U"))

length.comps.ss.all <- bind_rows(
  # triennial1.lcs.raw,
  # triennial2.lcs.raw,
  triennial_early.lcs.raw,
  triennial_late.lcs.raw,
  afsc.slope.lcs.raw,
  nw.slope.unsex.lcs.raw,
  nw.combo.unsex.lcs.raw,
  nwfsc.combo.lcs.raw
) %>%
  select(-ends_with(".1")) %>%
  dplyr::rename(Yr=year, Seas=month, FltSvy=fleet, Gender=sex, Part=partition, Nsamp=InputN) %>%
  dplyr::mutate(across(F6:M72, ~ .x/100)) %>% # ut into true proportions rather than per-100 rates
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "for_ss", "survey_length_comps_all_2023.csv")
  ) %>%
  print(n=100)

length.comps.ss.no.slope <- bind_rows(
  #triennial1.lcs.raw,
  #triennial2.lcs.raw,
  triennial_early.lcs.raw,
  triennial_late.lcs.raw,
  nw.combo.unsex.lcs.raw %>% mutate(fleet=7),
  nwfsc.combo.lcs.raw %>% mutate(fleet=7)
) %>%
  select(-ends_with(".1")) %>%
  dplyr::rename(Yr=year, Seas=month, FltSvy=fleet, Gender=sex, Part=partition, Nsamp=InputN) %>%
  dplyr::mutate(across(F6:M72, ~ .x/100)) %>% # ut into true proportions rather than per-100 rates
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "for_ss", "survey_length_comps_noslope_2023.csv")
  ) %>%
  print(n=1000)

length.comps.ss.one.triennial <- bind_rows(
  triennial.lcs.raw,
  afsc.slope.lcs.raw,
  nw.slope.unsex.lcs.raw,
  nw.combo.unsex.lcs.raw,
  nwfsc.combo.lcs.raw
) %>%
  select(-ends_with(".1")) %>%
  dplyr::rename(Yr=year, Seas=month, FltSvy=fleet, Gender=sex, Part=partition, Nsamp=InputN) %>%
  dplyr::mutate(across(F6:M72, ~ .x/100)) %>% # ut into true proportions rather than per-100 rates
  dplyr::mutate(
    FltSvy = ifelse(FltSvy > 5, FltSvy-1, FltSvy)
  ) %>%
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "for_ss", "survey_length_comps_single_triennial_2023.csv")
  ) %>%
  print(n=20)

length.comps.ss.no.slope.combined.triennial <- bind_rows(
  triennial.lcs.raw,
  nw.combo.unsex.lcs.raw,
  nwfsc.combo.lcs.raw
) %>%
  select(-ends_with(".1")) %>%
  dplyr::rename(Yr=year, Seas=month, FltSvy=fleet, Gender=sex, Part=partition, Nsamp=InputN) %>%
  dplyr::mutate(across(F6:M72, ~ .x/100)) %>% # ut into true proportions rather than per-100 rates
  dplyr::mutate(
    FltSvy = ifelse(FltSvy > 5, FltSvy-1, FltSvy)
  ) %>%
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "for_ss", "survey_length_comps_no_slope_combined_triennial_2023.csv")
  ) %>%
  print(n=20)

# Haul information ----------

# frequency of occurrence in tows
NWFSC.Combo.master <- PullCatch.fn(SurveyName = "NWFSC.Combo")
    # Shortspine 
    NWFSC.Combo.by.tow = NWFSC.Combo.master %>% 
      filter(Depth_m >= 500) %>% 
      group_by(Year, Vessel, Pass, Tow) %>% 
      summarise(n = n(), sst = length(which(Common_name == "shortspine thornyhead" & Subsample_count >= 1))) %>% 
      mutate(sst_present = sst >= 1)

    SST.freq.occurrence.tows = mean(NWFSC.Combo.by.tow$sst_present) 

    # longspine
    NWFSC.Combo.by.tow.longspine = NWFSC.Combo.master %>% 
      filter(Depth_m >= 500, Year <= 2013) %>% 
      group_by(Year, Vessel, Pass, Tow) %>% 
      summarise(n = n(), sst = length(which(Common_name == "longspine thornyhead" & Subsample_count >= 1))) %>% 
      mutate(sst_present = sst >= 1)

    SST.freq.occurrence.tows.longspine = mean(NWFSC.Combo.by.tow.longspine$sst_present) 
    
# find depts for each state 
names(NWFSC.Combo.master)

# latitude
# 42.06 - CA OR 
# 46.23 - OR WA 

NWFSC.Combo.master %>% filter(Latitude_dd > 46.23) %>% # WA 
                       filter(Common_name == "shortspine thornyhead") %>%
                       summarize(depth = mean(Depth_m, na.rm=T)) #342.5079

NWFSC.Combo.master %>% filter(between(Latitude_dd, 42.06, 46.23)) %>% # OR 
  filter(Common_name == "shortspine thornyhead") %>%
  summarize(depth = mean(Depth_m, na.rm=T)) #340.4969

NWFSC.Combo.master %>% filter(Latitude_dd < 42.06) %>% # CA 
  filter(Common_name == "shortspine thornyhead") %>%
  summarize(depth = mean(Depth_m, na.rm=T)) #442.4481


# sample size information for surveys by year

for(i in c("tri_early.survey", "tri_late.survey", "afsc.slope")) {
    x = eval(parse(text = paste0(i, ".bio$Lengths"))) %>% 
    group_by(Year) %>% 
    summarise(samples = n()) %>% 
    mutate(survey = str_replace(paste0(i), "[.]", " "))
    assign(paste(i, "_samples",sep = ""), x)  
    }
for(i in c("nwfsc.combo", "nwfsc.slope")) {
  x = eval(parse(text = paste0(i, ".bio"))) %>% 
    group_by(Year) %>% 
    summarise(samples = n()) %>% 
    mutate(survey = str_replace(paste0(i), "[.]", " "))
  assign(paste(i, "_samples",sep = ""), x)  
}

bio.samples.master = as.data.frame(rbind(tri_early.survey_samples, tri_late.survey_samples, afsc.slope_samples, 
      nwfsc.slope_samples, nwfsc.combo_samples))

for(i in c("tri_early.survey", "tri_late.survey", "afsc.slope")) {
  x = unique(eval(parse(text = paste0(i, ".bio$Lengths")))[c("Year", "Vessel", "Pass", "Tow", "Trawl_id")]) %>%  
  group_by(Year) %>% 
  summarise(hauls = n()) %>% 
  mutate(survey = str_replace(paste0(i), "[.]", " "))
  assign(paste(i, "_hauls",sep = ""), x)  
}

for(i in c("nwfsc.combo", "nwfsc.slope")) {
  x = unique(eval(parse(text = paste0(i, ".bio")))[c("Year", "Vessel", "Pass", "Tow", "Trawl_id")]) %>%  
    group_by(Year) %>% 
    summarise(hauls = n()) %>% 
    mutate(survey = str_replace(paste0(i), "[.]", " "))
  assign(paste(i, "_hauls",sep = ""), x)  
}

bio.hauls.master = as.data.frame(rbind(tri_early.survey_hauls, tri_late.survey_hauls, afsc.slope_hauls, 
                                         nwfsc.slope_hauls, nwfsc.combo_hauls))

haul.sample.info.master = merge(bio.samples.master , bio.hauls.master, by=c("Year","survey"))
out.dir <- file.path(outputs.dir, "surveys")
write.csv(haul.sample.info.master, file.path(out.dir, paste0("haul.sample.info.master.csv")))
write.csv(haul.sample.info.master, "doc/FinalTables/Summary/haul.sample.info.master.csv")


# Create table with haul and sample information  ------
library(kableExtra)
haul.sample.info.master <- read_csv("doc/FinalTables/Summary/haul.sample.info.master.csv")
options(knitr.kable.NA = '')

haul_sample_table = haul.sample.info.master %>% 
  pivot_wider(names_from = survey, 
              values_from = c(samples, hauls)) %>% 
  select("Year", 'samples_tri_early survey',"hauls_tri_early survey",
         "samples_tri_late survey", "hauls_tri_late survey",
         "samples_afsc slope", "hauls_afsc slope",
         "samples_nwfsc slope", "hauls_nwfsc slope",
         "samples_nwfsc combo", "hauls_nwfsc combo") %>% 
  kbl(col.names = c("Year", "samples", "hauls",
                    "samples", "hauls",
                    "samples", "hauls",
                    "samples", "hauls",
                    "samples", "hauls"),
      align = "c") %>% 
  kable_classic(full_width = F, html_font = "Times New Roman") %>% 
  add_header_above(c(" " = 1, "AFSC Triennial Shelf\nSurvey Early" = 2, "AFSC Triennial Shelf\nSurvey Late" = 2, 
                     "AFSC Slope\nSurvey" = 2, "NWFSC Slope\nSurvey" = 2,
                     "NWFSC Combo\nSurvey" = 2)) # %>%
  #save_kable(file = "outputs/surveys/haul_sample_table.png",
  #           zoom = 1.5) %>% 
  #save_kable(file = "doc/FinalTables/haul_sample_table.png",
  #           zoom = 1.5)



