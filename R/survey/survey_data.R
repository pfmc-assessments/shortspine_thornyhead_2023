# Survey catch and length composition data for shortspine thornyhead
# Contact: jane.sullivan@noaa.gov
# Last updated: January 2023

# devtools::session_info()
# R version 4.2.0
# Platform: x86_64-w64-mingw32/x64 (64-bit)

# warning: this script was developed by Jane as part of a homework assignment
# and it's not the official survey data processing script. please see
# survey-specific rmd files for the official survey data used in the assessment.
# all the output of this script is saved to subdirectories in data/raw, so that
# it won't be tracked by github.

# * strata definitions based on 2013 assessment
# * sex-structured assessment
# * no age data

# Note from Vladlena.Gertseva@noaa.gov 2023-01-20: Unlike NWFSC surveys, bio data files
# from AFSC surveys include two tables (for Length and Ages), and you will need
# to specify a table (bio = bio$Lengths) to run the expansion portion of the
# nwfscSurvey code. This applies to Triennial and AFSC Slope surveys (two
# historical surveys conducted by AFSC).

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
library(dplyr)

dir.create('data')
dir.create('data/raw')

len_bins <- seq(6, 72, 2) # from 2013 assessment

# all sizes below this threshold will assign unsexed fish by sexRatio set equal
# to 0.50, fish larger than this size will have unsexed fish assigned by the
# calculated sex ratio in the data. (proposed method: ~75% of unsexed fish below this
# size looking across all data sources?)
thorny_maxSizeUnsexed <- 16

# Shallow (<= 366 m) AFSC triennial shelf survey ----

tri1_path <- 'data/raw/Triennial1'; dir.create(tri1_path)

tri1_catch <- PullCatch.fn(Name = 'shortspine thornyhead', SurveyName = 'Triennial') %>% 
  filter(Depth_m <= 366)
saveRDS(tri1_catch, paste0(tri1_path, '/Triennial1_catch.rda'))

plot_cpue(catch = tri1_catch, dir = tri1_path)

tri1_bio <- PullBio.fn(Name = 'shortspine thornyhead', 
                              SurveyName = 'Triennial') 
tri1_bio <- tri1_bio$Lengths %>% 
  filter(Depth_m <= 366) 

saveRDS(tri1_bio, paste0(tri1_path, '/Triennial1_lengths.rda'))

plot_bio_patterns(bio = tri1_bio,
                  dir = tri1_path,
                  col_name = 'Length_cm')

wh_plot_proportion(data_bio = tri1_bio,
                   data_catch = tri1_catch,
                   dir = file.path(tri1_path, 'plots'))

# 1 stratum
tri1_strata <- CreateStrataDF.fn(depths.shallow = 55,
                                 depths.deep = 400, 
                                 lats.south = 34.5, 
                                 lats.north = 48.5) 
tri1_strata$name <- 'single_stratum'

# design-based estimate of biomass
tri1_biomass <- Biomass.fn(fleet = 5, # SS3 fleet/survey index
                           dir = tri1_path,
                           dat = tri1_catch,
                           strat.df = tri1_strata)

PlotBio.fn(dir = tri1_path, 
           dat = tri1_biomass,
           scalar = 1e3, # kg to mt
           ylab = 'Biomass (mt)',
           main = 'Triennial1')

# Length comps
tri1_effn <- GetN.fn(dir = tri1_path, 
             dat = tri1_bio, 
             type = "length", 
             species = "thorny")

# There are 572 tows where fish were observed but no lengths/ages taken. These
# tows contain 19277 lengths/ages that comprise 38.6 percent of total sampled
# fish.
unsexed <- tri1_bio %>% filter(Sex == "U" & year >= 1992) # omitted early data b/c it looked like more fish were unsexed overall across all lengths
summary(unsexed$Length_cm)
sexed <- tri1_bio %>% filter(Sex != "U" & year >= 1992)
summary(sexed$Length_cm)

tri1_lenfreq <- SurveyLFs.fn(fleet = 5, # SS3 fleet/survey index
                             dir = tri1_path, 
                             datL =  tri1_bio, 
                             datTows = tri1_catch,
                             strat.df = tri1_strata,
                             lgthBins = len_bins,
                             month = 7,
                             nSamps = tri1_effn,
                             sex = 3,
                             maxSizeUnsexed = thorny_maxSizeUnsexed, 
                             sexRatioUnsexed = 0.5) 

