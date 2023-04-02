########################################################################
######## Test ogive with environmental covariates

library(dplyr)   #for working with data frames
library(tidyr)   #for working with data frames
library(ggplot2) #for generating plots
library(mgcv)

source(file=file.path(here::here(), "R", "utils", "colors.R"))

### Load maturity data

tab_mat <- read.csv("data/raw/SST_maturitydata_forassessment03152023.csv")

### Define latitude and length data - will just be used to explore the predictions 

tab_mat %>%
  mutate(depth_class = Depth %/% 250 * 250,
         lat_class = Latitude %/% 4 * 4) -> tab_mat

### Define the table for predictions

dat_pred = crossing(Depth = seq(min(tab_mat$depth_class, na.rm=T), max(tab_mat$depth_class, na.rm=T), by=250),
                    Latitude = seq(min(tab_mat$lat_class, na.rm=T), max(tab_mat$lat_class, na.rm=T), by=4),
                    Length_cm = 0, #placeholder 
                    Functional_maturity = 1 #placeholder
)

### Glm including depth and latitude as covariates

l_mat_quad <- glm(Functional_maturity ~ 1 + Length_cm +
                          Depth + I(Depth^2) +
                          Latitude + I( Latitude^2),
                        data = tab_mat,
                        family=binomial(link = "logit"))

# Matrix that will be used for predictions

quad_model_matrix = model.matrix(l_mat_quad$formula, dat_pred)
quad_coef = coef(l_mat_quad)

# Calculation of L50 

L50_numerator = quad_model_matrix %*% quad_coef 
L50_denominator = quad_coef[["Length_cm"]]

L50_quad = - L50_numerator / L50_denominator
dat_pred$L50_quad <- c(L50_quad)

dat_pred$depth_class <- dat_pred$Depth
dat_pred$lat_class <- dat_pred$Latitude
#dat_pred$Functional_maturity_pred <- 
#dat_pred$Length_cm_obs <- 
obsfit <- cbind(filter(tab_mat, !is.na(Depth) & !is.na(Functional_maturity)), fitted(l_mat_quad))

###### Plot ogive changes with environmental covariates

ggplot(tab_mat, aes(x = Length_cm, y = Functional_maturity))+ 
  facet_grid(depth_class~lat_class, labeller = label_both) + 
  geom_point(size=1) +
  #geom_line(aes(y=prob), size=1)+
  geom_hline(yintercept = 0.5,linetype=2) +
  geom_vline(data = dat_pred, aes(xintercept = L50_quad), linetype=1, color="red", size=1.2) +
  geom_point(data =obsfit, aes(y= fitted(l_mat_quad) ),color="blue", alpha=0.5)+
  theme_bw()+
  theme(panel.grid = element_blank())



### 

dat_pred_continuous = crossing(Depth = seq(0, 1400, by=50),
                    Latitude = seq(32, 50, by=1),
                    Length_cm = 0, #dummy value of length. Set to zero so it will not affect the predictions
                    Functional_maturity = 1 #dummy value of condition; will not affect predicted L50 values, but it is needed for building the model matrix.
)

quad_model_matrix = model.matrix(l_mat_quad$formula, dat_pred_continuous)
quad_coef = coef(l_mat_quad)

L50_numerator = quad_model_matrix %*% quad_coef 
L50_denominator = quad_coef[["Length_cm"]]

L50_quad = - L50_numerator / L50_denominator
dat_pred_continuous$L50_quad <- c(L50_quad)

dat_pred_continuous %>%
  ggplot() +
  geom_tile(aes(x=Depth, y=Latitude, fill = L50_quad)) +
  scale_fill_gradientn(colours = rev(terrain.colors(225))) +
  scale_x_reverse() +
  theme_bw()

names(tab_mat)

#
# Same combo survey strata definitions: two southern strata below 34.5º N, one covering 183–550 m and the
# other covering 550–1280 m. Two central strata between 34.5º N and 40.5º N, had
# the same depth ranges. North of 40.5º N, three strata were used, covering the
# ranges 100–183 m, 183–550 m and the other covering 550–1280 m. The depth
# breaks at 183 m and 550 m are associated with changes in sampling intensity of
# the survey and are recommended to be used. South of 40.5º N, there are very
# few shortspine thornyheads shallower than 183 m so no shallow stratum was used
# in these latitudes.

tab_mat <- read.csv("data/raw/SST_maturitydata_forassessment03152023.csv")

tab_mat <- tab_mat %>% 
  filter(!is.na(Latitude) & !is.na(Depth)) %>% 
  mutate(Strata = case_when(Latitude < 34.5 & Depth < 550 ~ '1_South_shallow',
                            Latitude < 34.5 & Depth >= 550 ~ '2_South_deep',
                            between(Latitude, 34.5, 40.5) & Depth < 550 ~ '3_Central_shallow',
                            between(Latitude, 34.5, 40.5) & Depth >= 550 ~ '4_Central_deep',
                            Latitude > 40.5 & Depth < 183 ~ '5_North_shallow',
                            Latitude > 40.5 & between(Depth, 183, 550) ~ '6_North_mid',
                            Latitude > 40.5 & Depth > 550 ~ '7_North_deep')) #%>% 
  # mutate(Strata = factor(Strata, levels = c('South_shallow', 'South_deep',
  #                                            'Central_shallow', 'Central_deep',
  #                                            'North_shallow', 'Noth_mid', 'North_deep'),
         # ordered = TRUE))
nrow(tab_mat)
table(tab_mat$Strata)

