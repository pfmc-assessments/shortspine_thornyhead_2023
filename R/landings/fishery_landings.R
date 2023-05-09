# Fishery landings data from PacFIN for the 2023 SST stock assessment
# Contact: Haley Oleynik, Adam Hayes, Jane Sullivan
# Last updated March 2023

# length comps are weighted by state-specific landings because WA and OR length
# and catch information come from the port where sampling occurred. port
# sampling programs are state-specific, and therefore the lengths should be
# stratified/weighted by state. in general though, WA and OR vessels fish on the
# same fishing grounds which is why we combine them in the assessment as "north"

# set up ----

libs <- c('tidyverse', 'patchwork', 'ggthemes')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

# take black out of colorblind theme
scale_fill_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_fill_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

scale_color_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_color_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

out_path <- 'outputs/landings'; dir.create(out_path)

# read data ----

# shortspine thornyhead only
load("data/raw/PacFIN.SSPN.CompFT.17.Jan.2023.RData")
short.catch = catch.pacfin 

# longspine thornyhead only
load("data/raw/PacFIN.LSPN.CompFT.17.Feb.2023.RData")
long.catch = catch.pacfin 

# unidentified thornyhead only
load("data/raw/PacFIN.THDS.CompFT.30.Jan.2023.RData" )
un.catch = catch.pacfin 

rm(catch.pacfin)

# 2013 catches (use historical, pre-1981)
catch2013 <- read_csv('data/processed/SST_catch_2013assessment.csv')

historical_catch <- catch2013 %>% 
  tidyr::pivot_longer(cols = c('NTrawl', 'STrawl', 'NOther', 'SOther'),
               names_to = 'fleet_name', values_to = 'catch') %>% 
  dplyr::rename_all(tolower) %>% 
  dplyr::filter(year < 1981) %>% 
  dplyr::mutate(fleet = case_when(fleet_name == 'NTrawl' ~ 1,
                                fleet_name == 'STrawl' ~ 2,
                                fleet_name == 'NOther' ~ 3,
                                fleet_name == 'SOther' ~ 4))#,
                # fleet_name = case_when(fleet == 1 ~ 'Trawl_N',
                #                        fleet == 2 ~ 'Trawl_S',
                #                        fleet == 3 ~ 'Non-trawl_N',
                #                        fleet == 4 ~ 'Non-trawl_S'))

# updated catch reconstruction states
historical_2023 <- read_csv('data/processed/SST_2023_state_total_landings.csv') %>% 
  rename_all(tolower) %>% 
  rename(catch = round_mtons, fleet_name = fleet) %>% 
  mutate(assessment = '2023')

# oregon state data (for 1981-1986)
or_catch <- read_csv('data/processed/SST_OR_historical.csv') %>%
  filter(Year %in% 1981:1986) %>%
  mutate(state_gear = ifelse(Fleet %in% "NTrawl", "OR_Trawl", "OR_Non-trawl"), 
         species = "shortspine thornyhead") %>%
  dplyr::select(species, year = Year, state_gear, mtons = round_mtons)

# eda ----

glimpse(short.catch)
unique(short.catch$NOMINAL_TO_ACTUAL_PACFIN_SPECIES_NAME)
unique(long.catch$NOMINAL_TO_ACTUAL_PACFIN_SPECIES_NAME)
unique(un.catch$NOMINAL_TO_ACTUAL_PACFIN_SPECIES_NAME)
unique(short.catch$REMOVAL_TYPE_NAME)

short.catch %>% 
  group_by(PACFIN_GROUP_GEAR_CODE, PACFIN_GEAR_DESCRIPTION) %>% 
  tally(ROUND_WEIGHT_MTONS) %>% 
  arrange(-n) %>% 
  print(n = Inf)

short.catch %>% 
  group_by(COUNTY_STATE) %>% 
  tally(ROUND_WEIGHT_MTONS) %>% 
  arrange(-n) %>% 
  print(n = Inf) 

