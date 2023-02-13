###############################################################################
# Fishery landings  ------------------------------------------------

# shortspine thornyhead only - read data 
catch = "data/raw/PacFIN.SSPN.CompFT.17.Jan.2023.RData" 
load(file.path(getwd(), catch))
catch = catch.pacfin 

# Some states listed as "NA" - all washington, replace NAs with WA:
catch.test <- catch %>%
  mutate_at("COUNTY_STATE", ~replace_na(.,"WA"))

# look at landings  by state -----------------------------------
catch2 <- catch.test %>%
  group_by(LANDING_YEAR, COUNTY_STATE, PACFIN_GROUP_GEAR_CODE) %>%
  rename(State = COUNTY_STATE, Gear = PACFIN_GROUP_GEAR_CODE) %>%
  summarize(ROUND_WEIGHT_MTONS = sum(ROUND_WEIGHT_MTONS,na.rm=T))

# plot catch by state (use ROUND_WEIGHT_MTONS)
ggplot(data = catch2, aes(x=LANDING_YEAR,y=ROUND_WEIGHT_MTONS, color = State)) +
  geom_line() +
  ylab("Total Weight (MT)") +
  xlab("Year") + 
  ggtitle("SSPN") +
  theme_classic()

# look at landings by state AND gear type ----------------------------
table(catch$PACFIN_GROUP_GEAR_CODE)

# plot by state and gear type
ggplot(data = catch2, aes(x=LANDING_YEAR,y=ROUND_WEIGHT_MTONS, color = Gear)) +
  geom_line() +
  facet_wrap(vars(State)) + 
  ylab("Total Weight (MT)") +
  xlab("Year") + 
  ggtitle("SSPN") +
  theme_classic()

# create catch.csv to use for expansion -------------------------------------
catch2 <- catch.test %>%
  select(LANDING_YEAR, COUNTY_STATE, PACFIN_GROUP_GEAR_CODE, ROUND_WEIGHT_MTONS) %>%
  group_by(LANDING_YEAR, COUNTY_STATE, PACFIN_GROUP_GEAR_CODE) %>%
  rename(State = COUNTY_STATE, Gear = PACFIN_GROUP_GEAR_CODE) %>%
  summarize(Total.weight = sum(ROUND_WEIGHT_MTONS,na.rm=T))

# check 
sum(catch$ROUND_WEIGHT_MTONS)
sum(catch2$Total.weight)
unique(catch2$Gear) # "HKL" "NET" "TWL" "TWS" "POT" "TLS" (troll) "MSC"

trawl <- c("TWL", "TWS")

trawl.catch <- catch2 %>% 
  filter(Gear %in% trawl) %>%
  group_by(LANDING_YEAR, State) %>%
  summarize(Total.weight = sum(Total.weight,na.rm=T))

non.trawl <- c("HKL","NET", "POT", "TLS","MSC")

nontrawl.catch <- catch2 %>% 
  filter(Gear %in% non.trawl) %>%
  group_by(LANDING_YEAR, State) %>%
  summarize(Total.weight = sum(Total.weight,na.rm=T))

# check 
sum(trawl.catch$Total.weight) + sum(nontrawl.catch$Total.weight) # 65981.3

# put into wide format (cast by state)
trawl.cast <- dcast(trawl.catch, LANDING_YEAR~State, value.var = "Total.weight")

trawl.cast <- trawl.cast %>%
  rename(CA_TWL = CA, WA_TWL = WA, OR_TWL = OR, Year = LANDING_YEAR)

# put into wide format (cast by state)
nontrawl.cast <- dcast(nontrawl.catch, LANDING_YEAR~State, value.var = "Total.weight")

nontrawl.cast <- nontrawl.cast %>%
  rename(CA_NONTWL = CA, WA_NONTWL = WA, OR_NONTWL = OR, Year = LANDING_YEAR)

# FINAL DATAFRAME 
catch.final <- cbind(trawl.cast,nontrawl.cast)
catch.final <- catch.final[,-5]

#write.csv(catch.final, "SST_PacFIN_landings_2023.csv")

# use ROUND_WEIGHT_MTONS
colnames(catch) = c("Year", "CA_ALL", "OR_ALL", "WA_ALL") # we want trawl, non-trawl
