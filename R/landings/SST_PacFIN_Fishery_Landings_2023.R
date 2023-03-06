###############################################################################
# Fishery landings  -------------------------------------------------------
require(tidyverse)
require(ggplot2)
require(reshape2)
require(patchwork)
require(ggthemes)

# shortspine thornyhead only - read data 
load("data/raw/PacFIN.SSPN.CompFT.17.Jan.2023.RData")
short.catch = catch.pacfin 

###############################################################################
# Plot landings (use ROUND_WEIGHT_MTONS) -------------------------------------
# plot landings by STATE 
f1 <- short.catch %>% 
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  group_by(LANDING_YEAR,COUNTY_STATE) %>%
  summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  rename(State = COUNTY_STATE) %>%
  ggplot(aes(x=LANDING_YEAR,y=ROUND_WEIGHT_MTONS, color = State)) +
  geom_line(size=1.5) +
  ylab("Total Weight (MT)") +
  xlab("Year") + 
  ggtitle("Shortpine thornyhead Fishery Landings") +
  scale_color_colorblind() +
  theme_classic() + 
  theme(text=element_text(size=17))

# plot landings by STATE and GEAR 
f2 <- short.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  group_by(LANDING_YEAR, COUNTY_STATE, PACFIN_GROUP_GEAR_CODE) %>%
  rename(State = COUNTY_STATE, Gear = PACFIN_GROUP_GEAR_CODE) %>%
  summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
ggplot(aes(x=LANDING_YEAR,y=ROUND_WEIGHT_MTONS, color = Gear)) +
  geom_line(size=1.5) +
  facet_wrap(vars(State)) + 
  ylab("Total Weight (MT)") +
  xlab("Year") + 
  scale_color_colorblind() +
  theme_classic() + 
  theme(text=element_text(size=17))

# show on one plot (require patchwork)
f1 / f2

#ggsave("outputs/fishery data/SST_PacFIN_fishery_landings.png", dpi=300, height=10, width=10, units='in')

##################################################################################
# Create .csv to use for fishery length expansion -------------------------------------
# only use shortspine catches (not unid)
table(short.catch$PACFIN_GROUP_GEAR_CODE) # look at gears 

# change gear type to trawl or non-trawl, create fleets, spread
length.exp.catch <- short.catch %>% 
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  rename(State = COUNTY_STATE, Gear = PACFIN_GROUP_GEAR_CODE) %>%
  mutate(Gear = case_when(Gear == 'TWS' ~ 'TWL',
                         Gear == 'TWL' ~ 'TWL',
                         TRUE ~ 'NONTWL'))  %>% 
  group_by(LANDING_YEAR, State, Gear) %>%
  summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  unite("Fleet", State:Gear, sep = "_") %>%
  spread(Fleet, ROUND_WEIGHT_MTONS)

# write catch file to use in fishery length expansions 
# write.csv(length.exp.catch,"data/processed/SST_PacFIN_landings_2023.csv")

#######################################################################################
# PROPORTION of shortspine to total Thornyheads ---------------------------------------------------
# READ DATA 
# longspine thornyhead only - read data 
load("data/raw/PacFIN.LSPN.CompFT.17.Feb.2023.RData")
long.catch = catch.pacfin 

# unidentified thornyhead only - read data 
load("data/raw/PacFIN.THDS.CompFT.30.Jan.2023.RData" )
un.catch = catch.pacfin 

# CALCULATE TOTAL LANDED WEIGHTS by year - use ROUND_WEIGHT_MTONS
long <- long.catch %>%
  group_by(LANDING_YEAR) %>%
  summarize(LSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T))

short <- short.catch %>%
  group_by(LANDING_YEAR) %>%
  summarize(SSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T))

unid <- un.catch %>%
  group_by(LANDING_YEAR) %>%
  summarize(UNID = sum(ROUND_WEIGHT_MTONS, na.rm=T))

# combine dataframes, calculate ratios (like 2013 assessment did - see Fig. 3, page 60)
# ratio of shortspine / (shortspine + longspine)
# ratio of UNID / (shortspine + longspine + UNID) 