plot_comps(dir = tri1_path, 
           data = tri1_lenfreq)

# Deep (> 366 m) AFSC triennial shelf survey ----

tri2_path <- 'data/raw/Triennial2'; dir.create(tri2_path)

tri2_catch <- PullCatch.fn(Name = 'shortspine thornyhead', SurveyName = 'Triennial') %>% 
  filter(Depth_m > 366)
saveRDS(tri2_catch, paste0(tri2_path, '/Triennial2_catch.rda'))

plot_cpue(catch = tri2_catch, dir = tri2_path)

tri2_bio <- PullBio.fn(Name = 'shortspine thornyhead', 
                              SurveyName = 'Triennial') 
tri2_bio <- tri2_bio$Lengths %>% 
  filter(Depth_m > 366) 

saveRDS(tri2_bio, paste0(tri2_path, '/Triennial2_lengths.rda'))

plot_bio_patterns(bio = tri2_bio,
                  dir = tri2_path,
                  col_name = 'Length_cm')

wh_plot_proportion(data_bio = tri2_bio,
                   data_catch = tri2_catch,
                   dir = file.path(tri2_path, 'plots'))

# 1 stratum
tri2_strata <- CreateStrataDF.fn(depths.shallow = 350,
                                 depths.deep = 1280, 
                                 lats.south = 34.5, 
                                 lats.north = 48.5) 
tri2_strata$name <- 'single_stratum'

# design-based estimate of biomass
tri2_biomass <- Biomass.fn(fleet = 6, # SS3 fleet/survey index
                           dir = tri2_path,
                           dat = tri2_catch,
                           strat.df = tri2_strata)

PlotBio.fn(dir = tri2_path, 
           dat = tri2_biomass,
           scalar = 1e3, # kg to mt
           ylab = 'Biomass (mt)',
           main = 'Triennial2')

# Length comps
tri2_effn <- GetN.fn(dir = tri2_path, 
                     dat = tri2_bio, 
                     type = "length", 
                     species = "thorny")

# There are 36 tows where fish were observed but no lengths/ages taken. These
# tows contain 3940 lengths/ages that comprise 8.1 percent of total sampled
# fish.
unsexed <- tri2_bio %>% filter(Sex == "U") 
summary(unsexed$Length_cm)
sexed <- tri2_bio %>% filter(Sex != "U") 
summary(sexed$Length_cm)

tri2_lenfreq <- SurveyLFs.fn(fleet = 6, # SS3 fleet/survey index
                             dir = tri2_path, 
                             datL =  tri2_bio, 
                             datTows = tri2_catch,
                             strat.df = tri2_strata,
                             lgthBins = len_bins,
                             month = 7,
                             nSamps = tri2_effn,
                             sex = 3,
                             maxSizeUnsexed = thorny_maxSizeUnsexed, 
                             sexRatioUnsexed = 0.5)  

plot_comps(dir = tri2_path, 
           data = tri2_lenfreq)

# AFSC slope survey ----

afsc_slope_path <- 'data/raw/AFSCslope'; dir.create(afsc_slope_path)

# NOTE: There are 93 records with no area swept calculation. These record will be
# filled with the mean swept area across all tows.
afsc_slope_catch <- PullCatch.fn(Name = 'shortspine thornyhead',
                                 SurveyName = 'AFSC.Slope',
                                 Dir = afsc_slope_path,
                                 SaveFile = TRUE)

plot_cpue(catch = afsc_slope_catch, dir = afsc_slope_path)

# 1988-1996 data exist, low spatial resolution. Remove these data, similar to
# 2013 assessment
afsc_slope_catch <- afsc_slope_catch %>% filter(Year >= 1997)

afsc_slope_bio <- PullBio.fn(Name = 'shortspine thornyhead',
                           SurveyName = 'AFSC.Slope')

# No ages, but this df has length-weight pairs. Only save data after 1997
afsc_slope_lwpairs <- afsc_slope_bio$Ages %>% 
  filter(Year >= 1997)
