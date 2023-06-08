
library(tidyverse)
library(ggthemes)

# take black out of colorblind theme
scale_fill_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_fill_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

scale_color_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_color_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

load('data/for_ss/SST_SS_2023_Data_Parameters.Rdata')

dat <- SS_Param2023
rm(SS_Param2023)
names(dat)

fleetnames <- data.frame(fleet = 1:6,
                         fleetname = c('North Trawl', 'South Trawl', 'Non-Trawl', 
                                       'Early Triennial', 'Late Triennial', 'WCBTS'))
                           
names(dat$Fishery_LengthComp$data)
names(dat$Survey_LengthComp$data)

fsh <- dat$Fishery_LengthComp$data$ThreeFleets_NoSlope_SplitTriennial
srv <- dat$Survey_LengthComp$data$ThreeFleets_NoSlope_SplitTriennial

fshclean <- fsh %>% 
  select(c(1, 3:40)) %>% 
  left_join(fleetnames) %>% 
  mutate(fleet = fleetname,
         partition = ifelse(partition == 1, 'Discarded', 'Landed')) %>% 
  select(-fleetname) %>%
  mutate_at(6:39, ~.*Nsamp) %>% 
  pivot_longer(cols = 6:39, names_to = 'length', values_to = 'n') %>% 
  select(-Nsamp) %>% 
  mutate(sex = 'Combined',
         length = gsub(pattern = "f", replacement = "", x = length))
  
srv_unsexed <- srv %>% 
  filter(sex == 0) %>% 
  select(c(1, 3:40)) %>% 
  left_join(fleetnames) %>% 
  mutate(fleet = fleetname,
         partition = 'Landed') %>% 
  select(-fleetname) %>%
  mutate_at(6:39, ~.*Nsamp) %>% 
  pivot_longer(cols = 6:39, names_to = 'length', values_to = 'n') %>% 
  select(-Nsamp) %>% 
  mutate(sex = 'Combined',
         length = gsub(pattern = "f", replacement = "", x = length))

srv_female <- srv %>% 
  filter(sex == 3) %>% 
  select(c(1, 3:40)) %>% 
  left_join(fleetnames) %>% 
  mutate(fleet = fleetname,
         partition = 'Landed') %>% 
  select(-fleetname) %>%
  mutate_at(6:39, ~.*Nsamp) %>% 
  pivot_longer(cols = 6:39, names_to = 'length', values_to = 'n') %>% 
  select(-Nsamp) %>% 
  mutate(sex = 'Female',
         length = gsub(pattern = "f", replacement = "", x = length))

srv_male <- srv %>% 
  filter(sex == 3) %>%
  select(c(1, 3:6, 41:74)) %>%
  left_join(fleetnames) %>% 
  mutate(fleet = fleetname,
         partition = 'Landed') %>% 
  select(-fleetname) %>% 
  mutate_at(6:39, ~.*Nsamp) %>% 
  pivot_longer(cols = 6:39, names_to = 'length', values_to = 'n') %>% 
  select(-Nsamp) %>% 
  mutate(sex = 'Male',
         length = gsub(pattern = "m", replacement = "", x = length))

full <- bind_rows(fshclean, srv_unsexed, srv_female, srv_male) %>% 
  mutate(fleet = factor(fleet, levels = c('North Trawl', 'South Trawl', 'Non-Trawl', 
                                          'Early Triennial', 'Late Triennial', 'WCBTS'),
                        ordered = TRUE))

agg <- full %>% 
  group_by(fleet, sex, partition, length) %>% 
  summarize(n = sum(n)) %>% 
  group_by(fleet, sex, partition) %>% 
  mutate(N = sum(n)) %>% 
  ungroup() %>% 
  mutate(p = n / N,
         label = ifelse(fleet %in% c('North Trawl', 'South Trawl', 'Non-Trawl'), partition, sex),
         length = as.numeric(length))

unique(agg$label)
agg <- agg %>% 
  mutate(label = case_when(label == 'Landed' ~ 'Fishery Landings',
                           label == 'Discarded' ~ 'Fishery Discards',
                           label == 'Combined' ~ 'Survey: unsexed',
                           label == 'Male' ~ 'Survey Females',
                           label == 'Female' ~ 'Survey Males'),
         label = factor(label, levels = c('Fishery Landings',
                                          'Fishery Discards',
                                          'Survey: unsexed',
                                          'Survey Females',
                                          'Survey Males'),
                        ordered = TRUE)) %>% 
  filter(label != 'Survey: unsexed')


ggplot(agg, aes(x = length, y = p, fill = label)) +
  geom_col(position = "identity", alpha = 0.5, col = NA) +
  scale_fill_colorblind7() + 
  facet_wrap(~fleet, ncol = 1) + 
  theme_classic(base_size = 15) +
  labs(x = "Length (cm)", y = "Proportion", fill = "") + 
  scale_y_continuous(labels = scales::comma, expand = c(0, NA))

ggsave('outputs/all_comps.png', dpi=300, height=6.5, width=10, units='in')
