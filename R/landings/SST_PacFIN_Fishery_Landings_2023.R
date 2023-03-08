# Fishery landings data from PacFIN for the 2023 SST stock assessment
# Contact: Haley Oleynik
# Last updated March 2023

# length comps are weighted by state-specific landings because WA and OR length
# and catch information come from the port where sampling occurred. port
# sampling programs are state-specific, and therefore the lengths should be
# stratified/weighted by state. in general though, WA and OR vessels fish on the
# same fishing grounds which is why we combine them in the assessment as "north"

# Fishery landings  -----
libs <- c('tidyverse', 'patchwork', 'ggthemes')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

# shortspine thornyhead only - read data 
load("data/raw/PacFIN.SSPN.CompFT.17.Jan.2023.RData")
short.catch = catch.pacfin 

# take black out of colorblind theme
scale_fill_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_fill_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# Color
scale_color_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_color_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# Plot landings (use ROUND_WEIGHT_MTONS) 

# plot landings by STATE  ----
f1 <- short.catch %>% 
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  group_by(LANDING_YEAR,COUNTY_STATE) %>%
  dplyr::summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  dplyr::rename(State = COUNTY_STATE) %>%
  ggplot(aes(x=LANDING_YEAR,y=ROUND_WEIGHT_MTONS, color = State)) +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +
  geom_line(size=1.5) +
  ylab("Total Weight (mt)") +
  xlab("Year") + 
  ggtitle("Shortpine Thornyhead Fishery Landings") +
  scale_color_colorblind7() +
  theme_classic() + 
  theme(text=element_text(size=17))

# plot landings by STATE and GEAR  - line 
f2 <- short.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  group_by(LANDING_YEAR, COUNTY_STATE, PACFIN_GROUP_GEAR_CODE) %>%
  dplyr::rename(State = COUNTY_STATE, Gear = PACFIN_GROUP_GEAR_CODE) %>%
  dplyr::summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  ggplot(aes(x=LANDING_YEAR,y=ROUND_WEIGHT_MTONS, color = Gear)) +
  geom_line(size=1.5) +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +
  facet_wrap(vars(State)) + 
  ylab("Total Weight (mt)") +
  xlab("Year") + 
  scale_color_colorblind7() +
  theme_classic() + 
  theme(text=element_text(size=17))

# show on one plot (require patchwork)
f1 / f2

ggsave("outputs/fishery_data/SST_PacFIN_fishery_landings.png", dpi=300, height=10, width=10, units='in')

# stacked bar plots ----
f3 <- short.catch %>% 
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  group_by(LANDING_YEAR,COUNTY_STATE) %>%
  dplyr::summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  dplyr::rename(State = COUNTY_STATE) %>%
  ggplot(aes(x=LANDING_YEAR,y=ROUND_WEIGHT_MTONS, fill = State)) +
  geom_bar(position="stack", stat="identity") +
  labs(y = "Total Weight (mt)", x = "Year", title = "Shortpine Thornyhead Fishery Landings") +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +
  scale_fill_colorblind7() +
  theme_classic() + 
  theme(text=element_text(size=17))

f4 <- short.catch %>%
  mutate(PACFIN_GROUP_GEAR_CODE = ifelse(PACFIN_GROUP_GEAR_CODE %in% c('TWL', 'TWS'), 'Trawl', 'Non-trawl')) %>% 
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  group_by(LANDING_YEAR, COUNTY_STATE, PACFIN_GROUP_GEAR_CODE) %>%
  dplyr::rename(State = COUNTY_STATE, Gear = PACFIN_GROUP_GEAR_CODE) %>%
  dplyr::summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  ggplot(aes(x=LANDING_YEAR,y=ROUND_WEIGHT_MTONS, fill = forcats::fct_rev(Gear))) +
  geom_bar(position="stack", stat="identity") +
  facet_wrap(vars(State)) + 
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +
  labs(y = "Total Weight (mt)", x = "Year", fill = "Gear") +
  scale_fill_manual(values = c("#0072B2","#F0E442")) +
  theme_classic() + 
  theme(text=element_text(size=17),
        panel.spacing = unit(0.5, "cm"))

