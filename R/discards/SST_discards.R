# Shortspine Thornyhead Discards
# Contact: PY Hernvann
# Last updated March 2023

# set up ----
libs <- c('ggplot2', 'reshape', 'readxl', 'ggridges')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

# pak::pkg_install('pfmc-assessments/PacFIN.Utilities',upgrade = TRUE)
# pak::pkg_install('pfmc-assessments/nwfscSurvey',upgrade = TRUE)
library(PacFIN.Utilities)
library(nwfscSurvey)


# Color
scale_color_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_color_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

####--------------------------------------------------------------------#
####-------------------------	GEMM data ---------------------------------
####--------------------------------------------------------------------#

# The GEMM data set is a summary of catch statistics off the West Coast for different combinations of 
#fisheries groupings (main species targeted) and sectors (gear, main location, regulation regime)
# For each of these combinations, it provides the total yearly landings, discards, and derived discard rates
# Discard estimates are also calculated while accounting for the survival of discarded individuals based on 
#several studies.

GEMM_data <- read.csv(paste0(processed_discards_path,"/GEMM.csv"))

# Subset for Shortspine Thornyhead
GEMM_data %>%
  group_by(species) %>%
  filter(grepl("Shortspine Thornyhead", species)) -> thorny_GEMM

thorny_GEMM %>%
  filter(sector!="Research") %>%
  group_by(grouping, sector, species, year) %>%
  summarize(totland  = sum(total_landings_mt, na.rm=T),
            totdisc= sum(total_discard_mt, na.rm=T)) %>%
  ggplot(aes(x=year, y=totland, fill=sector)) +
  geom_bar(stat="identity", position="stack") +
  scale_fill_colorblind7()+
  facet_wrap(~grouping)+
  theme_classic() + 
  theme(text=element_text(size=20))

thorny_GEMM %>%
  filter(sector!="Research") %>%
  group_by(grouping, sector, species, year) %>%
  summarize(totland  = sum(total_landings_mt, na.rm=T),
            totdisc= sum(total_discard_mt, na.rm=T)) %>%
  ggplot(aes(x=year, y=totdisc, fill=sector)) +
  geom_bar(stat="identity", position="stack") +
  scale_fill_colorblind7()+
  facet_wrap(~grouping)+
  theme_classic() + 
  theme(text=element_text(size=20))

# Let's assign each sector to a catch share regime and a gear type to 
thorny_GEMM %>%
  group_by(sector) %>%
  mutate(catch_share=ifelse(grepl("CS", sector),"cs",ifelse(grepl("Research", sector),"research","ncs"))) %>% # Catch share only exist since 2011 - they are explicitely informed here
  mutate(gear = case_when(grepl("Limited|Tribal|Trawl|OA CA Halibut|Hake CP|Hake MSCV|Pink|Prawn|Cucumber|Halibut|Incidental", sector) ~ "Trawl",
                          # All trawls that were not pelagic / mid-water trawls were assigned to the Trawl fleet
                          grepl("Tribal|Recreational|LE|Midwater|Nearshore|Shoreside|Hook|Pot|Fixed", sector) ~ "Other", #Tribal = non hake; midwater!=bottom shoreside
                          # All non-trawl gears and pelagic/mid-water gears were included in the "Other fleet"
                          grepl("Research", sector) ~ "research") # Catch by fisheries-independent survey are also recorded
  ) -> thorny_GEMM

thorny_GEMM %>%
  group_by(sector) %>%
  mutate(catch_share = ifelse(grepl("CS", sector),"Y","N")) %>%
  group_by(sector, catch_share, species, year) %>%
  summarize(totland  = sum(total_landings_mt, na.rm=T),
            totdisc= sum(total_discard_mt, na.rm=T)) %>%
  ggplot(aes(x=year, y=totdisc, fill=catch_share)) +
  geom_bar(stat="identity") +
  facet_wrap(~species)+ theme_bw()

thorny_GEMM %>%
  group_by(sector) %>%
  mutate(catch_share = ifelse(grepl("CS", sector),"Y","N")) %>%
  group_by(sector, catch_share, species, year) %>%
  summarize(totland  = sum(total_landings_mt, na.rm=T),
            totdisc= sum(total_discard_mt, na.rm=T)) %>%
  ggplot(aes(x=year, y=totdisc+totland, fill=catch_share)) +
  geom_bar(stat="identity") +
  facet_wrap(~species) + theme_bw()

####--------------------------------------------------------------------#
####-----------------	WCGOP observer program ----------------------------
####--------------------------------------------------------------------#

# The WCGOP is the main source of information on discards. It covered the period from 2002 to the present.
# Data from the WCGOP has been accessed upon request at https://github.com/pfmc-assessments/nwfscDiscard
# It is split into different files 

### 1. Fleet-specific discard rates 

