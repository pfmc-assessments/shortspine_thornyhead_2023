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
# akslope <- readRDS('data/raw/AFSCslope/AFSCslope_lengthweight_pairs.rda')
combo <- readRDS('data/raw/NWFSCcombo/NWFSCcombo_lengthweight_pairs.rda')
# names(akslope) == names(combo)

# make sure there are no NAs
# akslope %>% filter(is.na(Length_cm), is.na(Weight), is.na(Sex))
combo %>% filter(is.na(Length_cm), is.na(Weight), is.na(Sex))

# combine surveys into single df and define state water areas
# dat <- bind_rows(akslope %>% mutate(survey = 'AFSCslope'), 
#             combo %>% mutate(survey = 'NWFSCcombo')) %>% 
dat <- combo %>% 
  mutate(survey = 'NWFSCcombo',
         state = dplyr::case_when(Latitude_dd < 34.5 ~ 'CA',
                                  Latitude_dd >= 34.5 & Latitude_dd < 40.5 ~ 'OR',
                                  Latitude_dd >= 40.5 ~ 'WA'),
         rn = row_number())

nrow(dat)

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
# source('R/bio/lw_outlier_app.R')
# shinyApp(ui = ui, server = server)
outliers <- read_csv('outputs/length-weight/potential_lw_outliers.csv')
outliers %>% filter(Project == 'NWFSC.Combo') # only two outliers identified originally

# NEW:  re-ran outlier app for star panel: modified original outlier app to only use
# combo survey data and also identify outliers in log-log space
# source('R/bio/lw_outlier_app_star.R')
# shinyApp(ui = ui, server = server)
outliers <- read_csv('outputs/length-weight/star_potential_lw_outliers.csv') # 32 outliers

# remove outliers
nrow(dat)
dat <- dat %>% filter(!rn %in% c(outliers$rn))
nrow(dat)

dat <- dat %>% 
  mutate(loglen = log(Length_cm),
         logwt = log(Weight)) %>% 
  filter(!(loglen < 2 & logwt > -5))

dat <- dat %>% 
  filter(loglen > 2.75)

ggplot(data = dat %>% 
         filter(survey == 'NWFSCcombo'), 
       aes(x = log(Length_cm), y = log(Weight), col = Sex)) +
  geom_point(alpha = 0.4, size = 2) +
  theme_bw(base_size = 15)

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

# standardized residuals: (resid_i) / (sd of all residuals)

# apply linear models in log-log space
lmFemale <- lm(log(Weight)~log(Length_cm), data = dat %>% filter(Sex == 'F'))
lmMale <- lm(log(Weight)~log(Length_cm), data = dat %>% filter(Sex == 'M'))
lmAll <- lm(log(Weight)~log(Length_cm), data = dat)

sdr <- data.frame(Sex = 'Female',
           log_length = dat %>% 
             filter(Sex == 'F') %>% 
             mutate(log_length = log(Length_cm)) %>% 
             pull(log_length),
           resid = rstandard(lmFemale)) %>% 
  bind_rows(data.frame(Sex = 'Male',
                       log_length = dat %>% 
                         filter(Sex == 'M') %>% 
                         mutate(log_length = log(Length_cm)) %>% 
                         pull(log_length),
                       resid = rstandard(lmMale)))

ggplot(data = sdr, aes(log_length, resid)) +
  geom_point() +
  geom_hline(yintercept = 0) +
  geom_hline(yintercept = -2, lty = 2, col = 'grey') +
  geom_hline(yintercept = 2, lty = 2, col = 'grey') +
  facet_wrap(~Sex) +
  theme_bw(base_size = 15) +
  labs(x = 'log(Length_cm)', y = 'Standardized residuals')

# function modified from @okenk, correction for median vs. mean in lognormal
# distribution

bias_correct <- function(model){
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

# # get parameter values for each model
# resultsF <- no_bias_correct(lmFemale)
# resultsM <- no_bias_correct(lmMale)
# resultsAll <- no_bias_correct(lmAll)

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
          'outputs/length-weight/star_lw_parameters_NWFSCcombo.csv')

# Write results for SS ----

forss <- data.frame(Version = 'WCBTS_Base_2023',
                    Param = c('Wtlen_1_Fem', 'Wtlen_2_Fem'),
                    Value = resultsM) %>% 
  bind_rows(data.frame(Version = 'WCBTS_Base_2023',
                       Param = c('Wtlen_1_Mal', 'Wtlen_2_Mal'),
                       Value = resultsF)) %>% 
  bind_rows(data.frame(Version = '2013_assessment',
                       Param = c('Wtlen_1_Fem', 'Wtlen_2_Fem', 'Wtlen_1_Mal', 'Wtlen_2_Mal'),
                       Value = c(4.77065e-06, 3.26298, 4.77065e-06, 3.26298)))

write_csv(forss, 'data/for_ss/star_wtlen_bysex_2023.csv')

# Plot results ----
ggplot(data = dat %>% 
         mutate(Sex = ifelse(Sex == 'M', 'Male', 'Female')), 
       aes(x = Length_cm, y = Weight, col = Sex, lty = Sex)) +
  geom_point(alpha = 0.2) +
  geom_line(data = preddf, aes(x = Length_cm, y = Weight, col = Sex),
            size = 1) +
  theme_bw(base_size = 15) +
  scale_color_colorblind() +
  scale_linetype_manual(values = c(1, 2, 2)) +
  labs(x = 'Length (cm)', 
       y = 'Weight (kg)',
       title = 'Shortspine thornyhead length-weight relationship',
       subtitle = paste0('NWFSC shelf/slope survey data, ', min(dat$Year), '-', max(dat$Year))) +
  theme(legend.position = c(.1, .8))