f3/f4

ggsave("outputs/fishery_data/SST_PacFIN_fishery_landings-bar.png", dpi=300, height=10, width=10, units='in')

# Create .csv to use for fishery length expansion -----

# only use shortspine catches (not unid)
table(short.catch$PACFIN_GROUP_GEAR_CODE) # look at gears 

# change gear type to trawl or non-trawl, create fleets, spread
length.exp.catch <- short.catch %>% 
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  dplyr::rename(State = COUNTY_STATE, Gear = PACFIN_GROUP_GEAR_CODE) %>%
  dplyr::mutate(Gear = case_when(Gear == 'TWS' ~ 'TWL', # TWS = shrimp trawl
                                 Gear == 'TWL' ~ 'TWL',
                                 TRUE ~ 'NONTWL'))  %>% 
  group_by(LANDING_YEAR, State, Gear) %>%
  dplyr::summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  tidyr::unite("Fleet", State:Gear, sep = "_") %>%
  tidyr::spread(Fleet, ROUND_WEIGHT_MTONS)
unique(length.exp.catch$LANDING_YEAR)

# write catch file to use in fishery length expansions 
write.csv(length.exp.catch,"data/processed/SST_PacFIN_length-comp-landings_2023.csv", row.names = FALSE)

# proportion of shortspine to total thornyheads -----

# longspine thornyhead only - read data 
load("data/raw/PacFIN.LSPN.CompFT.17.Feb.2023.RData")
long.catch = catch.pacfin 

# unidentified thornyhead only - read data 
load("data/raw/PacFIN.THDS.CompFT.30.Jan.2023.RData" )
un.catch = catch.pacfin 

# CALCULATE TOTAL LANDED WEIGHTS by year - use ROUND_WEIGHT_MTONS
long <- long.catch %>%
  group_by(LANDING_YEAR) %>%
  dplyr::summarize(LSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T))

short <- short.catch %>%
  group_by(LANDING_YEAR) %>%
  dplyr::summarize(SSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T))

unid <- un.catch %>%
  group_by(LANDING_YEAR) %>%
  dplyr::summarize(UNID = sum(ROUND_WEIGHT_MTONS, na.rm=T))

props <- long %>% 
  dplyr::left_join(short, by = "LANDING_YEAR") %>%
  dplyr::left_join(unid, by = "LANDING_YEAR") %>%
  dplyr::rowwise() %>%
  mutate(IDtotal = sum(SSPN,LSPN),
         total = sum(SSPN,LSPN,UNID, na.rm=T), 
         SSPNprop = SSPN / IDtotal, 
         UNIDprop = UNID / total, 
         SSPNtotal = SSPN + (UNID*SSPNprop))

# combine dataframes, calculate ratios (like 2013 assessment did - see Fig. 3, page 60)
# ratio of shortspine / (shortspine + longspine)
# ratio of UNID / (shortspine + longspine + UNID) 

# plot landings by year 
props %>%
  ggplot(aes(x=LANDING_YEAR)) +
  geom_line(aes(y = SSPN,color = "darkred"), size=1.5) +
  geom_line(aes(y = LSPN,color = "blue"), size=1.5) + 
  geom_line(aes(y = UNID, color = "black"), size=1.5) +
  xlab("Year") +
  ylab("Total Landings (mt)") +
  scale_color_identity(name = "",
                       breaks = c("darkred", "blue", "black"),
                       labels = c("Shortspine", "Longspine", "Unidentified"),
                       guide = "legend") +
  theme_classic() + 
  theme(text=element_text(size=20))