# Discard rates estimates are provided for each fleet, for both catch shares / non catch shares components.
# Discard rates are recorded for each monitored fishing operation and the discard rates of the fleets 
#are estimated from these observations.
# Fleets are defined by State (CA vs WA/OR) and gear (Trawl vs Fixed Gears)

# All fishing operations of the catch shares component are recorded. Thus, the estimated discard rates is supposed
#to be exact

processed_discards_path <- 'data/fishery_processed/discards'

disc_catch_share <- read.csv(paste0(processed_discards_path, "/shortspine_thornyhead_cs_wcgop_discard_all_years_Gear_Grouped_States_2023-02-09.csv"))
# Not all fishing operations of the non-catch shares component are recorded. Thus, the discard rates are estimated
#while accounting for the sampling size through a bootstrapping procedure
disc_no_catch_share <- read.csv(paste0(processed_discards_path, "/shortspine_thornyhead_ncs_wcgop_discard_all_years_Gear_Grouped_States_2023-02-09.csv"))

# Merge the 2 datasets a and retain the information we need.

disc_catch_share %>%
  mutate(median_boot_discard_mt = NA,
         sd_boot_discard_mt = NA,
         median_boot_ratio = NA,
         sd_boot_ratio = NA,
         n_bootstrap =NA) %>%
  relocate(colnames(disc_no_catch_share)) %>%
  bind_rows(disc_no_catch_share) %>%
  mutate(area_lg=ifelse(area == "CA", "S", "N"),
         gear=ifelse(gear == "FixedGears", "Other", gear)) %>%
  mutate(fleet=paste0(area_lg, gear)) %>%
  mutate(ob_ratio_boot = ifelse(!is.na(median_boot_ratio), median_boot_ratio, ob_ratio)) -> disc_rates_WCGOP

disc_rates_WCGOP %>%
  ggplot(aes(x=year, y=ob_ratio_boot)) +
  geom_point(aes(color=forcats::fct_rev(fleet), shape = catch_shares), size=2.5) +
  geom_errorbar(aes(ymin=ob_ratio_boot-2.16*sd_boot_ratio, ymax =ob_ratio_boot+2.16*sd_boot_ratio, color=forcats::fct_rev(fleet)), width=.2) +
  facet_wrap(~forcats::fct_rev(fleet), scales="free_y") +
  scale_color_manual(values = c("#E69F00", "#F0E442", "#56B4E9", "#009E73")) +
  labs(x = "Year", y = "Discard rate (Disc./(Disc.+Retained); %)", color="Fleet", shape="Catch shares", title = "Shortspine Thornyhead Discard Fraction (WCGOP)") + 
  coord_cartesian(ylim=c(0,1)) +
  theme_bw() +
  theme(legend.position = "top")

# In the stock assessment, fleets are only defined by their gear and their location. Thus, we should account for the fact that both
#catch shares and non catch shares fleets have different discard rates. This is done by weighing the discard rate of each
#fleet catch share component by their relative importance in the total catch.

# Relative importance of catch share / non-catch share components
thorny_GEMM %>%
  group_by(sector) %>%
  mutate(catch_share = ifelse(grepl("CS", sector), TRUE, FALSE)) %>%
  group_by(gear,  catch_share, species, year) %>%
  summarize(totland  = sum(total_landings_mt, na.rm=T),
            totdisc= sum(total_discard_with_mort_rates_applied_mt, na.rm=T)) %>% # Here we use the discard rates calculated considering the survivak rate of the discarded individuals
  mutate(totcatch = totland + totdisc) %>%
  group_by(gear,  species, year) %>%
  mutate(tot_catch_gear = sum(totcatch, na.rm=T)) %>% 
  ungroup() %>%
  mutate(prop=totcatch/tot_catch_gear)  %>%
  filter(gear!="research") -> rep_gear

disc_rates_WCGOP %>% 
  left_join(rep_gear[,c("gear","catch_share","year","prop")], by=c("year", "gear", "catch_shares"="catch_share"))  %>% 
  mutate(weighed_discr=prop*ob_ratio_boot) %>%
  group_by(fleet,year) %>%
  mutate(sd=sum(sd_boot_ratio,na.rm=T)) %>% # Question there: which uncertainty should we consider??
  summarize(mean_discr=sum(weighed_discr),
            mean_sd=ifelse(year>2010,0,sd)) -> disc_rates_WCGOP_GEMM

disc_rates_WCGOP_GEMM %>%
  ggplot(aes(x=year, y=mean_discr)) +
  geom_point(aes(color=forcats::fct_rev(fleet)), size=2.5) +
  geom_errorbar(aes(ymin=mean_discr-2.16*mean_sd, ymax=mean_discr+2.16*mean_sd, color=forcats::fct_rev(fleet)), width=.2) +
  facet_wrap(~fleet, scales="free_y") +
  scale_color_manual(values = c("#E69F00", "#F0E442", "#56B4E9", "#009E73")) +
  labs(x = "Year", y = "Discard rate (Disc./(Disc.+Retained); %)", color="Fleet", shape="Catch shares", title = "Shortspine Thornyhead Discard Fraction (WCGOP)") + 
  coord_cartesian(ylim=c(0,1)) +
  theme_bw() +
  theme(legend.position = "top")


