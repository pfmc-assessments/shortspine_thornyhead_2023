# Fishery landings data from PacFIN for the 2027 SST stock assessment

# Most of this code is similar to the 2023 version of this script.
# Main changes are:
# 1. Removing plots, EDA, etc.
# 2. Actually adding the mixed thornyhead estimate into the total shortspine landings
#    These catches were calculated but accidentally left out in 2023.
# 3. The historical reconstructions are read from state files instead of a single 
#    spreadsheet that only includes fleet labels. This allows for the creation of a 
#    time series for state approvals.

library(tidyverse)

# read data ----

# shortspine thornyhead only
load("data/raw/pacfin/2026-09-01/PacFIN.SSPN.CompFT.01.Sep.2026.RData")
short.catch = catch.pacfin 

# longspine thornyhead only
load("data/raw/pacfin/2026-10-29/PacFIN.LSPN.CompFT.29.Oct.2026.RData")
long.catch = catch.pacfin 

# unidentified thornyhead only
load("data/raw/pacfin/2026-10-29/PacFIN.THDS.CompFT.29.Oct.2026.RData" )
un.catch = catch.pacfin 

rm(catch.pacfin)

# process data ----

process_catch <- function(df) {
  df %>% 
    dplyr::rename_all(tolower) %>%  
    dplyr::select(species = nominal_to_actual_pacfin_species_name,
                  year = landing_year, state = county_state, 
                  mtons = round_weight_mtons, gear = pacfin_group_gear_code) %>%
    dplyr::mutate(state = replace_na(state, 'WA'), # all NAs are tribal landings in WA
                  gear = ifelse(gear %in% c('TWL', 'TWS'), 'Trawl', 'Non-trawl'),
                  species = tolower(species),
                  state_gear = paste0(state, '_', gear))
}

allcatch <- process_catch(short.catch) %>% 
  bind_rows(process_catch(long.catch)) %>% 
  bind_rows(process_catch(un.catch))

state_gear <- allcatch %>% 
  dplyr::group_by(species, year, state_gear) %>% 
  dplyr::summarise(mtons = sum(mtons)) %>% 
  filter( !(state_gear %in% c("OR_Trawl","OR_Non-trawl") & year %in% 1981:1986) ) %>%
  # bind_rows(or_catch) %>% KO: I am going to do this at the end with the rest of the historical catches
  dplyr::ungroup()

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
  # this is the line with the error in 2023
  dplyr::mutate(mtons_new = sum(mtons, mtons_estimated, na.rm = TRUE)) %>% 
  dplyr::ungroup()

# historical reconstructions ----

wa_hist <- read.csv(file.path("data","processed","SST_WA_historical.csv")) |>
  mutate(state = 'WA') |>
  filter(Year < 1981)

or_hist <- read.csv(file.path("data","processed","SST_OR_historical.csv")) |>
  mutate(state = 'OR') |>
  filter(Year < 1987)

ca_hist <- read.csv(file.path("data","processed","SST_CA_historical.csv")) |>
  filter(Species %in% c("THDS","SSPN")) %>%
  group_by(Year, Fleet) |>
  summarize(round_mtons = sum(round_mtons)) |> # I don't love this but it is very clearly documented in the report
  mutate(state = 'CA')

foreign.rodgers <- read.csv(file.path("data","processed","rodgers 2003 sst foreign fleet.csv")) %>%
  mutate(Fleet = ifelse(Area %in% c("UVAN","COL"),"NTrawl","STrawl")) %>% 
  group_by(Year, Fleet) %>%
  summarize(round_mtons = sum(Catch_t)) |>
  separate_wider_position(cols = Fleet, widths = c(area = 1, gear =5)) |>
  mutate(state = paste('Foreign', area)) |>
  rename(catch = round_mtons, year = Year) |>
  select(-area)

ashop.catch <- read_csv(file.path("data", "processed", "SST_ASHOP_landings.csv")) |>
  mutate(state = 'ASHOP', gear = 'Trawl') |>
  rename(catch = total_catch)

# finalize ----

fleetsum <- new_state_gear %>% 
  separate(state_gear, into = c('state', 'gear'), sep = '_', remove = TRUE) |>
  select(-mtons, -mtons_estimated, -species, catch = mtons_new)

all_catches <- bind_rows(wa_hist, or_hist, ca_hist) |> 
  mutate(gear = ifelse(grepl('Trawl', Fleet), 'Trawl', 'Non-trawl')) |>
  select(-Fleet) |> 
  rename(catch = round_mtons, year = Year) |> 
  bind_rows(fleetsum, foreign.rodgers, ashop.catch) |>
  filter(year > 1900)

all_catches |>
  pivot_wider(names_from = state, values_from = catch, values_fill = 0) |>
  filter(year < 2026) |>
  arrange(year) |>
  write.csv('data/processed_2027/catches_wide.csv', row.names = FALSE)

catch_for_ss3 <- all_catches |>
  mutate(area = case_when(state == 'WA' ~ 'N',
                          state == 'OR' ~ 'N',
                          state == 'CA' ~ 'S',
                          state == 'Foreign N' ~ 'N',
                          state == 'Foreign S' ~ 'S',
                          state == 'ASHOP' ~ 'N'), 
         fleet = case_when(gear == 'Non-trawl' ~ 3,
                           gear == 'Trawl' & area == 'N' ~ 1,
                           gear == 'Trawl' & area == 'S' ~ 2)) |> 
  group_by(year, fleet) |>
  summarize(catch = sum(catch)) |>
  mutate(catch_se = 0.01, season = 1) |>
  filter(catch > 0)

catch_for_ss3 |>
  write.csv('data/processed_2027/catch_ss3.csv', row.names = FALSE)

# compare catch time series ----

catch2013 <- read_csv('data/processed/SST_catch_2013assessment.csv')
catch2023 <- read_csv('data/for_ss/landings_3fleet_ashop_2023.csv')

compare_catches <- list(`2023` = catch2023, `2027` = catch_for_ss3) |>
  bind_rows(.id = 'assessment') |>
  group_by(assessment, year) |>
  summarize(catch = sum(catch)) |>
  bind_rows( {catch2013 |>
    pivot_longer(NTrawl:SOther, names_to = 'fleet', values_to = 'catch') |>
    rename(year = Year) |>
    group_by(year) |>
    summarize(catch = sum(catch)) |>
    mutate(assessment = '2013')
})

theme_set(ggsidekick::theme_sleek())
compare_catches |>
  filter(year %in% 1987:2005) |>
  ggplot() +
  geom_line(aes(x = year, y = catch, col = assessment)) +
  ylab('Total landed catch (mt)') +
  ggokabeito::scale_color_okabe_ito()

compare_catches |>
  filter(assessment != '2013', year < 2023 | assessment == '2027') |>
  ggplot() +
  geom_line(aes(x = year, y = catch, col = assessment)) +
  ylab('Total landed catch (mt)') +
  ggokabeito::scale_color_okabe_ito()

