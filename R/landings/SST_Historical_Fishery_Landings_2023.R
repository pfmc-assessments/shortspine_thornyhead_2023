# Fishery historical landings reconstructions
# Contact: Adam Hayes
# Last updated March 2023
# currently only includes Washington data

# R version 4.2.1
# system x86_64, mingw32

libs <- c('tidyverse', 'here', 'ggthemes')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

# shortspine thornyhead only - read data 
load("data/raw/PacFIN.SSPN.CompFT.17.Jan.2023.RData")
short.catch = catch.pacfin 

# How much does the new WA reconstruction add to the existing PacFIN data?
wa.pacfin.catch <- short.catch %>% 
  mutate(Gear = ifelse(PACFIN_GROUP_GEAR_CODE %in% c('TWL', 'TWS'), 'Trawl', 'Non-trawl')) %>% 
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  filter(COUNTY_STATE %in% "WA") %>%
  group_by(LANDING_YEAR, Gear) %>%
  dplyr::summarize(PACFIN_ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  dplyr::rename(Year = LANDING_YEAR)
  
# combine WA state data files for 1970-1980 and 1981-2014
wa.state.catch.1970 <- read.csv(here("data","raw","WA_SST_19812014.csv")) %>%
  mutate(round_mtons = RoundPounds_AfterComps*0.000453592) %>%
  dplyr::select(Year, GearGroup_SpeciesComp, round_mtons, SPID) %>%
  bind_rows(read.csv(here("data","raw","WA_SST_197080.csv")) %>%
              mutate(round_mtons = RoundPounds*0.000453592) ) %>%
  mutate(Gear = ifelse(GearGroup_SpeciesComp %in% "TWL","Trawl","Non-trawl")) %>%
  group_by(Year, Gear) %>%
  dplyr::summarize(WA_ROUND_WEIGHT_MTONS = sum(round_mtons, na.rm=TRUE))
  
# combine 1970+ WA state data with pre-1970 data
wa.state.catch <- read.csv(here("data","raw","WA_SST_pre1970.csv")) %>%
  mutate(Year = YearLanded_Orig, 
         round_mtons = Species_RoundWeight*0.000453592, # not sure if roundweight is pounds
         Gear = ifelse(GearGroup_SpeciesComp %in% "TWL","Trawl","Non-trawl"))%>% 
  group_by(Year, Gear) %>% # pre-1970 includes nominal spp codes as well
  dplyr::summarize(WA_ROUND_WEIGHT_MTONS = sum(round_mtons, na.rm=TRUE)) %>%
  bind_rows(wa.state.catch.1970)

# how much catch does the new WA reconstruction add?
wa.pacfin.catch %>%
  left_join(wa.state.catch %>% filter(Year >= 1981)) %>%
  group_by(Gear) %>%
  summarize(WA_ADDED_MTONS = sum(ifelse(WA_ROUND_WEIGHT_MTONS >= PACFIN_ROUND_WEIGHT_MTONS, 
            WA_ROUND_WEIGHT_MTONS - PACFIN_ROUND_WEIGHT_MTONS, 0), na.rm=TRUE), 
            PACFIN_TOTAL_MTONS = sum(PACFIN_ROUND_WEIGHT_MTONS), 
            PCT_WA_ADDED = WA_ADDED_MTONS / PACFIN_TOTAL_MTONS, 
            MAX_PCT_ADDED_YR = max(WA_ROUND_WEIGHT_MTONS / PACFIN_ROUND_WEIGHT_MTONS, na.rm=TRUE)-1)



