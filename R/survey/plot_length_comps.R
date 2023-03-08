library(tidyverse)
source(file=file.path("R", "utils", "colors.R"))

# Function that reshapes SS3 length comps (e.g.,
# 'forSS/Survey_Sex3_Bins_6_72_LengthComps.csv' output from
# nwfscSurvey::SurveyLFs.fn) into a long format and calculates proportions from
# frequencies
# Credit: Jane Sullivan
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

read.survey.length.comp.data <- function(survey.name, fname="Survey_Sex3_Bins_6_72_LengthComps.csv"){
  return(
    read_csv(file.path(here::here(), "outputs", "surveys", survey.name, "forSS", fname), show_col_types = FALSE) %>% print()
  )
}

triennial1.lcs.raw  <- read.survey.length.comp.data("triennial1")
triennial2.lcs.raw  <- read.survey.length.comp.data("triennial2")
afsc.slope.lcs.raw  <- read.survey.length.comp.data("afsc_slope")
nwfsc.slope.lcs.raw <- read.survey.length.comp.data("nwfsc_slope")
nwfsc.combo.lcs.raw <- read.survey.length.comp.data("nwfsc_combo")

nw.slope.unsex.lcs.raw <- read.survey.length.comp.data("nwfsc_slope", "Survey_Sex_Unsexed_Bins_6_72_LengthComps.csv")
nw.combo.unsex.lcs.raw <- read.survey.length.comp.data("nwfsc_combo", "Survey_Sex_Unsexed_Bins_6_72_LengthComps.csv")

length.comps <- bind_rows(
    reshape_SScomps(df = triennial1.lcs.raw,     fleet_name = 'Triennial1', sex = 3), 
    reshape_SScomps(df = triennial2.lcs.raw,     fleet_name = 'Triennial2', sex = 3),
    reshape_SScomps(df = afsc.slope.lcs.raw,     fleet_name = 'AFSCslope',  sex = 3),
    reshape_SScomps(df = nwfsc.slope.lcs.raw,    fleet_name = 'NWFSCslope', sex = 3),
    reshape_SScomps(df = nwfsc.combo.lcs.raw,    fleet_name = 'NWFSCcombo', sex = 3),
    reshape_SScomps(df = nw.slope.unsex.lcs.raw, fleet_name = 'NWFSCslope', sex = 0),
    reshape_SScomps(df = nw.combo.unsex.lcs.raw, fleet_name = 'NWFSCcombo', sex = 0)
) %>% mutate(
    survey = recode_factor(
      fleet_name,
      !!!c(
        Triennial1 = "Triennial 1",
        Triennial2 = "Triennial 2",
        AFSCslope  = "AFSC Slope",
        NWFSCslope = "NWFSC Slope",
        NWFSCcombo = "WCGBT"
      )
    ),
    sex = recode_factor(
      sex, 
      !!!c(
        F  = "Female",
        M = "Male",
        U = "Unsexed"
      )
    )
  ) %>%
  select(-c(fleet_name)) %>%
  write_csv(file.path(here::here(), "data", "processed", "survey_length_comps.csv"))

years <- unique(sort(length.comps$year))
year.breaks <- years[seq(1, length(years), 2)]

getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

survey.means <- length.comps %>% 
  group_by(survey, sex) %>% 
  summarize(meanlength = mean(length_bin, na.rm = TRUE),
            modelength = getmode(rep(length_bin, freq*1000)))

ggplot(data = length.comps, 
       aes(x = length_bin, y = factor(year), height = prop, fill = survey)) +
  geom_density_ridges(stat = "identity", col = "lightgrey", alpha = 0.50, panel_scaling = TRUE, size = 0.5) +
  # geom_vline(data = survey.means, 
  #            aes(xintercept = modelength, col = survey, lty = survey),
  #            size = 1) +
  scale_x_continuous(breaks=seq(0, 70, 10))+
  scale_fill_colorblind7()+
  scale_color_colorblind7()+
  facet_wrap(~sex)+
  labs(x = "Length (cm)", y="Year", title="Shortspine Thornyhead Survey Length Compositions", fill="Survey")+
  theme_classic()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    panel.spacing.x = unit(0.5, "cm"),
    legend.position = "right",
    axis.text = element_text(size=12),
    axis.title = element_text(size=14),
    legend.text = element_text(size=12),
    legend.title = element_text(size=14),
    plot.title = element_text(size=18),
    strip.text = element_text(size=12)
  )+
  guides(
    fill = guide_legend(ncol=1)
  )

ggsave(file.path(here::here(), "outputs", "surveys", "2023_length_compositions.png"), dpi=300, width=12, height=10)

