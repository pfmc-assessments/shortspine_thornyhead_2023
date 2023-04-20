# Shortspine Thornyhead Discards
# Contact: PY Hernvann
# Last updated March 2023

# set up ----
libs <- c('ggplot2', 'reshape', 'readxl', 'ggridges', 'dplyr', 'ggthemes', 'tidyr')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

# pak::pkg_install('pfmc-assessments/PacFIN.Utilities',upgrade = TRUE)
# pak::pkg_install('pfmc-assessments/nwfscSurvey',upgrade = TRUE)

# Color
source(file=file.path("R", "utils", "colors.R"))

processed_discards_path <- 'data/fishery_processed/discards'
confidential_discards_path <- 'data/fishery_confidential/discards'

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
  labs(y="Discards") +
  facet_wrap(~species)+ theme_bw()

thorny_GEMM %>%
  group_by(sector) %>%
  mutate(catch_share = ifelse(grepl("CS", sector),"Y","N")) %>%
  group_by(sector, catch_share, species, year) %>%
  summarize(totland  = sum(total_landings_mt, na.rm=T),
            totdisc= sum(total_discard_mt, na.rm=T)) %>%
  ggplot(aes(x=year, y=totdisc+totland, fill=catch_share)) +
  geom_bar(stat="identity") +
  labs(y="Catch") +
  facet_wrap(~species) + theme_bw()


#Added by Madi 3/15/23
#Summarize Discards in MT by year (Coastwide, gear grouping)

thorny_GEMM %>%
  filter(sector!="Research") %>%
  group_by(year, gear) %>%
  summarize(totland  = sum(total_landings_mt, na.rm=T),
            totdisc= sum(total_discard_mt, na.rm=T)) %>%
  ggplot(aes(x=year, y=totdisc, fill = gear )) +
  geom_bar(stat="identity", position="stack", color = "black") +
  scale_fill_manual(values = c( "#56B4E9","#F0E442"), name = "Gear Type") +
  labs(x = "Year", y = "Discard (mt)", title = "Shortspine Thornyhead Discards (GEMM)")+
  theme_classic() + 
  theme(text=element_text(size=20))

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

disc_catch_share <- read.csv(paste0(processed_discards_path, "/shortspine_thornyhead_cs_wcgop_discard_all_years_Gear_Grouped_States_2023-02-09.csv"))
# Not all fishing operations of the non-catch shares component are recorded. Thus, the discard rates are estimated
#while accounting for the sampling size through a bootstrapping procedure
disc_no_catch_share <- read.csv(paste0(processed_discards_path, "/shortspine_thornyhead_ncs_wcgop_discard_all_years_Gear_Grouped_States_2023-02-09.csv"))

# Merge the 2 datasets a and retain the information we need.

disc_catch_share %>%
  dplyr::select(-strata) %>%
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
  mutate(lower=ifelse(ob_ratio_boot-1.96*sd_boot_ratio<0, 0, ob_ratio_boot-1.96*sd_boot_ratio)) %>%
  mutate(fleet=recode_factor(fleet, !!!c(NTrawl="NTrawl", NOther="NOther", STrawl="STrawl", SOther="SOther"))) %>%
  ggplot(aes(x=year, y=ob_ratio_boot)) +
  geom_point(aes(color=forcats::fct_rev(fleet), shape = catch_shares), size=2.5) +
  geom_errorbar(aes(ymin=lower, ymax =ob_ratio_boot+1.96*sd_boot_ratio, color=forcats::fct_rev(fleet)), width=.2) +
  facet_wrap(~fleet)+
  #facet_wrap(~forcats::fct_rev(fleet), scales="free_y") +
  scale_shape_manual(values=c(1,19)) +
  scale_color_manual(values = c( "#F0E442","#E69F00", "#56B4E9","#009E73")) +
  labs(x = "Year", y = "Discard rate (Disc./(Disc.+Retained); %)", color="Fleet", shape="Catch shares", title = "Shortspine Thornyhead Discard Fraction (WCGOP)") + 
  coord_cartesian(ylim=c(0,1)) +
  theme_bw() +
  theme(legend.position = "right", legend.text=element_text(size=12),
        legend.title=element_text(size=14), axis.text = element_text(size=14), axis.title.x = element_text(size=14), axis.title.y = element_text(size=14))

ggsave("outputs/discard_data/SST_WCGOP_discard_rates.png", dpi=300, height=7, width=10, units='in')


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
  group_by(year, fleet) %>%
  mutate(rescale_if_required=sum(prop, na.rm=T)) %>%
  ungroup() %>%
  mutate(prop = prop / rescale_if_required) %>%
  mutate(weighed_discr = prop * ob_ratio_boot) %>%
  mutate(sd_boot_ratio = ifelse(year>=2011 & catch_shares==T & is.na(sd_boot_ratio), 0, sd_boot_ratio)) %>%
  mutate(var_boot_ratio = sd_boot_ratio^2) %>%
  mutate(weighed_var_boot_ratio = var_boot_ratio * prop^2) %>% 
  group_by(fleet, year) %>%
  mutate(varsum = sum(weighed_var_boot_ratio,na.rm=T)) %>% # Question there: which uncertainty should we consider??
  mutate(mean_sd = sqrt(varsum)) %>% 
  summarize(mean_discr=sum(weighed_discr),
            mean_sd = unique(mean_sd)) -> disc_rates_WCGOP_GEMM