# all NA states are WA
short.catch %>% filter(is.na(COUNTY_STATE)) %>% distinct(PACFIN_PORT_DESCRIPTION)
unique(short.catch$PACFIN_GEAR_CODE)
# process data ----

process_catch <- function(df) {
  df %>% 
    dplyr::rename_all(tolower) %>%  
    dplyr::select(species = nominal_to_actual_pacfin_species_name,
                  year = landing_year, state = county_state, 
                  mtons = round_weight_mtons, gear = pacfin_group_gear_code) %>%
    dplyr::mutate(state = replace_na(state, 'WA'),
                  gear = ifelse(gear %in% c('TWL', 'TWS'), 'Trawl', 'Non-trawl'),
                  species = tolower(species),
                  state_gear = paste0(state, '_', gear))
}

allcatch <- process_catch(short.catch) %>% 
  bind_rows(process_catch(long.catch)) %>% 
  bind_rows(process_catch(un.catch))

# replace 2017 CA PacFIN totals with CALCOM
# replace OR PacFIN data for 1981-1986 with state data
state_gear <- allcatch %>% 
  dplyr::group_by(species, year, state_gear) %>% 
  dplyr::summarise(mtons = sum(mtons)) %>% 
  dplyr::mutate(mtons = ifelse(state_gear %in% "CA_Trawl" &  
                                 year %in% 2017 & 
                                 species %in% "shortspine thornyhead", 158.3, mtons), 
                mtons = ifelse(state_gear %in% "CA_Non-trawl" &  
                                 year %in% 2017 & 
                                 species %in% "shortspine thornyhead", 184.77, mtons)) %>%
  filter( !(state_gear %in% c("OR_Trawl","OR_Non-trawl") & year %in% 1981:1986) ) %>%
  bind_rows(or_catch) %>%
  dplyr::ungroup()


p1 <- allcatch %>% 
  dplyr::group_by(species, year, state, gear) %>% 
  dplyr::summarise(mtons = sum(mtons)) %>% 
  dplyr::ungroup()%>% 
  bind_rows(data.frame(species = 'thornyheads (mixed)',
                       year = 1981,
                       state = 'WA',
                       gear = 'Non-trawl',
                       mtons = 0)) %>% 
  filter(species == 'thornyheads (mixed)') %>% 
  ggplot(aes(x = year, y = mtons, fill = gear)) +
  geom_bar(stat = 'identity') +
  scale_color_colorblind7() +
  scale_fill_colorblind7() +
  facet_wrap(~state, ncol = 1) +
  theme_classic() +
  labs(x = 'Year', y = "Catch (mt)", fill = 'Gear', title = 'Unidentified Thornyheads Catch (mt)') +
  theme(text = element_text(size = 10)) 
p1

ggsave("outputs/fishery_data/unid-catch.png", 
       dpi=300, height=7, width=10, units='in')


# proportion sspn ----

# get the proportion sspn out of the total identified thornyheads and apply it
# to the unidentified thornyheads

prop_sspn <- tidyr::expand_grid(year = unique(allcatch$year),
                         state_gear = unique(allcatch$state_gear)) %>% 
  dplyr::left_join(state_gear %>% 
                     dplyr::filter(species != 'thornyheads (mixed)') %>% 
                     dplyr::group_by(year, state_gear) %>% 
                     dplyr::mutate(total_mtons = sum(mtons),
                                   prop_sspn = mtons / total_mtons) %>% 
                     dplyr::filter(species == 'shortspine thornyhead')) %>% 
  group_by(state_gear) %>% 
  dplyr::mutate(interp_prop_sspn = zoo::na.approx(prop_sspn, rule = 2)) %>% 
  dplyr::select(year, state_gear, prop_sspn, interp_prop_sspn) %>% 
  dplyr::ungroup()

