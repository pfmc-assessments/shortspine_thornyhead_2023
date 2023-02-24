# Shortspine Thornyhead
# Age and Growth information
# Data: Kline 1996 and Butler et al 1995 data
# Description:
# Data provided by Donna Skaggs-Kline, Masters thesis, Moss Landing Marine
# Labs, California Written Documentation:
# Kline 1996 (no sex information); central California 1991 (Masters thesis)
# Butler et al. 1995 (sex information available); John Butler study, SWFSC
# retired; Oregon and northern California 1978-87, 1988, 1990 (missing some data
# from this study)(NOAA SWFSC tech memo)


# set up ----

library(tidyverse)
theme_set(theme_classic(base_size = 16))

dat_path <- 'data/experimental_age_data' 
out_path <- file.path('outputs/growth')
dir.create(out_path)

# data clean up ----
  
butler <- read_csv(paste0(dat_path, '/Original NMFS S. alascanus data_1991_formatted.csv'))

glimpse(butler)
butler %>% select(1:7) %>% distinct() # great for archiving, but we can get rid of these here
length(which(is.na(butler$SEX))) # no unsexed data
length(which(is.na(butler$AR_reader_1)))
length(which(is.na(butler$JB_reader_2)))
length(which(is.na(butler$DK_reader_4))) 
length(which(is.na(butler$`2rD`))) # get rid of the second read
butler %>% group_by(SIDE) %>% tally() # mostly side 2 of the otolith, only use these

butler <- butler %>% 
  rename_all(tolower) %>% 
  # only keep side 2 otoliths in an attempt to standardize the data set
  filter(side == 2) %>% 
  select(coll, fish, sex, oto, len_mm, wt_g,
         # otolith readers with initials. JB = Butler, DK = Kline, AR = we do
         # not know. do not include DK because she only aged 17 fish in this
         # sample
         r1 = ar_reader_1, r2 = jb_reader_2,
         # second read for JB (r2)
         r22 = `2rd`)  %>% 
  # get rid of otoliths that were not read by both readers
  filter(!is.na(r1) | !is.na(r2))  

# Explore some diagnostics
pd <- butler %>% 
  mutate(pd_r1_r2 = (r1-r2) / r2,
         pd_r2_r22 = (r2-r22) / r22)

# In all but two cases, the second read is smaller than the first. On average,
# the second read is ~65% less than the first read and in one extreme, it's 200%
# less than the first read. That makes no sense at all to me... I do not think
# this is the accurate column definition for '2rD' and I don't think we should
# use it.
hist(pd$pd_r2_r22)
sort(pd$pd_r2_r22)
mean(pd$pd_r2_r22, na.rm = TRUE)

# p-value << 0.05, evidence that the percent difference between the readers is
# not normally distributed (not sure this matters, except that this assumption
# is commonly made when constructing ageing error matrices). the histogram is
# skewed, which means there is evidence of reader of bias. in this case means
# that on average, reader 1 (AR) is more likely to age a fish older than reader
# 2 (JB)
shapiro.test(pd$pd_r1_r2) 
hist(pd$pd_r1_r2)
mean(pd$pd_r1_r2, na.rm = TRUE)

# >95% of the data are within 33% absolute difference. limit data to within that
# range to eliminate egregious outliers, at least with respect to agreement
# between readers
quantile(abs(pd$pd_r1_r2), 0.95, na.rm = TRUE) 

# now the mean is zero, which hopefully means we've evened out any potential
# bias
pd <- pd %>% filter(between(pd_r1_r2, -0.33, 0.33))
mean(pd$pd_r1_r2, na.rm = TRUE) 
hist(pd$pd_r1_r2)

butler <- butler %>% 
  mutate(pd_r1_r2 = (r1-r2) / r2) %>% 
  filter(between(pd_r1_r2, -0.33, 0.33)) %>% 
  select(-pd_r1_r2, -r22)

# Duplicates

