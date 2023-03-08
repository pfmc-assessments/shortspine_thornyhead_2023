library(tidyverse)

survey.indices.2013 <- read_csv(
  file.path(here::here(), "data", "processed", "survey_indices_2013.csv")
) %>% 
  mutate(
    lci = Value-1.96*Value*sd_log,
    uci = Value+1.96*Value*sd_log,
    survey = recode_factor(         # Change survey to a factor
      Survey, 
      !!!c(
        Triennial1 = "AFSC Triennial Shelf Survey 1",
        Triennial2 = "AFSC Triennial Shelf Survey 2",
        AFSCslope  = "AFSC Slope Survey",
        NWFSCslope = "NWFSC Slope Survey",
        NWFSCcombo = "West Coast Groundfish Bottom Trawl Survey"
      )
    )
  ) %>%
  print()

# Create single plot of all survey indices as point ranges
ggplot(survey.indices.2013, aes(x=Year, y=Value, color=survey))+
  geom_pointrange(aes(ymin=lci, ymax=uci))+
  scale_x_continuous(breaks=seq(1980, 2022, 5))+
  scale_y_continuous(breaks=seq(0, 80000, 10000), labels=scales::comma)+
  coord_cartesian(expand=0, ylim=c(0, 80000))+
  labs(
    x="Year",
    y="Biomass (mt)",
    title="2013 Shortspine Thornyhead Survey Abundance Indices",
    fill="Survey",
    color="Survey"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line()
  )

# Create single plot of all survey indices as points and confidence ribbons
ggplot(survey.indices.2013, aes(x=Year, y=Value, color=survey, fill=survey)) +
  geom_point()+
  geom_line()+
  geom_ribbon(aes(ymin=lci, ymax=uci), alpha=0.2)+
  scale_x_continuous(breaks=seq(1980, 2022, 5))+
  scale_y_continuous(breaks=seq(0, 80000, 10000), labels=scales::comma)+
  coord_cartesian(expand=0, ylim=c(0, 80000))+
  labs(
    x="Year",
    y="Biomass (mt)",
    title="2013 Shortspine Thornyhead Survey Abundance Indices",
    fill="Survey",
    color="Survey"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line()
  )

# Created faceted plot of survey indices as point ranges
ggplot(survey.indices.2013, aes(x=Year, y=Value, color=survey))+
  geom_pointrange(aes(ymin=lci, ymax=uci))+
  facet_wrap(~survey, scales="free_x")+
  scale_y_continuous(breaks=seq(0, 80000, 10000), labels=scales::comma)+
  coord_cartesian(expand=0, ylim=c(0, 80000))+
  labs(
    x="Year",
    y="Biomass (mt)",
    title="2013 Shortspine Thornyhead Survey Abundance Indices",
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
ggplot(survey.indices.2013, aes(x=Year, y=Value, color=survey, fill=survey))+
  geom_point()+
  geom_line()+
  geom_ribbon(aes(ymin=lci, ymax=uci), alpha=0.2)+
  facet_wrap(~survey, scales="free_x")+
  scale_y_continuous(breaks=seq(0, 80000, 10000), labels=scales::comma)+
  coord_cartesian(expand=0, ylim=c(0, 80000))+
  labs(
    x="Year",
    y="Biomass (mt)",
    title="2013 Shortspine Thornyhead Survey Abundance Indices",
    fill="Survey",
    color="Survey"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "none"
  )