# plot landings by year 
long %>% 
  left_join(short, by = "LANDING_YEAR") %>%
  left_join(unid, by = "LANDING_YEAR") %>%
  rowwise() %>%
  mutate(IDtotal = sum(SSPN,LSPN),total = sum(SSPN,LSPN,UNID, na.rm=T), SSPNprop = SSPN / IDtotal, UNIDprop = UNID / total, SSPNtotal = SSPN + (UNID*SSPNprop)) %>%
  ggplot(aes(x=LANDING_YEAR)) +
  geom_line(aes(y = SSPN,color = "darkred"),size=1.5) +
  geom_line(aes(y = LSPN,color = "blue"),size=1.5) + 
  geom_line(aes(y = UNID, color = "black"),size=1.5) +
  xlab("Year") +
  ylab("Total Landings (MT)") +
  scale_color_identity(name = "",
                       breaks = c("darkred", "blue", "black"),
                       labels = c("Shortspine", "Longspine", "Unidentified"),
                       guide = "legend") +
  theme_classic() + 
  theme(text=element_text(size=20))

#ggsave("outputs/fishery data/SST_PacFIN_all-thornyheads.png", dpi=300, height=7, width=10, units='in')
  
# plot ratios by year (Fig. 3, page 60 in 2013 assessment)
long %>% 
  left_join(short, by = "LANDING_YEAR") %>%
  left_join(unid, by = "LANDING_YEAR") %>%
  rowwise() %>%
  mutate(IDtotal = sum(SSPN,LSPN),total = sum(SSPN,LSPN,UNID, na.rm=T), SSPNprop = SSPN / IDtotal, UNIDprop = UNID / total, SSPNtotal = SSPN + (UNID*SSPNprop)) %>%
ggplot(aes(x=LANDING_YEAR)) +
  geom_line(aes(y = SSPNprop), size = 1.5) +
  geom_line(aes(y = UNIDprop), col = "red", linetype = "dashed") +
  ylim(0,1) + 
  xlab("Year") + 
  ylab("Ratio") +
  annotate("text", x = 2010, y = 0.85, label = "shortspine / (shortspine + longspine)", size = 5) +
  annotate("text", x = 2005, y = 0.08, label = "UNID thornyhead / (shortspine + longspine + UNID)", color = "red", size =5) +
  theme_classic() + 
  theme(text=element_text(size=20))

#ggsave("outputs/fishery data/SST_PacFIN_thornyhead-ratio.png", dpi=300, height=7, width=10, units='in')

