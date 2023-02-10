# plot all survey indices together
# jane.sullivan@noaa.gov
# last updated Feb 2023

# note that this code is based on the survey_data.R output

# set up ----
libs <- c('readr', 'dplyr', 'tidyr', 'ggplot2', 'ggthemes', 'ggridges', 'cowplot')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

# read in data -----

# 2013 assessment results from the SS dat file in the appendix of the report
dat2013 <- read_csv('data/raw/survey_indices_2013assessment_SSdatfile.csv') %>% 
  mutate(Assessment = '2013_assessment',
         uci = Value + 1.96 * (Value * sd_log),
         lci = Value - 1.96 * (Value * sd_log))

# 2023 assessment results based on survey_data.R
dat <- read_csv('data/raw/AFSCslope/forSS/design_based_indices.csv') %>% 
  mutate(Survey = 'AFSCslope') %>% 
  bind_rows(read_csv('data/raw/NWFSCcombo/forSS/design_based_indices.csv') %>% 
              mutate(Survey = 'NWFSCcombo')) %>% 
  bind_rows(read_csv('data/raw/NWFSCslope/forSS/design_based_indices.csv') %>% 
              mutate(Survey = 'NWFSCslope')) %>% 
  bind_rows(read_csv('data/raw/Triennial1/forSS/design_based_indices.csv') %>% 
              mutate(Survey = 'Triennial1')) %>% 
  bind_rows(read_csv('data/raw/Triennial2/forSS/design_based_indices.csv') %>% 
              mutate(Survey = 'Triennial2')) %>% 
  mutate(Assessment = '2023_assessment',
         uci = Value + 1.96 * (Value * seLogB),
         lci = Value - 1.96 * (Value * seLogB))

# plot current survey time series ----
ggplot(dat, aes(x = Year, y = Value, col = Survey, fill = Survey)) +
  geom_ribbon(aes(ymin = lci, ymax = uci), 
              alpha = 0.2, col = 'white') +
  geom_point() +
  geom_line() +
  # facet_wrap(~Survey, ncol = 1, scales = 'free_y') +
  scale_fill_colorblind() +
  scale_color_colorblind() +
  theme_bw() +
  scale_y_continuous(labels = scales::comma) +
  labs(y = 'Biomass (t)', 
       title = 'Shortspine thornyhead survey indices of abundance')

ggsave('outputs/surveys/survey_indices.png', height = 5,
       width = 7, dpi = 300)

# compare assessment time series ----
# mutate(Value = Value/1e3,
#        lci = lci/1e3,
#        uci = uci/1e3)
compare <- bind_rows(dat %>% 
                       mutate(Value = log(Value),
                              uci = Value + 1.96 * (Value * seLogB),
                              lci = Value - 1.96 * (Value * seLogB)) %>% 
                       select(Year, Survey, Assessment, Value, lci, uci),
                     dat2013 %>%  
                       mutate(Value = log(Value),
                              uci = Value + 1.96 * (Value * sd_log),
                              lci = Value - 1.96 * (Value * sd_log)) %>% 
                       select(Year, Survey, Assessment, Value, lci, uci)) 

ggplot(compare, aes(x = Year, y = Value, col = Assessment, 
                    fill = Assessment, linetype = Assessment)) +
  geom_ribbon(aes(ymin = lci, ymax = uci), 
              alpha = 0.2, col = 'white') +
  geom_point() +
  geom_line() +
  facet_wrap(~Survey, ncol = 1, scales = 'free_y') +
  scale_fill_colorblind() +
  scale_color_colorblind() +
  theme_bw() +
  scale_y_continuous(labels = scales::comma) +
  labs(y = 'log biomass', 
       title = 'Shortspine thornyhead survey indices of abundance')

ggsave('outputs/surveys/compare_assess_survey_indices.png', height = 7,
       width = 5, dpi = 300)