# stacked bar plot 
long %>% 
  left_join(short, by = "LANDING_YEAR") %>%
  left_join(unid, by = "LANDING_YEAR") %>%
  tidyr::gather("Species", "Landings", -LANDING_YEAR) %>%
  mutate(Species = case_when(Species == 'LSPN' ~ 'Longspine',
                             Species == 'SSPN' ~ 'Shortspine',
                             Species == 'UNID' ~ 'Unidentified')) %>% 
  ggplot(aes(x=LANDING_YEAR, y=Landings, fill = Species)) +
  geom_bar(position="stack", stat="identity") +
  xlab("Year") +
  ylab("Total Landings (MT)") +
  scale_color_identity(name = "",
                       breaks = c("darkred", "blue", "black"),
                       labels = c("Shortspine", "Longspine", "Unidentified"),
                       guide = "legend") +
  scale_fill_colorblind7() + 
  theme_classic() + 
  theme(text=element_text(size=20))

ggsave("outputs/fishery_data/SST_PacFIN_all-thornyheads.png", dpi=300, height=7, width=10, units='in')
  
# plot ratios by year (Fig. 3, page 60 in 2013 assessment)
props %>% 
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

ggsave("outputs/fishery_data/SST_PacFIN_thornyhead-ratio.png", dpi=300, height=7, width=10, units='in')

