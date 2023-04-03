# Allometry (length-weight relationship)
# Contact: jane.sullivan@noaa.gov
# Last updated February 2023

# note that this code is based on the survey_data.R output

# set up -----

libs <- c('readr', 'dplyr', 'tidyr', 'ggplot2', 'plotly', 'shiny',
          'ggthemes', 'ggridges', 'cowplot')
if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

# Available length-weight pairs were indentified in the survey_data.R script
akslope <- readRDS('data/raw/AFSCslope/AFSCslope_lengthweight_pairs.rda')
combo <- readRDS('data/raw/NWFSCcombo/NWFSCcombo_lengthweight_pairs.rda')
names(akslope) == names(combo)

# make sure there are no NAs
akslope %>% filter(is.na(Length_cm), is.na(Weight), is.na(Sex))
combo %>% filter(is.na(Length_cm), is.na(Weight), is.na(Sex))

# combine surveys into single df and define state water areas
dat <- bind_rows(akslope %>% mutate(survey = 'AFSCslope'), 
            combo %>% mutate(survey = 'NWFSCcombo')) %>% 
  mutate(state = dplyr::case_when(Latitude_dd < 34.5 ~ 'CA',
                                  Latitude_dd >= 34.5 & Latitude_dd < 40.5 ~ 'OR',
                                  Latitude_dd >= 40.5 ~ 'WA'),
         rn = row_number())

ggplot(data = dat, aes(x = Length_cm, y = Weight, col = Sex)) +
  geom_point(alpha = 0.4)

# sexes are very similar
ggplot(data = dat, aes(x = log(Length_cm), y = log(Weight), col = Sex)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = 'lm', se = F)

# combo survey has the best coverage by year and state
table(dat$Year, dat$survey, dat$state)

# data from both surveys giving very similar result
ggplot(data = dat, aes(x = log(Length_cm), y = log(Weight), col = survey, lty = survey)) +
  geom_point(alpha = 0.2) +
  facet_wrap(~Sex) +
  geom_smooth(method = 'lm', se = F)

# no clear trends by state
ggplot(data = dat, aes(x = log(Length_cm), y = log(Weight), col = state, lty = state)) +
  geom_point(alpha = 0.2) +
  facet_wrap(~Sex) +
  geom_smooth(method = 'lm', se = F)

# no reason to think there would be temporal trends (though there are high
# leverage points at small lengths when data is parsed this way)
ggplot(data = dat, aes(x = log(Length_cm), y = log(Weight), col = factor(Year))) +
  geom_point(alpha = 0.2) +
  facet_wrap(~Sex) +
  geom_smooth(method = 'lm', se = F)

# outliers -----

# run app to identify outliers (only need to do this)
# source('R/lw_outlier_app.R')
# shinyApp(ui = ui, server = server)
 
outliers <- read_csv('outputs/length-weight/potential_lw_outliers.csv')

# remove outliers
dat <- dat %>% filter(!rn %in% c(outliers$rn))

ggplot(data = dat, aes(x = Length_cm, y = Weight, col = Sex)) +
  geom_point(alpha = 0.4)

# assign unsexed fish ----

# assign <= 16 cm unsexed fish randomly as M or F. get rid of unsexed fish >16
# cm
set.seed(907) # gives the same result each time for the first time its run after set.seed
dat <- dat %>% 
  filter(Sex == 'U' & Length_cm <= 16) %>% 
  mutate(Sex = sample(x = c('M', 'F'), size = n(), prob = c(0.5, 0.5), replace = TRUE)) %>% 
  # group_by(Sex) %>% tally()
  bind_rows(dat %>% filter(Sex %in% c('M', 'F')))

#only use NWFSC combo survey ----

dat <- dat %>% filter(survey != 'AFSCslope')

ggplot(data = dat, aes(x = log(Length_cm), y = log(Weight), col = Sex)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = 'lm', se = F)

# fit model ----

# apply linear models in log-log space
lmFemale <- lm(log(Weight)~log(Length_cm), data = dat %>% filter(Sex == 'F'))
lmMale <- lm(log(Weight)~log(Length_cm), data = dat %>% filter(Sex == 'M'))
lmAll <- lm(log(Weight)~log(Length_cm), data = dat)

# function modified from @okenk, correction for median vs. mean in lognormal
# distribution