disc_rates_WCGOP_GEMM %>%
  mutate(fleet=factor(fleet, levels=c("NTrawl", "NOther", "STrawl", "SOther"))) %>%
  mutate(lower=ifelse(mean_discr-1.96*mean_sd<0, 0, mean_discr-1.96*mean_sd)) %>%
  ggplot(aes(x=year, y=mean_discr)) +
  geom_point(aes(color=forcats::fct_rev(fleet)), size=2.5) +
  geom_errorbar(aes(ymin=lower, ymax=mean_discr+1.96*mean_sd, color=forcats::fct_rev(fleet)), width=.2) +
  facet_wrap(~fleet) +
  scale_color_manual(values = c( "#F0E442","#E69F00","#56B4E9","#009E73")) +
  labs(x = "Year", y = "Discard rate (Disc./(Disc.+Retained); %)", color="Fleet", shape="Catch shares", title = "Shortspine Thornyhead Discard Fraction (WCGOP)") + 
  coord_cartesian(ylim=c(0,1)) +
  theme_classic()  +
  theme(legend.position = "right", legend.text=element_text(size=12),
        legend.title=element_text(size=14), axis.text = element_text(size=14), axis.title.x = element_text(size=14), axis.title.y = element_text(size=14))


ggsave("outputs/discard_data/SST_WCGOP_GEMM_discard_rates.png", dpi=300, height=7, width=10, units='in')


###Generate figure with discard in MT for time series to compare to landings 

##!!! Don't use these, I they don't accurately reflect discards !!!##

# Observed Discards in (MT) at the same scale as landings data
disc_rates_WCGOP %>%
  ggplot(aes(x=year, y=ob_discard_mt, fill = fleet)) +
  geom_bar(stat="identity", position="stack", color = "black") +
  scale_y_continuous(expand = c(0, 0))+
  scale_fill_manual(values = c("#009E73" ,"#56B4E9","#F0E442","#E69F00"),
  breaks = c("NTrawl", "NOther", "STrawl", "SOther"), name = "Fleet")+
  labs(x = "Year", y = "Observed Discard (mt)", color="Fleet", title = "Shortspine Thornyhead Discards (WCGOP)") + 
  coord_cartesian(ylim=c(0,4500)) +
  theme_classic() +
  theme(legend.position = "right", legend.text=element_text(size=12),
        legend.title=element_text(size=14), axis.text = element_text(size=14), axis.title.x = element_text(size=14), axis.title.y = element_text(size=14))

# Observed Discards in (MT) with a different Y-axis scale 
    #NOTE that the scale is less than the GEMM data set
disc_rates_WCGOP %>%
  ggplot(aes(x=year, y=ob_discard_mt, fill = fleet)) +
  geom_col(color = "black") +
  scale_y_continuous(expand = c(0, 0))+
  scale_fill_manual(values = c("#009E73" ,"#56B4E9","#F0E442","#E69F00"),
                    breaks = c("NTrawl", "NOther", "STrawl", "SOther"), name = "Fleet")+
  labs(x = "Year", y = "Observed Discard (mt)", color="Fleet", title = "Shortspine Thornyhead Discards (WCGOP)") + 
  #coord_cartesian(ylim=c(0, 50)) +
  theme_classic() +
  theme(legend.position = "right", legend.text=element_text(size=12),
        legend.title=element_text(size=14), axis.text = element_text(size=14), axis.title.x = element_text(size=14), axis.title.y = element_text(size=14))



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

## Need to add median vertical lines!


medDisc <- disc_lencomp_WCGOP %>%
  group_by(fleet, Lenbin) %>%
  summarize(medianlength = median(N_Fish)) %>%
  group_by(fleet) %>%
  slice(which.max(medianlength))%>%
  mutate(Lenbin = Lenbin + 1)#%>%
  #mutate(fleet=factor(fleet, levels=c("NTrawl", "NOther", "STrawl", "SOther")))


