library(tidyverse)
library(ggplot2)
library(ggthemes)

source(file=file.path(here::here(), "R", "utils", "colors.R"))

read.geostat.index <- function(file, survey.name, method){
  load(file=file)
  indices <- as_tibble(index_areas) %>%
    mutate(
      area=recode_factor(
        area,
        !!!c(
          "coastwide" = "Total",
          "CA" = "California",
          "OR" = "Oregon",
          "WA" = "Washington"
        )
      ),
      method=method,
      survey=survey.name
    )
}

file.path <- file.path(here::here("data/processed/surveys"), "sdm_tmb_indices_2023.csv")
if(!file.exists(file.path)){
  wcgbt.indices.dg <- read.geostat.index(file.path(here::here("data/raw"), "wcgbts_index_dg.Rdata"), "WCGBTS", "delta-gamma")
  wcgbt.indices.dln <- read.geostat.index(file.path(here::here("data/raw"), "wcgbts_index_dln.Rdata"), "WCGBTS", "delta-lognormal")
  
  triennial.indices.dg <- read.geostat.index(file.path(here::here("data/raw"), "triennial_index_dg.Rdata"), "Triennial", "delta-gamma")
  triennial.indices.dln <- read.geostat.index(file.path(here::here("data/raw"), "triennial_index_dln.Rdata"), "Triennial", "delta-lognormal")
  
  nwfsc_slope.indices.dg <- read.geostat.index(file.path(here::here("data/raw"), "nwfsc_slope_index_dg.Rdata"), "NWFSC Slope", "delta-gamma")
  nwfsc_slope.indices.dln <- read.geostat.index(file.path(here::here("data/raw"), "nwfsc_slope_index_dln.Rdata"), "NWFSC Slope", "delta-lognormal")

  afsc_slope.indices.dg <- read.geostat.index(file.path(here::here("data/raw"), "afsc_slope_index_dg.Rdata"), "AFSC Slope", "delta-gamma")
  afsc_slope.indices.dln <- read.geostat.index(file.path(here::here("data/raw"), "afsc_slope_index_dln.Rdata"), "AFSC Slope", "delta-lognormal")
  
  
  indices <- bind_rows(triennial.indices.dg, triennial.indices.dln, 
                       wcgbt.indices.dg, wcgbt.indices.dln, 
                       nwfsc_slope.indices.dg, nwfsc_slope.indices.dln,
                       afsc_slope.indices.dg, afsc_slope.indices.dln) %>%
             mutate(
               survey=recode_factor(
                 survey, 
                 !!!c(
                   "Triennial" = "Triennial",
                   "AFSC Slope" = "AFSC Slope Survey",
                   "NWFSC Slope" = "NWFSC Slope Survey",
                   "WCGBTS" = "WCGBTS"
                 )
               )
             )
  write.csv(indices, file.path(here::here("data/processed/surveys"), "sdm_tmb_indices_2023.csv"))
  
}

# File path for depth covariate included
file.path <- file.path(here::here("data/processed/surveys"), "sdm_tmb_indices_2023_depth.csv")
if(!file.exists(file.path)){
  wcgbt.indices.dg <- read.geostat.index(file.path(here::here("data/raw"), "wcgbts_index_dg_depth.Rdata"), "WCGBTS", "delta-gamma")
  wcgbt.indices.dln <- read.geostat.index(file.path(here::here("data/raw"), "wcgbts_index_dln_depth.Rdata"), "WCGBTS", "delta-lognormal")
  
  triennial.indices.dg <- read.geostat.index(file.path(here::here("data/raw"), "triennial_index_dg_depth.Rdata"), "Triennial", "delta-gamma")
  triennial.indices.dln <- read.geostat.index(file.path(here::here("data/raw"), "triennial_index_dln_depth.Rdata"), "Triennial", "delta-lognormal")
  
  nwfsc_slope.indices.dg <- read.geostat.index(file.path(here::here("data/raw"), "nwfsc_slope_index_dg.Rdata"), "NWFSC Slope", "delta-gamma")
  nwfsc_slope.indices.dln <- read.geostat.index(file.path(here::here("data/raw"), "nwfsc_slope_index_dln.Rdata"), "NWFSC Slope", "delta-lognormal")
  
  afsc_slope.indices.dg <- read.geostat.index(file.path(here::here("data/raw"), "afsc_slope_index_dg.Rdata"), "AFSC Slope", "delta-gamma")
  afsc_slope.indices.dln <- read.geostat.index(file.path(here::here("data/raw"), "afsc_slope_index_dln.Rdata"), "AFSC Slope", "delta-lognormal")
  
  
  indices <- bind_rows(triennial.indices.dg, triennial.indices.dln, 
                       wcgbt.indices.dg, wcgbt.indices.dln, 
                       nwfsc_slope.indices.dg, nwfsc_slope.indices.dln,
                       afsc_slope.indices.dg, afsc_slope.indices.dln) %>%
    mutate(
      survey=recode_factor(
        survey, 
        !!!c(
          "Triennial" = "Triennial",
          "AFSC Slope" = "AFSC Slope Survey",
          "NWFSC Slope" = "NWFSC Slope Survey",
          "WCGBTS" = "WCGBTS"
        )
      )
    )
  write.csv(indices, file.path(here::here("data/processed/surveys"), "sdm_tmb_indices_2023_depth.csv"))
  
}

