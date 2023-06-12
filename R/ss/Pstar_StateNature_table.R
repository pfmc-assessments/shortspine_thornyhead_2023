library(tidyverse)
library(kableExtra)
library(rvest)

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
  add_header_above(c(" " = 3, "High State\nof Nature\n(M = 0.03)" = 2, "Base State of\nNature\n(M = 0.04)" = 2, "Low State of\nNature\n(M = 0.05)" = 2))  %>% 
  column_spec(c(1,3,5,7,9), border_right = "1.5px solid black") %>%
  column_spec (1, border_left = "1.5px solid black")  %>%
  collapse_rows(columns = 1, valign = "middle") %>%
  row_spec(13, extra_css = "border-top: 1.5px solid;")
  





  