# ratio of shortspine / total thornyheads by STATE ------------------------
long2 <- long.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA with WA 
  group_by(LANDING_YEAR, COUNTY_STATE) %>%
  dplyr::summarize(LSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  tidyr::spread(COUNTY_STATE, LSPN) %>%
  dplyr::rename(CA.LSPN = CA, OR.LSPN = OR, WA.LSPN = WA)

short2 <- short.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA"))%>%
  group_by(LANDING_YEAR, COUNTY_STATE) %>%
  dplyr::summarize(SSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  tidyr::spread(COUNTY_STATE, SSPN) %>%
  dplyr::rename(CA.SSPN = CA, OR.SSPN = OR, WA.SSPN = WA)

unid2 <- un.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>%
  group_by(LANDING_YEAR, COUNTY_STATE) %>%
  dplyr::summarize(UNID = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  tidyr::spread(COUNTY_STATE, UNID) %>%
  dplyr::rename(CA.UNID = CA, OR.UNID = OR)

# plot ratio of shortspine / total by state 
long2 %>% 
  left_join(short2, by = "LANDING_YEAR") %>%
  left_join(unid2, by = "LANDING_YEAR") %>%
  dplyr::rowwise() %>%
  mutate(WAtotal = sum(WA.SSPN,WA.LSPN,na.rm=T), 
         SSPNpropWA = WA.SSPN / WAtotal,
         ORtotal = sum(OR.SSPN,OR.LSPN,na.rm=T), 
         SSPNpropOR = OR.SSPN / ORtotal,
         CAtotal = sum(CA.SSPN,CA.LSPN,na.rm=T), 
         SSPNpropCA = CA.SSPN / CAtotal) %>%
  ggplot(aes(x=LANDING_YEAR)) +
  geom_line(aes(y=SSPNpropWA, color = "#009e73"), size = 1.5) + 
  geom_line(aes(y=SSPNpropOR, color = "#56b4e9"), size = 1.5) + 
  geom_line(aes(y=SSPNpropCA, color = "#e69F00"), size = 1.5) + 
  ylim(0,1) +
  xlab("Year") + 
  ylab("Ratio (Shortspine / Total)") +
  theme_classic() +
  scale_color_identity(name = "State",
                       breaks = c("#009e73", "#56b4e9", "#e69F00"),
                       labels = c("WA", "OR", "CA"),
                       guide = "legend") + 
  theme(text=element_text(size=20))

ggsave("outputs/fishery_data/SST_PacFIN_thornyhead-ratio-state.png", dpi=300, height=7, width=10, units='in')

# ratio of shortspine / total thornyheads by STATE AND GEAR ------------------------

# WA is different from OR and CA because there are no unidentified thornyheads.
# There are longspine, however, so we have a column of NAs for the unident
# thornyheads in WA that we add to the total thornyheads. The ratio of
# shortspine/total is applied to the uniden thornyheads, so this doesn't need to
# be done in WA
long.totalcatch <- long.catch %>%
  dplyr::mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>%
  dplyr::mutate(Gear = case_when(PACFIN_GROUP_GEAR_CODE == 'TWS' ~ 'TWL',
                          PACFIN_GROUP_GEAR_CODE == 'TWL' ~ 'TWL',
                          TRUE ~ 'NONTWL')) %>% # replace NA with WA 
  dplyr::group_by(LANDING_YEAR, COUNTY_STATE, Gear) %>%
  dplyr::summarize(LSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  tidyr::unite("Fleet", COUNTY_STATE:Gear, sep = "_") %>%
  tidyr::spread(Fleet, LSPN) %>%
  dplyr::select(LANDING_YEAR,CA_NONTWL,CA_TWL,OR_NONTWL,OR_TWL,WA_NONTWL,WA_TWL) %>%
  dplyr::rename(CA_NONTWL.LSPN = CA_NONTWL, CA_TWL.LSPN = CA_TWL, 
                OR_NONTWL.LSPN = OR_NONTWL, OR_TWL.LSPN = OR_TWL,
                WA_NONTWL.LSPN = WA_NONTWL, WA_TWL.LSPN = WA_TWL)

short.totalcatch <- short.catch %>%
  dplyr::mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA with WA 
  dplyr::mutate(Gear = case_when(PACFIN_GROUP_GEAR_CODE == 'TWS' ~ 'TWL',
                          PACFIN_GROUP_GEAR_CODE == 'TWL' ~ 'TWL',
                          TRUE ~ 'NONTWL')) %>% 
  dplyr::group_by(LANDING_YEAR, COUNTY_STATE, Gear) %>%
  dplyr::summarize(SSPN = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  tidyr::unite("Fleet", COUNTY_STATE:Gear, sep = "_") %>%
  tidyr::spread(Fleet, SSPN) %>%
  dplyr::select(LANDING_YEAR,CA_NONTWL,CA_TWL,OR_NONTWL,OR_TWL,WA_NONTWL,WA_TWL) %>%
  dplyr::rename(CA_NONTWL.SSPN = CA_NONTWL, CA_TWL.SSPN = CA_TWL, 
                OR_NONTWL.SSPN = OR_NONTWL, OR_TWL.SSPN = OR_TWL,
                WA_NONTWL.SSPN = WA_NONTWL, WA_TWL.SSPN = WA_TWL)

totalcatch <- long.totalcatch %>% 
  dplyr::left_join(short.totalcatch, by = "LANDING_YEAR") %>%
  dplyr::rowwise() %>%
  dplyr::mutate(OR_TWL.total = sum(OR_TWL.SSPN,OR_TWL.LSPN,na.rm=T), 
                SSPNpropOR_TWL = OR_TWL.SSPN / OR_TWL.total,
                OR_NONTWL.total = sum(OR_NONTWL.SSPN,OR_NONTWL.LSPN,na.rm=T), 
                SSPNpropOR_NONTWL = OR_NONTWL.SSPN / OR_NONTWL.total,
                CA_TWL.total = sum(CA_TWL.SSPN,CA_TWL.LSPN,na.rm=T), 
                SSPNpropCA_TWL = CA_TWL.SSPN / CA_TWL.total,
                CA_NONTWL.total = sum(CA_NONTWL.SSPN,CA_NONTWL.LSPN,na.rm=T), 
                SSPNpropCA_NONTWL = CA_NONTWL.SSPN / CA_NONTWL.total,
                WA_TWL.total = sum(WA_TWL.SSPN,WA_TWL.LSPN,na.rm=T), 
                SSPNpropWA_TWL = WA_TWL.SSPN / WA_TWL.total,
                WA_NONTWL.total = sum(WA_NONTWL.SSPN,WA_NONTWL.LSPN,na.rm=T), 
                SSPNpropWA_NONTWL = WA_NONTWL.SSPN / WA_NONTWL.total) %>%
  dplyr::select(LANDING_YEAR,SSPNpropCA_NONTWL,SSPNpropCA_TWL,
                SSPNpropOR_NONTWL,SSPNpropOR_TWL,
                SSPNpropWA_NONTWL,SSPNpropWA_TWL) 

# plot ratio of shortspine / total by state 

longprops <- totalcatch %>% 
  dplyr::select(LANDING_YEAR, prop = SSPNpropCA_NONTWL) %>% 
  dplyr::mutate(state = 'CA',
                gear = 'NONTWL') %>% 
  bind_rows(totalcatch %>% 
              dplyr::select(LANDING_YEAR, prop = SSPNpropCA_TWL) %>% 
              dplyr::mutate(state = 'CA',
                            gear = 'TWL')) %>% 
  bind_rows(totalcatch %>% 
              dplyr::select(LANDING_YEAR, prop = SSPNpropOR_NONTWL) %>% 
              dplyr::mutate(state = 'OR',
                            gear = 'NONTWL')) %>% 
  bind_rows(totalcatch %>% 
              dplyr::select(LANDING_YEAR, prop = SSPNpropOR_TWL) %>% 
              dplyr::mutate(state = 'OR',
                            gear = 'TWL')) %>% 
  bind_rows(totalcatch %>% 
              dplyr::select(LANDING_YEAR, prop = SSPNpropWA_NONTWL) %>% 
              dplyr::mutate(state = 'WA',
                            gear = 'NONTWL')) %>% 
  bind_rows(totalcatch %>% 
              dplyr::select(LANDING_YEAR, prop = SSPNpropWA_TWL) %>% 
              dplyr::mutate(state = 'WA',
                            gear = 'TWL')) 

  
longprops %>% 
  mutate(Gear = ifelse(gear == 'TWL', 'Trawl', 'Non-trawl')) %>% 
  ggplot(aes(x = LANDING_YEAR, y = prop, col = Gear)) +
  geom_line(size = 1.5) +
  facet_wrap(~state) +
  theme_classic() +
  theme(text=element_text(size=20),
        panel.spacing = unit(0.5, "cm")) +
  labs(x = 'Year',
       y = 'Ratio (Shortspine / All Thornyheads)') +
  scale_color_colorblind7() +
  ylim(limits = c(0, NA)) 

ggsave("outputs/fishery_data/SST_PacFIN_thornyhead-ratio-state-gear.png", dpi=300, height=7, width=12, units='in')

# Apply ratio ----

# unidentified catch
un.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>%
  mutate(Gear = case_when(PACFIN_GROUP_GEAR_CODE == 'TWS' ~ 'TWL',
                          PACFIN_GROUP_GEAR_CODE == 'TWL' ~ 'TWL',
                          TRUE ~ 'NONTWL'),
         fleet = paste0(COUNTY_STATE, '_', Gear)) %>% 
  group_by(year = LANDING_YEAR, fleet) %>%
  dplyr::summarize(unid_catch = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  readr::write_csv('outputs/fishery_data/unid_catch.csv')

longprops %>% 
  mutate(fleet = paste0(state, '_', gear)) %>% 
  dplyr::select(year = LANDING_YEAR, fleet, prop) %>% 
  write_csv('outputs/fishery_data/raw_proportion_sst.csv')

# because there are only unident thornyheads in OR and CA, only apply the ratio
# to those states
un.totalcatch <- un.catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>%
  mutate(Gear = case_when(PACFIN_GROUP_GEAR_CODE == 'TWS' ~ 'TWL',
                          PACFIN_GROUP_GEAR_CODE == 'TWL' ~ 'TWL',
                          TRUE ~ 'NONTWL')) %>% 
  group_by(LANDING_YEAR, COUNTY_STATE, Gear) %>%
  dplyr::summarize(UNID = sum(ROUND_WEIGHT_MTONS, na.rm=T)) %>%
  tidyr::unite("Fleet", COUNTY_STATE:Gear, sep = "_") %>%
  tidyr::spread(Fleet, UNID) %>%
  dplyr::rename(CA_NONTWL.UNID = CA_NONTWL,
                CA_TWL.UNID = CA_TWL, 
                OR_NONTWL.UNID = OR_NONTWL, OR_TWL.UNID = OR_TWL) %>%
  dplyr::left_join(totalcatch, by = "LANDING_YEAR") %>%
  rowwise() %>%
  dplyr::mutate(OR_TWL = OR_TWL.UNID*SSPNpropOR_TWL,
                OR_NONTWL = OR_NONTWL.UNID*SSPNpropOR_NONTWL,
                CA_TWL = CA_TWL.UNID*SSPNpropCA_TWL,
                CA_NONTWL = CA_NONTWL.UNID*SSPNpropCA_NONTWL) %>%
  dplyr::select(LANDING_YEAR,OR_TWL,OR_NONTWL,CA_TWL,CA_NONTWL)

# when split by gear - for some state/ geartype combinations there's not enough
# info to calculate the ratio. When no ratio info is available it calculates NA
# - is that okay?
  
# Create data file with fleet structure for SS model -----
# add unidentified catches (with applied ratio above) to shortspine catches

catch.ss <- short.catch %>% 
  dplyr::mutate_at("COUNTY_STATE", ~replace_na(.,"WA")) %>% # replace NA states with WA
  dplyr::rename(State = COUNTY_STATE, Gear = PACFIN_GROUP_GEAR_CODE) %>%
  dplyr::mutate(Gear = case_when(Gear == 'TWS' ~ 'TWL',
                          Gear == 'TWL' ~ 'TWL',
                          TRUE ~ 'NONTWL'))  %>% 
  dplyr::mutate(State = case_when(State == 'WA' ~ 'North',
                           State == 'OR' ~ 'North',
                          TRUE ~ 'South'))  %>% 
  dplyr::group_by(LANDING_YEAR, State, Gear) %>%
  dplyr::summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T)) %>%
  tidyr::unite("Fleet", State:Gear, sep = "_") %>%
  tidyr::spread(Fleet, ROUND_WEIGHT_MTONS) %>%
  dplyr::left_join(un.totalcatch, by = "LANDING_YEAR") %>%
  dplyr::mutate(North_NONTWL = sum(North_NONTWL,OR_NONTWL,na.rm=T),
                North_TWL = sum(North_TWL,OR_TWL,na.rm=T),
                South_NONTWL = sum(South_NONTWL,CA_NONTWL,na.rm=T),
                South_TWL = sum(South_TWL,CA_TWL,na.rm=T)) %>%
  dplyr::select(LANDING_YEAR,South_TWL,South_NONTWL,North_TWL,North_NONTWL)

catch.ss <- catch.ss %>% 
  dplyr::mutate(Season = 1) %>% 
  dplyr::select(NTrawl = North_TWL, STrawl = South_TWL,
                NOther = North_NONTWL, SOther = South_NONTWL,
                Year = LANDING_YEAR, Season)

write.csv(catch.ss,"data/processed/SST_PacFIN_total-landings_2023.csv",row.names = FALSE)

# plot final landings by fleet 
catch.ss %>% 
  pivot_longer(cols = -c(Year, Season), names_to = 'Fleet', values_to = 'Catch') %>% 
  ggplot(aes(x=Year, y = Catch, #col = forcats::fct_rev(Fleet), 
             fill = forcats::fct_rev(Fleet))) +
  geom_bar(stat = 'identity', col = 'black') +
  scale_fill_manual(values = c("#E69F00", "#F0E442", "#56B4E9", "#009E73")) +
  # scale_fill_colorblind7() +
  xlab("Year") + 
  ylab("Total Landings (mt)") +
  labs(fill = 'Fleet') +
  theme_classic() +
  theme(text=element_text(size=20)) +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) 

ggsave("outputs/fishery_data/SST_PacFIN_total-shortspine-landings-bar.png", dpi=300, height=7, width=10, units='in')