# create a unique id for each collection/fish and get mean age
n_distinct(butler$coll)
n_distinct(butler$fish)
n_distinct(butler$oto)

butler <- butler %>% 
  mutate(id = paste(coll, fish, oto, sep = '_'))
n_distinct(butler$id); nrow(butler) # one duplicate?

# This one duplicate is probably a data entry issue, going to delete it
dup <- butler %>% dplyr::count(id) %>% filter(n > 1)
butler %>% filter(id == dup$id) # 1310_409_90
butler <- butler %>% 
  filter(id != dup$id)

# Finally, get mean age, convert length to cm, get rid of unused cols
butler <- butler %>% 
  mutate(mean_age = rowMeans(select(., r1, r2)),
         length_cm = len_mm / 10,
         sex = ifelse(sex == 1, 'Male', 'Female')) %>% 
  select(id, sex, r1, r2, age = mean_age, length_cm)

# Schnute with sex-specific parameters ----

# write own likelihood function for bias correction (back transform to mean
# instead of median)
vbgf.loglik <- function(log.pars, dat.m, dat.f, a1, a2) {
  pars <- exp(log.pars)
  
  l.pred.m <- pars['la1.m'] + (pars['la2.m'] - pars['la1.m']) * 
    (1-exp(-pars['k.m']*(dat.m$age - a1))) / 
    (1-exp(-pars['k.m']*(a2-a1)))
  
  l.pred.f <- pars['la1.f'] + (pars['la2.f'] - pars['la1.f']) * 
    (1-exp(-pars['k.f']*(dat.f$age - a1))) / 
    (1-exp(-pars['k.f']*(a2-a1)))
  
  nll <- -dlnorm(x = c(dat.m$length_cm, dat.f$length_cm), 
                 meanlog = log(c(l.pred.m, l.pred.f)) -
                   pars['cv']^2 / 2,   #divide by 2 for 2 sexes
                 sdlog = pars['cv'], log = TRUE) %>%
    sum()
  return(nll)
}

#filter data by sex
dat.m <- butler %>% filter(sex == 'Male')
dat.f <- butler %>% filter(sex == 'Female') 

# starting values from Table 8 in the 2013 SST assessment
pars.init <- log(c(la1.m = 7,  la1.f = 7, 
                   la2.m = 67.5, la2.f = 75, 
                   k.m = 0.018, k.f = 0.018, 
                   cv = 0.2))

#estimate with "optim"
vbgf.optim <- optim(pars.init, vbgf.loglik, 
                    dat.m = dat.m, dat.f = dat.f, 
                    a1 = 2, a2 = 100,  #pick age 1 and age 2
                    method = 'L-BFGS-B',
                    # control = list(maxit = 1e5),#, reltol = 1e-8), #factr = 1e-8),
                    hessian = TRUE) #, trace = TRUE, REPORT = 1))
exp(vbgf.optim$par)

optim.m  <- exp(vbgf.optim$par)[c(1,3,5)]
optim.f  <- exp(vbgf.optim$par)[c(2,4,6)]

aic1 <- -2 * vbgf.optim$value + 2 * length(vbgf.optim$par)

# Schnute with sex-specific L2 and k parameters ----

# write own likelihood function for bias correction (back transform to mean
# instead of median)
vbgf.loglik <- function(log.pars, dat.m, dat.f, a1, a2) {
  pars <- exp(log.pars)
  
  l.pred.m <- pars['la1'] + (pars['la2.m'] - pars['la1']) * 
    (1-exp(-pars['k.m']*(dat.m$age - a1))) / 
    (1-exp(-pars['k.m']*(a2-a1)))
  
  l.pred.f <- pars['la1'] + (pars['la2.f'] - pars['la1']) * 
    (1-exp(-pars['k.f']*(dat.f$age - a1))) / 
    (1-exp(-pars['k.f']*(a2-a1)))
  
  nll <- -dlnorm(x = c(dat.m$length_cm, dat.f$length_cm), 
                 meanlog = log(c(l.pred.m, l.pred.f)) -
                   pars['cv']^2 / 2,   #divide by 2 for 2 sexes
                 sdlog = pars['cv'], log = TRUE) %>%
    sum()
  return(nll)
}

