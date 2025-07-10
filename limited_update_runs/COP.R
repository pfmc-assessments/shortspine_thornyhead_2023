library(dplyr)
library(r4ss)
exe_loc <- here::here('limited_update_runs/ss3.exe')

# Index -------------------------------------------------------------------

survey_ind <- read.csv('C:/Users/kiva.oken/Downloads/shortspine_reanalysis_indexwc/shortspine_reanalysis_indexwc/wcgbts/delta_gamma_model_2/index/est_by_area.csv') |>
  filter(area=='Coastwide')


# Length comps ------------------------------------------------------------

sst_bio <- nwfscSurvey::pull_bio('NWFSC.Combo', common_name = 'shortspine thornyhead')
sst_catch <- nwfscSurvey::pull_catch('NWFSC.Combo', common_name = 'shortspine thornyhead')


## Strata and length bins copied from R/survey/SST_surveys_2023.R

nwfsc.combo.strata = nwfscSurvey::CreateStrataDF.fn(
  names          = c("shallow_south", "deep_south", "shallow_cen", "deep_cen", "shallow_north", "mid_north", "deep_north"), 
  depths.shallow = c(183, 549, 183, 549, 100, 183, 549), 
  depths.deep    = c(549, 1280, 549, 1280, 183, 549, 1280),
  lats.south     = c(32, 32, 34.5, 34.5, 40.5, 40.5, 40.5),
  lats.north     = c(34.5, 34.5, 40.5, 40.5, 49, 49, 49) 
)

length.bins <- seq(6, 72, 2)

sst_lengths <- nwfscSurvey::get_expanded_comps(bio_data = sst_bio |> filter(Year >= 2023), 
                                               catch_data = sst_catch |> filter(Year >= 2023), 
                                               comp_bins = length.bins, 
                                               strata = nwfsc.combo.strata, 
                                               fleet = 6, month = 7)

# Catch -------------------------------------------------------------------

gemm <- nwfscSurvey::pull_gemm(common_name = 'shortspine thornyhead', years = 2023)

catch_2023 <- gemm |>
  mutate(fleetname = case_when(grepl('hook|pot', sector, ignore.case = TRUE) ~ 'Non-trawl',
                               TRUE~ 'Trawl' # GEMM does not report trawl catch separately for CA vs OR/WA. Will use recent division of catch instead.
                               ),
         catch_for_mod = ifelse(grepl('At-sea', sector), total_discard_with_mort_rates_applied_and_landings_mt, # all at-sea mortality goes into directed landings
                                total_landings_mt) # otherwise discards are modeled with retention
  ) |>
  group_by(fleetname) |>
  summarise(catch_mt = sum(catch_for_mod))
  



# Model -------------------------------------------------------------------

mod_2023 <- SS_read('Q:/Assessments/Archives/ShortspineThornyhead/Shortspine_thornyhead_2023/2_base_model')

mod_new <- mod_2023

# extend end year
mod_new$dat$endyr <- 2024
mod_new$ctl$Block_Design <- purrr::map(mod_2023$ctl$Block_Design, \(x) {x[length(x)] <- 2024; return(x)})

# extend catches
trawl_frac <- mod_2023$dat$catch |>
  filter(year > 2017, year < 2023, 
         fleet == 1 | fleet == 2) |> # trawl fleets
  group_by(fleet) |>
  summarise(catch = sum(catch)) |>
  mutate(frac = catch/sum(catch))

new_catch <- data.frame(seas = 1,
                        fleet = 1:3,
                        catch = c(catch_2023$catch_mt[catch_2023$fleetname == 'Trawl'] * trawl_frac$frac[trawl_frac$fleet == 1],
                                  catch_2023$catch_mt[catch_2023$fleetname == 'Trawl'] * trawl_frac$frac[trawl_frac$fleet == 2],
                                  catch_2023$catch_mt[catch_2023$fleetname == 'Non-trawl']),
                        catch_se = 0.01)

mod_new$dat$catch <- bind_rows(list(`2023` = new_catch,
               `2024` = new_catch),
          .id = 'year') |>
  mutate(year = as.numeric(year)) |>
  bind_rows(mod_2023$dat$catch |> filter(year < 2023))
SS_write(mod_new, dir = 'limited_update_runs/1_extend_catches', overwrite = TRUE)


# replace survey index
wcgbts_new <- survey_ind |>
  select(year, 
         obs = est, 
         se_log = se) |>
  mutate(month = 7,
         index = 6)

mod_new$dat$CPUE <- bind_rows(
    mod_2023$dat$CPUE |> filter(index != 6),
    wcgbts_new
  )

mod_new$ctl$Q_parms[3, 'INIT'] <- 0.5
 
SS_write(mod_new, dir = 'limited_update_runs/2_catches_index', overwrite = TRUE)


# extend survey lengths

