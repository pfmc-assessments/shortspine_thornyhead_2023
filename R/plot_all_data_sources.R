# data sources plot 
# jane.sullivan@noaa.gov
# last updated march 2023

# set up ----

library(tidyverse)
library(ggthemes)
theme_set(theme_classic(base_size = 16))

dat_path <- 'data/experimental_age_data' 
out_path <- file.path('outputs/growth')
dir.create(out_path)

# take black out of colorblind theme
scale_fill_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_fill_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# Color
scale_color_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_color_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# data ----

# amazing file that haley oleynik assembled
dat <- read_csv('data/processed/SST_meta-data.csv')

dat <- dat %>% 
  filter(Year < 2023) %>% 
  mutate(Group = case_when(group == 'catch' ~ 'Catch',
                           group == 'discards' ~ 'Discards',
                           group == 'survey' ~ 'Abundance indices',
                           group == 'lengthcomps' ~ 'Length compositions',
                           group == 'weights' ~ 'Mean body weight'),
         Group = factor(Group, 
                        levels = c('Catch', 'Abundance indices', 'Length compositions',
                                   'Discards', 'Mean body weight'),
                        ordered = TRUE),
         Fleet = case_when(category %in% c('Ntrawl', 'L_Ntrawl', 'D_Ntrawl', 'W_Ntrawl') ~ 'North Trawl',
                           category %in% c('Strawl', 'L_Strawl', 'D_Strawl', 'W_Strawl') ~ 'South Trawl',
                           category %in% c('Nother', 'L_Nother', 'D_Nother', 'W_Nother') ~ 'North Non-Trawl',
                           category %in% c('Sother', 'L_Sother', 'D_Sother', 'W_Sother') ~ 'South Non-Trawl',
                           category %in% c('AFSCTriennialSurvey1', 'L_TriennialShelf1') ~ 'Triennial 1 Survey',
                           category %in% c('AFSCTriennialSurvey2', 'L_TriennialShelf2') ~ 'Triennial 2 Survey',
                           category %in% c('AFSCSlopeSurvey', 'L_AFSCSlope') ~ 'AFSC Slope Survey',
                           category %in% c('NWFSCSlopeSurvey', 'L_NWFSCSlope') ~ 'NWFSC Slope Survey',
                           category %in% c('ComboSurvey', 'L_Combo') ~ 'NWFSC Combo Survey'),
         Fleet = factor(Fleet,
                        levels = c('North Trawl', 'South Trawl', 
                                   'North Non-Trawl', 'South Non-Trawl',
                                   'Triennial 1 Survey', 'Triennial 2 Survey',
                                   'AFSC Slope Survey', 'NWFSC Slope Survey', 'NWFSC Combo Survey'),
                        ordered = TRUE))

dat <- dat %>% 
  group_by(Group, Fleet) %>% 
  mutate(min = min(Year[present == 1])) %>% 
  filter(Year >= min) 

dat %>% 
  ggplot(aes(x = Year, y = Fleet, color = Fleet, fill = Fleet, alpha = factor(present))) +
  geom_point(size = 4, shape=15) + 
  facet_wrap(~Group, ncol = 1, scales = 'free_y') +
  scale_y_discrete(position = 'right', limits = rev) +
  scale_alpha_manual(values = c(0, 1)) +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 20) +
  theme(legend.position = 'none')

ggsave('outputs/assessment_data_timeseries.jpg', 
       bg='white', dpi=300, height=12, width=16, units="in")

dat %>% 
  filter(Group == 'Abundance indices') %>% 
  ggplot(aes(x = Year, y = Fleet, col = Fleet, fill = Fleet, alpha = factor(present))) +
  geom_point(size = 5, shape=15) + 
  # facet_wrap(~Group, ncol = 1, scales = 'free_y') +
  scale_y_discrete(position = 'right', limits = rev) +
  scale_alpha_manual(values = c(0, 1)) +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 20) +
  theme(legend.position = 'none')

ggsave('outputs/assessment_data_timeseries_surveys.jpg', 
       bg='white', dpi=300, height=3, width=11, units="in")