disc_lencomp_WCGOP %>%
  #mutate(fleet=factor(fleet, levels=c("NTrawl", "NOther", "STrawl", "SOther"))) %>%
  mutate(meanLen = Lenbin + 1) %>% # just for plotting purpose - we center each bar on the mean value of the size bin
  ggplot(aes(x=meanLen, y=factor(Year), height = Prop.numbers, fill = forcats::fct_rev(fleet))) + 
  geom_density_ridges(stat = "identity", col = "lightgrey", alpha = 0.45, 
                      panel_scaling = TRUE, size = 0.5) +
  geom_vline(data = medDisc, aes(xintercept = Lenbin, color = fleet), size = 1, linetype = "dashed" ) +
  scale_color_manual(values = c("#56B4E9","#009E73","#F0E442","#E69F00"))+ #Lines 
  scale_fill_manual(values = c("#E69F00", "#F0E442", "#009E73","#56B4E9")) + #Shapes 
  theme_light() +
  labs(x = "Length (cm)", y = NULL, fill = "Fleet", title = "Shortspine Thornyhead Discard Length Compositions (WCGOP)") + 
  theme(legend.position = "right", legend.text=element_text(size=12),
        legend.title=element_text(size=14), axis.text = element_text(size=14), axis.title.x = element_text(size=14))+
  guides(color = "none", fill = guide_legend())
  
ggsave("outputs/discard_data/SST_WCGOP_discard_lencomps_med.png", dpi=300, height=10, width=7, units='in')


#No Median Lines 

disc_lencomp_WCGOP %>%
  #mutate(fleet=factor(fleet, levels=c("NTrawl", "NOther", "STrawl", "SOther"))) %>%
  mutate(meanLen = Lenbin + 1) %>% # just for plotting purpose - we center each bar on the mean value of the size bin
  ggplot(aes(x=meanLen, y=factor(Year), height = Prop.numbers, fill = forcats::fct_rev(fleet))) + 
  geom_density_ridges(stat = "identity", col = "lightgrey", alpha = 0.45, 
                      panel_scaling = TRUE, size = 0.5) +
  scale_fill_manual(values = c("#E69F00", "#F0E442", "#009E73","#56B4E9")) + #Shapes 
  theme_light() +
  labs(x = "Length (cm)", y = NULL, fill = "Fleet", title = "Shortspine Thornyhead Discard Length Compositions (WCGOP)") + 
  theme(legend.position = "right", legend.text=element_text(size=12),
        legend.title=element_text(size=14), axis.text = element_text(size=14), axis.title.x = element_text(size=14))
  
ggsave("outputs/discard_data/SST_WCGOP_discard_lencomps.png", dpi=300, height=10, width=7, units='in')


#########Histogram of length comps for discards 


##Need to add median vertical lines!

disc_lencomp_WCGOP %>%
  mutate(fleet=factor(fleet, levels=c("NTrawl", "NOther", "STrawl", "SOther"))) %>%
  mutate(meanLen = Lenbin + 1) %>% # just for plotting purpose - we center each bar on the mean value of the size bin
  group_by(meanLen, fleet) %>%
  summarize(Nfish = sum(N_Fish))%>%
  ggplot(aes(x = meanLen, y = Nfish, fill = forcats::fct_rev(fleet), color = forcats::fct_rev(fleet))) +
  geom_col(position = "identity", alpha = 0.5) +
  scale_fill_manual(values = c("#009E73" ,"#56B4E9","#F0E442","#E69F00"),
                    breaks = c("NTrawl", "NOther", "STrawl", "SOther"), name = "Fleet")+
  scale_color_manual(values = c("#009E73" ,"#56B4E9","#F0E442","#E69F00"),
                     breaks = c("NTrawl", "NOther", "STrawl", "SOther"), name = "Fleet")+
  xlab("Length (cm)") + ylab("Number of fish") +
  facet_wrap(~fleet, nrow =1) + 
  theme_classic()+
  labs(x = "Length (cm)", y = "Number of fish", fill = "Fleet", title = "Shortspine Thornyhead Discard Length Compositions")

#write.csv(disc_lencomp_WCGOP, "outputs/fishery_data/discard_lengths.csv")

#Output disc_lencomp for a combo plot 

write.csv(disc_lencomp_WCGOP, "outputs/discard_data/disc_lencomp.csv")


# write.csv(, "outputs/discard_data/*******.csv")

### 3. Fleet-specific discard average weight

# Discarded individuals are sampled on-board and measured. We will use this information to fit different selectivity curves in SS3

disc_weight <- read_excel(paste0(processed_discards_path, "/SSPN_WCGOP_WAOR-CA_Trawl-NonTrawl.xlsx"),
                          sheet = "Average Weight")

# /!\ Late update - A. Rovellini just got the information from Andi Stephens that the weights from the WCGOP are actually in
#pounds. It seems that the previous assessment was wrong and considered that this weight was in kg. This probably led to the 
#underestimation of the average weight of discards observed after fitting the model in  2013.
disc_weight %>%
  mutate(AVG_WEIGHT.Mean=AVG_WEIGHT.Mean*0.453592,
         AVG_WEIGHT.SD=AVG_WEIGHT.SD*0.453592) ->  disc_weight

plotylim <- c(0,3)