mod_new$dat$lencomp <- sst_lengths$sexed |>
  rename(part = partition,
         Nsamp = input_n) |>
  bind_rows(
    mod_2023$dat$lencomp
  )

SS_write(mod_new, 'limited_update_runs/3_all_data', overwrite = TRUE)

# read models, etc.

out_2023 <- SS_output('model/Sensitivity_Anal/Base_Model/5.25_Decision_Table_045/1_23.base.dt_base_45/run')
extend_catches <- SS_output('limited_update_runs/1_extend_catches')
update_index <- SS_output('limited_update_runs/2_catches_index')
extend_lengths <- SS_output('limited_update_runs/3_all_data')



#list(out_2023, extend_catches, update_index, extend_lengths) |>

# tune comps

tune_comps(dir = 'limited_update_runs/4_tune_comps', exe = exe_loc, extras = '-nohess', niters_tuning = 3)

tuned <- SS_output('limited_update_runs/4_tune_comps')

list(out_2023, extend_catches, update_index, extend_lengths, tuned) |>
  SSsummarize() |> 
  SStableComparisons(names = c('OFLCatch_2027', 'R0'))
  # SSplotComparisons(subplots = c(1,3,19,11,9), new = FALSE, legendlabels = c('2023 base', 'extend catches', 'reanalyze index', 'extend WCGBTS lengths', 'tune comps'))

SS_plots(tuned)


# rerun base --------------------------------------------------------------

mod_2023 <- SS_read('model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official/run')

mod_2023$fore$Flimitfraction_m <- PEPtools::get_buffer(years = 2023:2034, sigma = 1, pstar = 0.45)

SS_write(mod_2023, 'limited_update_runs/base_model_pstar_0.4')

# COP ---------------------------------------------------------------------

mod_2023 <- SS_read('limited_update_runs/base_model_pstar_0.4')

fore_catch <- readr::read_csv('limited_update_runs/2025 Catch Projection Updates - Shortspine.csv', n_max = 4) |>
  select(1:4) |>
  tidyr::pivot_longer(-Year, names_to = 'fleet_name', values_to = 'catch_or_F') |>
  mutate(fleet = case_when(grepl('north', fleet_name) ~ 1,
                           grepl('south', fleet_name) ~ 2,
                           TRUE ~ 3),
         seas = 1) |>
  select(year = Year, seas, fleet, catch_or_F) |>
  as.data.frame()

cop <- mod_2023
cop$fore$ForeCatch <- fore_catch
cop$fore$Flimitfraction_m <- PEPtools::get_buffer(years = 2023:2036, sigma = 1, pstar = 0.45, verbose = FALSE)
cop$fore$Flimitfraction_m$buffer[cop$fore$Flimitfraction_m$year <= 2026] <- 1
cop$fore$Nforecastyrs <- 14
cop$fore$FirstYear_for_caps_and_allocations <- 2027

SS_write(cop, 'limited_update_runs/cop1', overwrite = TRUE)

cop_out <- SS_output('limited_update_runs/cop1')

### alternative COP

cop <- mod_2023
cop$fore$ForeCatch <- fore_catch |>
  filter(year < 2026)
cop$fore$Flimitfraction_m <- PEPtools::get_buffer(years = 2023:2036, sigma = 1, pstar = 0.45, verbose = FALSE)
cop$fore$Flimitfraction_m$buffer[cop$fore$Flimitfraction_m$year < 2026] <- 1
cop$fore$Nforecastyrs <- 14
cop$fore$FirstYear_for_caps_and_allocations <- 2026

SS_write(cop, 'limited_update_runs/cop2a', overwrite = TRUE)

cop_temp <- SS_output('limited_update_runs/cop2a')

acl_2026 <- cop_temp$derived_quants |> 
  filter(grepl('ForeCatch_2026', Label)) |>
  pull(Value)

catch_2026 <- fore_catch |>
  filter(year == 2026) |>
  summarise(catch = sum(catch_or_F)) |>
  pull(catch)

attain_2026 <- catch_2026 / 825 # current 2026 ACL = 825 mt

cop$fore$Flimitfraction_m$buffer[cop$fore$Flimitfraction_m$year == 2026] <- 1
cop$fore$ForeCatch <- filter(fore_catch, year == 2026) |>
  mutate(prop = catch_or_F / sum(catch_or_F)) |>
  select(-catch_or_F) |>
  mutate(catch_or_F = prop * attain_2026 * acl_2026) |>
  select(-prop) |>
  bind_rows(cop$fore$ForeCatch) |>
   arrange(year, fleet)

cop$fore$FirstYear_for_caps_and_allocations <- 2027

SS_write(cop, 'limited_update_runs/cop2b', overwrite = TRUE)

cop_alt_out <- SS_output('limited_update_runs/cop2b')


list(out_2023, cop_out, cop_alt_out) |>
  SSsummarize() |> 
  SStableComparisons(names = c('ForeCatch', 'R0'))
