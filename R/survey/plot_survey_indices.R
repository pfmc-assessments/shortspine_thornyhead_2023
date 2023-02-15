library(tidyverse)
source(file=file.path(here::here(), "R", "survey", "survey_utils.R"))

# Read index values for each survey
afsc.triennial1.idx <- read.index.data("triennial1")
afsc.triennial2.idx <- read.index.data("triennial2")
afsc.slope.idx  <- read.index.data("afsc_slope")
nwfsc.slope.idx <- read.index.data("nwfsc_slope")
nwfsc.combo.idx <- read.index.data("nwfsc_combo")

survey.indices <- bind_rows(
  afsc.triennial1.idx,
  afsc.triennial2.idx,
  afsc.slope.idx,
  nwfsc.slope.idx,
  nwfsc.combo.idx
) %>%
  mutate(
    lci = Value-1.96*Value*seLogB,  # Lower 95% CI
    uci = Value+1.96*Value*seLogB,  # Upper 95% CI
    survey = recode_factor(         # Change survey to a factor
      survey, 
      !!!c(
        triennial1 = "AFSC Triennial Shelf Survey 1",
        triennial2 = "AFSC Triennial Shelf Survey 2",
        afsc_slope = "AFSC Slope Survey",
        nwfsc_slope = "NWFSC Slope Survey",
        nwfsc_combo = "West Coast Groundfish Bottom Trawl Survey"
      )
    ),
  ) %>%
  write_csv(  # Save survey indices to processed data directory
    file.path(here::here(), "data", "processed", "survey_indices_2023.csv")
  )

# Create single plot of all survey indices as point ranges
ggplot(survey.indices, aes(x=Year, y=Value, color=survey))+
  geom_pointrange(aes(ymin=lci, ymax=uci))+
  scale_x_continuous(breaks=seq(1980, 2022, 5))+
  scale_y_continuous(breaks=seq(0, 12500, 2500), labels=scales::comma)+
  coord_cartesian(expand=0, ylim=c(0, 12500))+
  labs(
    x="Year",
    y="Biomass (mt)",
    title="Shortspine Thornyhead Survey Abundance Indices",
    fill="Survey",
    color="Survey"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line()
  )

# Create single plot of all survey indices as points and confidence ribbons
ggplot(survey.indices, aes(x=Year, y=Value, color=survey, fill=survey)) +
  geom_point()+
  geom_line()+
  geom_ribbon(aes(ymin=lci, ymax=uci), alpha=0.2)+
  scale_x_continuous(breaks=seq(1980, 2022, 5))+
  scale_y_continuous(breaks=seq(0, 12500, 2500), labels=scales::comma)+
  coord_cartesian(expand=0, ylim=c(0, 12500))+
  labs(
    x="Year",
    y="Biomass (mt)",
    title="Shortspine Thornyhead Survey Abundance Indices",
    fill="Survey",
    color="Survey"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line()
  )

# Created faceted plot of survey indices as point ranges
ggplot(survey.indices, aes(x=Year, y=Value, color=survey))+
  geom_pointrange(aes(ymin=lci, ymax=uci))+
  facet_wrap(~survey, scales="free_x")+
  scale_y_continuous(breaks=seq(0, 12500, 2500), labels=scales::comma)+
  coord_cartesian(expand=1, ylim=c(0, 12500))+
  labs(
    x="Year",
    y="Biomass (mt)",
    title="Shortspine Thornyhead Survey Abundance Indices",
    fill="Survey",
    color="Survey"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "none"
  )

# Create facest plot of survey indices as points and confidence ribbons
ggplot(survey.indices, aes(x=Year, y=Value, color=survey, fill=survey))+
  geom_point()+
  geom_line()+
  geom_ribbon(aes(ymin=lci, ymax=uci), alpha=0.2)+
  facet_wrap(~survey, scales="free_x")+
  scale_y_continuous(breaks=seq(0, 12500, 2500), labels=scales::comma)+
  coord_cartesian(expand=1, ylim=c(0, 12500))+
  labs(
    x="Year",
    y="Biomass (mt)",
    title="Shortspine Thornyhead Survey Abundance Indices",
    fill="Survey",
    color="Survey"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "none"
  )