#filter data by sex
dat.m <- butler %>% filter(sex == 'Male')
dat.f <- butler %>% filter(sex == 'Female') 

# starting values from Table 8 in the 2013 SST assessment
pars.init <- log(c(la1 = 7,
                   la2.m = 67.5, la2.f = 75, 
                   k.m = 0.018, k.f = 0.018, 
                   cv = 0.2))

#estimate with "optim"
vbgf.optim2 <- optim(pars.init, vbgf.loglik, 
                    dat.m = dat.m, dat.f = dat.f, 
                    a1 = 2, a2 = 100,  #pick age 1 and age 2
                    method = 'L-BFGS-B',
                    # control = list(maxit = 1e5),#, reltol = 1e-8), #factr = 1e-8),
                    hessian = TRUE) #, trace = TRUE, REPORT = 1))
exp(vbgf.optim2$par)

optim2.m  <- exp(vbgf.optim2$par)[c(1,2,4)]
optim2.f  <- exp(vbgf.optim2$par)[c(1,3,5)]

aic2 <- -2 * vbgf.optim2$value + 2 * length(vbgf.optim2$par)

# Schnute with sex-specific L2 parameters ----

# write own likelihood function for bias correction (back transform to mean
# instead of median)
vbgf.loglik <- function(log.pars, dat.m, dat.f, a1, a2) {
  pars <- exp(log.pars)
  
  l.pred.m <- pars['la1'] + (pars['la2.m'] - pars['la1']) * 
    (1-exp(-pars['k']*(dat.m$age - a1))) / 
    (1-exp(-pars['k']*(a2-a1)))
  
  l.pred.f <- pars['la1'] + (pars['la2.f'] - pars['la1']) * 
    (1-exp(-pars['k']*(dat.f$age - a1))) / 
    (1-exp(-pars['k']*(a2-a1)))
  
  nll <- -dlnorm(x = c(dat.m$length_cm, dat.f$length_cm), 
                 meanlog = log(c(l.pred.m, l.pred.f)) -
                   pars['cv']^2 / 2,   #divide by 2 for 2 sexes
                 sdlog = pars['cv'], log = TRUE) %>%
    sum()
  return(nll)
}

#filter data by sex
dat.m <- butler %>% filter(sex == 'Male')
dat.f <- butler %>% filter(sex == 'Female') 

# starting values from Table 8 in the 2013 SST assessment
pars.init <- log(c(la1 = 7,
                   la2.m = 67.5, la2.f = 75, 
                   k = 0.018, 
                   cv = 0.2))

#estimate with "optim"
vbgf.optim3 <- optim(pars.init, vbgf.loglik, 
                     dat.m = dat.m, dat.f = dat.f, 
                     a1 = 2, a2 = 100,  #pick age 1 and age 2
                     method = 'L-BFGS-B',
                     # control = list(maxit = 1e5),#, reltol = 1e-8), #factr = 1e-8),
                     hessian = TRUE) #, trace = TRUE, REPORT = 1))
exp(vbgf.optim3$par)

optim3.m  <- exp(vbgf.optim3$par)[c(1,2,4)]
optim3.f  <- exp(vbgf.optim3$par)[c(1,3,4)]

aic3 <- -2 * vbgf.optim3$value + 2 * length(vbgf.optim3$par)

# Plot ----

# 2013 assessment
par.2013.m <-c(7, 67.5, 0.018)  #la1, la2, k a1=2, a2=100
par.2013.f <-c(7, 75, 0.018)

