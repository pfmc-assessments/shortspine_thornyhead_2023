# Fishery historical landings reconstructions
# Contact: Adam Hayes
# Last updated March 2023

# R version 4.2.1
# system x86_64, mingw32

libs <- c('tidyverse', 'here', 'ggthemes')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)
source(file=file.path("R", "utils", "colors.R"))

# shortspine thornyhead only - read data 
load("data/raw/PacFIN.SSPN.CompFT.17.Jan.2023.RData")
short.catch = catch.pacfin 
# longspine thornyhead only - read data 
load("data/raw/PacFIN.LSPN.CompFT.17.Feb.2023.RData")
long.catch = catch.pacfin 
# unidentified thornyhead only - read data 
load("data/raw/PacFIN.THDS.CompFT.30.Jan.2023.RData" )
un.catch = catch.pacfin 
# load 
catch.pacfin <- read.csv("data/processed/SST_PacFIN_total-landings_2023.csv") %>%
  dplyr::select(-Season) %>%
  gather("Fleet","round_mtons",NTrawl:SOther)

#### Load and save data #### 
##### Previous Assessments #####
# load data from previous assessments
SST.2013 <- read.csv(here("data","processed","SST_catch_2013assessment.csv")) %>%
  dplyr::select(-Season) %>%
  gather("Fleet","round_mtons",-Year)
# 2005 assessment didn't not differentiate by gear - assign all to trawl
SST.2005 <- read.csv(here("data","processed","SST_catch_2005assessment.csv")) %>%
  gather("Fleet","round_mtons",-Year) %>%
  mutate(Fleet = ifelse(Fleet %in% "North", "NTrawl", "STrawl"))

##### WA data  #####

# all sst 
# sablefish longrun
# 2005 and 2013 assessments
# 1900 - present
# All datasets

# combine WA state data files for 1970-1980 and 1981-2014
wa.state.catch.1970 <- read.csv(here("data","raw","WA_SST_19812014.csv")) %>%
  mutate(round_mtons = RoundPounds_AfterComps*0.000453592) %>%
  dplyr::select(Year, GearGroup_SpeciesComp, round_mtons, SPID) %>%
  bind_rows(read.csv(here("data","raw","WA_SST_197080.csv")) %>%
              mutate(round_mtons = RoundPounds*0.000453592) ) %>%
  mutate(Fleet = ifelse(GearGroup_SpeciesComp %in% "TWL","NTrawl","NOther")) %>%
  group_by(Year, Fleet) %>%
  dplyr::summarize(round_mtons = sum(round_mtons, na.rm=TRUE))
  
# combine 1970+ WA state data with pre-1970 data
wa.state.catch <- read.csv(here("data","raw","WA_SST_pre1970.csv")) %>%
  mutate(Year = YearLanded_Orig, 
         round_mtons = Species_RoundWeight*0.000453592, # not sure if roundweight is pounds
         Gear = ifelse(GearGroup_SpeciesComp %in% "TWL","Trawl","Non-trawl"), 
         Fleet = ifelse(Gear %in% "Trawl","NTrawl","NOther")) %>% 
  group_by(Year, Fleet) %>% # pre-1970 includes nominal spp codes as well
  dplyr::summarize(round_mtons = sum(round_mtons, na.rm=TRUE)) %>%
  bind_rows(wa.state.catch.1970) 

write.csv(wa.state.catch, file = here("data","processed","SST_WA_historical.csv"), row.names=FALSE)

##### OR data  #####
or.state.catch <- read.csv(here("data","raw","OR_SST.csv")) %>%
  rename(NTrawl = Trawl, NOther = Other) %>%
  gather("Fleet","round_mtons",-Year)

write.csv(or.state.catch, file = here("data","processed","SST_OR_historical.csv"), row.names=FALSE)

##### CA data  #####
ca.state.catch <- read.csv(here("data","raw","Ralston_et_al_2010_thornyhead.csv")) %>%
  rename(Year = year, POUNDS = pounds) %>%
  group_by(Year) %>%
  mutate(Fleet = "STrawl", Species="THDS") %>% # assume gear = trawl
  bind_rows(read.csv(here("data","raw","SST_CALCOM.csv")) %>%
              mutate(Fleet = ifelse(GEAR_GRP %in% "TWL", "STrawl", "SOther")) %>%
              rename(Year = YEAR, Species = SPECIES)) %>%
  group_by(Year, Species, Fleet) %>%
  summarize(round_mtons = sum(POUNDS*0.000453592, na.rm=TRUE))