disc_weight %>%
  mutate(lower=ifelse(AVG_WEIGHT.Mean-1.96*AVG_WEIGHT.SD<0, 0, AVG_WEIGHT.Mean-1.96*AVG_WEIGHT.SD)) %>%
  mutate(area_lg = ifelse(State == "CA", "S", "N"),
         Gear = ifelse(Gear == "NonTRAWL", "Other", "Trawl")) %>%
  mutate(fleet = paste0(area_lg, Gear)) %>%
  mutate(maxall=max(AVG_WEIGHT.Mean+1.96*AVG_WEIGHT.SD)) %>%
  mutate(lowb = lower,
         highb = AVG_WEIGHT.Mean+1.96*AVG_WEIGHT.SD) %>%
  mutate(fleet=factor(fleet, levels=c("NTrawl", "NOther", "STrawl", "SOther"))) %>%
  ggplot(aes(x=Year, y=AVG_WEIGHT.Mean,  color = forcats::fct_rev(fleet))) + 
  geom_point(size=2.5) +
  geom_errorbar(aes(ymin=lowb,ymax=highb, width=.2) )+
  coord_cartesian(ylim=plotylim) +
  geom_hline(yintercept=0, color="grey") + # this just overlays the lower uncertainty bound of the error bar to highlight that they are truncated <0
  scale_color_manual(values = c( "#F0E442","#E69F00", "#56B4E9","#009E73")) +
  labs(x = "Year", y = "Weight (kg)", color="Fleet", title = "Shortspine Thornyhead Observed Average Weight (kg, WCGOP)") + 
  theme_bw() +
  theme(legend.position = "right", legend.text=element_text(size=12),
        legend.title=element_text(size=14), axis.text = element_text(size=14), axis.title.x = element_text(size=14), axis.title.y = element_text(size=14)) +
  facet_wrap(~fleet)

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

### 1. Discard rates 

# The Pikitch dataset will provide discard rates estimates and length composition for the 1980s

# The discard data is available for both groundfish and shrimp gears, in separate files. For each fleet, the mean rates and standard deviation
#are estimated at different levels of aggreagation of fishing areas
#

disc_rates_Pik_trawl <- get(load(paste0(processed_discards_path, "/Pikitch.et.al.SSPN.Discard.Rates 19 Mar 2023.RData")))

dodge <- position_dodge(width=0.45) 

disc_rates_Pik_trawl %>%
  filter(Areas %in% c("3B 3S","3A","2C","2B", "2B 2C 3A 3B 3S")) %>%
  mutate(lowbound=ifelse(DiscardRate.Sp.Wt.Wgting-1.96*SD.DiscardRate.Sp.Wt.Wgting>=0, DiscardRate.Sp.Wt.Wgting-1.96*SD.DiscardRate.Sp.Wt.Wgting, 0),
         highbound=DiscardRate.Sp.Wt.Wgting+1.96*SD.DiscardRate.Sp.Wt.Wgting) -> disc_rates_Pik_trawl_forplot

disc_rates_Pik_trawl_forplot %>%
  filter(Areas %in% c("3B 3S","3A","2C", "2B")) %>%
  ggplot(aes(x=factor(Year), y=DiscardRate.Sp.Wt.Wgting)) +
  geom_point(size=2.2, aes(color=Areas), position=dodge, alpha=0.15) +
  geom_errorbar(aes(ymin=lowbound,
                  ymax=highbound, color=Areas), position=dodge, alpha=0.15, width=.3, size=0.8) +
  scale_colour_manual(values=c("#009E73","#009E05","#56B4E9", "#90B4E1")) +
  scale_fill_manual(values=c("#009E73","#009E05","#56B4E9", "#90B4E1")) +
  geom_point(data=filter(disc_rates_Pik_trawl_forplot, Areas=="2B 2C 3A 3B 3S"), aes(x=factor(Year), y=DiscardRate.Sp.Wt.Wgting), color="#56B4E9", size=3)+#, position=dodge) +
  geom_errorbar(data=filter(disc_rates_Pik_trawl_forplot, Areas=="2B 2C 3A 3B 3S"), aes(ymin=lowbound,
                    ymax=highbound), position=dodge, color="#56B4E9",width=.1, size=1) +
  labs(x="Year", y="Discard rate (disc./(disc.+retained); %)", title="Discard Rates of North Trawl (Groundfish) - Pikitch et al.") +
  geom_hline(yintercept=0, color="grey70", size=1) +
  theme_bw()

ggsave("outputs/discard_data/SST_Pikitch_discard_rates.png", dpi=300, height=7, width=10, units='in')


disc_rates_Pik_shrimp <- get(load(paste0(processed_discards_path, "/Pikitch.et.al.SSPN.Discard.Rates.SHR 22 Mar 2023.RData")))

