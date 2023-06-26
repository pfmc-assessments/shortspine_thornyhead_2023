library(tidyverse)
library(kableExtra)
library(rvest)
library(r4ss) 
library(dplyr) 
library(reshape2) 
library(stringr)

fsep <- .Platform$file.sep #easy for file.path() function 

# Directories 
# Path to the model folder 
dir_model <- file.path(here::here(), 'model', fsep = fsep)

# Path to the Executable folder 
Exe_path <- file.path(dir_model, 'ss_executables') 

# Path to the R folder 
dir_script <- file.path(here::here(), 'R', fsep = fsep)

# Path to the Sensitivity analysis folder 
dir_SensAnal <- file.path(dir_model, 'Sensitivity_Anal', 'Base_model', fsep = fsep)

# Path to data folder 
dir_data <- file.path(here::here(), 'data', 'for_ss', fsep = fsep)

# Useful function
source(file=file.path(dir_script,'utils','clean_functions.R', fsep = fsep))
source(file=file.path(dir_script,'utils','ss_utils.R', fsep=fsep))
source(file=file.path(dir_script,'utils','sensistivity_analysis_utils.R', fsep=fsep))

# Load the .Rdata object with the parameters and data for 2023
load(file.path(dir_data,'SST_SS_2023_Data_Parameters.RData', fsep = fsep))

# Path to the 23.dt.low repertory
Dir_23_dt_low <- file.path(dir_SensAnal, '5.24_Decision_Table_040','2_23.base.dt_low_40' , 'run',fsep = fsep)

# Path to the 23.dt.base repertory
Dir_23_dt_base <- file.path(dir_SensAnal, '5.24_Decision_Table_040','1_23.base.dt_base_40' , 'run',fsep = fsep)

# Path to the 23.dt.high repertory
Dir_23_dt_high <- file.path(dir_SensAnal, '5.24_Decision_Table_040','3_23.base.dt_high_40' , 'run',fsep = fsep)

# Path to the 23.dt.low_045 repertory
Dir_23_dt_low_045 <- file.path(dir_SensAnal, '5.25_Decision_Table_045','2_23.base.dt_low_45' , 'run',fsep = fsep)

# Path to the 23.dt.base_045 repertory
Dir_23_dt_base_045 <- file.path(dir_SensAnal, '5.25_Decision_Table_045','1_23.base.dt_base_45' , 'run',fsep = fsep)

# Path to the 23.dt.high_045 repertory
Dir_23_dt_high_045 <- file.path(dir_SensAnal, '5.25_Decision_Table_045','3_23.base.dt_high_45' , 'run',fsep = fsep)



low.dt.040 <- SS_decision_table_stuff(
  SS_output(Dir_23_dt_low),
  yrs=2023:2035,
)

base.dt.040 <- SS_decision_table_stuff(
  SS_output(Dir_23_dt_base),
  yrs=2023:2035,
)

high.dt.040 <- SS_decision_table_stuff(
  SS_output(Dir_23_dt_high),
  yrs=2023:2035,
)

low.dt.045 <- SS_decision_table_stuff(
  SS_output(Dir_23_dt_low_045),
  yrs=2023:2035,
)

base.dt.045 <- SS_decision_table_stuff(
  SS_output(Dir_23_dt_base_045),
  yrs=2023:2035,
)

high.dt.045 <- SS_decision_table_stuff(
  SS_output(Dir_23_dt_high_045),
  yrs=2023:2035,
)


decision_table_long <- bind_rows(low.dt.040, base.dt.040, high.dt.040, low.dt.045, base.dt.045, high.dt.045) %>%
  as_tibble %>%
  mutate(
    Pstar=c(rep(0.40, 3*nrow(low.dt.040)), rep(0.45, 3*nrow(low.dt.040))),
    State=rep(c(rep("Low", nrow(low.dt.040)), rep("Base", nrow(base.dt.040)), rep("High", nrow(high.dt.040))), 2)
  ) %>%
  rename(Yr=yr,Catch=catch,SO=SpawnBio,Depletion=dep) %>%
  write_csv(file.path(here::here(), "data", "ss_outputs", "decision_table_values.csv")) %>%
  print(n=25)

decision_table  = read.csv(file = file.path(here::here(), "data", "ss_outputs", "decision_table_values.csv"))
decision_table = decision_table[,1:6]

pstar0.4 = decision_table %>%
  mutate(Pstar = recode(Pstar, "0.4" = 'P* = 0.4', "0.45" = 'P* = 0.45')) %>%
  filter(Pstar == 'P* = 0.4') %>% 
  select(Yr, Catch, Pstar, SO, Depletion, State) %>% 
  pivot_wider(names_from = State, 
              values_from = c(SO, Depletion)) %>% 
  select("Pstar", "Yr", 'Catch',
         "SO_Low", "Depletion_Low",
         "SO_Base", "Depletion_Base",
         "SO_High", "Depletion_High") 

pstar0.45 = decision_table %>%
  mutate(Pstar = recode(Pstar, "0.4" = 'P* = 0.4', "0.45" = 'P* = 0.45')) %>%
  filter(Pstar == 'P* = 0.45') %>% 
  select(Yr, Catch, Pstar, SO, Depletion, State) %>% 
  pivot_wider(names_from = State, 
              values_from = c(SO, Depletion)) %>% 
  select("Pstar", "Yr", 'Catch',
         "SO_Low", "Depletion_Low",
         "SO_Base", "Depletion_Base",
         "SO_High", "Depletion_High") 

decision_data_wide = rbind(pstar0.4, pstar0.45)

decision_data_wide %>% 
  #select(-Pstar) %>% 
  kbl(col.names = c("", "Year", "Catch", 
                    "SO", "Dep.",
                    "SO", "Dep.",
                    "SO", "Dep."),
      align = "c") %>% 
  kable_classic(full_width = F, html_font = "Times New Roman") %>% 
  add_header_above(c(" " = 3, "Low State\nof Nature\n(M = 0.03)" = 2, "Base State of\nNature\n(M = 0.04)" = 2, "High State of\nNature\n(M = 0.05)" = 2))  %>% 
  column_spec(c(1,3,5,7,9), border_right = "1.5px solid black") %>%
  column_spec (1, border_left = "1.5px solid black")  %>%
  collapse_rows(columns = 1, valign = "middle") %>%
  row_spec(13, extra_css = "border-top: 1.5px solid;")

  





  