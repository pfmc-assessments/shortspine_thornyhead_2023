library(nwfscSurvey)

# Need to know how to deal with unsexed fish when computing length compositions from
# survey data. Generally, fish could be unsexed due to being immature (and thus sexing
# is difficult to impossible) or were mature but not sexed for unknown reasons. Best
# practice is usually to assume that immature unsexed fish are a 50-50 split of males
# to females, while mature but unsexed fish occur at the same rate as the overall sex
# ratio of the population.
#
# We need to set a maximum length below which we assume unsexed fish are immature, and
# can thus apply the prior sexing split.

triennial1.data <- read_csv(file.path(here::here(), "data", "raw", "triennial1_survey_bio.csv"), show_col_types = FALSE) %>%
  filter(Year > 1994) %>% select(Year, Length_cm, Sex) %>%
  mutate(survey="triennial1")
triennial2.data <- read_csv(file.path(here::here(), "data", "raw", "triennial2_survey_bio.csv"), show_col_types = FALSE) %>%
  select(Year, Length_cm, Sex) %>%
  mutate(survey="triennial2")
afsc.slope.data <- read_csv(file.path(here::here(), "data", "raw", "afsc_slope_survey_bio_lengths.csv"), show_col_types = FALSE) %>%
  select(Year, Length_cm, Sex) %>% filter(Year > 1984)  %>% # omitting 1984 due to unreliable sexing
  mutate(survey="afsc_slope")

# Dont use NWFSC Slope as there is almost no sexed data. Heavily skews results.
# nwfsc.slope.data <- read_csv(file.path(here::here(), "data", "raw", "nwfsc_slope_survey_bio.csv"), show_col_types = FALSE) %>%
#   select(Year, Length_cm, Sex) %>%
#   mutate(survey="nwfsc_slope")

nwfsc.combo.data <- read_csv(file.path(here::here(), "data", "raw", "nwfsc_combo_survey_bio.csv"), show_col_types = FALSE) %>%
  select(Year, Length_cm, Sex) %>% filter(Year > 2004) %>% # omitting 2003/2004 due to unreliable sexing
  mutate(survey="nwfsc_combo")

survey.data <- bind_rows(triennial1.data, triennial2.data, afsc.slope.data, nwfsc.combo.data)
unsex.summ <- summary(survey.data %>% filter(Sex == "U") %>% pull(Length_cm))
unsex.quantiles <- quantile(survey.data %>% filter(Sex == "U") %>% pull(Length_cm), c(0.025, 0.25, 0.50, 0.75, 0.975), na.rm=TRUE)

survey.data %>% filter(Sex == "U") %>% 
  group_by(survey) %>%
  summarise(
    n.samples = n(),
    Q025 = quantile(Length_cm, 0.025, na.rm=TRUE),
    Q25  = quantile(Length_cm, 0.25, na.rm=TRUE),
    Q50  = quantile(Length_cm, 0.50, na.rm=TRUE),
    Q75  = quantile(Length_cm, 0.75, na.rm=TRUE),
    Q975 = quantile(Length_cm, 0.975, na.rm=TRUE),
  ) %>%
  bind_rows(
    data.frame(
      survey = "global", 
      n.samples = nrow(survey.data %>% filter(Sex=="U"))-32, 
      Q025 = unsex.quantiles[1], 
      Q25  = unsex.quantiles[2], 
      Q50  = unsex.quantiles[3], 
      Q75  = unsex.quantiles[4], 
      Q975 = unsex.quantiles[5]
    )
  )

# Seems like a reasonable threshold for "unsexed due to being immature"
# would be ~16cm. Would also be worth it to look at the maturity-at-length
# curve says about maturity proportion at that length. If <75% are mature 
# at 16cm of length, then maybe move the threshold up. But 16cm seems
# reasonable given the data we have available at this time.
#
# survey      n.samples  Q025   Q25   Q50   Q75  Q975
# afsc_slope      13319     8    12    14    15    19
# nwfsc_combo     10832     8    13    15    17    22
# triennial1       2441     9    13    15    18    29
# triennial2       6126     8    12    15    17    30
# global          32686     8    12    14    16    24