p2 <- prop_sspn %>% 
  tidyr::separate(col = state_gear, sep = '_', into = c('state', 'gear'), remove = FALSE) %>% 
  dplyr::rename(Data = prop_sspn, Interpolation = interp_prop_sspn) %>% 
  dplyr::mutate(Interpolation = ifelse(is.na(Data), Interpolation, NA)) %>% 
  tidyr::pivot_longer(cols = c('Data', 'Interpolation')) %>% 
  ggplot() +
  geom_line(aes(year, value, col = gear, group = interaction(state_gear, name))) +
  geom_point(aes(year, value, shape = name, col = gear), size = 3) +
  scale_shape_manual(values = c(1, 17)) +
  scale_color_colorblind7() +
  facet_wrap(~state, ncol = 1) +
  labs(x = 'Year', y = "Ratio", title = 'Proportion shortspine in identified thornyhead catch',
       shape = 'Source', col = 'Gear') +
  theme_classic() +
  theme(text = element_text(size = 10)) +
  expand_limits(y=0)
p2

ggsave("outputs/fishery_data/proportion-sspn.png", 
       dpi=300, height=7, width=10, units='in')

state_gear %>% 
  dplyr::filter(species == 'thornyheads (mixed)') %>%
  write_csv('outputs/fishery_data/unid_catch.csv')

prop_sspn %>% write_csv('outputs/fishery_data/prop_sspn.csv')

state_gear %>% 
  dplyr::filter(species != 'thornyheads (mixed)') %>%
  write_csv('outputs/fishery_data/identified_catch.csv')

unidcatch <- state_gear %>% 
  dplyr::filter(species == 'thornyheads (mixed)') %>% 
  dplyr::left_join(prop_sspn) %>% 
  dplyr::group_by(state_gear) %>% 
  dplyr::mutate(mtons = interp_prop_sspn * mtons)

# add the unidentified catch assumed to be sspn back into the sspn
new_state_gear <- state_gear %>% 
  dplyr::filter(species == 'shortspine thornyhead') %>% 
  dplyr::left_join(unidcatch %>% 
              dplyr::select(year, state_gear, mtons_estimated = mtons)) %>% 
  dplyr::rowwise() %>% 
  dplyr::mutate(mtons_new = sum(mtons, mtons_estimated, na.rm = TRUE)) %>% 
  dplyr::ungroup()

new_state_gear %>% 
  tidyr::separate(col = state_gear, sep = '_', into = c('state', 'gear'), remove = FALSE) %>% 
  dplyr::rename(Data = mtons, Estimated = mtons_estimated) %>% 
  pivot_longer(cols = c('Data', 'Estimated')) %>% 
  mutate(name = factor(name, levels = c('Estimated', 'Data'),
                       ordered = TRUE)) %>%
  ggplot(aes(x = year, y = value, fill = name)) +
  geom_area(alpha = 0.6 , size = 0.5, colour = NA) +
  scale_fill_colorblind7() +
  facet_wrap(~ state_gear, ncol = 2) +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +   
  labs(x = NULL, y = "Landed catch (mt)", fill = 'Source') +
  theme_classic() +
  theme(text = element_text(size = 17))

ggsave("outputs/fishery_data/estimated-total-catch-sspn.png", 
       dpi=300, height=7, width=10, units='in')

p3 <- new_state_gear %>% 
  tidyr::separate(col = state_gear, sep = '_', into = c('state', 'gear'), remove = FALSE) %>% 
  group_by(year, state) %>% 
  summarize(mtons = sum(mtons, na.rm = TRUE),
            mtons_estimated = sum(mtons_estimated, na.rm = TRUE)) %>% 
  dplyr::rename(Data = mtons, Estimated = mtons_estimated) %>% 
  pivot_longer(cols = c('Data', 'Estimated')) %>% 
  mutate(name = factor(name, levels = c('Estimated', 'Data'),
                       ordered = TRUE)) %>%
  ggplot(aes(x = year, y = value, fill = name)) +
  geom_bar(stat = 'identity', col = 'black') +
  scale_fill_colorblind7() +
  facet_wrap(~ state, ncol = 1) +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +   
  labs(x = NULL, y = "Landed catch (mt)", fill = 'Source') +
  theme_classic() +
  theme(text = element_text(size = 17))