# ratio of shortspine / total thornyheads by STATE ------------------------
long2 <- long.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA with WA 
  group_by(LANDING_YEAR, COUNTY_STATE) %>%
  summarize(LSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  spread(COUNTY_STATE, LSPN) %>%
  rename(CA.LSPN = CA, OR.LSPN = OR, WA.LSPN = WA)

short2 <- short.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA"))%>%
  group_by(LANDING_YEAR, COUNTY_STATE) %>%
  summarize(SSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  spread(COUNTY_STATE, SSPN) %>%
  rename(CA.SSPN = CA, OR.SSPN = OR, WA.SSPN = WA)

unid2 <- un.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>%
  group_by(LANDING_YEAR, COUNTY_STATE) %>%
  summarize(UNID = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  spread(COUNTY_STATE, UNID) %>%
  rename(CA.UNID = CA, OR.UNID = OR)

# plot ratio of shortspine / total by state 
long2 %>% 
  left_join(short2, by = "LANDING_YEAR") %>%
  left_join(unid2, by = "LANDING_YEAR") %>%
  rowwise() %>%
  mutate(WAtotal = sum(WA.SSPN,WA.LSPN,na.rm=T), SSPNpropWA = WA.SSPN / WAtotal,
         ORtotal = sum(OR.SSPN,OR.LSPN,na.rm=T), SSPNpropOR = OR.SSPN / ORtotal,
         CAtotal = sum(CA.SSPN,CA.LSPN,na.rm=T), SSPNpropCA = CA.SSPN / CAtotal) %>%
ggplot(aes(x=LANDING_YEAR)) +
  geom_line(aes(y=SSPNpropWA, color = "#56b4e9"), size = 1.5) + 
  geom_line(aes(y=SSPNpropOR, color = "#e69F00"), size = 1.5) + 
  geom_line(aes(y=SSPNpropCA, color = "black"), size = 1.5) + 
  ylim(0,1) +
  xlab("Year") + 
  ylab("Ratio") +
  theme_classic() +
  scale_color_identity(name = "State",
                       breaks = c("#56b4e9", "#e69F00", "black"),
                       labels = c("WA", "OR", "CA"),
                       guide = "legend") + 
  theme(text=element_text(size=20))

#ggsave("outputs/fishery data/SST_PacFIN_thornyhead-ratio-state.png", dpi=300, height=7, width=10, units='in')

# ratio of shortspine / total thornyheads by STATE AND GEAR ------------------------
# don't need WA bc no unid's recorded 
long.totalcatch <- long.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>%
  mutate(Gear = case_when(PACFIN_GROUP_GEAR_CODE == 'TWS' ~ 'TWL',
                          PACFIN_GROUP_GEAR_CODE == 'TWL' ~ 'TWL',
                          TRUE ~ 'NONTWL')) %>% # replace NA with WA 
  group_by(LANDING_YEAR, COUNTY_STATE, Gear) %>%
  summarize(LSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  unite("Fleet", COUNTY_STATE:Gear, sep = "_") %>%
  spread(Fleet, LSPN) %>%
  select(LANDING_YEAR,CA_NONTWL,CA_TWL,OR_NONTWL,OR_TWL) %>%
  rename(CA_NONTWL.LSPN = CA_NONTWL, CA_TWL.LSPN = CA_TWL, OR_NONTWL.LSPN = OR_NONTWL, OR_TWL.LSPN = OR_TWL)

short.totalcatch <- short.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA with WA 
  mutate(Gear = case_when(PACFIN_GROUP_GEAR_CODE == 'TWS' ~ 'TWL',
                          PACFIN_GROUP_GEAR_CODE == 'TWL' ~ 'TWL',
                          TRUE ~ 'NONTWL')) %>% 
  group_by(LANDING_YEAR, COUNTY_STATE, Gear) %>%
  summarize(SSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  unite("Fleet", COUNTY_STATE:Gear, sep = "_") %>%
  spread(Fleet, SSPN) %>%
  select(LANDING_YEAR,CA_NONTWL,CA_TWL,OR_NONTWL,OR_TWL) %>%
  rename(CA_NONTWL.SSPN = CA_NONTWL, CA_TWL.SSPN = CA_TWL, OR_NONTWL.SSPN = OR_NONTWL, OR_TWL.SSPN = OR_TWL)

totalcatch <- long.totalcatch %>% 
  left_join(short.totalcatch, by = "LANDING_YEAR") %>%
  rowwise() %>%
  mutate(OR_TWL.total = sum(OR_TWL.SSPN,OR_TWL.LSPN,na.rm=T), SSPNpropOR_TWL = OR_TWL.SSPN / OR_TWL.total,
         OR_NONTWL.total = sum(OR_NONTWL.SSPN,OR_NONTWL.LSPN,na.rm=T), SSPNpropOR_NONTWL = OR_NONTWL.SSPN / OR_NONTWL.total,
         CA_TWL.total = sum(CA_TWL.SSPN,CA_TWL.LSPN,na.rm=T), SSPNpropCA_TWL = CA_TWL.SSPN / CA_TWL.total,
         CA_NONTWL.total = sum(CA_NONTWL.SSPN,CA_NONTWL.LSPN,na.rm=T), SSPNpropCA_NONTWL = CA_NONTWL.SSPN / CA_NONTWL.total) %>%
  select(LANDING_YEAR,SSPNpropCA_NONTWL,SSPNpropCA_TWL,SSPNpropOR_NONTWL,SSPNpropOR_TWL) # don't need WA bc no unid's recorded 

# plot ratio of shortspine / total by state 
ggplot(totalcatch, aes(x=LANDING_YEAR)) +
  geom_line(aes(y=SSPNpropOR_TWL, color = "#e69F00",linetype = "solid"), size = 1.5) + 
  geom_line(aes(y=SSPNpropOR_NONTWL, color = "#e69F00",linetype = "dashed")) + 
  geom_line(aes(y=SSPNpropCA_TWL, color = "black", linetype = "solid"), size = 1.5) + 
  geom_line(aes(y=SSPNpropCA_NONTWL, color = "black", linetype = "dashed")) +
  ylim(0,1) +
  xlab("Year") + 
  ylab("Ratio (shortspine / all thornyheads)") +
  theme_classic() +
  scale_color_identity(name = "State",
                       breaks = c("#e69F00", "black"),
                       labels = c("OR", "CA"),
                       guide = "legend") +
  scale_linetype_identity(name = "Gear",
                          breaks = c("solid", "dashed"),
                          labels = c("Trawl", "Non-trawl"),
                          guide = "legend") + 
  theme(text=element_text(size=20))

#ggsave("outputs/fishery data/SST_PacFIN_thornyhead-ratio-state-gear.png", dpi=300, height=7, width=10, units='in')

# Apply ratio ------------------------------------------------------
un.totalcatch <- un.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>%
  mutate(Gear = case_when(PACFIN_GROUP_GEAR_CODE == 'TWS' ~ 'TWL',
                          PACFIN_GROUP_GEAR_CODE == 'TWL' ~ 'TWL',
                          TRUE ~ 'NONTWL')) %>% 
  group_by(LANDING_YEAR, COUNTY_STATE, Gear) %>%
  summarize(UNID = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  unite("Fleet", COUNTY_STATE:Gear, sep = "_") %>%
  spread(Fleet, UNID) %>%
  rename(CA_NONTWL.UNID = CA_NONTWL,
         CA_TWL.UNID = CA_TWL, 
         OR_NONTWL.UNID = OR_NONTWL, OR_TWL.UNID = OR_TWL) %>%
  left_join(totalcatch, by = "LANDING_YEAR") %>%
  rowwise() %>%
  mutate(OR_TWL = OR_TWL.UNID*SSPNpropOR_TWL,
         OR_NONTWL = OR_NONTWL.UNID*SSPNpropOR_NONTWL,
         CA_TWL = CA_TWL.UNID*SSPNpropCA_TWL,
         CA_NONTWL = CA_NONTWL.UNID*SSPNpropCA_NONTWL) %>%
  select(LANDING_YEAR,OR_TWL,OR_NONTWL,CA_TWL,CA_NONTWL)

# when split by gear - for some state/ geartype combinations there's not enough info to calculate the ratio. When no ratio info is available it calculates NA - is that okay? 
  
# Create data file with fleet structure for SS model --------------------------------
# add unidentified catches (with applied ratio above) to shortspine catches

catch.ss <- short.catch %>% 
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  rename(State = COUNTY_STATE, Gear = PACFIN_GROUP_GEAR_CODE) %>%
  mutate(Gear = case_when(Gear == 'TWS' ~ 'TWL',
                          Gear == 'TWL' ~ 'TWL',
                          TRUE ~ 'NONTWL'))  %>% 
  mutate(State = case_when(State == 'WA' ~ 'North',
                           State == 'OR' ~ 'North',
                          TRUE ~ 'South'))  %>% 
  group_by(LANDING_YEAR, State, Gear) %>%
  summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  unite("Fleet", State:Gear, sep = "_") %>%
  spread(Fleet, ROUND_WEIGHT_MTONS) %>%
  left_join(un.totalcatch, by = "LANDING_YEAR") %>%
  mutate(North_NONTWL = sum(North_NONTWL,OR_NONTWL,na.rm=T),
         North_TWL = sum(North_TWL,OR_TWL,na.rm=T),
         South_NONTWL = sum(South_NONTWL,CA_NONTWL,na.rm=T),
         South_TWL = sum(South_TWL,CA_TWL,na.rm=T)) %>%
  select(LANDING_YEAR,South_TWL,South_NONTWL,North_TWL,North_NONTWL)

# plot final landings by fleet 
ggplot(catch.ss, aes(x=LANDING_YEAR)) +
  geom_line(aes(y=North_TWL, color = "blue",linetype = "solid")) + 
  geom_line(aes(y=North_NONTWL, color = "blue",linetype = "dashed")) + 
  geom_line(aes(y=South_TWL, color = "firebrick", linetype = "solid")) + 
  geom_line(aes(y=South_NONTWL, color = "firebrick", linetype = "dashed")) +
  xlab("Year") + 
  ylab("Total Landings (MT)") +
  theme_classic() +
  scale_color_identity(name = "Area",
                       breaks = c("blue", "firebrick"),
                       labels = c("North", "South"),
                       guide = "legend") +
  scale_linetype_identity(name = "Gear",
                          breaks = c("solid", "dashed"),
                          labels = c("Trawl", "Non-trawl"),
                          guide = "legend") + 
  theme(text=element_text(size=20))

#ggsave("outputs/fishery data/SST_PacFIN_total-shortspine-landings.png", dpi=300, height=7, width=10, units='in')
