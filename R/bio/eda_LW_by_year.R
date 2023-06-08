# Shortspine thornyhead
# Explore L-W relationship by year

# packages
library(nwfscSurvey)

# List of functions
ls("package:nwfscSurvey")


# NWFSC.combo survey

# pull other biological data
bio_mat = pull_biological_samples(common_name = "shortspine thornyhead", 
                                  survey = "NWFSC.Combo")

bio <- PullBio.fn(Name = "shortspine thornyhead",
  SurveyName = "NWFSC.Combo",
  SaveFile = FALSE)

#~~~~~~~~~~~~~~~~~~

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


#combo_path <- 'data/raw/NWFSCcombo'; dir.create(combo_path)

combo_catch <- PullCatch.fn(Name = 'shortspine thornyhead',
                            SurveyName = 'NWFSC.Combo',
                            Dir = combo_path,
                            SaveFile = TRUE)

plot_cpue(catch = combo_catch, dir = combo_path)

#combo_bio <- PullBio.fn(Name = 'shortspine thornyhead',
 #                       SurveyName = 'NWFSC.Combo')

# No ages, but this df has length-weight pairs for all years
#combo_lwpairs <- combo_bio %>% filter(!is.na(Weight) & !is.na(Length_cm))
#saveRDS(combo_lwpairs, paste0(combo_path, '/NWFSCcombo_lengthweight_pairs.rda'))

# there are some sexed fish by depth with no length data in a few years... get
# rid of these.
#combo_bio <- combo_bio %>% filter(!is.na(Length_cm))

#saveRDS(combo_bio, paste0(combo_path, '/NWFSCcombo_lengths.rda'))


combo_bio<-readRDS(paste0(combo_path, '/NWFSCcombo_lengths.rda'))


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

# remove the small fish
combo.bio.rm.small<- combo_bio[combo_bio$Length_cm> 16,]

#Data by sex
combo.bio.rm.small.fem <-combo.bio.rm.small[combo.bio.rm.small$Sex=="F",]
combo.bio.rm.small.male<-combo.bio.rm.small[combo.bio.rm.small$Sex=="M",]

#all fish
ggplot() +
  geom_point(data = combo.bio.rm.small, aes(x = Length_cm, y = Weight, col = Year), size = 0.5) +
  facet_wrap(~Year)

ggplot(data = combo.bio.rm.small, aes(x = log(Length_cm), y = log(Weight), col = factor(Year))) +
  geom_point(alpha = 0.2) +
  facet_wrap(~Sex) +
  geom_smooth(method = 'lm', se = F)



#females
ggplot() +
  geom_point(data = combo.bio.rm.small.fem, aes(x = Length_cm, y = Weight, col = Year), size = 0.5) +
  facet_wrap(~Year)

ggplot(data = combo.bio.rm.small.fem, aes(x = log(Length_cm), y = log(Weight), col = factor(Year))) +
  geom_point(alpha = 0.2) +
  facet_wrap(~Sex) +
  geom_smooth(method = 'lm', se = F)

#males
ggplot() +
  geom_point(data = combo.bio.rm.small.male, aes(x = Length_cm, y = Weight, col = Year), size = 0.5) +
  facet_wrap(~Year)

ggplot(data = combo.bio.rm.small.male, aes(x = log(Length_cm), y = log(Weight), col = factor(Year))) +
  geom_point(alpha = 0.2) +
  facet_wrap(~Sex) +
  geom_smooth(method = 'lm', se = F)

#sample size of SST caught by year
as.data.frame(table(combo_bio$Year))
