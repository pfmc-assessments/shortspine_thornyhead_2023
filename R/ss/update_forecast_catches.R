
update.forecast.files <- function(model.dir, forecast.file){
  #ForeFile = file.path(here::here(), "model/sst_forecast_STAR_Pstar_40.ss")
  
  Fore <-SS_readforecast(
    file = forecast.file,
    version = '3.30',
    verbose = T,
    readAll = T
  )
  
  #model.dir <- file.path(here::here(), "model", "Sensitivity_Anal", "STAR_Panel", "5.21_STAR_decision_table_040", "2_23.dt.base", "run")
  model <- SS_output(model.dir)
  
  Fore$Flimitfraction <- 1
  Fore$Flimitfraction_m <- data.frame()
  
  forecast_catches <- model$timeseries %>% select(Yr, starts_with("dead(B)")) %>% filter(Yr > 2022)
  fore_catches = forecast_catches %>% 
    tidyr::pivot_longer(starts_with("dead(B)"), names_to="Fleet", values_to="Catch(or_F)") %>%
    mutate(
      Seas=1,
      Fleet = case_when(
        Fleet=="dead(B):_1" ~ 1,
        Fleet=="dead(B):_2" ~ 2,
        Fleet=="dead(B):_3" ~ 3
      )
    ) %>% 
    select(Yr, Seas, Fleet, "Catch(or_F)") %>%
    print(n=100)
  
  Fore$ForeCatch <- fore_catches
  
  SS_writeforecast(
    mylist =  Fore,
    dir = file.path(here::here(), "model"), 
    file = forecast.file,
    writeAll = TRUE,
    verbose = TRUE,
    overwrite = TRUE
  )
}








ForeFile = file.path(here::here(), "model/sst_forecast_STAR_Pstar_45.ss")

Fore <-SS_readforecast(
  file = ForeFile,
  version = '3.30',
  verbose = T,
  readAll = T
)

model.dir <- file.path(here::here(), "model", "Sensitivity_Anal", "Base_Model", "5.25_Decision_Table_045", "1_23.base.dt_base_45", "run")
model <- SS_output(model.dir)

Fore$Flimitfraction <- 1
Fore$Flimitfraction_m <- data.frame()

forecast_catches <- model$timeseries %>% select(Yr, starts_with("dead(B)")) %>% filter(Yr > 2022)
fore_catches = forecast_catches %>% 
  tidyr::pivot_longer(starts_with("dead(B)"), names_to="Fleet", values_to="Catch(or_F)") %>%
  mutate(
    Seas=1,
    Fleet = case_when(
      Fleet=="dead(B):_1" ~ 1,
      Fleet=="dead(B):_2" ~ 2,
      Fleet=="dead(B):_3" ~ 3
    )
  ) %>% 
  select(Yr, Seas, Fleet, "Catch(or_F)") %>%
  print(n=100)

Fore$ForeCatch <- fore_catches

SS_writeforecast(
  mylist =  Fore,
  dir = file.path(here::here(), "model"), 
  file = 'sst_forecast_STAR_Pstar_45.ss',
  writeAll = TRUE,
  verbose = TRUE,
  overwrite = TRUE
)