ggsave("outputs/discard_data/SST_WCGOP_GEMM_discard_rates.png", dpi=300, height=7, width=10, units='in')

# write.csv(, "outputs/discard_data/*******.csv")

# !! In order to expand the discard rates, we need to access the relative % of "catch shares" vs "no catch shares" in the total SST catch (or landings)
  

### 2. Fleet-specific discard length composition 

# Discarded individuals are sampled on-board and measured. We will use this information to fit different selectivity curves in SS3
  
disc_length <- read_excel(paste0(processed_discards_path, "/SSPN_WCGOP_WAOR-CA_Trawl-NonTrawl.xlsx"),
                               sheet = "Length Frequency")

disc_length %>%
  mutate(area_lg = ifelse(State == "CA", "S", "N"),
         Gear = ifelse(Gear == "NonTRAWL", "Other", "Trawl")) %>%
  mutate(fleet = paste0(area_lg, Gear)) -> disc_lencomp_WCGOP

disc_lencomp_WCGOP %>%
  mutate(meanLen = Lenbin + 1) %>% # just for plotting purpose - we center each bar on the mean value of the size bin
  ggplot(aes(x=meanLen, y=factor(Year), height = Prop.numbers, fill = forcats::fct_rev(fleet))) + 
  geom_density_ridges(stat = "identity", col = "lightgrey", alpha = 0.45, 
                      panel_scaling = TRUE, size = 0.5) +
  scale_fill_manual(values = c("#E69F00", "#F0E442", "#56B4E9", "#009E73")) +
  theme_light() +
  labs(x = "Length (cm)", y = NULL, fill = "Fleet", title = "Shortspine Thornyhead Discard Length Compositions") + 
  theme(legend.position = "top") +
  facet_wrap(~forcats::fct_rev(fleet), ncol=4)

ggsave("outputs/discard_data/SST_WCGOP_discard_lencomps.png", dpi=300, height=10, width=7, units='in')
  
# write.csv(, "outputs/discard_data/*******.csv")

### 3. Fleet-specific discard average weight

# Discarded individuals are sampled on-board and measured. We will use this information to fit different selectivity curves in SS3

disc_weight <- read_excel(paste0(processed_discards_path, "/SSPN_WCGOP_WAOR-CA_Trawl-NonTrawl.xlsx"),
                          sheet = "Average Weight")

plotylim <- c(0,6)

disc_weight%>%
  mutate(area_lg = ifelse(State == "CA", "S", "N"),
         Gear = ifelse(Gear == "NonTRAWL", "Other", "Trawl")) %>%
  mutate(fleet = paste0(area_lg, Gear)) %>%
  mutate(maxall=max(AVG_WEIGHT.Mean+2.16*AVG_WEIGHT.SD)) %>%
  mutate(lowb = AVG_WEIGHT.Mean-2.16*AVG_WEIGHT.SD,
         highb = AVG_WEIGHT.Mean+2.16*AVG_WEIGHT.SD) %>%
  ggplot(aes(x=Year, y=AVG_WEIGHT.Mean,  color = forcats::fct_rev(fleet))) + 
  geom_point(size=2.5) +
  geom_errorbar(aes(ymin=lowb,ymax=highb, width=.2) )+
  coord_cartesian(ylim=plotylim) +
  scale_color_manual(values = c("#E69F00", "#F0E442", "#56B4E9", "#009E73")) +
  labs(x = "Year", y = NULL, color="Fleet", title = "Shortspine Thornyhead Observed Average Weight (kg, WCGOP)") + 
  theme_bw() +
  theme(legend.position = "top") +
  facet_wrap(~forcats::fct_rev(fleet))

ggsave("outputs/discard_data/SST_WCGOP_discard_avgweight.png", dpi=300, height=7, width=10, units='in')

# write.csv(, "outputs/discard_data/*******.csv")

####--------------------------------------------------------------------#
####------------------------	EDCP data --------------------------------
####--------------------------------------------------------------------#

# The EDCP dataset will provide discard rates estimates for the mid-1990s

# The data should be updated compared to that considered in the previous assessment (new methodology for calculating the rates).
# We are still waiting for getting the data

####--------------------------------------------------------------------#
####------------------------	Pikitch data --------------------------------
####--------------------------------------------------------------------#

# The Pikitch dataset will provide discard rates estimates and length composition for the 1980s

# The data should be comparable to that considered in the previous assessment. W should also be able to access newly available sex-information.
# Request has been made to John Wallace.





  
  
  