write.csv(ca.state.catch, file = here("data","processed","SST_CA_historical.csv"), row.names=FALSE)

##### Add OR data to pacfin for 1981-1986 #####
pacfin.state <- catch.pacfin %>%
  left_join(
  or.state.catch %>%
    group_by(Year, Fleet) %>%
    summarize(mtons_OR = sum(round_mtons, na.rm=TRUE))
) %>%
  mutate(round_mtons = ifelse(Year %in% 1981:1986 & Fleet %in% c("NTrawl","NOther"), 
                              round_mtons + mtons_OR, round_mtons)) %>% 
  dplyr::select(Year, Fleet, round_mtons)

#####  Load foreign fleets #####
# consistent with 2005 and 2013 assessments:
## assign US Border-Vancouver and Columbia areas to North trawl fleet
## assign Eureka and Monterey areas to South trawl fleet (although Eureka area extends into Oregon)
foreign.rodgers <- read.csv(here("data","raw","rodgers 2003 sst foreign fleet.csv")) %>%
  mutate(Fleet = ifelse(Area %in% c("UVAN","COL"),"NTrawl","STrawl")) %>% 
  group_by(Year, Fleet) %>%
  summarize(round_mtons = sum(Catch_t))

##### Combine all state landings #####
# for now, assume all Thornyheads are Shortspine for California reconstruction
catch.all <- bind_rows(or.state.catch,wa.state.catch,foreign.rodgers) %>%
  bind_rows(ca.state.catch %>% 
              ungroup() %>%
              dplyr::filter(Species %in% c("THDS","SSPN")) %>% 
              dplyr::select(Year, Fleet, round_mtons)) %>%
  group_by(Year, Fleet) %>%
  summarize(round_mtons = sum(round_mtons, na.rm=TRUE)) %>% filter(Year < 1981) %>%
  bind_rows(pacfin.state) 

catch.all %>% 
  spread(Fleet, round_mtons, fill=0) %>%
  mutate(Season = 1) %>% 
  write.csv(file = here("data","processed","SST_PacFIN+state_total-landings.csv"), row.names=FALSE)

catch.comp <- catch.all %>% mutate(Assessment = "2023") %>%
  bind_rows(SST.2013 %>% mutate(Assessment = "2013")) %>%
  bind_rows(SST.2005 %>% mutate(Assessment = "2005"))

##### Examine specific issues #####
# 2013 vs 2023 assessment 
ggplot(catch.comp %>% filter(Assessment %in% c(2013,2023)), 
       aes(x = Year, y=round_mtons, group=as.factor(Assessment), color=as.factor(Assessment))) + 
  geom_line(size=1.5) + 
  theme_classic() + 
  scale_color_colorblind7() +
  guides(color = guide_legend(title = "Assessment")) +
  theme(text=element_text(size=20)) + 
  ylab("Total Weight (mt)") +
  xlab("Year") + 
  facet_wrap(~Fleet, scales="free")
ggsave("outputs/fishery_data/SST_Compare-Assessments-All.png", dpi=300, height=7, width=10, units='in')


# Differences between all three assessments in N Trawl
ggplot(catch.comp %>% filter(Fleet %in% "NTrawl" & Year >= 1980), 
       aes(x = Year, y=round_mtons, group=as.factor(Assessment), color=as.factor(Assessment))) + 
  geom_line(size=1.5) + 
  theme_classic() + 
  scale_color_colorblind7() +
  guides(color = guide_legend(title = "Assessment")) +
  theme(text=element_text(size=20)) + 
  ylab("North Trawl Weight (mt)") +
  xlab("Year")
ggsave("outputs/fishery_data/SST_Compare-Assessments-NTrawl.png", dpi=300, height=7, width=10, units='in')

# impute South fleet SSTs based on sablefish
sablefish.catch <- read.csv(here("data","processed","sablefish_catch_2019assessment.csv")) %>%
  mutate(NTrawl = WA.Trawl + OR.Trawl, NOther = WA.Fixed + OR.Fixed, 
         STrawl = CA.Trawl, SOther = CA.Fixed) %>%
  dplyr::select(Year, NTrawl, NOther, STrawl, SOther) %>%
  gather("Fleet","Sablefish_mtons",NTrawl:SOther)