p3
ggsave("outputs/fishery_data/estimated-total-catch-sspn2.png", 
       dpi=300, height=7, width=10, units='in')

new_state_gear %>% 
  tidyr::separate(col = state_gear, sep = '_', into = c('state', 'gear'), remove = FALSE) %>% 
  group_by(year, state, gear) %>% 
  summarize(mtons_new = sum(mtons_new, na.rm = TRUE)) %>% 
  ggplot(aes(x = year, y = mtons_new, fill = gear)) +
  geom_bar(stat = 'identity', col = 'black') +
  # scale_fill_colorblind7() +
  scale_fill_manual(values = c("#56B4E9", "#F0E442")) +
  
  facet_wrap(~ state, ncol = 3) +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +   
  labs(x = NULL, y = "Landed catch (mt)", fill = 'Source') +
  theme_classic() +
  theme(text = element_text(size = 17),
        legend.position = c(0.9, 0.8))

ggsave("outputs/fishery_data/estimated-total-catch-sspn3.png", 
       dpi=300, height=5, width=10, units='in')
  
p1a <- p1 + facet_wrap(~state, nrow = 1)
p2a <- p2 + facet_wrap(~state, nrow = 1) +
  ggtitle('Proportion Shortspine in Identified Thornyhead Catch')
p3a <- p3 + facet_wrap(~state, nrow = 1) +
  labs(x = 'Year', y = NULL, title = 'New Estimated Shortspine Catch (mt)') +
  scale_fill_manual(values = c("#009E73", "#F0E442"))
# scale_fill_manual(values = c("#009E73", "#F0E442")) +
  
p1a / p2a / p3a
p1a / p2a

ggsave("outputs/fishery_data/unidcatch-props.png", 
       dpi=300, height=6, width=10, units='in')

# finalize ----

fleetsum <- new_state_gear %>% 
  dplyr::mutate(fleet_name = case_when(state_gear %in% c('WA_Trawl', 'OR_Trawl') ~ 'NTrawl',
                                  state_gear == 'CA_Trawl' ~ 'STrawl',
                                  state_gear %in% c('WA_Non-trawl', 'OR_Non-trawl') ~ 'NOther',
                                  state_gear == 'CA_Non-trawl' ~ 'SOther'),
                fleet = case_when(fleet_name == 'NTrawl' ~ 1,
                                  fleet_name == 'STrawl' ~ 2,
                                  fleet_name == 'NOther' ~ 3,
                                  fleet_name == 'SOther' ~ 4),
                season = 1) %>% 
  dplyr::group_by(year, fleet_name, fleet, season) %>% 
  dplyr::summarise(catch = sum(mtons, na.rm = TRUE)) %>% 
  dplyr::ungroup() 

finalcatch <- fleetsum %>% 
  dplyr::select(-fleet, -season) %>% 
  #dplyr::bind_rows(historical_catch %>% 
  #            # remove - received data from CA
  #              dplyr::filter(fleet_name %in% c('STrawl', 'SOther')) %>% 
  #              dplyr::select(-fleet, -season)) %>%
  # add in new NTrawl and NOther historical catches
  dplyr::bind_rows(historical_2023 %>% 
                     dplyr::filter(year >= 1901) %>% 
                     dplyr::select(-assessment)) %>% 
  dplyr::mutate(catch_se = 0.01) %>% 
  dplyr::arrange(fleet_name, year)

finalcatch %>% 
  # mutate(fleet_name = factor(fleet_name, 
  #                            levels = c('STrawl','NTrawl', 'SOther', 'NOther'),
  #                            ordered = TRUE)) %>% 
  ggplot(aes(x = year, y = catch, fill = forcats::fct_reorder(fleet_name, catch))) +
  geom_area(alpha = 0.8 , size = 0.1, colour = 'white') + #, colour = "black"
  geom_vline(xintercept = 1980.5, lty = 2, col = 'darkgrey') +
  # scale_fill_colorblind7() +
  scale_fill_manual(values = c("#56B4E9", "#009E73", "#E69F00", "#F0E442")) +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +   
  labs(x = NULL, y = "Catch (mt)", fill = "Fleet") +
  theme_classic() +
  theme(text = element_text(size = 20),
        legend.position = c(0.15, 0.8))