saveRDS(afsc_slope_lwpairs, paste0(afsc_slope_path, '/AFSCslope_lengthweight_pairs.rda'))

# Data for length comps
afsc_slope_bio <- afsc_slope_bio$Lengths %>% 
  filter(Year >= 1997)
saveRDS(afsc_slope_bio, paste0(afsc_slope_path, '/AFSCslope_lengths.rda'))

plot_bio_patterns(bio = afsc_slope_bio,
                  dir = afsc_slope_path,
                  col_name = 'Length_cm')

wh_plot_proportion(data_bio = afsc_slope_bio,
                   data_catch = afsc_slope_catch,
                   dir = file.path(afsc_slope_path, 'plots'))

# 2 strata, shallower and deeper than 500 m
afsc_slope_strata <- CreateStrataDF.fn(names = c("below_500m", "above_500m"), 
                                       depths.shallow = c(55, 500),# min(afsc_slope_catch$Depth_m); max(afsc_slope_catch$Depth_m)
                                       depths.deep    = c(500, 1280),
                                       lats.south     = 34, # min(afsc_slope_catch$Latitude_dd); max(afsc_slope_catch$Latitude_dd)
                                       lats.north     = 48.5) 

afsc_slope_biomass <- Biomass.fn(fleet = 7, # SS3 fleet/survey index
                           dir = afsc_slope_path,
                           dat = afsc_slope_catch,
                           strat.df = afsc_slope_strata)

PlotBio.fn(dir = afsc_slope_path, 
           dat = afsc_slope_biomass,
           scalar = 1e3, # kg to mt
           ylab = 'Biomass (mt)',
           main = 'AFSCslope')

PlotBioStrata.fn(dir = afsc_slope_path, 
                 dat = afsc_slope_biomass,
                 scalar = 1e3, # kg to mt
                 ylab = 'Biomass (mt)',
                 mfrow = c(1, 2))

# Length comps
afsc_slope_effn <- GetN.fn(dir = afsc_slope_path, 
                           dat = afsc_slope_bio, 
                           type = "length", 
                           species = "thorny")

# There are 3 tows where fish were observed but no lengths/ages taken. These
# tows contain 32 lengths/ages that comprise 0.1 percent of total sampled fish.
unsexed <- afsc_slope_bio %>% filter(Sex == "U") 
summary(unsexed$Length_cm)
sexed <- afsc_slope_bio %>% filter(Sex != "U") 
summary(sexed$Length_cm)

afsc_slope_lenfreq <- SurveyLFs.fn(fleet = 7, # SS3 fleet/survey index
                             dir = afsc_slope_path, 
                             datL =  afsc_slope_bio, 
                             datTows = afsc_slope_catch,
                             strat.df = afsc_slope_strata,
                             lgthBins = len_bins,
                             month = 7,
                             nSamps = afsc_slope_effn,
                             sex = 3,
                             maxSizeUnsexed = thorny_maxSizeUnsexed, 
                             sexRatioUnsexed = 0.5) # 

plot_comps(dir = afsc_slope_path, 
           data = afsc_slope_lenfreq)

# NWFSC slope survey ----

nwfsc_slope_path <- 'data/raw/NWFSCslope'; dir.create(nwfsc_slope_path)

# NOTE: There are 4 records with no area swept calculation. These record will be
# filled with the mean swept area across all tows.
nwfsc_slope_catch <- PullCatch.fn(Name = 'shortspine thornyhead',
                                 SurveyName = 'NWFSC.Slope',
                                 Dir = nwfsc_slope_path,
                                 SaveFile = TRUE)

plot_cpue(catch = nwfsc_slope_catch, dir = nwfsc_slope_path)

nwfsc_slope_bio <- PullBio.fn(Name = 'shortspine thornyhead',
                               SurveyName = 'NWFSC.Slope')
unique(nwfsc_slope_bio$Weight) # no weight-length pairs

saveRDS(nwfsc_slope_bio, paste0(nwfsc_slope_path, '/NWFSCslope_lengths.rda'))

plot_bio_patterns(bio = nwfsc_slope_bio,
                  dir = nwfsc_slope_path,
                  col_name = 'Length_cm')

