# set up ----
libs <- c('readr', 'dplyr', 'tidyr', 'ggplot2', 'ggthemes', 'ggridges', 'cowplot')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

dat <- read_csv('data/surveys/AFSCslope/forSS/design_based_indices.csv') %>% 
  mutate(Survey = 'AFSCslope') %>% 
  bind_rows(read_csv('data/surveys/NWFSCcombo/forSS/design_based_indices.csv') %>% 
              mutate(Survey = 'NWFSCcombo')) %>% 
  bind_rows(read_csv('data/surveys/NWFSCslope/forSS/design_based_indices.csv') %>% 
              mutate(Survey = 'NWFSCslope')) %>% 
  bind_rows(read_csv('data/surveys/Triennial1/forSS/design_based_indices.csv') %>% 
              mutate(Survey = 'Triennial1')) %>% 
  bind_rows(read_csv('data/surveys/Triennial2/forSS/design_based_indices.csv') %>% 
              mutate(Survey = 'Triennial2')) 

names(dat)

dat <- dat %>% 
  mutate(uci = Value + 1.96 * (Value * seLogB),
         lci = Value - 1.96 * (Value * seLogB))

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


ggsave('results/data_summaries/survey_indices.png', height = 5,
       width = 7, dpi = 300)
