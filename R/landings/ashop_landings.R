library(dplyr)
library(tidyr)

# This function processes NorPAC data sent by V. Tuttle to K. Oken on 5/15/2023
# It is mostly copied from B. Langseth's code for canary rockfish:
# https://github.com/pfmc-assessments/canary_2023/blob/main/code/canary_ashop_processing.R

get_ashop_catches <- function(filename, early_sheet, early_sheet_exp, late_sheet, late_sheet_exp) {
  late <- readxl::read_excel(path = filename, 
                             sheet = late_sheet)
  late_exp <- readxl::read_excel(path = filename, 
                                 sheet = late_sheet_exp)
  late$year <- late$YEAR
  
  late$PERCENT_RETAINED[is.na(late$PERCENT_RETAINED)] = 100 #assume all retained if no information on it
  
  late <- left_join(late, late_exp, join_by("year" == "YEAR"))
  
  late_agg <- late %>% group_by(year) %>% 
    summarize(sum = sum(EXTRAPOLATED_WEIGHT_KG * `WEIGHT-BASED_EXPANSION_FACTOR`)/1000, 
              "just_landed" = sum(EXTRAPOLATED_WEIGHT_KG * PERCENT_RETAINED/100 * `WEIGHT-BASED_EXPANSION_FACTOR`)/1000)

  # Vanessa says don't worry about confidentiality if aggregating to coastwide
  # late_aggN <- late %>% group_by(year) %>%
  #   summarize(Np = length(unique(PERMIT)),
  #             Nc = length(unique(CATCHER_BOAT_ADFG)))
  
  if(!is.null(early_sheet)) {
    early <- readxl::read_excel(filename, 
                                sheet = early_sheet)
    early_exp <- readxl::read_excel(path = filename, 
                                    sheet = early_sheet_exp, range = "A1:B15") %>% 
      arrange(YEAR) 
    # 1975 expansion value same as 1976-1983 values
    # 1990 (early) expansion from form A-SHOP Expansion factors_updated_050123 in Canary rockfish google drive
    early_exp <- rbind(cbind("YEAR" = 1975, early_exp[2,2]),
                       early_exp,
                       cbind("YEAR" = 1990, "HAULS_SAMPLED_EXPANSION_FACTOR" = 1.478930759)) 
    early$year <- as.numeric(format(early$HAUL_DATE, "%Y"))
    early <- left_join(early, early_exp, join_by("year" == "YEAR"))
    
    early_agg <- early %>% group_by(year) %>% 
      summarize(sum = sum(SPECIES_EXTRAPOLATED_WT_KG * HAULS_SAMPLED_EXPANSION_FACTOR)/1000)
    # Vanessa says don't worry about confidentiality if aggregating to coastwide
    # early_aggN <- early %>% group_by(year) %>%
    #   summarize(Nv = length(unique(VESSEL_CODE)), #Catcher boats aren't recorded until 1984 so still have issues with CA < 1984
    #             Nc = length(unique(CATCHER_BOAT_ADFG))) 
    
    # aggN <- bind_rows(early_aggN, late_aggN) |>
    #   group_by(year) |>
    #   summarize(across(everything(), sum))
    
    #Combine and regroup because 1990 is in both datasets
    ashop_agg <- rbind(early_agg, late_agg[,c("year","sum")]) |>
      group_by(year) |>
      summarize(sum = sum(sum)) 
  } else {
    ashop_agg <- late_agg |>
      select(year, sum)
  }
  
  return(ashop_agg)
}

sst_catches <- get_ashop_catches(
  filename = 'data/raw/Thornyhead Catches_1975-2022_051523.xlsx',
  early_sheet = "SST_1975-1990 ",
  early_sheet_exp = "Expansion_Factors_1975-1990",
  late_sheet = "SST_1990-2022",
  late_sheet_exp = "Expansion_Factors_1990-2022"
)

lst_catches <- get_ashop_catches(
  filename = 'data/raw/Thornyhead Catches_1975-2022_051523.xlsx',
  early_sheet = "LST_1975-2022", # 2022 was a typo, it is actually 1990
  early_sheet_exp = "Expansion_Factors_1975-1990",
  late_sheet = "LST_1990-2022",
  late_sheet_exp = "Expansion_Factors_1990-2022"
)

unid_catches <- get_ashop_catches(
  filename = 'data/raw/Thornyhead Catches_1975-2022_051523.xlsx',
  early_sheet = NULL,
  early_sheet_exp = "Expansion_Factors_1975-1990",
  late_sheet = "TH_unID_1990-2022",
  late_sheet_exp = "Expansion_Factors_1990-2022"
)

lst_catches |>
  right_join(sst_catches, by = 'year', suffix = c('_lst', '_sst')) |> 
  mutate(sum_lst = ifelse(is.na(sum_lst), 0, sum_lst),
         pct_sst = sum_sst/(sum_sst + sum_lst)) |>
  left_join(unid_catches, by = 'year') |>
  mutate(sum = ifelse(is.na(sum), 0, sum),
    total_catch = sum_sst + sum * pct_sst) |>
  arrange(year) |> 
  select(year, total_catch) |>
  write.csv('data/processed/SST_ASHOP_landings.csv', row.names = FALSE)


