# Length compositions for the landings data
# Contact: Haley Oleynik
# Last updated March 2023

# set up ----
libs <- c('tidyverse', 'patchwork', 'ggthemes', 'ggridges')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

# pak::pkg_install('pfmc-assessments/PacFIN.Utilities',upgrade = TRUE)
# pak::pkg_install('pfmc-assessments/nwfscSurvey',upgrade = TRUE)
library(PacFIN.Utilities)
library(nwfscSurvey)

# take black out of colorblind theme
scale_fill_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_fill_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# Color
scale_color_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_color_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# we're not using any length comps from unidentified thornyheads because
# longspine and shortspine grow differently.

#	PacFIN Data Expansion for Shortspine thornyhead 2023 -----

# Pull PacFIN biological (bds) data 
bds_file_short = "PacFIN.SSPN.bds.17.Jan.2023"
bds_file = paste0("data/raw/", bds_file_short, ".RData") # not hosted on github -- confidential
load(bds_file)
out = bds.pacfin 
rm(bds.pacfin)

# Clean data 
Pdata <- cleanPacFIN(
  Pdata = out,
  keep_age_method = c("B", "BB", 1),
  CLEAN = TRUE, 
  verbose = TRUE)

# Plot fishery length comps 
Pdata$year <- as.character(Pdata$year) # make year a character 

ggplot(Pdata %>% 
               filter((between(lengthcm, 6, 80))), 
       aes(x=lengthcm,y=year, fill = state, color = state)) + 
  geom_density_ridges(alpha = 0.5) + 
  facet_wrap(vars(SEX)) + 
  ylab("") + 
  xlab("Length (cm)") +
  labs(fill = 'State', col = 'State') +
  ggtitle("Shortspine Thornyhead Fishery Length Compositions") + 
  scale_fill_colorblind7() +
  scale_color_colorblind7() +
  theme_classic()

ggsave("outputs/fishery_data/SST_PacFIN_fishery_lencomps.png", dpi=300, height=7, width=10, units='in')

# create fleet structure for expansion
# Check fleet structure
table(Pdata$geargroup)

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

# Data checking -----
# Check lengths 
quantile(Pdata$lengthcm, na.rm = TRUE) 
summary(Pdata$lengthcm)
table(Pdata$geargroup[is.na(Pdata$length)])
table(Pdata$fleet[is.na(Pdata$length)])
# Length data is mostly missing for CA NonTrawl. Only a small percentage of the
# dataset

# in early iterations of the analysis, we identified 3 fish from 1981 caught in
# in California that are skewing the expansion (sample id = 1981223128134).
# Filter out these 3 weird fish (tiny proportion of fish sampled).
Pdata <- Pdata %>% filter(AGENCY_SAMPLE_NUMBER != 1981223128134)

# W-L plot 
ggplot(Pdata, aes(x = lengthcm, y = weightkg)) +
  geom_jitter() + 
  geom_point(aes(col = SEX), size = 2) +
  scale_colour_viridis_d()

# look at small weights 
filter(Pdata, weightkg < 0.15) %>%
  select(lengthcm, weightkg, SEX) %>%
  ggplot(aes(x = lengthcm, y = weightkg)) +
  geom_jitter() + 
  geom_point(aes(col = SEX), size = 2) +
  scale_colour_viridis_d()

# what are this odd data points?
Pdata %>%
  filter(lengthcm > 39 & weightkg < 0.05) %>% 
  dplyr::select(year, fleet) %>%
  table()
# --> Mainly recent data (2020) from Washington state

# Fix the weight errors using the conversion between lb and kg
Pdata %>%
  dplyr::mutate(weightkg=ifelse(lengthcm > 39 & weightkg < 0.05, 
                                weightkg*0.453592*1000, weightkg)) %>% 
  dplyr::select(lengthcm, weightkg, SEX) %>%
  ggplot(aes(x = lengthcm, y = weightkg)) +
  geom_jitter() + 
  geom_point(aes(col = SEX), size = 2) +
  scale_colour_viridis_d()

Pdata <- Pdata %>%
  dplyr::mutate(weightkg=ifelse(lengthcm > 39 & weightkg < 0.05, 
                                weightkg*0.453592*1000, weightkg)) 