dat_pred2 = crossing(Strata = unique(tab_mat$Strata),
                     Length_cm = 0, #placeholder 
                     Functional_maturity = 1 #placeholder
)

l_mat_strat <- glm(Functional_maturity ~ 1 + Length_cm + Strata,
                  data = tab_mat,
                  family=binomial(link = "logit"))
summary(l_mat_strat)

# get survey biomass by stratum
# also called West Coast Groundfish Bottom Trawl Survey (WCGBT)?
library(nwfscSurvey)
combo_path <- 'data/raw/NWFSCcombo'; dir.create(combo_path)

combo_catch <- PullCatch.fn(Name = 'shortspine thornyhead',
                            SurveyName = 'NWFSC.Combo',
                            Dir = combo_path,
                            SaveFile = TRUE)

# 7 strata; two southern strata below 34.5º N, one covering 183–550 m and the
# other covering 550–1280 m. Two central strata between 34.5º N and 40.5º N, had
# the same depth ranges. North of 40.5º N, three strata were used, covering the
# ranges 100–183 m, 183–550 m and the other covering 550–1280 m. The depth
# breaks at 183 m and 550 m are associated with changes in sampling intensity of
# the survey and are recommended to be used. South of 40.5º N, there are very
# few shortspine thornyheads shallower than 183 m so no shallow stratum was used
# in these latitudes.
combo_strata <- CreateStrataDF.fn(names = c('1_South_shallow', '2_South_deep', 
                                            '3_Central_shallow', '4_Central_deep', 
                                            '5_North_shallow', '6_North_mid', '7_North_deep'), 
                                  depths.shallow = c(183, 549, 183, 549, 100, 183, 549), 
                                  depths.deep = c(549, 1280, 549, 1280, 183, 549, 1280),
                                  lats.south = c(32, 32, 34.5, 34.5, 40.5, 40.5, 40.5),
                                  lats.north = c(34.5, 34.5, 40.5, 40.5, 49, 49, 49)) 

combo_biomass <- Biomass.fn(fleet = 9, # SS3 fleet/survey index
                            dir = combo_path,
                            dat = combo_catch,
                            strat.df = combo_strata)
names(combo_biomass)
weights <-  do.call('rbind', combo_biomass$StrataEsts) %>% 
  tibble::rownames_to_column(var = 'rn') %>% 
  tidyr::separate_wider_delim('rn', names = c('Strata', 'year'), delim = '.') %>%
  filter(year %in% unique(tab_mat$Year)) %>% 
  group_by(Strata) %>% 
  summarise(strataN = mean(Nhat)) %>% 
  ungroup() %>% 
  mutate(totN = sum(strataN),
         wt = strataN / totN) 

# weight model coefficients by abundance in the survey
strat_model_matrix = model.matrix(l_mat_strat$formula, dat_pred2)
strat_coef = coef(l_mat_strat)
summary(l_mat_strat)

# Calculation of L50 and kmat (note only the intercepts vary by strata)
L50_numerator = strat_model_matrix %*% strat_coef 
L50_denominator = strat_coef[["Length_cm"]]

L50_strat = - L50_numerator / L50_denominator
dat_pred2$L50_strat <- c(L50_strat)

len = 40 # doesn't matter what length you use here
(kmat <- round(((L50_numerator[,1] + strat_coef[2]*len) / (len - L50_strat[,1])), 2))[1]

out <- dat_pred2 %>% 
  left_join(weights) %>% 
  mutate(L50 = sum(L50_strat * wt)/sum(wt)) %>% 
  mutate(kmat = kmat) %>% 
  select(-Length_cm, -Functional_maturity)

out %>% write_csv('outputs/maturity/mhead_weighted_parameters.csv')
  
dat_pred3 = crossing(Strata = unique(tab_mat$Strata),
                     Length_cm = seq(6, 72, 0.2)
)

dat_pred3 <- dat_pred3 %>% 
  mutate(pred = predict(object = l_mat_strat,newdata = dat_pred3),
         pred = exp(pred)/(1+exp(pred)))

pmat <- tab_mat %>% 
  filter(!is.na(Functional_maturity)) %>% 
  group_by(Strata, Length_cm) %>% 
  summarise(p_mature = length(which(Functional_maturity == 1)) / n())

# Pearson and Gunderson values
a <- 41.913	
b <- -2.3046
# l50 <- 18.19

matatlength <- data.frame(length = lens) %>% 
  mutate(pmat = )

pred <- data.frame(Length_cm = seq(6, 72, 0.2)) %>% 
  mutate(pred =  1 / (1 + exp(-kmat * (Length_cm - unique(out$L50)))),
         version = 'Head 2023 (weighted by abundance)') %>% 
  bind_rows( data.frame(Length_cm = seq(6, 72, 0.2)) %>% 
               mutate(pred =  1 / (1 + exp(a + b * Length_cm)),
                      version = 'Pearson and Gunderson (2003)'))

ggplot() +
  geom_line(data = pred, aes(Length_cm, pred, lty = version), size = 1.5) +
  geom_point(data = pmat, aes(Length_cm, p_mature, col = Strata)) +
  geom_line(data = dat_pred3, aes(Length_cm, pred, col = Strata)) +
  scale_color_colorblind7()+
  scale_fill_colorblind7()+
  scale_y_continuous(labels = scales::comma)+
  labs(x="Year", y="P(mature)", color="Strata", lty = 'Version')+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "right",
    axis.text = element_text(size=12),
    axis.title = element_text(size=12)
  )
ggsave(file.path(here::here(), "outputs", "maturity", "mhead_maturity.png"), dpi=300, width=10, height=7, units = "in")

         