indices <- read_csv(file.path, col_names = TRUE, col_types="dfddddddff") %>% 
  filter(method=="delta-gamma") %>%
  mutate(
    area=case_when(area=="Total" ~ "Coastwide",
                   area=="California" ~ "California",
                   area=="Oregon" ~ "Oregon",
                   area=="Washington" ~ "Washington")
  )

ggplot(indices , aes(x=year, y=est, ymin=lwr, ymax=upr, color=area, fill=area, shape=survey, linetype=area))+
  #geom_pointrange()+
  geom_line()+
  geom_ribbon(alpha=0.25)+
  scale_color_colorblind7()+
  scale_fill_colorblind7()+
  scale_shape_manual(values=c(16, 1, 100, 20))+
  scale_y_continuous(breaks=seq(0, 125000, 25000), labels=scales::comma)+
  labs(x="Year", y="Estimated Biomass (mt)", title="Model-based Indices of Abundance", color="State")+
  guides(fill="none")+
  facet_wrap(~survey)+
  theme_classic()+
  theme(
    panel.grid.major.y = element_line(),
    legend.position = "bottom"
  )+
  guides(linetype="none", shape="none")

ggsave(file.path(here::here(), "outputs", "surveys", "wcgbts_geostat_indices_state_comparison.png"), dpi=300, width=10, height=7, units = "in")

ggplot(indices, aes(x=year, y=est, ymin=lwr, ymax=upr, color=area, fill=area))+
  #geom_pointrange()+
  geom_line()+
  geom_ribbon(alpha=0.25)+
  scale_color_colorblind()+
  scale_fill_colorblind()+
  scale_shape_manual(values=c(16, 1, 100))+
  #scale_y_continuous(breaks=seq(0, 125000, 25000), labels=scales::comma)+
  labs(x="Year", y="Estimated Biomass (mt)", title="WCGBTS Model-based Index of Abundance", color="State")+
  guides(fill="none")+
  facet_grid(rows=vars(survey), cols=vars(method), scales="free_y")+
  theme_classic()+
  theme(
    panel.grid.major.y = element_line(),
    legend.position = "bottom"
  )+
  guides(linetype="none", shape="none")




dbi <- read_csv(file.path(here::here(), "data", "processed", "surveys", "survey_indices_2023.csv")) %>%
    #filter(survey %in% c("AFSC Triennial Shelf Survey 1", "AFSC Triennial Shelf Survey 2", "West Coast Groundfish Bottom Trawl Survey")) %>%
    mutate(
      assessment="2023",
      survey=case_when(survey == "AFSC Triennial Shelf Survey 1" ~ "Triennial",
                       survey == "AFSC Triennial Shelf Survey 2" ~ "Triennial 2",
                       survey == "NWFSC Slope Survey" ~ "NWSlope",
                       survey == "AFSC Slope Survey" ~ "AKSlope",
                       survey == "West Coast Groundfish Bottom Trawl Survey" ~ "WCGBTS")
    )
    
    # bind_rows(
    #   read_csv(file.path(here::here(), "data" ,"processed", "surveys", "survey_indices_2013.csv")) %>%
    #     mutate(assessment="2013")
    # )

format.indices <- indices %>% 
      filter(area == "Coastwide") %>%
      dplyr::select(year, est, lwr, upr, se, method, survey) %>%
      mutate(
        Fleet=NA,
        Season=NA,
        survey=case_when(survey == "Triennial" ~ "Triennial",
                         survey == "WCGBTS" ~ "West Coast Groundfish Bottom Trawl Survey",
                         survey == "NWFSC Slope Survey" ~ "NWSlope",
                         survey == "AFSC Slope Survey" ~ "AKSlope")
      ) %>%
      rename(Value=est, lci=lwr, uci=upr, seLogB=se, Year=year) %>%
      relocate(Year, Season, Fleet, Value, seLogB, survey, lci, uci, method) %>% 
      filter(method=="delta-gamma")

ggplot(dbi, aes(x=Year, y=Value, ymin=lci, ymax=uci, color=survey, fill=survey, group=survey))+
  geom_pointrange(linetype="longdash")+
  geom_line(data=format.indices , aes(group=survey, linetype=method))+
  geom_ribbon(data=format.indices, aes(linetype=method), alpha=0.25)+
  scale_color_colorblind7()+
  scale_fill_colorblind7()+
  scale_y_continuous(labels = scales::comma, breaks=seq(0, 100000, 20000))+
  coord_cartesian(ylim=c(0, 100000), expand = FALSE)+
  labs(x="Year", y="Estimated Biomass (mt)", color="Survey", fill="Survey", title="Shortspine Thornyhead Survey Abundance Indices")+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "bottom",
    axis.text = element_text(size=12),
    axis.title = element_text(size=12)
  )+
  guides(linetype="none", color=guide_legend(ncol=2))

ggsave(file.path(here::here(), "outputs", "surveys", "geostat_db_comp_wgcbts_tri.png"), dpi=300, width=10, height=7, units = "in")
