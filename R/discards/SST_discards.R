library(ggplot2)
library(PacFIN.Utilities)
library(nwfscSurvey)
library(reshape2)
library(readxl)
library(ggridges)

####--------------------------------------------------------------------#
####-----------------	Discard rates observations -----------------------
####--------------------------------------------------------------------#

disc_catch_share <- read.csv(paste0(processed_discards_path, "/shortspine_thornyhead_cs_wcgop_discard_all_years_Gear_Grouped_States_2023-02-09.csv"))
disc_no_catch_share <- read.csv(paste0(processed_discards_path, "/shortspine_thornyhead_ncs_wcgop_discard_all_years_Gear_Grouped_States_2023-02-09.csv"))

##### Observed discard rates

disc_catch_share %>%
  mutate(median_boot_discard_mt = NA,
         sd_boot_discard_mt = NA,
         median_boot_ratio = NA,
         sd_boot_ratio = NA,
         n_bootstrap =NA) %>%
  relocate(colnames(disc_no_catch_share)) %>%
  bind_rows(disc_no_catch_share) %>%
  mutate(area_lg=ifelse(area == "CA", "S", "N"),
         gear=ifelse(gear == "FixedGears", "NonTrawl", gear)) %>%
  mutate(fleet=paste(gear, area_lg, sep="_")) %>%
  mutate(ob_ratio_boot = ifelse(!is.na(median_boot_ratio), median_boot_ratio, ob_ratio)) %>%
  ggplot(aes(x=year, y=ob_ratio_boot)) +
  geom_point(aes(color=catch_shares), size=2.5) +
  geom_errorbar(aes(ymin=ob_ratio_boot-2.16*sd_boot_ratio, ymax=ob_ratio_boot+2.16*sd_boot_ratio, color=catch_shares), width=.2) +
  facet_wrap(~fleet, scales="free_y") +
  scale_color_manual(values=c("black", "grey")) +
  ylab("Shortspine thornyhead observed discard fraction (WCGOP)") +
  coord_cartesian(ylim=c(0,1)) +
  theme_bw() +
  theme(legend.position = "top")

# !! In order to expand the discard rates, we need to access the relative % of "catch shares" vs "no catch shares" in the total SST catch (or landings)
  
##### Length distribution of discards 

####--------------------------------------------------------------------#
####-----------------	Discard length  compo -----------------------
####--------------------------------------------------------------------#

disc_length <- read_excel(paste0(processed_discards_path, "/SSPN_WCGOP_WAOR-CA_Trawl-NonTrawl.xlsx"),
                               sheet = "Length Frequency")

disc_length %>%
  mutate(area_lg = ifelse(State == "CA", "S", "N"),
         Gear = ifelse(Gear == "NonTRAWL", "NonTrawl", "Trawl")) %>%
  mutate(fleet = paste(Gear, area_lg, sep="_")) %>%
  mutate(meanLen = Lenbin + 1) %>% 
  ggplot(aes(x=meanLen, y=factor(Year), height = Prop.numbers, fill = fleet)) + 
  geom_density_ridges(stat = "identity", col = "lightgrey", alpha = 0.45, 
                      panel_scaling = TRUE, size = 0.5) +
  ggthemes::scale_fill_colorblind() +
  theme_light() +
  labs(x = "Length (cm)", y = NULL, fill = NULL, title = "Shortspine thornyhead discard length compositions") + 
  theme(legend.position = "top") +
  facet_wrap(~fleet, ncol=4)
  
####--------------------------------------------------------------------#
####-----------------	Discard laverage weight -----------------------
####--------------------------------------------------------------------#

disc_weight <- read_excel(paste0(processed_discards_path, "/SSPN_WCGOP_WAOR-CA_Trawl-NonTrawl.xlsx"),
                          sheet = "Average Weight")

plotylim <- c(0,6)

disc_weight%>%
  mutate(area_lg = ifelse(State == "CA", "S", "N"),
         Gear = ifelse(Gear == "NonTRAWL", "NonTrawl", "Trawl")) %>%
  mutate(fleet = paste(Gear, area_lg, sep="_")) %>%
  mutate(maxall=max(AVG_WEIGHT.Mean+2.16*AVG_WEIGHT.SD)) %>%
  mutate(lowb = AVG_WEIGHT.Mean-2.16*AVG_WEIGHT.SD,
         highb = AVG_WEIGHT.Mean+2.16*AVG_WEIGHT.SD) %>%
  ggplot(aes(x=Year, y=AVG_WEIGHT.Mean,  color = fleet)) + 
  geom_point(size=2.5) +
  geom_errorbar(aes(ymin=lowb,ymax=highb, width=.2) )+
  ylab("Shortspine thornyhead observed average weight (kg, WCGOP)") +
  coord_cartesian(ylim=plotylim) +
  ggthemes::scale_color_colorblind() +
  theme_bw() +
  theme(legend.position = "top") +
  facet_wrap(~fleet)

  
