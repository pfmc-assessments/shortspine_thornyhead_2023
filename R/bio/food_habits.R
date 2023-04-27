# Food habits analysis

# Data info - data accessed 4/26/23
# Contact: Joe Bizzarro, who led its development.
# The California Current Trophic Database (CCTD) is now publicly available at
# the following web-address
# (https://oceanview.pfeg.noaa.gov/erddap/search/index.html?&searchFor=SWFSC-CCTD).
# We built an associated website to provide additional information and resources
# for interested users (https://oceanview.pfeg.noaa.gov/cctd/). We will
# periodically update the CCTD, with the next update happening in late 2023. If
# you are aware of any additional food habits data, please let us know.
# 
# Please Note: Users are expected to read and fully understand the metadata and
# additional information and resources provided on the CCTD website
# (https://oceanview.pfeg.noaa.gov/cctd/) to ensure proper use. Unlike other
# food habits databases that are associated with standardized surveys, the data
# in the CCTD were derived from a variety of sources. Although considerable
# effort was devoted to standardization, it is wise to access publications
# related to specific data sets to fully understand how samples were collected
# and processed (see Table 1, User Guide).


library(tidyverse)

prey <- read_csv('data/food_habits/sst_diets.csv')
problems() # not concerned about larva field

names(prey)
# prey %>% count(region)
# length(which(is.na(prey$prey_weight_g))) # use this one
# length(which(is.na(prey$prey_number_corrected)))
# length(which(is.na(prey$prey_volume_percent))) # has the fewest NAs, but the percentages didn't easily add up
# prey %>% count(region)

prey <- prey %>% 
  filter(region %in% c('CenCal', 'NorCal/OR/WA') & !is.na(prey_weight_g) & !is.na(prey_common_name)) %>% 
  select(year, month, region, # lon = longitude_degrees_east, lat = latitude_degrees_north,
         prey_common_name, # prey_number, prey_number_corrected, prey_volume_percent,
         prey_weight_g) 

prey %>% 
  group_by(region, year) %>% 
  mutate(total_weight = sum(prey_weight_g)) %>% 
  ungroup() %>% 
  mutate(ratio = prey_weight_g / total_weight) %>% 
  distinct(region, year, prey_common_name, ratio) %>% 
  arrange(-ratio) %>% 
  print(n=100)

preysum <- prey %>% 
  group_by(year, prey_common_name) %>% 
  summarise(weight = sum(prey_weight_g)) %>% 
  group_by(year) %>%
  mutate(ratio = weight / sum(weight)) %>% 
  ungroup() %>% 
  arrange(-ratio) 

preysum %>% print(n=Inf)
preysum <- preysum %>%
  mutate(prey = ifelse(ratio >= 0.1, prey_common_name, 'other')) %>% 
  mutate(prey_common_name = forcats::fct_reorder(factor(prey_common_name), -ratio))

ggplot(preysum, aes(factor(year), ratio, fill = prey)) +
  geom_bar(stat = 'identity', col = 'black') +
  theme_bw() +
  # ggthemes::scale_fill_colorblind() +
  labs(x = 'Year', y = 'Proportion',
       title = 'Shortspine Thornyhead Stomach Contents', 
       subtitle = 'California Current Trophic Database: https://oceanview.pfeg.noaa.gov/cctd/', fill = 'Prey Item') 

prey %>% count(region)

ggsave('outputs/food_habits/sst_diet.png', units = 'in', 
       width = 6, height = 8, dpi = 300)
  
# predators ----

pred <- read_csv('data/food_habits/sst_predators.csv')
pred %>% count(region)
names(pred)
length(which(is.na(pred$prey_weight))) # use this one
length(which(is.na(pred$pred_number_corrected)))
length(which(is.na(pred$pred_volume_percent))) # has the fewest NAs, but the percentages didn't easily add up
pred %>% count(region)

pred <- pred %>% 
  filter(region %in% c('CenCal', 'NorCal/OR/WA', 'SoCal') & 
           !is.na(prey_weight) & !is.na(predator_taxa)) %>% 
  select(year, month, region, predator_taxa,  # lon = longitude_degrees_east, lat = latitude_degrees_north,
         predator_common_name, prey_common_name, # pred_number, pred_number_corrected, pred_volume_percent,
         prey_weight) 

predsum <- pred %>% 
  group_by(year, predator_common_name) %>% 
  summarise(weight = sum(prey_weight)) %>% 
  group_by(year) %>%
  mutate(ratio = weight / sum(weight)) %>% 
  ungroup() %>% 
  arrange(-ratio) 

predsum %>% print(n=Inf)

ggplot(predsum, aes(factor(year), ratio, fill = predator_common_name)) +
  geom_bar(stat = 'identity', col = 'black') +
  theme_bw() +
  # ggthemes::scale_fill_colorblind() +
  labs(x = 'Year', y = 'Proportion',
       title = 'Shortspine Thornyhead Predatation', 
       subtitle = 'California Current Trophic Database: https://oceanview.pfeg.noaa.gov/cctd/', fill = 'pred Item') 

ggsave('outputs/food_habits/sst_predators.png', units = 'in', 
       width = 6, height = 8, dpi = 300)

  


