# Length comp plotting function using ggridges

# set up ----
libs <- c('readr', 'dplyr', 'tidyr', 'ggplot2', 'ggthemes', 'ggridges', 'cowplot')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

outpath <- 'results'; dir.create(outpath)
outpath <- 'results/data_summaries'; dir.create(outpath)

# Function that reshapes SS3 length comps (e.g.,
# 'forSS/Survey_Sex3_Bins_6_72_LengthComps.csv' output from
# nwfscSurvey::SurveyLFs.fn) into a long format and calculates proportions from
# frequencies
reshape_SScomps <- function(df = nwslope, 
                            fleet_name = 'Triennial1', 
                            sex = 0) {
  
  if(!any(names(df[1:6]) %in% c('year', 'month', 'fleet', 'sex', 'partition', 'InputN'))) stop(
    "input dataframe should begin with the following column names: c('year', 'month', 'fleet', 'sex', 'partition', 'InputN')")
  
  if(!sex %in% c(0,3)) stop("input sex should be 0 for unsexed comps or 3 for sexed comps")
  
  # index for first plus group length bin
  i_plsgrp <- 6+(length(names(df))-6)/2
  
  # sex-specific comps (Sex = 3 in SS3)
  if(sex == 3) {
    df <- dplyr::bind_rows(
      df %>% # females
        dplyr::select(1, 3, 7:i_plsgrp) %>% 
        tidyr::pivot_longer(cols = -c(1:2), names_to = 'length_bin', values_to = 'freq') %>% 
        tidyr::separate(col = length_bin, into = c('sex', 'length_bin'), sep = 1),
      df %>% # males
        dplyr::select(1, 3, (i_plsgrp+1):length(names(df))) %>% 
        tidyr::pivot_longer(cols = -c(1:2), names_to = 'length_bin', values_to = 'freq') %>% 
        tidyr::separate(col = length_bin, into = c('sex', 'length_bin'), sep = 1)
    )
  }
  
  # unsexed comps (Sex = 0)
  if(sex == 0) {
    df <- df %>% # unsexed
      dplyr::select(1, 3, 7:i_plsgrp) %>% 
      tidyr::pivot_longer(cols = -c(1:2), names_to = 'length_bin', values_to = 'freq') %>% 
      tidyr::separate(col = length_bin, into = c('sex', 'length_bin'), sep = 1)
  }
  
  df <- df %>% 
    dplyr::mutate(fleet_name = fleet_name) %>% 
    dplyr::group_by(year, sex) %>%  
    dplyr::mutate(prop = freq/sum(freq)) %>% 
    dplyr::ungroup() %>% 
    dplyr::mutate(length_bin = as.numeric(length_bin)) %>% 
    dplyr::select(fleet, fleet_name, year, sex, length_bin, freq, prop)
  
  # test that the output is summing correctly
  tst <- df %>% group_by(sex, year) %>% summarize(tst = sum(prop)) %>% pull(tst) 
  if(!any(tst == 1)) warning(
    "proportions are not summing to 1, something is wrong with the supplied data set or the function.")
  
  return(df)
}

# Data ----

# sex-specific comps
tri1 <- read_csv('data/surveys/Triennial1/forSS/Survey_Sex3_Bins_6_72_LengthComps.csv')
tri2 <- read_csv('data/surveys/Triennial2/forSS/Survey_Sex3_Bins_6_72_LengthComps.csv')
akslope <- read_csv('data/surveys/AFSCslope/forSS/Survey_Sex3_Bins_6_72_LengthComps.csv')
combo <- read_csv('data/surveys/NWFSCcombo/forSS/Survey_Sex3_Bins_6_72_LengthComps.csv')

# unsexed comps
nwslope <- read_csv('data/surveys/NWFSCslope/forSS/Survey_Sex0_Bins_6_72_LengthComps.csv')
combo_nosex <- read_csv('data/surveys/NWFSCcombo/forSS/Survey_Sex0_Bins_6_72_LengthComps.csv')

# length comps -----
df <- reshape_SScomps(df = tri1, fleet_name = 'Triennial1', sex = 3) %>% 
  dplyr::bind_rows(reshape_SScomps(df = tri2, fleet_name = 'Triennial2', sex = 3)) %>% 
  dplyr::bind_rows(reshape_SScomps(df = akslope, fleet_name = 'AFSCslope', sex = 3)) %>% 
  dplyr::bind_rows(reshape_SScomps(df = combo, fleet_name = 'NWFSCcombo', sex = 3)) %>% 
  dplyr::bind_rows(reshape_SScomps(df = nwslope, fleet_name = 'NWFSCslope', sex = 0)) %>% 
  dplyr::bind_rows(reshape_SScomps(df = combo_nosex, fleet_name = 'NWFSCcombo', sex = 0))

df <- expand.grid(fleet = unique(df$fleet),
                  fleet_name = unique(df$fleet_name),
                  sex = unique(df$sex),
                  year = min(df$year):max(df$year)) %>% 
  left_join(df) %>% 
  mutate(fleet_name = factor(fleet_name))

p1 <- ggplot(data = df %>% 
               filter((between(length_bin, 6, 70))), 
             aes(x = length_bin, y = factor(year), height = prop, fill = fleet_name)) +
  geom_density_ridges(stat = "identity", col = "lightgrey", alpha = 0.45, 
                      panel_scaling = TRUE, size = 0.5) +
  ggthemes::scale_fill_colorblind() +
  labs(x = "Length (cm)", y = NULL, fill = NULL, title = "Shortspine thornyhead survey length compositions") + 
  theme_light() +
  theme(legend.position = "top") +
  facet_wrap(~sex)
p1

ggsave(paste0(outpath, '/survey_lencomps.png'), dpi=300, height=7, width=10, units='in')