disc_rates_Pik_shrimp %>%
  mutate(lowbound=ifelse(DiscardRate.Sp.Wt.Wgting-1.96*SD.DiscardRate.Sp.Wt.Wgting>=0, DiscardRate.Sp.Wt.Wgting-1.96*SD.DiscardRate.Sp.Wt.Wgting, 0),
         highbound=DiscardRate.Sp.Wt.Wgting+1.96*SD.DiscardRate.Sp.Wt.Wgting) %>%
  ggplot(aes(x=factor(Year), y=DiscardRate.Sp.Wt.Wgting)) +
  geom_point(size=2.2, position=dodge, color="black") +
  geom_errorbar(aes(ymin=lowbound,
                    ymax=highbound), position=dodge, width=.3, size=0.5, color="black") +
  labs(x="Year", y="Discard rate (disc./(disc.+retained); %)", title="Discard Rates of Northern Shrimp Trawls - Pikitch et al.") +
  geom_hline(yintercept=0, color="grey50", size=1) +
  theme_bw()


### Should we integrate Shrimp discards in our estimates?

### 2. Length composition

# Length data is available from Pikitch data. 2 tables are provided. On is sex-resolved, on is unsexed.

#len_comp_sex <- get(load(paste0(processed_discards_path, "/Pikitch.et.al.SSPN.Lengths.wt.PacFIN.assm 21 Mar 2023.RData")))

len_comp <- get(load(paste0(processed_discards_path, "/Pikitch.et.al.SSPN.Lengths.wt.PacFIN.assm.No.Sex 21 Mar 2023.RData")))

len_comp %>%
  filter(Disposition=="Discarded") %>%
  filter(Areas=="3A 3S_&_3B 2C 2B") %>%
  pivot_longer("L.6":"L.72", names_to="sizebin", values_to="Prop.numbers") %>%
  mutate(meanLen=as.numeric(gsub("L.","",sizebin))+1) %>%
  ggplot(aes(x=meanLen, y=factor(Year), height = Prop.numbers, fill="NTrawl")) + 
  geom_density_ridges(stat = "identity", col = "lightgrey", alpha = 0.45, 
                      panel_scaling = TRUE, size = 0.5) +
  scale_fill_manual(values = c( "#56B4E9")) +
  theme_light() +
  labs(x = "Length (cm)", y = NULL, fill = "Fleet", title = "Shortspine Thornyhead Discard Length Compositions - Pikitch et al.") + 
  theme(legend.position = "top") 

# Note that the patterns are very similar across years but the data is actually different 
ggsave("outputs/discard_data/SST_Pikitch_discard_lencomps.png", dpi=300, height=7, width=10, units='in')


### Formatting for SS -------

#Discard Rates 
#_Yr	Seas	Flt	Discard	Std_in

#Four Fleets -----
  #NTrawl = 1, STrawl = 2, NOther = 3, SOther = 4

#WCGOP 
WCGOP_rates <- disc_rates_WCGOP_GEMM %>%
  dplyr::mutate(Seas = 1) %>%
  dplyr::mutate(fleet=case_when(fleet == "NTrawl" ~ 1,
                    fleet == "STrawl" ~ 2,
                    fleet == "NOther" ~ 3,
                    fleet == "SOther" ~ 4)) %>%
  select(year, Seas, fleet, mean_discr, mean_sd) %>%
  rename(Yr = year, Seas = Seas, Flt = fleet, Discard = mean_discr, Std_in = mean_sd) %>%
  dplyr::mutate(Std_in = Std_in / Discard) %>% #convert to CV
  dplyr::mutate(Std_in = ifelse(Std_in == 0, 0.001, Std_in)) %>%
  arrange(Flt)

#the mean_SD was much smaller than the previous SS data file, and in the manual the uncertainty is 
#specified as the CV. However, I'm not sure how to deal with uncertainty in the terminal years. 
### PY's answer it seems that the previous assessment was wrong and calculated discar/landings ratio intead of disc/(tot catch). So our ratio makes sense.
  
#EDCP 
EDCP_rates <- tibble(Yr = c(1995, 1996, 1997, 1998, 1999),
  Seas = c(1, 1, 1, 1, 1),
  Flt = c(1, 1, 1, 1, 1),
  Discard = c(0.132, 0.155, 0.201, 0.136, 0.252),
  Std_in = c(0.4, 0.2, 0.21, 0.22, 0.3)) #I used the same data from the original data file here  ### PY's reply: Great!!

#Pikitch
Pikitch_rates <- disc_rates_Pik_trawl_forplot %>%
  filter(Areas == "2B 2C 3A 3B 3S") %>%
  #group_by(Year) %>%
  #summarize(Discard = mean(DiscardRate.Sp.Wt.Wgting),
  #          Std_in = sd(DiscardRate.Sp.Wt.Wgting)) %>% # THIS IS VERY DIFFERENT FROM SS DATA FILE
  dplyr::mutate(Discard = DiscardRate.Sp.Wt.Wgting,
                Std_in = SD.DiscardRate.Sp.Wt.Wgting) %>% 
  dplyr::mutate(Seas = 1) %>%
  dplyr::mutate(fleet = 1) %>%
  select(Year, Seas, fleet, Discard, Std_in) %>%
  rename(Yr = Year, Seas = Seas, Flt = fleet, Discard = Discard, Std_in = Std_in) %>%
  dplyr::mutate(Std_in = Std_in/Discard) #convert to CV, STILL LOW compared to Original SS dat file ### PY's reply: should be ok now!!
  