ggsave("outputs/fishery_data/total-landings.png", 
       dpi=300,height=4, width=7, units='in')

finalcatch %>% 
  mutate(fleet_name = factor(fleet_name,
                             levels = c('NTrawl', 'NOther','STrawl', 'SOther'),
                             ordered = TRUE)) %>%
  ggplot(aes(x = year, y = catch, fill = fleet_name)) +
  geom_bar(stat = 'identity', colour = 'black', size = 0.1) + 
  geom_vline(xintercept = 1980.5, lty = 2, col = 'darkgrey', size = 1) +
  # scale_fill_colorblind7() +
  scale_fill_manual(values = c("#009E73","#56B4E9", "#F0E442", "#E69F00")) +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +   
  labs(x = NULL, y = "Catch (mt)", fill = "Fleet") +
  theme_classic() +
  theme(text = element_text(size = 20),
        legend.position = c(0.15, 0.8))

ggsave("outputs/fishery_data/total-landings2.png", 
       dpi=300, height=4, width=7, units='in')

# final catch with 3 fleets
finalcatch %>% 
  mutate(fleet_name = case_when(fleet_name %in% c('NOther', 'SOther') ~ 'NonTrawl',
                                fleet_name == 'NTrawl' ~ 'NTrawl',
                                fleet_name == 'STrawl' ~ 'STrawl')) %>%
  mutate(fleet_name = factor(fleet_name,
                             levels = c('NTrawl','STrawl', 'NonTrawl'),
                             ordered = TRUE)) %>%
  ggplot(aes(x = year, y = catch, fill = fleet_name)) +
  geom_bar(stat = 'identity', colour = 'black', size = 0.1) + 
  #geom_vline(xintercept = 1980.5, lty = 2, col = 'darkgrey', size = 1) +
  # scale_fill_colorblind7() +
  scale_fill_manual(values = c("#009E73", "#F0E442", "#56B4E9"),labels=c('North Trawl', 'South Trawl', 'Non Trawl')) +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +   
  labs(x = "Year", y = "Catch (mt)", fill = "Fleet") +
  theme_classic() +
  theme(text = element_text(size = 10),
        legend.position = c(0.15, 0.8))

ggsave("outputs/fishery_data/total-landings-3fleets.png", 
       dpi=300, height=4, width=7, units='in')

# compare catch time series ----

comparecatch <- catch2013 %>% 
  tidyr::pivot_longer(cols = c('NTrawl', 'STrawl', 'NOther', 'SOther'),
                      names_to = 'fleet_name', values_to = 'catch') %>% 
  dplyr::select(year = Year, fleet_name, catch) %>% 
  mutate(assessment = '2013') %>% 
  bind_rows(finalcatch %>% 
              dplyr::select(year, fleet_name, catch) %>% 
              mutate(assessment = '2023')) %>% 
  bind_rows(historical_2023 %>% 
              filter(year >= 1901))

comparecatch %>% 
  filter(year <= 2012) %>%
  ggplot(aes(x = year, y = catch,  fill = assessment, col = assessment)) + 
  geom_area(position = "identity", alpha = 0.25, size = 1) +
  scale_fill_manual(values = c("#00BFC4", "grey30")) + 
  scale_colour_manual(values = c("#00BFC4", "grey30")) +
  geom_vline(xintercept = 1980.5, lty = 2, col = 'darkgrey') +
  facet_wrap(~fleet_name, scales = 'free') +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +   
  labs(x = NULL, y = "Catch (mt)", fill = "Assessment", col = "Assessment") 

ggsave("outputs/fishery_data/compare-assessment-landings.png", 
       dpi=300, height=7, width=10, units='in')


# write ss ----