wh_plot_proportion(data_bio = nwfsc_slope_bio,
                   data_catch = nwfsc_slope_catch,
                   dir = file.path(nwfsc_slope_path, 'plots'))

# 6 strata, breaks dividing a southern, central, and northern strata at 40.5º N
# and 43º N, each separated between shallower and deeper than 500 m
nwfsc_slope_strata <- CreateStrataDF.fn(names = c('CA_lte500m', 'CA_gt500m', 'OR_lte500m', 'OR_gt500m',  'WA_lte500m', 'WA_gt500m'), 
                                        depths.shallow = c(55, 500, 55, 500, 55, 500), # min(nwfsc_slope_catch$Depth_m); max(nwfsc_slope_catch$Depth_m)
                                        depths.deep = c(500, 1280, 500, 1280, 500, 1280),
                                        lats.south = c(32, 32, 42, 42, 46, 46),
                                        lats.north = c(42, 42, 46, 46, 49, 49)) 

nwfsc_slope_biomass <- Biomass.fn(fleet = 8, # SS3 fleet/survey index
                                 dir = nwfsc_slope_path,
                                 dat = nwfsc_slope_catch,
                                 strat.df = nwfsc_slope_strata)

PlotBio.fn(dir = nwfsc_slope_path, 
           dat = nwfsc_slope_biomass,
           scalar = 1e3, # kg to mt
           ylab = 'Biomass (mt)',
           main = 'NWFSCslope')

PlotBioStrata.fn(dir = nwfsc_slope_path, 
           dat = nwfsc_slope_biomass,
           scalar = 1e3, # kg to mt
           ylab = 'Biomass (mt)',
           mfrow = c(2, 3))

# Length comps

# Most lengths are unsexed (a handful in 2000 were sexed) - assume all are
# unsexed.
table(nwfsc_slope_bio$Sex, nwfsc_slope_bio$Year)
nwfsc_slope_bio$Sex <- "U"

nwfsc_slope_effn <- GetN.fn(dir = nwfsc_slope_path, 
                            dat = nwfsc_slope_bio, 
                            type = "length", 
                            species = "thorny")

# There are 8 tows where fish were observed but no lengths/ages taken. These
# tows contain 53 lengths/ages that comprise 0.1 percent of total sampled fish.
nwfsc_slope_lenfreq <- SurveyLFs.fn(fleet = 8, # SS3 fleet/survey index
                                   dir = nwfsc_slope_path, 
                                   datL =  nwfsc_slope_bio, 
                                   datTows = nwfsc_slope_catch,
                                   strat.df = nwfsc_slope_strata,
                                   lgthBins = len_bins,
                                   month = 7,
                                   nSamps = nwfsc_slope_effn,
                                   sex = 0) 

plot_comps(dir = nwfsc_slope_path, 
           data = nwfsc_slope_lenfreq)

# NWFSC combo survey ----

# also called West Coast Groundfish Bottom Trawl Survey (WCGBT)?

combo_path <- 'data/raw/NWFSCcombo'; dir.create(combo_path)

combo_catch <- PullCatch.fn(Name = 'shortspine thornyhead',
                            SurveyName = 'NWFSC.Combo',
                            Dir = combo_path,
                            SaveFile = TRUE)

plot_cpue(catch = combo_catch, dir = combo_path)

combo_bio <- PullBio.fn(Name = 'shortspine thornyhead',
                               SurveyName = 'NWFSC.Combo')

# No ages, but this df has length-weight pairs for all years
combo_lwpairs <- combo_bio %>% filter(!is.na(Weight) & !is.na(Length_cm))
saveRDS(combo_lwpairs, paste0(combo_path, '/NWFSCcombo_lengthweight_pairs.rda'))

# there are some sexed fish by depth with no length data in a few years... get
# rid of these.
combo_bio <- combo_bio %>% filter(!is.na(Length_cm))

saveRDS(combo_bio, paste0(combo_path, '/NWFSCcombo_lengths.rda'))

plot_bio_patterns(bio = combo_bio,
                  dir = combo_path,
                  col_name = 'Length_cm')

wh_plot_proportion(data_bio = combo_bio,
                   data_catch = combo_catch,
                   dir = file.path(combo_path, 'plots'))