discardRates_ss_allFleets <- bind_rows(Pikitch_rates, EDCP_rates, WCGOP_rates) %>%
  write.csv(  # Save to ss directory
  file.path(here::here(), "data", "for_ss", "discardRates_4Fleets.csv"))


#Three Fleets -----
  #NTrawl = 1, STrawl = 2, Other = 3
#WCGOP 
#Rates 

WCGOP_rates_3 <- WCGOP_rates %>%
  dplyr::mutate(Flt = ifelse(Flt %in% c(3, 4), 3, Flt)) %>%
  group_by(Flt, Yr, Seas) %>%
  summarise(
    Discard=sum(Discard),
    Std_in=mean(Std_in)) %>% #Is this correct with cvs? 
  select(Yr, Seas, Flt, Discard, Std_in)

discardRates_ss_ThreeFleets <- bind_rows(Pikitch_rates, EDCP_rates, WCGOP_rates_3) %>%
    write.csv(  # Save to ss directory
    file.path(here::here(), "data", "for_ss", "discardRates_3Fleets.csv"))

#Length Comps (PLEASE CHECK MY WORK HERE)

#Four Fleets 

#WCGOP
disc_lencomp_WCGOP

#write.csv(disc_lencomp_WCGOP, file.path(here::here(), "data", "fishery_processed", "discards", "LengthComp_test.csv"))
#I was struggling with getting length comps formatted correctly and did it in excel for timing reasons

lencomp_WCGOP_1 <- disc_lencomp_WCGOP %>%
  dplyr::mutate(fleet=case_when(fleet == "NTrawl" ~ 1,
                                fleet == "STrawl" ~ 2,
                                fleet == "NOther" ~ 3,
                                fleet == "SOther" ~ 4)) %>%
    pivot_wider(
    names_from = "Lenbin",
    values_from = "Prop.numbers",
    values_fill = 0,
    names_prefix = "f"
  ) %>%
  select(Year, fleet, starts_with("f")) %>%
  group_by(fleet, Year) %>%
  summarise(across(starts_with("f"), sum))


Nsamp <- disc_lencomp_WCGOP%>%
  dplyr::mutate(fleet=case_when(fleet == "NTrawl" ~ 1,
                                fleet == "STrawl" ~ 2,
                                fleet == "NOther" ~ 3,
                                fleet == "SOther" ~ 4))%>%
  group_by(Year, fleet)%>%
  summarize(Nsamp = sum(N_Fish)) %>%
  mutate(Nsamp=Nsamp^0.6) #PLEASE DOUBLE CHECK THIS I'M UNSURE IF THIS IS CORRECT 
  
  
Lencomp_WCGOP_allFleets_1 <- left_join(lencomp_WCGOP_1, Nsamp, by = c("Year", "fleet"))

Lencomp_WCGOP_allFleets <- Lencomp_WCGOP_allFleets_1%>%
  dplyr::mutate(Seas = 1) %>%
  dplyr::mutate(Gender = 0) %>%
  dplyr::mutate(Part = 1) %>%
  select(Year, Seas, fleet, Gender, Part, Nsamp, starts_with("f"))%>%
  dplyr::rename(Yr=Year, Seas=Seas, Flt=fleet, Gender=Gender, Part=Part, Nsamp=Nsamp)%>%
  dplyr::mutate(m6 = 0, m8 = 0, m10 = 0, m12 = 0, m14 = 0, m16 = 0,
         m18 = 0, m20 = 0, m22 = 0, m24 = 0, m26 = 0, m28 = 0,
         m30 = 0, m32 = 0, m34 = 0, m36 = 0, m38 = 0, m40 = 0,
         m42 = 0, m44 = 0, m46 = 0, m48 = 0, m50 = 0, m52 = 0,
         m54 = 0, m56 = 0, m58 = 0, m60 = 0, m62 = 0, m64 = 0,
         m66 = 0, m68 = 0, m70 = 0, m72 = 0) #I know this is clunky but we got there 


#Pikitch 