catch.ss <- finalcatch %>% 
  dplyr::select(year, season, fleet, catch, catch_se)

# fleetsum %>% 
#   tidyr::pivot_wider(id_cols = c(year, season, f names_from = fleet, values_from = catch, values_fill = 0)


# state %>% 
#   ggplot(aes(x = year, y = mtons, color = state)) +
#   scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +
#   geom_line(size = 1.5) +
#   labs(x = 'Year', y = 'Total Weight (mt)', title = 'Shortpine Thornyhead Fishery Landings') +
#   scale_color_colorblind7() +
#   theme_classic() + 
#   theme(text = element_text(size = 17)) +
#   facet_wrap(~species)
# 
f2 <- state_gear %>%
  filter(species == 'shortspine thornyhead') %>%
  ggplot(aes(x = year, y = mtons, color = state_gear)) +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +
  geom_area(size = 1.5) +
  labs(x = 'Year', y = 'Total Weight (mt)') +#, title = 'Shortpine Thornyhead Fishery Landings') +
  scale_color_colorblind7() +
  theme_classic() +
  theme(text = element_text(size = 17)) +
  facet_wrap(~ state_gear)
f2

ggplot(aes(x = year, y = value, fill = name)) +
  geom_area(alpha = 0.6 , size = 0.5, colour = NA) + 
  scale_fill_colorblind7() +
  facet_wrap(~ state_gear, ncol = 2) +
  # theme_bw() +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +   
  labs(x = NULL, y = "Landed catch (mt)", fill = 'Source') +
  theme_classic() +
  theme(text = element_text(size = 17))

ggsave("outputs/fishery_data/estimated-total-catch-sspn.png", 
       dpi=300, height=7, width=10, units='in')

# new figs ----
new_state_gear %>% 
  tidyr::separate(col = state_gear, sep = '_', into = c('state', 'gear'), remove = FALSE) %>% 
  ggplot(aes(x = year, y = mtons_new, fill = gear)) +
  geom_area(alpha = 0.6 , size = 0.5, colour = NA) + 
  scale_fill_colorblind7() +
  facet_wrap(~ state, ncol = 1) +
  # theme_bw() +
  scale_y_continuous(labels = scales::comma, expand = c(0, NA)) +   
  theme_classic() +
  theme(text = element_text(size = 17)) +
  labs(x = NULL, y = "Landed catch (mt)", fill = 'State') 

ggsave("outputs/fishery_data/estimated-total-catch-sspn.png", 
       dpi=300, height=7, width=10, units='in')

# look at price info (for introduction) -----------
short.catch$PRICE_PER_POUND

# filter by gear type too 
short.catch %>% 
  dplyr::mutate(fleet = case_when(PACFIN_GROUP_GEAR_CODE %in% c('TWL', 'TWS') ~ 'Trawl',
                                  PACFIN_GROUP_GEAR_CODE %in% c('NET', 'HKL','POT','TLS','MSC') ~ 'NonTrawl')) %>%
  group_by(LANDING_YEAR,fleet) %>%
  summarize(price = mean(PRICE_PER_POUND)) %>%
  ggplot(aes(x=LANDING_YEAR,y=price, color = fleet)) +
  geom_line()

HKLprice <- short.catch %>% group_by(LANDING_YEAR) %>%
  filter(PACFIN_GROUP_GEAR_CODE == "HKL") %>%
  summarize(price = mean(PRICE_PER_POUND))

TWLprice <- short.catch %>% group_by(LANDING_YEAR) %>%
  filter(PACFIN_GROUP_GEAR_CODE == "TWL") %>%
  summarize(price = mean(PRICE_PER_POUND))

library(priceR)

HKLprice$inflation.price <- priceR::adjust_for_inflation(HKLprice$price, country = "US", from_date = HKLprice$LANDING_YEAR, to_date = 2020)

ggplot(HKLprice, aes(x=LANDING_YEAR)) +
  geom_line(aes(y=price), col= "red") +
  geom_line(aes(y=inflation.price), col = "blue")