# 7 strata; two southern strata below 34.5º N, one covering 183–550 m and the
# other covering 550–1280 m. Two central strata between 34.5º N and 40.5º N, had
# the same depth ranges. North of 40.5º N, three strata were used, covering the
# ranges 100–183 m, 183–550 m and the other covering 550–1280 m. The depth
# breaks at 183 m and 550 m are associated with changes in sampling intensity of
# the survey and are recommended to be used. South of 40.5º N, there are very
# few shortspine thornyheads shallower than 183 m so no shallow stratum was used
# in these latitudes.
combo_strata <- CreateStrataDF.fn(names = c('South_183-550m', 'South_550-1280m', 
                                            'Central_183-550m', 'Central_550-1280m', 
                                            'North_100-183m', 'North_183-550m', 'North_550-1280'), 
                                  depths.shallow = c(183, 549, 183, 549, 100, 183, 549), 
                                  depths.deep = c(549, 1280, 549, 1280, 183, 549, 1280),
                                  lats.south = c(32, 32, 34.5, 34.5, 40.5, 40.5, 40.5),
                                  lats.north = c(34.5, 34.5, 40.5, 40.5, 49, 49, 49)) 

combo_biomass <- Biomass.fn(fleet = 9, # SS3 fleet/survey index
                            dir = combo_path,
                            dat = combo_catch,
                            strat.df = combo_strata)

PlotBio.fn(dir = combo_path, 
           dat = combo_biomass,
           scalar = 1e3, # kg to mt
           ylab = 'Biomass (mt)',
           main = 'NWFSCcombo')

PlotBioStrata.fn(dir = combo_path, 
           dat = combo_biomass,
           scalar = 1e3, # kg to mt
           ylab = 'Biomass (mt)',
           mfrow = c(2, 4))

# Length comps
combo_effn <- GetN.fn(dir = combo_path, 
                      dat = combo_bio, 
                      type = "length", 
                      species = "thorny")

# Very few fish sexed in 2003, only ~50% in 2004 - in 2013 assessment they
# assumed these first two years were all unsexed. Do same here:
combo_bio <- combo_bio %>% mutate(Sex = ifelse(Year %in% c(2003, 2004), "U", Sex))

unsexed <- combo_bio %>% filter(Sex == "U" & Year > 2004) 
summary(unsexed$Length_cm)
sexed <- combo_bio %>% filter(Sex != "U") 
summary(sexed$Length_cm)

# unsexed years: There are 5 tows where fish were observed but no lengths/ages
# taken. These tows contain 512 lengths/ages that comprise 2.5 percent of total
# sampled fish.
combo_lenfreq1 <- SurveyLFs.fn(fleet = 9, # SS3 fleet/survey index
                               dir = combo_path, 
                               datL =  combo_bio %>% filter(Year <= 2004), 
                               datTows = combo_catch %>% filter(Year <= 2004),
                               strat.df = combo_strata,
                               lgthBins = len_bins,
                               month = 7,
                               nSamps = combo_effn[1:2],
                               sex = 0) 

plot_comps(dir = combo_path, 
           data = combo_lenfreq1)

# sexed years: There are 11 tows where fish were observed but no lengths/ages
# taken. These tows contain 635 lengths/ages that comprise 0.3 percent of total
# sampled fish.
combo_lenfreq2 <- SurveyLFs.fn(fleet = 9, # SS3 fleet/survey index
                               dir = combo_path, 
                               datL =  combo_bio %>% filter(Year > 2004),  
                               datTows = combo_catch %>% filter(Year > 2004), 
                               strat.df = combo_strata,
                               lgthBins = len_bins,
                               month = 7,
                               nSamps = combo_effn[3:length(combo_effn)],
                               sex = 3,
                               maxSizeUnsexed = thorny_maxSizeUnsexed,
                               sexRatioUnsexed = 0.5) 

plot_comps(dir = combo_path, 
           data = combo_lenfreq2)


PlotMap.fn(
  dir = 'outputs/surveys/wcgbts_cpue_map.png',
  combo_catch,
  main = "wcgbts",
  dopng = lifecycle::deprecated(),
  plot = 1
)