ggsave('outputs/length-weight/lw_NWFSCcombo.png', height = 5,
       width = 7, dpi = 300)

ggplot(data = dat %>% 
         mutate(Sex = ifelse(Sex == 'M', 'Male', 'Female')) %>% 
         filter(Sex != 'Combined'), 
       aes(x = log(Length_cm), y = log(Weight))) +
  # geom_point(alpha = 0.01, size = 3) +
  geom_hex() +
  geom_line(data = preddf %>% 
              filter(Sex != 'Combined'), 
            aes(x = log(Length_cm), y = log(Weight)),
            size = 1, col = 'red') +
  scale_fill_gradient(trans = "log") +
  theme_bw() +
  scale_color_colorblind() +
  xlim(c(1, 5)) +
  ylim(c(-6, 2)) +
  facet_wrap(~Sex) +
  scale_linetype_manual(values = c(1, 2, 2)) +
  labs(x = 'log(Length_cm)', 'log(Weight_kg)', fill = 'log(count)',
       title = 'Shortspine thornyhead length-weight relationship',
       subtitle = paste0('NWFSC shelf/slope survey data, ', min(dat$Year), '-', max(dat$Year))) +
  theme(legend.position = c(.1, .8))




ggplot(data = dat %>% 
         mutate(Sex = ifelse(Sex == 'M', 'Male', 'Female')) %>% 
         filter(Sex != 'Combined'), 
       aes(x = Length_cm, y = Weight)) +
  # geom_point(alpha = 0.2) +
  geom_hex() +
  geom_line(data = preddf %>% 
              filter(Sex != 'Combined'), 
            aes(x = Length_cm, y = Weight),
            size = 1, col = 'red') +
  scale_fill_gradient(trans = "log") +
  theme_bw() +
  scale_color_colorblind() +
  facet_wrap(~Sex) +
  scale_linetype_manual(values = c(1, 2, 2)) +
  labs(x = 'Length (cm)', 'Weight (kg)', #col = NULL, lty = NULL,
       title = 'Shortspine thornyhead length-weight relationship',
       subtitle = paste0('NWFSC shelf/slope survey data, ', min(dat$Year), '-', max(dat$Year))) +
  theme(legend.position = c(.1, .8))



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

# compare different curves ----
results

tmp <- read_csv('outputs/length-weight/lw_parameters_NWFSCcombo.csv') %>% 
  mutate(Model = 'Base 2023') %>% 
  bind_rows(read_csv('outputs/length-weight/star_lw_parameters_NWFSCcombo.csv') %>% 
              mutate(Model = 'Updated LW for STAR')) %>% 
  filter(sex != 'Sexes_combined') %>% 
  bind_rows(data.frame(alpha = c(4.77065e-6, 4.77065e-6),
             beta = c(3.26298, 3.26298),
             sex = c('Female', 'Male'),
             Model = 'Base 2013'))

fem_tmp <- tmp %>% filter(sex == 'Female')
mal_tmp <- tmp %>% filter(sex == 'Male')

tmp <- data.frame(Length_cm = 6:72, Sex = 'Female') %>%
  mutate(`Base 2023` = fem_tmp$alpha[fem_tmp$Model == 'Base 2023'] * Length_cm ^ fem_tmp$beta[fem_tmp$Model == 'Base 2023'],
         `Updated LW for STAR` = fem_tmp$alpha[fem_tmp$Model == 'Updated LW for STAR'] * Length_cm ^ fem_tmp$beta[fem_tmp$Model == 'Updated LW for STAR'], 
         `2013 Assessment` = fem_tmp$alpha[fem_tmp$Model == 'Base 2013'] * Length_cm ^ fem_tmp$beta[fem_tmp$Model == 'Base 2013']) %>% 
  bind_rows(data.frame(Length_cm = 6:72, Sex = 'Male') %>%
              mutate(`Base 2023` = mal_tmp$alpha[mal_tmp$Model == 'Base 2023'] * Length_cm ^ mal_tmp$beta[mal_tmp$Model == 'Base 2023'],
                     `Updated WL for STAR` = mal_tmp$alpha[mal_tmp$Model == 'Updated LW for STAR'] * Length_cm ^ mal_tmp$beta[mal_tmp$Model == 'Updated LW for STAR'], 
                     `2013 Assessment` = mal_tmp$alpha[mal_tmp$Model == 'Base 2013'] * Length_cm ^ mal_tmp$beta[mal_tmp$Model == 'Base 2013'])) %>% 
  pivot_longer(cols = c('Base 2023', 'Updated WL for STAR', '2013 Assessment'),
               names_to = 'Model', values_to = 'Weight')

ggplot() + 
  geom_line(data = tmp, 
            aes(x = Length_cm, y = Weight, col = Model, lty = Model),
            size = 1) +
  theme_bw(base_size = 15) +
  facet_wrap(~Sex) +
  scale_color_colorblind() +
  # scale_linetype_manual(values = c(1,1,1,1,2)) +
  labs(x = 'Length (cm)', y = 'Weight (kg)', col = NULL, lty = NULL,
       main = 'Shortspine thornyhead length-weight relationships') +
  theme(legend.position = c(.15, .8))