ages <- data.frame(age = seq(min(butler$age), max(butler$age), 0.5))
pred <- ages %>%   
  mutate(Female = optim.f[1] + (optim.f[2] - optim.f[1]) * 
           (1-exp(-optim.f[3]*(age-1))) / (1-exp(-optim.f[3]*99)),
         Male = optim.m[1] + (optim.m[2] - optim.m[1]) * 
           (1-exp(-optim.m[3]*(age-1))) / (1-exp(-optim.m[3]*99))) %>% 
  pivot_longer(c(Male, Female), names_to = 'sex', values_to = 'length_cm') %>%
  mutate(assessment = '2023 sex-specific L1, L2, k') %>% 
  bind_rows(ages %>%
              mutate(Female = par.2013.f[1] + (par.2013.f[2] - par.2013.f[1]) *
                       (1-exp(-par.2013.f[3]*(age-1))) / (1-exp(-par.2013.f[3]*99)),
                     Male = par.2013.m[1] + (par.2013.m[2] - par.2013.m[1]) *
                       (1-exp(-par.2013.m[3]*(age-1))) / (1-exp(-par.2013.m[3]*99))) %>%
              pivot_longer(c(Male, Female), names_to = 'sex', values_to = 'length_cm') %>%
              mutate(assessment = '2013')) %>%
  bind_rows(ages %>%   
              mutate(Female = optim2.f[1] + (optim2.f[2] - optim2.f[1]) * 
                       (1-exp(-optim2.f[3]*(age-1))) / (1-exp(-optim2.f[3]*99)),
                     Male = optim2.m[1] + (optim2.m[2] - optim2.m[1]) * 
                       (1-exp(-optim2.m[3]*(age-1))) / (1-exp(-optim2.m[3]*99))) %>% 
              pivot_longer(c(Male, Female), names_to = 'sex', values_to = 'length_cm') %>%
              mutate(assessment = '2023 sex-specific L2, k')) %>% 
  bind_rows(ages %>%   
              mutate(Female = optim3.f[1] + (optim3.f[2] - optim3.f[1]) * 
                       (1-exp(-optim3.f[3]*(age-1))) / (1-exp(-optim3.f[3]*99)),
                     Male = optim3.m[1] + (optim3.m[2] - optim3.m[1]) * 
                       (1-exp(-optim3.m[3]*(age-1))) / (1-exp(-optim3.m[3]*99))) %>% 
              pivot_longer(c(Male, Female), names_to = 'sex', values_to = 'length_cm') %>%
              mutate(assessment = '2023 sex-specific L2'))

ggplot() +
  geom_point(data = butler, aes(x = age, y = length_cm, col = sex), size = 0.5) +
  geom_line(data = pred, aes(x = age, y = length_cm, col = sex, lty = assessment),
            size = 0.8)

ggplot() +
  geom_point(data = butler, aes(x = age, y = length_cm), size = 0.5) +
  geom_line(data = pred, aes(x = age, y = length_cm, col = assessment),
            size = 0.8) +
  facet_wrap(~sex)

aic1;aic2;aic3

# sensitivity ----

pred <- ages %>%   
  mutate(Female = optim.f[1] + (optim.f[2] - optim.f[1]) * 
           (1-exp(-optim.f[3]*(age-1))) / (1-exp(-optim.f[3]*99)),
         Male = optim.m[1] + (optim.m[2] - optim.m[1]) * 
           (1-exp(-optim.m[3]*(age-1))) / (1-exp(-optim.m[3]*99))) %>% 
  pivot_longer(c(Male, Female), names_to = 'sex', values_to = 'length_cm') %>%
  mutate(assessment = '2023') %>% 
  bind_rows(ages %>%
              mutate(Female = par.2013.f[1] + (par.2013.f[2] - par.2013.f[1]) *
                       (1-exp(-par.2013.f[3]*(age-1))) / (1-exp(-par.2013.f[3]*99)),
                     Male = par.2013.m[1] + (par.2013.m[2] - par.2013.m[1]) *
                       (1-exp(-par.2013.m[3]*(age-1))) / (1-exp(-par.2013.m[3]*99))) %>%
              pivot_longer(c(Male, Female), names_to = 'sex', values_to = 'length_cm') %>%
              mutate(assessment = '2013')) 

