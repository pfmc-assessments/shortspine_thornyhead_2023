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

# take black out of colorblind theme
scale_fill_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_fill_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# Color
scale_color_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_color_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

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
              mutate(assessment = '2005/2013')) %>%
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
              mutate(assessment = '2005/2013')) 

sensitivities <- ages %>%
              mutate(Female = optim.f[1]*1.25 + (optim.f[2]*1.25 - optim.f[1]*1.25) * 
                       (1-exp(-optim.f[3]*(age-1))) / (1-exp(-optim.f[3]*99)),
                     Male = optim.m[1]*1.25 + (optim.m[2]*1.25 - optim.m[1]*1.25) * 
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
                     assessment = '2005/2013'))

ggplot() +
  geom_point(data = butler, aes(x = age, y = length_cm), size = 1.5, shape = 16) +
  geom_ribbon(data = sensitivities,
              aes(x = age, ymin = lower, ymax = upper,
                  fill = assessment),
              alpha = 0.3, col = NA) +
  geom_line(data = pred, aes(x = age, y = length_cm, col = assessment),
            size = 0.8) +
  scale_fill_colorblind7() +
  scale_color_colorblind7() +
  facet_wrap(~sex, ncol = 1) +
  labs(x = 'Age (y)', y = 'Length (cm)', col = 'Assessment', fill = 'Assessment')

ggsave(paste0(out_path, '/growth_curve_sensitivities.png'), units = 'in', 
       width = 6, height = 8, dpi = 300)

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
              mutate(Length_at_A1 = Length_at_A1 * 1.25,
                     Length_at_A2 = Length_at_A2 * 1.25,
                     Sensitivity_Run = 'Increase_Lengths_at_A1_and_A2_25percent')) %>% 
  bind_rows(out %>% 
              mutate(Length_at_A1 = Length_at_A1 * 0.9,
                     Length_at_A2 = Length_at_A2 * 0.9,
                     Sensitivity_Run = 'Decrease_Lengths_at_A1_and_A2_10percent')) %>% 
  select(Sensitivity_Run, Sex, A1, A2, Length_at_A1, 
         Length_at_A2, k) 

out %>% write_csv(paste0(out_path, '/growth_curve_sensitivities.csv'))
butler %>% write_csv(paste0(dat_path, '/cleaned_butler_for_growth_curves_2023.csv'))

# kline ----

kline <- read_csv(file.path(dat_path, "S. alascanus_Kline 1996_formatted.csv")) %>% 
  rename_all(tolower)
glimpse(kline)
unique(kline$tow) # data from 13 tows
length(which(!is.na(kline$age_1st_read))) # 203
length(which(!is.na(kline$age_2nd_read))) # 80
length(which(!is.na(kline$age_3rd_read))) # 202

# Everything in notes_1 (DK's notes) looks like good reason to eliminate. Only
# use rows where notes_1 is NA
unique(kline$notes_1)
# [1] "Frozen specimen. Used only for training and pilot study."                             
# [2] "Frozen specimen. Used only for training and pilot study. Thrown out. Questionable ID."
# [3] "*Frozen specimen. Used only for training and pilot study."                            
# [4] "*Frozen specimen. Used only for training and pilot study. Section broken, thrown out."
# [5] NA                                                                                     
# [6] "*Broken"                                                                              
# [7] "alt"                                                                                  
# [8] "ground away"                                                                          
# [9] "thin"                                                                                 
# [10] "alt?"                                                                                 
# [11] "missing"                                                                              
# [12] "too thin"                                                                             
# [13] "Sectioned but not aged."

# reduced N frm 427 to 329
kline <- kline %>% filter(is.na(notes_1))

# notes_2 (notes that were added by Sabrina Beyer). Hard to interpret the
# asterisk comments (does it mean the 2nd age is the preferred or the most
# questionable?). Going to remove those rows. The "core calculation" comment
# doesn't seem bad.
table(kline$notes_2)
# [1] "has core calculation; first five incremenets from fish with <100mm otoliths; ocular measurement"
# [2] NA                                                                                               
# [3] "**; *13 2nd age read had an asterisk"                                                           
# [4] "\"**\" was in the sex column"                                                                   
# [5] "*22 2nd age read had an asterisk"                                                               
# [6] "\"**3\" was in sex column"                                                                      
# [7] "*15 2nd age read had an asterisk" 

# reduced N to 324
kline <- kline %>% filter(!grepl('asterisk|sex', notes_2))

# age_2nd_read has the most non-NAs of any of the ages and is the one DK used in
# her thesis. Use these ages only. reduces N to 321
kline <- kline %>% filter(!is.na(age_2nd_read))

# get rid of any specimens without lengths associated with them. reduces N to
# 319
kline <- kline %>% filter(!is.na(len_mm))
nrow(kline)

# make sure 'specimen' is a unique identifier
length(unique(kline$specimen)) == nrow(kline)

kline <- kline %>% 
  mutate(length_cm = len_mm / 10) %>% 
  select(id = specimen, length_cm, age = age_2nd_read)
nrow(kline)

names(kline)
names(butler)
allages <- bind_rows(kline %>% 
                       mutate(source = 'Kline',
                              sex = 'Unknown'),
                     butler %>% 
                       mutate(source = 'Butler') %>% 
                       select(-r1,-r2)) %>% 
  mutate(newid = paste0('Source=', source, '; Sex=', sex))

ggplot(allages, aes(age, length_cm, col = newid, shape = newid)) +
  geom_point(size = 2) +
  scale_color_colorblind7() +
  labs(x = 'Age (y)', y = 'Length (cm)', col = NULL, shape = NULL) +
  theme(legend.position = c(0.75, 0.2))

ggsave(paste0(out_path, '/laa_butler_vs_kline.png'), units = 'in', 
       width = 6.5, height = 4, dpi = 300)

ggplot() +
  geom_point(data = kline %>% 
               mutate(Data = 'Kline (unsexed)'), 
             aes(x = age, y = length_cm, shape = Data), 
             size = 1.5, col = 'purple') +
  geom_point(data = butler %>% 
               mutate(Data = 'Butler (sexed)'), 
             aes(x = age, y = length_cm, shape = Data), 
             size = 1.5, col = 'black') +
  geom_ribbon(data = sensitivities,
              aes(x = age, ymin = lower, ymax = upper,
                  fill = assessment),
              alpha = 0.3, col = NA) +
  geom_line(data = pred, aes(x = age, y = length_cm, col = assessment),
            size = 0.8) +
  scale_fill_colorblind7() +
  scale_color_colorblind7() +
  facet_wrap(~sex, ncol = 1) +
  scale_shape_manual(values = c(16, 4)) +
  labs(x = 'Age (y)', y = 'Length (cm)', col = 'Assessment', fill = 'Assessment')

ggsave(paste0(out_path, '/growth_curve_sensitivities_with_kline.png'), units = 'in', 
       width = 6, height = 8, dpi = 300)

kline %>% 
  dplyr::rename(specimen = id) %>%  
  write_csv(file.path(dat_path, 'cleaned_kline_for_growth_sensitivity_2023.csv'))