Lencomp_Pikitch_1<-len_comp %>%
  select(Year, Num.Study.Lengths, starts_with("L"))%>%
  dplyr::mutate(Seas = 1) %>%
  dplyr::mutate(Gender = 0) %>%
  dplyr::mutate(Part = 1) %>%
  dplyr::mutate(fleet = 1) %>%
  rename_at(vars(paste0("L.", seq(from = 6, to = 72, by = 2))), 
            ~paste0("f", seq(from = 6, to = 72, by = 2)))%>%
  select(Year, Seas, fleet, Gender, Part, Num.Study.Lengths, starts_with("f"))%>%
  dplyr::rename(Yr=Year, Seas=Seas, Flt=fleet, Gender=Gender, Part=Part, Nsamp=Num.Study.Lengths)%>%
  dplyr::mutate(m6 = 0, m8 = 0, m10 = 0, m12 = 0, m14 = 0, m16 = 0,
                m18 = 0, m20 = 0, m22 = 0, m24 = 0, m26 = 0, m28 = 0,
                m30 = 0, m32 = 0, m34 = 0, m36 = 0, m38 = 0, m40 = 0,
                m42 = 0, m44 = 0, m46 = 0, m48 = 0, m50 = 0, m52 = 0,
                m54 = 0, m56 = 0, m58 = 0, m60 = 0, m62 = 0, m64 = 0,
                m66 = 0, m68 = 0, m70 = 0, m72 = 0) %>%
  group_by(Yr) %>%
  summarize(across(starts_with("f"), mean, na.rm = TRUE))


#THESE SAMPLE SIZES ARE MUCH LARGER THAN THE ORIGINAL DATA AND I'M NOT SURE IF THEY'RE CORRECT
Nsamp_Pik<-len_comp%>% 
  group_by(Year)%>% 
  dplyr::rename(Yr=Year)%>%
  summarize(Nsamp = sum(Num.Study.Lengths)) %>%
  mutate(Nsamp = Nsamp^0.6)#DOUBLE CHECK THIS 

Lencomp_Pikitch_2<-left_join(Lencomp_Pikitch_1,Nsamp_Pik, by = "Yr" )

Lencomp_Pikitch<-Lencomp_Pikitch_2 %>%
  
  dplyr::mutate(Seas = 1) %>%
  dplyr::mutate(Gender = 0) %>%
  dplyr::mutate(Part = 1) %>%
  dplyr::mutate(m6 = 0, m8 = 0, m10 = 0, m12 = 0, m14 = 0, m16 = 0,
                m18 = 0, m20 = 0, m22 = 0, m24 = 0, m26 = 0, m28 = 0,
                m30 = 0, m32 = 0, m34 = 0, m36 = 0, m38 = 0, m40 = 0,
                m42 = 0, m44 = 0, m46 = 0, m48 = 0, m50 = 0, m52 = 0,
                m54 = 0, m56 = 0, m58 = 0, m60 = 0, m62 = 0, m64 = 0,
                m66 = 0, m68 = 0, m70 = 0, m72 = 0) %>%
  select(Yr, Seas, Flt, Gender, Part, Nsamp, starts_with("f"),starts_with("m") )

#Final for all fleets 

DiscLencomp_allFleets<-bind_rows(Lencomp_Pikitch,Lencomp_WCGOP_allFleets)%>%
  write.csv(  # Save to ss directory
    file.path(here::here(), "data", "for_ss", "discardLenComp_ss_4Fleets.csv"))


#ThreeFleets
    
Lencomp_WCGOP_ThreeFleets_1<-disc_lencomp_WCGOP%>%
  dplyr::mutate(fleet=case_when(fleet == "NTrawl" ~ 1,
                                fleet == "STrawl" ~ 2,
                                fleet == "NOther" ~ 3,
                                fleet == "SOther" ~ 3))%>%
  pivot_wider(
    names_from = "Lenbin",
    values_from = "Prop.numbers",
    values_fill = 0,
    names_prefix = "f"
  ) %>%
  select(Year, fleet, starts_with("f")) %>%
  group_by(fleet, Year) %>%
  summarise(across(starts_with("f"), sum))


Nsamp_ThreeFleets<-disc_lencomp_WCGOP%>%
  dplyr::mutate(fleet=case_when(fleet == "NTrawl" ~ 1,
                                fleet == "STrawl" ~ 2,
                                fleet == "NOther" ~ 3,
                                fleet == "SOther" ~ 3))%>%
  group_by(Year, fleet)%>%
  summarize(Nsamp = sum(N_Fish)) %>%
  mutate(Nsamp = Nsamp^0.6) #Same here, please check 


Lencomp_WCGOP_ThreeFleets_2 <- left_join(Lencomp_WCGOP_ThreeFleets_1, Nsamp, by = c("Year", "fleet"))

