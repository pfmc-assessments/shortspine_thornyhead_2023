###############################################################################
# Fishery landings  -------------------------------------------------------
require(tidyverse)
require(ggplot2)
require(reshape2)

# shortspine thornyhead only - read data 
load("data/raw/PacFIN.SSPN.CompFT.17.Jan.2023.RData" )
short.catch = catch.pacfin 

###############################################################################
# Plot landings (use ROUND_WEIGHT_MTONS) -------------------------------------
# plot landings by STATE 
short.catch %>% 
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  group_by(LANDING_YEAR,COUNTY_STATE) %>%
  summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  rename(State = COUNTY_STATE) %>%
  ggplot(aes(x=LANDING_YEAR,y=ROUND_WEIGHT_MTONS, color = State)) +
  geom_line() +
  ylab("Total Weight (MT)") +
  xlab("Year") + 
  ggtitle("SSPN") +
  theme_classic()

# plot landings by STATE and GEAR 
short.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  group_by(LANDING_YEAR, COUNTY_STATE, PACFIN_GROUP_GEAR_CODE) %>%
  rename(State = COUNTY_STATE, Gear = PACFIN_GROUP_GEAR_CODE) %>%
  summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
ggplot(aes(x=LANDING_YEAR,y=ROUND_WEIGHT_MTONS, color = Gear)) +
  geom_line() +
  facet_wrap(vars(State)) + 
  ylab("Total Weight (MT)") +
  xlab("Year") + 
  ggtitle("SSPN") +
  theme_classic()

##################################################################################
# Create .csv to use for fishery length expansion -------------------------------------
table(short.catch$Gear) # look at gears 

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
# shortspine thornyhead only - read data 
load("data/raw/PacFIN.SSPN.CompFT.17.Jan.2023.RData" )
short.catch = catch.pacfin 

# longspine thornyhead only - read data 
load("data/raw/PacFIN.LSPN.CompFT.17.Feb.2023.RData" )
long.catch = catch.pacfin 

# unidentified thornyhead only - read data 
load("data/raw/PacFIN.THDS.CompFT.30.Jan.2023.RData" )
un.catch = catch.pacfin 

# CALCULATE TOTAL LANDED WEIGHTS by year - use ROUND_WEIGHT_MTONS
long.totalcatch <- long.catch %>%
  group_by(LANDING_YEAR) %>%
  summarize(LSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T))

short.totalcatch <- short.catch %>%
  group_by(LANDING_YEAR) %>%
  summarize(SSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T))

un.totalcatch <- un.catch %>%
  group_by(LANDING_YEAR) %>%
  summarize(UNID = sum(ROUND_WEIGHT_MTONS, na.rm=T))

# combine dataframes, calculate ratios (like 2013 assessment did - see Fig. 3, page 60)
# ratio of shortspine / (shortspine + longspine)
# ratio of UNID / (shortspine + longspine + UNID) 
totalcatch <- long.totalcatch %>% 
  left_join(short.totalcatch, by = "LANDING_YEAR") %>%
  left_join(un.totalcatch, by = "LANDING_YEAR") %>%
  rowwise() %>%
  mutate(IDtotal = sum(SSPN,LSPN),total = sum(SSPN,LSPN,UNID, na.rm=T), SSPNprop = SSPN / IDtotal, UNIDprop = UNID / total, SSPNtotal = SSPN + (UNID*SSPNprop))

# plot shortspine, longspine, and UNID landings by year 
ggplot(totalcatch, aes(x=LANDING_YEAR)) +
  geom_line(aes(y = SSPN), color = "red") +
  geom_line(aes(y = LSPN), color = "blue") + 
  geom_line(aes(y = UNID), linetype = "dashed") +
  theme_classic()
  
# plot ratios by year (Fig. 3, page 60 in 2013 assessment)
ggplot(totalcatch, aes(x=LANDING_YEAR)) +
  geom_line(aes(y = SSPNprop)) +
  geom_line(aes(y = UNIDprop), col = "red", linetype = "dashed") +
  ylim(0,1) + 
  xlab("Year") + 
  ylab("Ratio") +
  annotate("text", x = 2010, y = 0.85, label = "shortspine / (shortspine + longspine)") +
  annotate("text", x = 2005, y = 0.08, label = "UNID thornyhead / (shortspine + longspine + UNID)", color = "red") +
  theme_classic()

# look at ratio of shortspine / total thornyheads by state ------------------------
long.totalcatch <- long.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA with WA 
  group_by(LANDING_YEAR, COUNTY_STATE) %>%
  summarize(LSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  spread(COUNTY_STATE, LSPN) %>%
  rename(CA.LSPN = CA, OR.LSPN = OR, WA.LSPN = WA)

short.totalcatch <- short.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA"))%>%
  group_by(LANDING_YEAR, COUNTY_STATE) %>%
  summarize(SSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  spread(COUNTY_STATE, SSPN) %>%
  rename(CA.SSPN = CA, OR.SSPN = OR, WA.SSPN = WA)

un.totalcatch <- un.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>%
  group_by(LANDING_YEAR, COUNTY_STATE) %>%
  summarize(UNID = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  spread(COUNTY_STATE, UNID) %>%
  rename(CA.UNID = CA, OR.UNID = OR)

totalcatch <- long.totalcatch %>% 
  left_join(short.totalcatch, by = "LANDING_YEAR") %>%
  left_join(un.totalcatch, by = "LANDING_YEAR") %>%
  rowwise() %>%
  mutate(WAtotal = sum(WA.SSPN,WA.LSPN,na.rm=T), SSPNpropWA = WA.SSPN / WAtotal,
         ORtotal = sum(OR.SSPN,OR.LSPN,na.rm=T), SSPNpropOR = OR.SSPN / ORtotal,
         CAtotal = sum(CA.SSPN,CA.LSPN,na.rm=T), SSPNpropCA = CA.SSPN / CAtotal)

# plot ratio of shortspine / total by state 
ggplot(totalcatch, aes(x=LANDING_YEAR)) +
  geom_line(aes(y=SSPNpropWA, color = "firebrick")) + 
  geom_line(aes(y=SSPNpropOR, color = "darkblue")) + 
  geom_line(aes(y=SSPNpropCA, color = "orange")) + 
  ylim(0,1) +
  xlab("Year") + 
  ylab("Ratio") +
  theme_classic() +
  scale_color_identity(name = "State",
                       breaks = c("firebrick", "darkblue", "orange"),
                       labels = c("WA", "OR", "CA"),
                       guide = "legend")

##################################################################################
# Create data file with fleet structure for model --------------------------------