# First stage expansion -----

# expand comps to the trip level
Pdata_exp <- getExpansion_1(
  Pdata = Pdata,
  plot = file.path("outputs/fishery_data"),
  fa = fa, fb = fb, ma = ma, mb = mb, ua = ua, ub = ub) # weight-length params

# check expansion factors (want them to be < 500)
hist(Pdata_exp$Expansion_Factor_1_L)

# check the filled weight values are consistent with observations
# dev.off() # use if plot isn't rendering
Pdata_exp %>%
  dplyr::mutate(is.weight=ifelse(is.na(weightkg), "N", "Y")) %>%
  ggplot(aes(x = lengthcm, y = bestweight)) +
  geom_jitter() + 
  geom_point(aes(col = is.weight), size = 2) +
  scale_colour_viridis_d() +
  theme_bw()

# Second stage expansion ----
# expand comps up to the state and fleet (gear group)

# Read in processed PacFIN catch data - Each state should be kept seperate for
# state based expansions for each gear fleet within that state. Landings
# reported data from pacfin - separate for each state because different sampling
# and coverage
catch <- read.csv("data/processed/SST_PacFIN_length-comp-landings_2023.csv")

# second stage expansion 
# The stratification.col input below needs to be the same as in the catch csv file
Pdata_exp <- getExpansion_2(
  Pdata = Pdata_exp, 
  Catch = catch, # catch file - needs to match state and fleet 
  Units = "MT", 
  stratification.cols = c("state", "geargroup"),
  savedir = file.path("outputs/fishery_data"))

# look expansion factors and caps ???
# multiply expansion factors together 
# cap values applies 0.95 quantile (anything outside gets capped)
Pdata_exp$Final_Sample_Size <- capValues(Pdata_exp$Expansion_Factor_1_L * Pdata_exp$Expansion_Factor_2)

# Calculate the final expansion size -----

# redefine strata definitions to north/south instead by state
# Trawl_n=1
# Trawl_s=2
# Non-trawl_N=3
# Non-trawl_S=4
Pdata_exp <- Pdata_exp %>% 
  dplyr::mutate(fleet = case_when(fleet %in% c('OR_TWL', 'WA_TWL') ~ 1,
                                  fleet %in% c('CA_TWL') ~ 2,
                                  fleet %in% c('OR_NONTWL', 'WA_NONTWL') ~ 3,
                                  fleet %in% c('CA_NONTWL') ~ 4))

# data frame with expansion factors - only records with lengths, take out na
# dataframe with composition by length bin, state, year, gear
length_comps <- getComps(
  Pdata = Pdata_exp2[!is.na(Pdata_exp2$lengthcm), ], 
  Comps = "LEN")

# diagnostics 
table(Pdata$SOURCE_AGID, Pdata$SEX)

# look at where unsexed fish are 
Pdata$count <- 1
ggplot(Pdata, aes(x = lengthcm, y = count, fill = SEX))  + 
  geom_histogram(aes(y = count), position="stack", stat="identity") +
  scale_fill_viridis_d()

# Create the length composition data
# code to do sex ratio: 
# Commenting out for now because I don't want to assign unsexed due to the
# dimorphic growth
# There area a fair number of U in CA and in the early years of WA
# length_compSR <- doSexRatio(
#	CompData = length_comps, 
# 	ratioU = 0.5, 
# 	maxsizeU = 25, 
# 	savedir = file.path(dir, "commercial_comps"))

# length bins 
len_bins = c(seq(6, 72, 2))

writeComps(
  inComps = length_comps, 
  fname = file.path("outputs/fishery_data", paste0("length_comps/", bds_file_short, ".csv")), # tell file name for .csv
  lbins = len_bins, 
  sum1 = TRUE, # sum comps to 1, SS does this for you 
  partition = 2, # only retained fish 
  digits = 4, # round 
  dummybins = FALSE)


# format the csv files for SS3
out = read.csv(
  file.path("outputs/fishery_data", paste0("length_comps/", bds_file_short, ".csv")), 
  skip = 3, 
  header = TRUE)

