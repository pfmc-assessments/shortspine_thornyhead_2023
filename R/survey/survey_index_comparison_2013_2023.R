library(tidyverse)

abundance.idxs.2023 <- read_csv(
  file.path(here::here(), "data", "processed", "surveys", "survey_indices_2023.csv")
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
    assessment = "2023",
    Survey = case_when(Survey == "AFSC Triennial Shelf Survey 1" ~ "Triennial 1",
                         Survey == "AFSC Triennial Shelf Survey 2" ~ "Triennial 2",
                         Survey == "AFSC Slope Survey" ~ "AFSC Slope",
                         Survey == "NWFSC Slope Survey" ~ "NWFSC Slope",
                         Survey == "West Coast Groundfish Bottom Trawl Survey" ~ "WCGBT")
  ) %>%
  print()

abundance.idxs.2013 <- read_csv(
  file.path(here::here(), "data", "processed", "surveys", "survey_indices_2013.csv")
) %>% 
  mutate(
    lci = Value-1.96*Value*sd_log,
    uci = Value+1.96*Value*sd_log,
    assessment = "2013",
    Survey = case_when(Survey == "Triennial1" ~ "Triennial 1",
                       Survey == "Triennial2" ~ "Triennial 2",
                       Survey == "AFSCslope" ~ "AFSC Slope",
                       Survey == "NWFSCslope" ~ "NWFSC Slope",
                       Survey == "NWFSCcombo" ~ "WCGBT")
  ) %>%
  print()

# Checking relative difference between 2013 and 2023 indices, since scales
# dont match up. Didn't really find anything.
#
# abundance.idxs.2013 %>%
#   left_join(abundance.idxs.2023, by=c("Year", "Survey"), suffix=c(".2013", ".2023")) %>%
#   select(Year, Survey, Value.2013, sd_log.2013, lci.2013, uci.2013, Value.2023, sd_log.2023, lci.2023, uci.2023) %>%
#   mutate(
#     rel = Value.2013/Value.2023
#   ) %>%
#   print(n=100)

abundance.idxs <- bind_rows(abundance.idxs.2013, abundance.idxs.2023) %>%
  mutate(
    Survey = factor(Survey, levels=c("Triennial 1", "Triennial 2", "AFSC Slope", "NWFSC Slope", "WCGBT"))
    )

ggplot(abundance.idxs, aes(x=Year, y=Value, color=Survey, fill=Survey, shape=assessment)) +
  geom_point()+
  geom_line()+
  geom_ribbon(data=abundance.idxs.2023, aes(ymin=lci, ymax=uci), alpha=0.2)+
  geom_pointrange(data=abundance.idxs.2013, aes(ymin=lci, ymax=uci), alpha=0.2)+
  scale_x_continuous(breaks=seq(1980, 2022, 5))+
  scale_y_continuous(breaks=seq(0, 110000, 20000), labels=scales::comma)+
  scale_shape_manual(values=c(1, 15))+
  coord_cartesian(expand=0, ylim=c(0, 110000))+
  labs(
    x="Year",
    y="Biomass (mt)",
    title="Shortspine Thornyhead Survey Abundance Indices",
    fill="Survey",
    color="Survey"
  )+
  scale_color_colorblind7()+
  scale_fill_colorblind7()+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "bottom",
    axis.text = element_text(size=14),
    axis.title = element_text(size=16),
    legend.text = element_text(size=14),
    legend.title = element_blank()
  )+
  guides(color=guide_legend(nrow=2), shape="none")

ggsave(file.path(here::here(), "outputs", "surveys", "2013_2023_survey_indices_comparison.png"), dpi=300, width=12, height=7)




# Plot 2013 and 2023 surveys together as point ranges on original scale
ggplot(abundance.idxs, aes(x=Year, y=Value, col=assessment, linetype=assessment))+
  geom_pointrange(aes(ymin=lci, ymax=uci))+
  facet_wrap(~Survey)+
  scale_y_continuous(
    breaks=seq(0, 110000, 10000), 
    labels=scales::comma,
    #sec.axis = sec_axis( ~ .*1/5, name="2023")
  )+
  coord_cartesian(expand=1)+
  labs(
    x="Year",
    y="Biomass",
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

# Same plot but on log scale and with free axes
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
    fill="Assessment",
    color="Assessment",
    linetype="Assessment"
  )+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "bottom"
  )


# All of this standardizes the abundance indices to be relative to the
# index value in the first year of each survey. This allows for plotting
# the indexes from 2013 and 2023 on identical scales and analyzing the
# overall trend in each index, to ensure that index trends match between 
# the 2013 and 2023 assessments.
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


# Try and manually do the CPUE index calculation to see if there is a problem
# with the nwfscSurvey package, or if the 2013 assessment is doing something
# strange that is undocumented.
#
# nwfsc.combo.data <- read_csv(file.path(here::here(), "data", "raw", "nwfsc_combo_survey_catch.csv"), show_col_types=FALSE) %>%
#   select(Trawl_id, Year, Pass, Tow, Area_Swept_ha, Depth_m, Latitude_dd, total_catch_wt_kg, CPUE_kg_per_ha, cpue_kg_km2) %>%
#   print(n=10)
# 
# strata = CreateStrataDF.fn(
#   names          = c("shallow_south", "deep_south", "shallow_cen", "deep_cen", "shallow_north", "mid_north", "deep_north"), 
#   depths.shallow = c(183, 549, 183, 549, 100, 183, 549), 
#   depths.deep    = c(549, 1280, 549, 1280, 183, 549, 1280),
#   lats.south     = c(32, 32, 34.5, 34.5, 40.5, 40.5, 40.5),
#   lats.north     = c(34.5, 34.5, 40.5, 40.5, 49, 49, 49) 
# )
# 
# n.strata <- nrow(strata)
# years <- unique(nwfsc.combo.data$Year)
# n.years <- length(years)
# 
# index <- rep(NA, n.years)
# j = 0
# for(y in years){
#   j <- j+1
#   strata.indices <- rep(NA, n.strata)
#   for(i in 1:n.strata){
#     min.depth <- strata$Depth_m.1[i]
#     max.depth <- strata$Depth_m.2[i]
#     min.lat <- strata$Latitude_dd.1[i]
#     max.lat <- strata$Latitude_dd.2[i]
#     
#     strata.cpue <- nwfsc.combo.data %>%
#       filter(
#         Year == y,
#         Depth_m > min.depth,
#         Depth_m <= max.depth,
#         Latitude_dd > min.lat,
#         Latitude_dd <= max.lat
#       ) %>%
#       pull(cpue_kg_km2) %>%
#       mean(., na.rm=TRUE)
#     
#     strata.index <- strata.cpue * strata$area[i]
#     strata.indices[i] <- strata.index
#   } 
#   total.index <- sum(strata.indices)
#   index[j] <- total.index
# }
# index 
#
# Values match up closely with those from the nwfscSurvey code for 2023.
# Seems like the 2013 assessment was doing something different all together.