sensitivities <- ages %>%
              mutate(Female = optim.f[1]*1.1 + (optim.f[2]*1.1 - optim.f[1]*1.1) * 
                       (1-exp(-optim.f[3]*(age-1))) / (1-exp(-optim.f[3]*99)),
                     Male = optim.m[1]*1.1 + (optim.m[2]*1.1 - optim.m[1]*1.1) * 
                       (1-exp(-optim.m[3]*(age-1))) / (1-exp(-optim.m[3]*99))) %>% 
              pivot_longer(c(Male, Female), names_to = 'sex', values_to = 'upper') %>%
              mutate(assessment = '2023') %>% 
  left_join(ages %>%
              mutate(Female = optim.f[1]*0.9 + (optim.f[2]*0.9 - optim.f[1]*0.9) * 
                       (1-exp(-optim.f[3]*(age-1))) / (1-exp(-optim.f[3]*99)),
                     Male = optim.m[1]*0.9 + (optim.m[2]*0.9 - optim.m[1]*0.9) * 
                       (1-exp(-optim.m[3]*(age-1))) / (1-exp(-optim.m[3]*99))) %>% 
              pivot_longer(c(Male, Female), names_to = 'sex', values_to = 'lower') %>%
              mutate(assessment = '2023')) %>% 
  bind_rows(ages %>% 
              mutate(sex = 'Male',
                     assessment = '2013'))

ggplot() +
  geom_ribbon(data = sensitivities,
              aes(x = age, ymin = lower, ymax = upper,
                  fill = assessment),
              alpha = 0.2, col = 'white') +
  geom_point(data = butler, aes(x = age, y = length_cm), size = 0.5) +
  geom_line(data = pred, aes(x = age, y = length_cm, col = assessment),
            size = 0.8) +
  facet_wrap(~sex) +
  labs(x = 'Age (y)', y = 'Length (cm)', col = 'Assessment', fill = 'Assessment')

ggsave(paste0(out_path, '/growth_curve_sensitivities.png'), units = 'in', 
       width = 7, height = 4, dpi = 300)

out <- as.data.frame(t(as.matrix(exp(vbgf.optim$par[c(1, 3, 5)])))) %>% 
  mutate(Sex = 'Male',
         A1 = 2,
         A2 = 100) %>% 
  select(Sex, A1, A2, Length_at_A1 = la1.m, 
         Length_at_A2 = la2.m, k = k.m) %>% 
  bind_rows(as.data.frame(t(as.matrix(exp(vbgf.optim$par[c(2, 4, 6)])))) %>% 
  mutate(Sex = 'Female',
         A1 = 2,
         A2 = 100) %>% 
    select(Sex, A1, A2, Length_at_A1 = la1.f, 
           Length_at_A2 = la2.f, k = k.f)) %>% 
  mutate(Sensitivity_Run = 'Base_2023')

out <- out %>% 
  bind_rows(out %>% 
              mutate(Length_at_A1 = Length_at_A1 * 1.1,
                     Length_at_A2 = Length_at_A2 * 1.1,
                     Sensitivity_Run = 'Increase_Length_at_A1_and_A2_10percent')) %>% 
  bind_rows(out %>% 
              mutate(Length_at_A1 = Length_at_A1 * 0.9,
                     Length_at_A2 = Length_at_A2 * 0.9,
                     Sensitivity_Run = 'Decrease_Length_at_A1_and_A2_10percent')) %>% 
  select(Sensitivity_Run, Sex, A1, A2, Length_at_A1, 
         Length_at_A2, k) 

out %>% write_csv(paste0(out_path, '/growth_curve_sensitivities.csv'))
butler %>% write_csv(paste0(dat_path, '/cleaned_butler_for_growth_curves_2023.csv'))
