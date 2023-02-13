library(ggplot2)
library(PacFIN.Utilities)
library(nwfscSurvey)
library(reshape2)

####--------------------------------------------------------------------#
####-----------------	Discard rates observations -----------------------
####--------------------------------------------------------------------#

dics_catch_share <- read.csv(paste0(processed_discards_path, "/shortspine_thornyhead_cs_wcgop_discard_all_years_Gear_Grouped_States_2023-02-09.csv"))
dics_no_catch_share <- read.csv(paste0(processed_discards_path, "/shortspine_thornyhead_ncs_wcgop_discard_all_years_Gear_Grouped_States_2023-02-09.csv"))

##### Observed discard rates

dics_catch_share %>%
  mutate(median_boot_discard_mt = NA,
         sd_boot_discard_mt = NA,
         median_boot_ratio = NA,
         sd_boot_ratio = NA,
         n_bootstrap =NA) %>%
  relocate(colnames(dics_no_catch_share)) %>%
  bind_rows(dics_no_catch_share) %>%
  mutate(area_lg=ifelse(area == "CA", "S", "N"),
         gear=ifelse(gear == "FixedGears", "NonTrawl", gear)) %>%
  mutate(fleet=paste(gear, area_lg, sep="_")) %>%
  mutate(ob_ratio_boot = ifelse(!is.na(median_boot_ratio), median_boot_ratio, ob_ratio)) %>%
  ggplot(aes(x=year, y=ob_ratio_boot)) +
  geom_point(aes(color=catch_shares)) +
  geom_errorbar(aes(ymin=ob_ratio_boot-2.16*sd_boot_ratio, ymax=ob_ratio_boot+2.16*sd_boot_ratio, color=catch_shares), width=.2) +
  facet_wrap(~fleet, scales="free_y") +
  ylab("Observed discard fraction") +
  ylim(c(0,1)) +
  theme_bw()

# !! In order to expand the discard rates, we need to access the relative % of "catch shares" vs "no catch shares" in the total SST catch (or landings)
  
##### Length distribution of discards 

####--------------------------------------------------------------------#
####-----------------	Discard rates observations -----------------------
####--------------------------------------------------------------------#












