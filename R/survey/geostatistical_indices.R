library(tidyverse)
library(ggplot2)

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

wcgbt.indices.dg <- read.geostat.index(file.path(here::here("data/processed/surveys"), "wcgbts_index_dg.Rdata"), "WCGBTS", "delta-gamma")
wcgbt.indices.dln <- read.geostat.index(file.path(here::here("data/processed/surveys"), "wcgbts_index_dln.Rdata"), "WCGBTS", "delta-lognormal")

triennial.indices.dg <- read.geostat.index(file.path(here::here("data/processed/surveys"), "triennial_index_dg.Rdata"), "Triennial", "delta-gamma")
triennial.indices.dln <- read.geostat.index(file.path(here::here("data/processed/surveys"), "triennial_index_dln.Rdata"), "Triennial", "delta-lognormal")

indices <- bind_rows(triennial.indices.dg, triennial.indices.dln, wcgbt.indices.dg, wcgbt.indices.dln)

ggplot(indices, aes(x=year, y=est, ymin=lwr, ymax=upr, color=area, fill=area, shape=survey, linetype=method))+
  #geom_pointrange()+
  geom_line()+
  geom_ribbon(alpha=0.25)+
  scale_color_colorblind()+
  scale_fill_colorblind()+
  scale_shape_manual(values=c(16, 1, 100))+
  scale_y_continuous(breaks=seq(0, 125000, 25000), labels=scales::comma)+
  labs(x="Year", y="Estimated Biomass (mt)", title="WCGBTS Model-based Index of Abundance", color="State")+
  guides(fill="none")+
  facet_wrap(~method)+
  theme_classic()+
  theme(
    panel.grid.major.y = element_line(),
    legend.position = "bottom"
  )+
  guides(linetype="none", shape="none")

ggsave(file.path(here::here(), "outputs", "surveys", "wcgbts_geostat_indices_comparison.png"), dpi=300, width=10, height=7, units = "in")

dbi <- read_csv(file.path(here::here(), "data", "processed", "surveys", "survey_indices_2023.csv"))
  # bind_rows(
  #   indices %>% 
  #     filter(area == "Total") %>% 
  #     select(year, est, lwr, upr, se, method) %>%
  #     mutate(
  #       Fleet=NA,
  #       Season=NA,
  #       survey="WCGBT"
  #     ) %>%
  #     rename(Value=est, lci=lwr, uci=upr, seLogB=se, Year=year) %>%
  #     relocate(Year, Season, Fleet, Value, seLogB, survey, lci, uci, method)  
  # )

format.indices <- indices %>% 
      filter(area == "Total") %>%
      select(year, est, lwr, upr, se, method, survey) %>%
      mutate(
        Fleet=NA,
        Season=NA,
        survey=case_when(survey == "Triennial" ~ "AFSC Triennial Shelf Survey 1",
                         survey == "WCGBTS" ~ "West Coast Groundfish Bottom Trawl Survey")
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
  scale_y_continuous(labels = scales::comma)+
  labs(x="Year", y="Estimated Biomass (mt)", color="Survey", fill="Survey")+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "bottom",
    axis.text = element_text(size=12),
    axis.title = element_text(size=12)
  )+
  guides(linetype="none", color=guide_legend(nrow=2))

ggsave(file.path(here::here(), "outputs", "surveys", "geostat_db_comp.png"), dpi=300, width=10, height=7, units = "in")