Lencomp_WCGOP_ThreeFleets <- Lencomp_WCGOP_ThreeFleets_2%>%
  dplyr::mutate(Seas = 1) %>%
  dplyr::mutate(Gender = 0) %>%
  dplyr::mutate(Part = 1) %>%
  select(Year, Seas, fleet, Gender, Part, Nsamp, starts_with("f"))%>%
  dplyr::rename(Yr=Year, Seas=Seas, Flt=fleet, Gender=Gender, Part=Part, Nsamp=Nsamp)%>%
  dplyr::mutate(m6 = 0, m8 = 0, m10 = 0, m12 = 0, m14 = 0, m16 = 0,
                m18 = 0, m20 = 0, m22 = 0, m24 = 0, m26 = 0, m28 = 0,
                m30 = 0, m32 = 0, m34 = 0, m36 = 0, m38 = 0, m40 = 0,
                m42 = 0, m44 = 0, m46 = 0, m48 = 0, m50 = 0, m52 = 0,
                m54 = 0, m56 = 0, m58 = 0, m60 = 0, m62 = 0, m64 = 0,
                m66 = 0, m68 = 0, m70 = 0, m72 = 0) #I know this is clunky but we got there 

DiscLencomp_ThreeFleets<-bind_rows(Lencomp_Pikitch,Lencomp_WCGOP_ThreeFleets)%>%
  write.csv(  # Save to ss directory
    file.path(here::here(), "data", "for_ss", "discardLenComp_ss_3Fleets.csv"))

## Same deal, please check the Nsamp values, I'm not sure I've got them correct. 

#Weights -----

#Ensure units are correct by re-reading in data and converting (Redundant but I've been testing a lot)

disc_weight <- read_excel(paste0(processed_discards_path, "/SSPN_WCGOP_WAOR-CA_Trawl-NonTrawl.xlsx"),
                          sheet = "Average Weight")
#Convert to correct Units 
disc_weight %>%
  dplyr::mutate(AVG_WEIGHT.Mean=AVG_WEIGHT.Mean*0.453592,
         AVG_WEIGHT.SD=AVG_WEIGHT.SD*0.453592) ->  disc_weight


#_Year	Seas	Fleet	Partition	Type	Value	Std_in 
#Value is mean body weight and cv

#Four Fleets 

MeanWeights_allfleets <- disc_weight %>%
  dplyr::mutate(area_lg = ifelse(State == "CA", "S", "N"),
         Gear = ifelse(Gear == "NonTRAWL", "Other", "Trawl")) %>%
  dplyr::mutate(fleet = paste0(area_lg, Gear)) %>%
  dplyr::mutate(fleet=factor(fleet, levels=c("NTrawl", "NOther", "STrawl", "SOther"))) %>%
  dplyr::mutate(fleet=case_when(fleet == "NTrawl" ~ 1,
                                fleet == "STrawl" ~ 2,
                                fleet == "NOther" ~ 3,
                                fleet == "SOther" ~ 4))%>%
  group_by(Year,fleet) %>%
  summarise(mean_weight = mean(AVG_WEIGHT.Mean),
            CV = mean(AVG_WEIGHT.SD / AVG_WEIGHT.Mean)) %>%
  dplyr::mutate(Seas = 1) %>%
  dplyr::mutate(Partition = 1) %>%
  dplyr::mutate(Type = 2) %>%
  select(Year, Seas, fleet, Partition, Type, mean_weight, CV) %>%
  rename(Year=Year, Seas=Seas, Fleet=fleet, Partition=Partition, 
         Type=Type, Value=mean_weight, Std_in=CV)%>%
  arrange(Fleet)%>%
  ungroup()%>%
  write.csv(  # Save to ss directory
    file.path(here::here(), "data", "for_ss", "discardWeights_ss_4Fleets.csv"))

#Three Fleets 

MeanWeights_ThreeFleets <- disc_weight %>%
  dplyr::mutate(area_lg = ifelse(State == "CA", "S", "N"),
                Gear = ifelse(Gear == "NonTRAWL", "Other", "Trawl")) %>%
  dplyr::mutate(fleet = paste0(area_lg, Gear)) %>%
  dplyr::mutate(fleet = ifelse(fleet == "NOther" | fleet == "SOther", "Other", fleet)) %>%
  dplyr::mutate(fleet = factor(fleet, levels=c("NTrawl", "STrawl", "Other"))) %>%
  dplyr::mutate(fleet=case_when(fleet == "NTrawl" ~ 1,
                                fleet == "STrawl" ~ 2,
                                fleet == "Other" ~ 3)) %>%
  group_by(Year,fleet) %>%
  summarise(mean_weight = mean(AVG_WEIGHT.Mean),
            CV = mean(AVG_WEIGHT.SD / AVG_WEIGHT.Mean)) %>%
  dplyr::mutate(Seas = 1) %>%
  dplyr::mutate(Partition = 1) %>%
  dplyr::mutate(Type = 2) %>%
  select(Year, Seas, fleet, Partition, Type, mean_weight, CV) %>%
  rename(Year=Year, Seas=Seas, Fleet=fleet, Partition=Partition, 
         Type=Type, Value=mean_weight, Std_in=CV)%>%
  arrange(Fleet)%>%
  ungroup()%>%
  write.csv(  # Save to ss directory
    file.path(here::here(), "data", "for_ss", "discardWeights_ss_3Fleets.csv"))