# from last assessment, assume STrawl = 0.3*(STrawl_sable + SOther_sable) 
sablefish.catch %>% 
  filter(Fleet %in% c("STrawl","SOther")) %>%
  group_by(Year) %>%
  summarize(round_mtons = 0.3*sum(Sablefish_mtons), 
            Fleet= "STrawl", 
            Assessment = "SST_sabl") %>%
  bind_rows(catch.comp %>% 
              filter(Fleet %in% "STrawl" & Assessment != "2005")) %>%
  filter(Year %in% 1901:1961) %>%
  mutate(Assessment = ifelse(Assessment %in% "2023","Ralston",Assessment)) %>%
  ggplot(aes(x=Year, y=round_mtons, group=Assessment, color=Assessment)) + 
  geom_line(size=1.5) + 
  theme_classic() + 
  scale_color_colorblind7() +
  guides(color = guide_legend(title = "Source")) +
  theme(text=element_text(size=20)) + 
  ylab("Total Weight (mt)") +
  xlab("Year") + 
  facet_wrap(~Fleet, scales="free")
ggsave("outputs/fishery_data/SST_Compare-STrawl-pre1964.png", dpi=300, height=7, width=10, units='in')


# OR and WA updated some PacFIN era data also
# Does that impact catch substantially?
# WA only goes through 2014
# weird - pacfin has slightly higher catch for early 1990s
bind_rows(or.state.catch %>% mutate(source = "state"),
                         wa.state.catch %>% mutate(source = "state"), 
                         pacfin.state %>% mutate(source="pacfin")) %>% 
  filter(Year %in% 1981:2014 & Fleet %in% c("NTrawl","NOther")) %>%
  group_by(Year, Fleet, source) %>%
  summarize(round_mtons = sum(round_mtons, na.rm=TRUE)) %>%
  ggplot(aes(x = Year, y = round_mtons, group=source, color=source)) + 
  geom_line(size=1.5) + 
  facet_wrap(~Fleet, scales="free") + theme_classic() + 
  scale_color_colorblind7() +
  guides(color = guide_legend(title = "Source")) +
  theme(text=element_text(size=20)) + 
  ylab("Total Weight (mt)") +
  xlab("Year")



#### Scraps - do not run below this line ####

SST.sabl.prop <- sablefish.catch %>% left_join(catch.all) %>%
  filter(Year >= 1981) %>%
  mutate(SST.ratio = round_mtons/Sablefish_mtons) %>%
  dplyr::select(Year, Fleet, SST.prop) %>%
  spread(Fleet,SST.prop) 

sablefish.catch$Sablefish_mtons[which(sablefish.catch$Fleet %in% "STrawl")]

SST.sabl.prop.means <- data.frame(Fleet = colnames(SST.sabl.prop)[2:5], 
                                  sabl.prop = colMeans(SST.sabl.prop[,2:5]))


catch.hist.sablefish <- sablefish.catch %>% 
  left_join(SST.sabl.prop.means) %>%
  mutate(round_mtons = Sablefish_mtons*sabl.prop) %>% dplyr::select(Year, Fleet, round_mtons) %>%
  bind_rows(foreign.rodgers) %>%
  group_by(Year, Fleet) %>%
  summarize(round_mtons = sum(round_mtons, na.rm=TRUE), Assessment="2023_sabl") %>%
  bind_rows(catch.comp) %>%
  filter(Assessment %in% c("2023","2023_sabl","2013") & 
           Fleet %in% c("STrawl","SOther") & Year %in% 1901:1978)

ggplot(catch.hist.sablefish, aes(x=Year, y=round_mtons, group=Assessment, color=Assessment)) + 
  geom_line(size=1.5) + 
  theme_classic() + 
  scale_color_colorblind7() +
  guides(color = guide_legend(title = "Source")) +
  theme(text=element_text(size=20)) + 
  ylab("Total Weight (mt)") +
  xlab("Year") + 
  facet_wrap(~Fleet, scales="free")
  


# use catch.calc after 1981-2022
north.fleet.catch <- bind_rows(or.state.catch,wa.state.catch,foreign.rodgers) %>%
  filter(Fleet %in% c("NOther","NTrawl")) %>%
  group_by(Year, Fleet) %>%
  summarize(round_mtons = sum(round_mtons, na.rm=TRUE)) %>%
  spread(Fleet, round_mtons, fill=0) %>%
  filter(Year < 1980) %>%
  bind_rows(catch.calc %>% filter(Year >= 1980) %>% dplyr::select(Year, NOther, NTrawl))

