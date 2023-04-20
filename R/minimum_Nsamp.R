# Identify minimum sample size for length comps
# 95% quantile
# Jane, Josh, Haley
# April 2023

library(tidyverse)

fsep <- .Platform$file.sep
dir_dat <- file.path(here::here(), "data", "for_ss", fsep = fsep)

srv_len_all <- read_csv(file.path(dir_dat, "survey_length_comps_all_2023.csv"))
landings_lencomps3 <-  read_csv(file.path(dir_dat, "landings_length_comps_3fleet_2023.csv"))
discard_lencomps3 <- read_csv(file.path(dir_dat, "discardLenComp_ss_3Fleets.csv"))[-1]

names(landings_lencomps3) <- names(srv_len_all)
names(discard_lencomps3) <- names(srv_len_all)

lencomps <- bind_rows(srv_len_all %>% mutate(type = 'survey'), 
                      landings_lencomps3 %>% mutate(type = 'landed'), 
                      discard_lencomps3 %>% mutate(type = 'discard')) %>% 
  filter(Nsamp > 0) #%>% 
  # filter(between(Nsamp, 0, 300))

hist(lencomps$Nsamp)
(cutoff <- quantile(lencomps$Nsamp, 0.05))
# 5% 
# 11.4753 

remove_data <- lencomps %>%
  filter(Nsamp <= cutoff) %>% 
  distinct(Yr, FltSvy, type, Nsamp) 
remove_data
# Yr FltSvy type   
# <dbl>  <dbl> <chr>  
# 1  1981      1 landed 
# 2  1994      1 landed 
# 3  1995      1 landed 
# 4  1985      3 landed 
# 5  1986      3 landed 
# 6  1988      3 landed 
# 7  1993      3 landed 
# 8  1995      3 landed 
# 9  1996      3 landed 
# 10  1997     3 landed 
# 11  2005     3 discard
