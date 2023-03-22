# Code to run the smooth_sspn_ratio.cpp program, a multivariate state-space
# random walk model used to smooth the time series of SSPN ratios
# Contact: jane.sullivan@noaa.gov
# Last updated March 2023

library(tidyverse)
library(TMB)
library(scales)

scale_fill_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_fill_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

scale_color_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_color_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# data ----

id_thorny <- read_csv('outputs/fishery_data/identified_catch.csv')
prop_sspn <- read_csv('outputs/fishery_data/prop_sspn.csv') %>% 
  dplyr::filter(!state_gear %in% c('WA_Trawl', 'WA_Non-trawl')) 

# the CVs of the sspn ratio data are assumed to be inversely proportional to the
# size of the identified catch of thornyheads (sspn + lspn). we assume that the
# smallest catch within each fleet has a CV=0.3 and the largest catch has a
# CV=0.05
id_thorny <- id_thorny %>% 
  tidyr::complete(species, year, state_gear, fill = list(mtons = 0)) %>%
  dplyr::group_by(year, fleet = state_gear) %>% 
  dplyr::summarise(catch = sum(mtons)) %>% 
  dplyr::group_by(fleet) %>% 
  dplyr::mutate(cv = scales::rescale(catch, to = c(0.3, 0.05))) 

id_thorny %>% pivot_wider(id_cols = year, names_from = fleet, values_from = cv)
         
# new
prop_dat <- prop_sspn %>% 
  dplyr::select(year, fleet = state_gear, prop_sspn) %>% 
  dplyr::left_join(id_thorny) %>% 
  dplyr::select(-catch) %>% 
  dplyr::mutate(cv = ifelse(is.na(cv), 0.3, cv))

# data list for TMB ----
dat <- list(model_yrs = sort(unique(prop_dat$year)))

tmp <- prop_dat %>% 
  tidyr::pivot_wider(id_cols = year, names_from = fleet, values_from = prop_sspn, values_fill = NA) %>% # print(n=Inf)
  dplyr::select(-year) %>% 
  as.matrix()
tmp[tmp == 1] <- 0.9999; tmp[tmp == 0] <- 0.0001
dat$logit_ratio_obs <- log((tmp)/(1-tmp)) # logit transformation

dat$ratio_cv <- prop_dat %>% 
  tidyr::pivot_wider(id_cols = year, names_from = fleet, values_from = cv, values_fill = NA) %>% 
  dplyr::select(-year) %>% 
  as.matrix()

dat$pointer_PE <- 0:(ncol(dat$ratio_cv)-1) # unique process error estimated for each fleet. tmb/c++ indexing starts at 0
# dat$pointer_PE <- rep(0, ncol(dat$ratio_cv)) # only process error estimated (simplest model)

# parameter list for TMB ----
par <- list()

# process error starting value = 1
par$log_PE <- rep(log(1), length(unique(dat$pointer_PE)))

# predicted sspn ratios (estimated as random effects in logit space). use
# interpolated values as starting values. note that values cannot exactly equal
# 1 or 0 using this approach
tmp <- apply(X = tmp, MARGIN = 2, FUN = zoo::na.approx, maxgap = 100, rule = 2)
tmp[tmp == 1] <- 0.9999; tmp[tmp == 0] <- 0.0001
par$logit_ratio_pred <- log((tmp)/(1-tmp)) # logit transformation

# map list for TMB ----

map <- par
map$log_PE <- as.factor(1:length(map$log_PE))

map$logit_ratio_pred <- as.factor(1:length(map$logit_ratio_pred))

# id parameters that should be estimated as random effects
random = 'logit_ratio_pred'

# fit model ----

# need to run these if you don't have the program compiled
# setwd('R/landings')
# TMB::compile('smooth_sspn_ratio.cpp')
# dyn.load(TMB::dynlib('smooth_sspn_ratio'))

obj <- TMB::MakeADFun(data = dat, parameters = par, random = random,
                     DLL = 'smooth_sspn_ratio', map = map)  

# lower and upper bounds relate to obj$par and must be the same length as obj$par
opt <- nlminb(start = obj$par, objective = obj$fn, hessian = obj$gr)

sdrep <- TMB::sdreport(obj)
summary(sdrep)

# plot results ----
out <- data.frame(name = rownames(summary(sdrep)),
                  estimate = data.frame(summary(sdrep))$Estimate,
                  se = data.frame(summary(sdrep))$Std..Error)

pred <- tidyr::expand_grid(fleet = colnames(dat$logit_ratio_obs),
                   variable = 'pred_prop_sspn',
                   year = dat$model_yrs) %>% 
  dplyr::left_join(prop_dat) %>% 
  tidyr::separate(col = fleet, sep = '_', into = c('state', 'gear'), remove = FALSE) %>%
  dplyr::mutate(ratio_pred = out$estimate[out$name == 'ratio_pred'],
                logit_ratio_pred = out$estimate[out$name == 'logit_ratio_pred'],
                sd_logit_ratio_pred = out$se[out$name == 'logit_ratio_pred'],
                pred_uci = 1 / (1 + exp(-logit_ratio_pred - 1.96 * sd_logit_ratio_pred)),
                pred_lci = 1 / (1 + exp(-logit_ratio_pred + 1.96 * sd_logit_ratio_pred)))
              
ggplot(pred, aes(x = year, col = gear, fill = gear)) +
  geom_point(aes(y = prop_sspn)) +
  geom_ribbon(aes(ymin = pred_lci, ymax = pred_uci), col = NA, alpha = 0.2) +
  geom_line(aes(y = ratio_pred)) +
  scale_color_colorblind7() +
  scale_fill_colorblind7() +
  facet_wrap(~state, ncol = 1) +
  labs(x = 'Year', y = 'Proportion', title = 'Porportion shortspine thornyhead in identified catch',
       fill = 'Gear', col = 'Gear')

pred %>% write_csv('outputs/fishery_data/smooth_sspn_ratios.csv')
ggsave("outputs/fishery_data/smooth_sspn_ratios.png", dpi=300, height=8, width=10, units='in')