# compare current 2005 and 2013
north.catch.comp

write.csv(north.state.catch, file = here("data","processed","SST_states_historical_NORTH.csv"), row.names=FALSE)

##### Disaggregate Thornyheads: Southern Fleet  #####

# unidentified thornyhead as proportion of total
ca.state.catch %>% group_by(Year) %>%
  summarize(pct_THDS = sum(round_mtons*(Species=="THDS") / sum(round_mtons))) %>%
  ggplot(aes(x = Year, y=pct_THDS)) + geom_line()

# Option 1: Assign all CA Thornyheads to Shortspine
ca.state.catch %>%
  spread(Species, round_mtons) %>%
  left_join(s.prop.summ) %>%
  left_join(foreign.rodgers %>% rename(Foreign = round_mtons)) %>%
  replace_na(list(LSPN=0,SSPN=0,THDS=0,Foreign=0)) %>%
  mutate(THDS_all = SSPN + Foreign + THDS) %>%
  left_join(SST.2013) 


# Option 2: Impute shortspine using sablefish reconstruction





# 
ca.state.catch %>%
  spread(Species, round_mtons) %>%
  left_join(s.prop.summ) %>%
  left_join(foreign.rodgers %>% rename(Foreign = round_mtons)) %>%
  replace_na(list(LSPN=0,SSPN=0,THDS=0,Foreign=0)) %>%
  mutate(THDS_all = SSPN + Foreign + THDS) %>%
  left_join(SST.2013) %>%
  ggplot(aes(x=Year)) + 
  geom_line(aes(y=THDS_all, color="blue"), size=1.5) + 
  geom_line(aes(y=Assmt13, color="black"), size=1.5) + 
  scale_color_identity(name = "",
                       breaks = c("red", "blue","black"),
                       labels = c("SST_split", "SST_all", "2013_assmt"),
                       guide = "legend") +
  xlab("Year") +
  ylab("Total Landings (mt)") +
  facet_wrap(~Fleet, scales="free") + 
  theme_classic() + 
  theme(text=element_text(size=20))


##### Update sablefish comparisons  #####
sablefish.catch <- read.csv(here("data","processed","sablefish_historical.csv")) %>%
  mutate(NTrawl = WA.Trawl + OR.Trawl, NOther = WA.Fixed + OR.Fixed, 
         STrawl = CA.Trawl, SOther = CA.Fixed) %>%
  dplyr::select(Year, NTrawl, NOther, STrawl, SOther) %>%
  gather("Fleet","Sablefish_mtons",NTrawl:SOther)

 
SST.sabl.prop <- sablefish.catch %>% left_join(catch.calc %>% 
                                                 gather("Fleet","mtons",NTrawl:SOther)) %>%
  filter(Year >= 1981) %>%
  mutate(SST.prop = mtons/Sablefish_mtons) %>%
  dplyr::select(Year, Fleet, SST.prop) %>%
  spread(Fleet,SST.prop) 

SST.sabl.prop %>%
  ggplot(aes(x=Year)) + 
  geom_line(aes(y=NTrawl, color = "#61646F"), size = 1.5) + 
  geom_line(aes(y=STrawl, color = "#472D7B"), size = 1.5) + 
  geom_line(aes(y=NOther, color = "#C7E020"), size = 1.5) + 
  geom_line(aes(y=SOther, color = "#FDE725"), size = 1.5) + 
  theme_classic() + 
  labs(y = "Shortspine/Sablefish", x = "Year") +
  scale_color_identity(name = "Fleet",
                       breaks = c("#61646F", "#472D7B", "#C7E020", "#FDE725"),
                       labels = c("NTrawl", "STrawl", "NOther", "SOther"),
                       guide = "legend") 

SST.prop.means <- data.frame(Fleet = c("NOther","NTrawl","SOther","STrawl"), 
                                   SST.prop = colMeans(SST.sabl.prop[,2:5]))

