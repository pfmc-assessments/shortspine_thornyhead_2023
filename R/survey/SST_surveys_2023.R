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
triennial.survey.data <- get.survey.data(survey.name = "Triennial", write=FALSE)

# Triennial 1 Survey (triennial survey all years but low depth)
out.dir <- file.path(outputs.dir, "surveys", "triennial1")
fleet.num <- 5

t1.survey.catch <- triennial.survey.data$catch %>% filter(Depth_m <= 366)
t1.survey.bio   <- triennial.survey.data$bio
t1.survey.bio$Lengths <- t1.survey.bio$Lengths %>% filter(Depth_m <= 366)

t1.survey.strata = CreateStrataDF.fn(
  depths.shallow = 100,
  depths.deep    = 400,
  lats.south     = 34.5,
  lats.north     = 49
)

PlotStrata.fn(t1.survey.strata, strata.groups = c("A"), title="Triennial 1 Survey Strata")

t1.index = Biomass.fn(dir = out.dir, dat = t1.survey.catch, strat.df = t1.survey.strata, fleet = fleet.num)

t1.eff.n <- GetN.fn(dir     = out.dir, 
                    dat     = t1.survey.bio$Lengths, 
                    type    = "length", 
                    species = "thorny")

t1.length.freq <- SurveyLFs.fn(dir      = out.dir, 
                               datL     = t1.survey.bio$Lengths, 
                               datTows  = t1.survey.catch,
                               strat.df = t1.survey.strata,
                               lgthBins = length.bins,
                               nSamps   = t1.eff.n,
                               sex      = 3,
                               maxSizeUnsexed  = max.size.unsexed, 
                               sexRatioUnsexed = 0.5,
                               fleet = fleet.num,
                               month = 7)

# Triennial 2 Survey (triennial survey al years but high depth)
out.dir <- file.path(outputs.dir, "surveys", "triennial2")
fleet.num <- 6

t2.survey.catch <- triennial.survey.data$catch %>% filter(Depth_m > 366)
t2.survey.bio   <- triennial.survey.data$bio
t2.survey.bio$Lengths <- t2.survey.bio$Lengths %>% filter(Depth_m > 366)

t2.survey.strata = strata = CreateStrataDF.fn(
  depths.shallow = 400,
  depths.deep    = 500,
  lats.south     = 32,
  lats.north     = 49
)

PlotStrata.fn(t2.survey.strata, strata.groups = c("A"), title="Triennial 2 Survey Strata")

t2.index = Biomass.fn(dir = out.dir, dat = t2.survey.catch, strat.df = t2.survey.strata, fleet = fleet.num)

t2.eff.n <- GetN.fn(dir     = out.dir, 
                    dat     = t2.survey.bio$Lengths, 
                    type    = "length", 
                    species = "thorny")

t2.length.freq <- SurveyLFs.fn(dir      = out.dir, 
                               datL     = t2.survey.bio$Lengths, 
                               datTows  = t2.survey.catch,
                               strat.df = t2.survey.strata,
                               lgthBins = length.bins,
                               nSamps   = t2.eff.n,
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

afsc.slope.index = Biomass.fn(dir = out.dir, dat = afsc.slope.catch, strat.df = afsc.slope.strata, fleet = fleet.num)

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

nwfsc.slope.index = Biomass.fn(dir = out.dir, dat = nwfsc.slope.catch, strat.df = nwfsc.slope.strata, fleet = fleet.num)

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
                                       sex      = 3,
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

nwfsc.combo.index = Biomass.fn(dir = out.dir, dat = nwfsc.combo.catch, strat.df = nwfsc.combo.strata, fleet = fleet.num)

nwfsc.combo.eff.n <- GetN.fn(dir     = out.dir, 
                             dat     = nwfsc.combo.bio, 
                             type    = "length", 
                             species = "thorny")

nwfsc.combo.length.freq <- SurveyLFs.fn(dir      = out.dir, 
                                        datL     = nwfsc.combo.bio, 
                                        datTows  = nwfsc.combo.catch,
                                        strat.df = nwfsc.combo.strata,
                                        lgthBins = length.bins,
                                        nSamps   = nwfsc.combo.eff.n,
                                        sex      = 3,
                                        maxSizeUnsexed  = max.size.unsexed, 
                                        sexRatioUnsexed = 0.5,
                                        fleet = fleet.num,
                                        month = 7)


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

# sample size information for surveys by year

for(i in c("t1.survey", "t2.survey", "afsc.slope")) {
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

bio.samples.master = as.data.frame(rbind(t1.survey_samples, t2.survey_samples, afsc.slope_samples, 
      nwfsc.slope_samples, nwfsc.combo_samples))

for(i in c("t1.survey", "t2.survey", "afsc.slope")) {
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

bio.hauls.master = as.data.frame(rbind(t1.survey_hauls, t2.survey_hauls, afsc.slope_hauls, 
                                         nwfsc.slope_hauls, nwfsc.combo_hauls))

haul.sample.info.master = merge(bio.samples.master , bio.hauls.master, by=c("Year","survey"))
out.dir <- file.path(outputs.dir, "surveys")
write.csv(haul.sample.info.master, file.path(out.dir, paste0("haul.sample.info.master.csv")))

