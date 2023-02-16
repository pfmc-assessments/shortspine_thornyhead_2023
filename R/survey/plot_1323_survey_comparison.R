library(tidyverse)

abundance.idxs.2023 <- read_csv(
  file.path(here::here(), "data", "processed", "survey_indices_2023.csv")
) %>% 
  rename(
    Seas=Season,
    Fishery=Fleet,
    sd_log = seLogB,
    Survey = survey
  ) %>%
  mutate(
    Seas=1,
    Fishery=5,
    assessment = "2023"
  ) %>%
  print()

abundance.idxs.2013 <- read_csv(
  file.path(here::here(), "data", "processed", "survey_indices_2013.csv")
) %>% 
  mutate(
    lci = Value-1.96*Value*sd_log,
    uci = Value+1.96*Value*sd_log,
    Survey = recode_factor(         # Change survey to a factor
      Survey, 
      !!!c(
        Triennial1 = "AFSC Triennial Shelf Survey 1",
        Triennial2 = "AFSC Triennial Shelf Survey 2",
        AFSCslope  = "AFSC Slope Survey",
        NWFSCslope = "NWFSC Slope Survey",
        NWFSCcombo = "West Coast Groundfish Bottom Trawl Survey"
      )
    ),
    assessment = "2013"
  ) %>%
  print()

# Checking relative difference between 2013 and 2023 indices, since scales
# dont match up. Didn't really find anything.
#
abundance.idxs.2013 %>%
  left_join(abundance.idxs.2023, by=c("Year", "Survey"), suffix=c(".2013", ".2023")) %>%
  select(Year, Survey, Value.2013, sd_log.2013, lci.2013, uci.2013, Value.2023, sd_log.2023, lci.2023, uci.2023) %>%
  mutate(
    rel = Value.2013/Value.2023
  ) %>%
  print(n=100)

abundance.idxs <- bind_rows(abundance.idxs.2013, abundance.idxs.2023)

ggplot(abundance.idxs, aes(x=Year, y=log(Value), col=assessment, linetype=assessment))+
  geom_pointrange(aes(ymin=log(lci), ymax=log(uci)))+
  facet_wrap(~Survey, scale="free")+
  scale_y_continuous(
    breaks=seq(5, 12, 1), 
    labels=scales::comma,
    #sec.axis = sec_axis( ~ .*1/5, name="2023")
  )+
  coord_cartesian(expand=1)+
  labs(
    x="Year",
    y="Log Biomass",
    title="Shortspine Thornyhead Survey Abundance Indices",
    fill="Assessment",
    color="Assessment",
    linetype="Assessment"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "bottom",
    panel.spacing = unit(0.5, "cm")
  )

ggplot(abundance.idxs, aes(x=Year, y=log(Value), col=assessment, fill=assessment, linetype=assessment))+
  geom_point()+
  geom_line()+
  geom_ribbon(aes(ymin=log(lci), ymax=log(uci)), alpha=0.4)+
  facet_wrap(~Survey, scales = "free")+
  #scale_y_continuous(breaks=seq(0, 75000, 10000), labels=scales::comma)+
  coord_cartesian(expand=1)+
  labs(
    x="Year",
    y="Log Biomass",
    title="Shortspine Thornyhead Survey Abundance Indices",
    fill="Assessment",
    color="Assessment",
    linetype="Assessment"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "bottom"
  )+
  guides(linetype="none")

ggplot(abundance.idxs, aes(x=Year, y=Value, col=assessment, fill=assessment, linetype=assessment))+
  geom_point()+
  geom_line()+
  geom_ribbon(aes(ymin=lci, ymax=uci), alpha=0.2)+
  facet_wrap(~Survey, scale="free_x")+
  coord_cartesian(expand=1)+
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

baseline.idx.2013 <- abundance.idxs.2013 %>%
  group_by(Survey) %>%
  filter(row_number()==1) %>%
  print(n=10)

baseline.idx.2023 <- abundance.idxs.2023 %>%
  group_by(Survey) %>%
  filter(row_number()==1) %>%
  print(n=10)

rel.abundance.idxs <- abundance.idxs.2013 %>%
  select(Year, Survey, Value, sd_log, lci, uci) %>%
  group_by(Survey, Year) %>%
  summarise(
    baseline = as.numeric(baseline.idx.2013[baseline.idx.2013$Survey == Survey, "Value"]),
    Value = Value / baseline,
    lci   = lci   / baseline,
    uci   = uci   / baseline,
  ) %>%
  select(-c(baseline)) %>%
  mutate(
    assessment="2013"
  ) %>%
  bind_rows(
    abundance.idxs.2023 %>%
      select(Year, Survey, Value, sd_log, lci, uci) %>%
      group_by(Survey, Year) %>%
      summarise(
        baseline = as.numeric(baseline.idx.2023[baseline.idx.2023$Survey == Survey, "Value"]),
        Value = Value / baseline,
        lci   = lci   / baseline,
        uci   = uci   / baseline,
      ) %>%
      select(-c(baseline)) %>%
      mutate(
        assessment = "2023"
      )
  ) %>%
  print()


ggplot(rel.abundance.idxs, aes(x=Year, y=Value, col=assessment, linetype=assessment))+
  geom_pointrange(aes(ymin=lci, ymax=uci))+
  facet_wrap(~Survey, scales="free_x")+
  scale_y_continuous(
    breaks=seq(0, 2, 0.5), 
    labels=scales::comma,
    #sec.axis = sec_axis( ~ .*1/5, name="2023")
  )+
  coord_cartesian(expand=1, ylim=c(0, 2))+
  labs(
    x="Year",
    y="Relative Index Value",
    title="Shortspine Thornyhead Survey Abundance Indices",
    fill="Assessment",
    color="Assessment",
    linetype="Assessment"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "bottom",
    panel.spacing = unit(0.5, "cm")
  )
