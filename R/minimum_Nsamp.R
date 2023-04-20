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
# 10.44568

remove_data <- lencomps %>%
  filter(Nsamp <= cutoff) %>% 
  distinct(Yr, FltSvy, type, Nsamp) 
remove_data

#Yr FltSvy Nsamp type   
#<dbl>  <dbl> <dbl> <chr>  
#  1  1981      1  5.14 landed 
#2  1994      1  6.52 landed 
#3  1995      1  5.31 landed 
#4  1985      3  3.41 landed 
#5  1986      3 10.2  landed 
#6  1988      3  8.10 landed 
#7  1993      3  3.41 landed 
#8  1996      3  4.59 landed 
#9  1997      3  6.97 landed 
#10  2005      3  3.21 discard  
#