bind_rows(or.state.catch,wa.state.catch) %>%
  mutate(Species = "SSPN") %>% bind_rows(ca.state.catch) %>%
  group_by(Year, Species, Fleet) %>%
  summarize(round_mtons = sum(round_mtons, na.rm=TRUE)) %>%
  spread(Species, round_mtons,fill=0) %>%
  left_join(s.prop.summ) %>% 
  left_join(foreign.rodgers %>% rename(Foreign = round_mtons)) %>%
  left_join(SST.2013) %>%
  replace_na(list(LSPN=0,SSPN=0,THDS=0,Foreign=0,sst.prop=1, Assmt13=0)) %>%
  mutate(SSPN_split = SSPN + Foreign + sst.prop*THDS, 
         SSPN_all = SSPN + Foreign + THDS) %>%
  left_join(SST.prop.means) %>%
  left_join(sablefish.catch) %>%
  mutate(SSPN_sabl = Sablefish_mtons*SST.prop) %>%
  ggplot(aes(x=Year)) + 
  geom_line(aes(y=SSPN_split, color="red"), size=1.5) + 
  geom_line(aes(y=SSPN_all, color="blue"), size=1.5) + 
  geom_line(aes(y=Assmt13, color="black"), size=1.5) + 
  geom_line(aes(y=SSPN_sabl, color="gold"), size=1.5) + 
  scale_color_identity(name = "",
                       breaks = c("red", "blue","black","gold"),
                       labels = c("SST_split", "SST_all", "2013_assmt","Sablefish"),
                       guide = "legend") +
  xlab("Year") +
  ylab("Total Landings (mt)") +
  facet_wrap(~Fleet, scales="free") + 
  theme_classic() + 
  theme(text=element_text(size=20))
  
# 

# add 
bind_rows(ca.calcom, ca.ralston) %>%
  spread(Species, round_mtons) %>%
  left_join(s.prop.10yr) %>%
  left_join(foreign.rodgers) %>%
  replace_na(list(LSPN = 0, SSPN=0, THDS=0, Foreign = 0)) %>%
  mutate(SSPN_split = Foreign + SSPN + THDS*0.5, 
         SSPN_10yr = Foreign + SSPN + THDS*sst.10yr, 
         SSPN_All = Foreign + SSPN + THDS) %>%
  left_join(SST.2013 %>% rename(SSPN13 = ROUND_WEIGHT_MTONS)) %>%
  left_join(SST.2005 %>% rename(SSPN05 = ROUND_WEIGHT_MTONS)) %>%
  ggplot(aes(x=Year)) + 
  geom_line(aes(y=SSPN_split, color="red"), size=1.5) + 
  geom_line(aes(y=SSPN_10yr, color="green"), size=1.5) + 
  geom_line(aes(y=SSPN_All, color="blue"), size=1.5) + 
  geom_line(aes(y=SSPN13, color="black"), size=1.5) + 
#  geom_line(aes(y=SSPN05)) + 
  scale_color_identity(name = "",
                       breaks = c("red", "green", "blue","black"),
                       labels = c("SST_split", "SST_10yr", "SST_all", "2013_assmt"),
                       guide = "legend") +
  facet_wrap(~Fleet, scales="free")



# combine Washington and oregon state data + northern foreign
north.state.catch <- bind_rows(or.state.catch %>% rename(MTONS = OR_MTONS), 
                               wa.state.catch %>% rename(MTONS = WA_MTONS), 
                               foreign.rodgers) %>%
  filter(Region %in% "N" & Year < 2010) %>%
  mutate("Fleet" = ifelse(Gear %in% "Trawl","NTrawl","NOther")) %>%
  group_by(Year, Fleet) %>%
  summarize(ROUND_WEIGHT_MTONS = sum(MTONS))
write.csv(north.state.catch, file = here("data","processed","SST_states_historical_NORTH.csv"), row.names=FALSE)



  
# compare state catch to the previous assessment for two northern fleets
# specifically, compare the pre-1981 data
north.catch.comp <- SST.2013 %>% mutate(Source = "Assmt13") %>%
  bind_rows(north.state.catch %>% mutate(Source = "state")) %>% 
  bind_rows(pacfin.catch %>% mutate(Source = "pacfin")) %>%
  filter(Fleet %in% c("NTrawl","NOther") & Year < 2010)

ggplot(north.catch.comp %>% filter(Year>1980), aes(x=Year,y=ROUND_WEIGHT_MTONS,group=Source)) + 
  geom_line(aes(color=Source)) + 
  xlab("Year") + 
  ylab("Total Landings (mt)") + 
  theme_classic() + 
  facet_wrap(~Fleet, scales="free")