bias_correct <- function(model, sex = 'unsexed'){
  alpha_med <- exp(model$coefficients[1])
  beta <- model$coefficients[2]
  sdres <- sd(model$residuals)# sigma(model)
  alpha_mean <- alpha_med*exp(0.5*sdres^2)
  return(as.numeric(c(alpha_mean, beta)))
}

# get parameter values for each model
resultsF <- bias_correct(lmFemale)
resultsM <- bias_correct(lmMale)
resultsAll <- bias_correct(lmAll)

# make table of all models
results <- data.frame(rbind(resultsF,resultsM,resultsAll))
names(results) <- c("alpha","beta")
print(results)

preddf <- data.frame(Length_cm = 1:80) %>% 
  mutate(Female = results[1,1] * Length_cm ^ results[1,2],
         Male = results[2,1] * Length_cm ^ results[2,2],
         `Combined` = results[3,1] * Length_cm ^ results[3,2]) %>% 
  pivot_longer(cols = -Length_cm, names_to = 'Sex', values_to = 'Weight')

# Write results ----
write_csv(results %>% 
            mutate(sex = c('Female', 'Male', 'Sexes_combined')), 
          'outputs/length-weight/lw_parameters_NWFSCcombo.csv')

# Write results for SS ----

forss <- data.frame(Version = 'WCBTS_Base_2023',
                    Param = c('Wtlen_1_Fem', 'Wtlen_2_Fem'),
                    Value = resultsM) %>% 
  bind_rows(data.frame(Version = 'WCBTS_Base_2023',
                       Param = c('Wtlen_1_Mal', 'Wtlen_2_Mal'),
                       Value = resultsF)) %>% 
  bind_rows(data.frame(Version = '2013_assessment',
                       Param = c('Wtlen_1_Fem', 'Wtlen_2_Fem', 'Wtlen_1_Mal', 'Wtlen_2_Mal'),
                       Value = c(4.77065e-06, 3.26298, 4.77065e-06, 3.26298))

write_csv(forss, 'data/for_ss/wtlen_bysex_2023.csv')

# Plot results ----
ggplot(data = dat %>% 
         mutate(Sex = ifelse(Sex == 'M', 'Male', 'Female')), 
       aes(x = Length_cm, y = Weight, col = Sex, lty = Sex)) +
  geom_point(alpha = 0.2) +
  geom_line(data = preddf, aes(x = Length_cm, y = Weight, col = Sex),
            size = 1) +
  theme_bw() +
  scale_color_colorblind() +
  scale_linetype_manual(values = c(1, 2, 2)) +
  labs(x = 'Length (cm)', 'Weight (kg)', #col = NULL, lty = NULL,
       title = 'Shortspine thornyhead length-weight relationship',
       subtitle = paste0('NWFSC shelf/slope survey data, ', min(dat$Year), '-', max(dat$Year))) +
  theme(legend.position = c(.1, .8))

ggsave('outputs/length-weight/lw_NWFSCcombo.png', height = 5,
       width = 7, dpi = 300)

# Compare with previous assessment values ----
preddf <- data.frame(Length_cm = 6:72) %>% 
  mutate(NWFSCcombo_Female = results[1,1] * Length_cm ^ results[1,2],
         NWFSCcombo_Male = results[2,1] * Length_cm ^ results[2,2],
         NWFSCcombo_Sexes_combined = results[3,1] * Length_cm ^ results[3,2],
         `2013_assessment` = 0.0000047707 * Length_cm ^ 3.263,
         `2005_assessment` = 0.0000049 * Length_cm ^ 3.264) %>% 
  pivot_longer(cols = -Length_cm, names_to = 'Sex', values_to = 'Weight')

ggplot() + 
  geom_line(data = preddf, 
            aes(x = Length_cm, y = Weight, col = Sex, lty = Sex),
            size = 1) +
  theme_bw() +
  scale_color_colorblind() +
  scale_linetype_manual(values = c(1,1,1,1,2)) +
  labs(x = 'Length (cm)', 'Weight (kg)', col = NULL, lty = NULL,
       main = 'Shortspine thornyhead length-weight relationships') +
  theme(legend.position = c(.2, .8))

ggsave('outputs/length-weight/lw_comparisons.png', height = 5,
       width = 7, dpi = 300)