start = 1 
end   = which(as.character(out[,1]) %in% c(" Females only ")) - 1 
cut_out = out[start:end,]
# 
# # format the length comps
# cut_out$fleet[cut_out$fleet =="CA_ALL"] = 1
# cut_out$fleet[cut_out$fleet =="WA_OR_ALL"] = 2

ind = which(colnames(cut_out) %in% paste0("F", min(len_bins))):
  which(colnames(cut_out) %in% paste0("M", max(len_bins)))
format = cbind(cut_out$year, cut_out$month, cut_out$fleet, cut_out$sex, cut_out$partition, cut_out$InputN, cut_out[,ind])
colnames(format) = c("year", "month", "fleet", "sex", "part", "InputN", colnames(cut_out[ind]))
# format = format[format$year != 2021, ]
write.csv(
  format, 
  file = file.path("outputs/fishery data", paste0("Lcomps_for_SS3_", out_name, ".csv")), 
  row.names = FALSE)


# Let's create the sample table - goes into assessment report 
temp = Pdata[!is.na(Pdata$lengthcm) & Pdata$year < 2021,]
Nfish = table(temp$year, temp$state)
colnames(Nfish) = sort(unique(temp$state)) 

aa = sort(unique(temp$state)) 
yy = sort(unique(temp$year))
Ntows = matrix(0, length(yy), length(aa))
for(y in 1:length(yy)){
  for(a in 1:length(aa)){
    ind = which(temp$year == yy[y] & temp$state  == aa[a])
    if(length(ind) > 0) {Ntows[y, a] = length(unique(temp$SAMPLE_NO[ind])) }
  }
}
colnames(Ntows) = aa
rownames(Ntows) = yy

samples = cbind(rownames(Ntows), Ntows[,"CA"] , Nfish[,"CA"], 
                Ntows[,"OR"] , Nfish[,"OR"],  Ntows[,"WA"] , Nfish[,"WA"])

colnames(samples) = c("Year", "CA Ntows", "CA Nfish",
                      "OR Ntows", "OR Nfish", "WA Ntows", "WA Nfish")
write.csv(
  samples, 
  file = file.path("outputs/fishery data", paste0("PacFIN_Length_Samples_by_State.csv")), 
  row.names = FALSE)

##########################################################################################
### Explore missing total weights in bio data ---------------------------------
# look at fish ticket IDs for missing total weights 

# look at Washington 2021 and 2022 - why is expansion factor capped at 1 for so many trips? 
check.WA <- Pdata_exp %>% filter(state == "WA")

# looks like we're missing total weights for 73 fish in 2021 and 136 fish in 2022
View(check.WA %>% group_by(year) %>%
       tally(is.na(RWT_LBS))) # same for RWT_LBS or TOTAL_WGT

# filter out samples with na total weight 
check.WA2 <- check.WA %>% filter(year > 2020 & is.na(RWT_LBS))
# 209 fish of 19 trips missing from 2021 and 2022

# look at fish ticket IDs for missing total weights 
check.WA3 <- filter(check.WA2, year == 2021)
unique(check.WA3$FTID)
unique(check.WA3$PACFIN_PORT_NAME)

# check 2021
unique(check.WA3$FTID)
# Fish tickets with total weight missing in bio data: "EA009055" "JN652835" "JN660466" "JN660454" "EA003940" "JN652823" "JN660474" "JN623994" "JN660465"
# These fish tickets have total weight in catch data: JN652835, JN660466, JN660454, JN623994, JN660465
View(short.catch %>% filter(FTID == "JN652835") %>% select(LANDED_WEIGHT_LBS, ROUND_WEIGHT_LBS))

#RWT_LBS in bio, ROUND_WEIGHT_LBS in catch
View(short.catch %>% select(FTID, ROUND_WEIGHT_LBS) %>%
  filter(ROUND_WEIGHT_LBS > 1))

#3186627 5241.686486
Pdata %>% filter(FTID == "3186627") %>% select(RWT_LBS)
# out$WEIGHT_OF_LANDING_LBS
out %>% filter(FTID == "R426114") %>% select(WEIGHT_OF_LANDING_LBS)



