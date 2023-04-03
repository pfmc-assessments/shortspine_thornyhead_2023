########################################################################
######## Test ogive with environmental covariates

library(dplyr)   #for working with data frames
library(tidyr)   #for working with data frames
library(ggplot2) #for generating plots
library(ggthemes)
library(mgcv)
library(nwfscSurvey)
library(tidyverse)

###------------------------------------------###
###----------- Maturity data -------------------
###------------------------------------------###

source(file=file.path(here::here(), "R", "utils", "colors.R"))

### Load maturity data

tab_mat <- read.csv("data/raw/SST_maturitydata_forassessment03152023.csv")

names(tab_mat)

#
# Same combo survey strata definitions: two southern strata below 34.5º N, one
# covering 183–550 m and the other covering 550–1280 m. Two central strata
# between 34.5º N and 40.5º N, had the same depth ranges. North of 40.5º N,
# three strata were used, covering the ranges 100–183 m, 183–550 m and the other
# covering 550–1280 m. The depth breaks at 183 m and 550 m are associated with
# changes in sampling intensity of the survey and are recommended to be used.
# South of 40.5º N, there are very few shortspine thornyheads shallower than 183
# m so no shallow stratum was used in these latitudes.
table(tab_mat$Certainty)
tab_mat <- tab_mat %>% 
  filter(!is.na(Latitude) & !is.na(Depth)) %>% 
  mutate(Strata = case_when(Latitude < 34.5 & Depth < 550 ~ '1_South_shallow',
                            Latitude < 34.5 & Depth >= 550 ~ '2_South_deep',
                            between(Latitude, 34.5, 40.5) & Depth < 550 ~ '3_Central_shallow',
                            between(Latitude, 34.5, 40.5) & Depth >= 550 ~ '4_Central_deep',
                            Latitude > 40.5 & Depth < 183 ~ '5_North_shallow',
                            Latitude > 40.5 & between(Depth, 183, 550) ~ '6_North_mid',
                            Latitude > 40.5 & Depth > 550 ~ '7_North_deep')) %>% 
  filter(Certainty == 1)
nrow(tab_mat)
table(tab_mat$Strata)


###---------------------------------------###
###---------- Stratum method ----------------
###---------------------------------------###

dat_pred2 = crossing(Strata = unique(tab_mat$Strata),
                     Length_cm = 0, #placeholder 
                     Functional_maturity = 1 #placeholder
)

# Logistic model with separate intercepts for each stratum
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

# same 7 strata; see definitions above
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
kmat <- ((L50_numerator[,1] + strat_coef[2]*len) / (len - L50_strat[,1]))[1]

out <- dat_pred2 %>% 
  left_join(weights) %>% 
  mutate(L50 = sum(L50_strat * wt)/sum(wt)) %>% 
  mutate(kmat = kmat) %>% 
  select(-Length_cm, -Functional_maturity)

out %>% write_csv('outputs/maturity/head2023_strata_parameters.csv')
  
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

pred <- data.frame(Length_cm = seq(6, 72, 0.2)) %>% 
  mutate(pred =  1 / (1 + exp(-kmat * (Length_cm - unique(out$L50)))),
         version = 'Head 2023 (weighted by abundance)') %>% 
  bind_rows( data.frame(Length_cm = seq(6, 72, 0.2)) %>% 
               mutate(pred =  1 / (1 + exp(a + b * Length_cm)),
                      version = 'Pearson and Gunderson (2003)'))

ggplot() +
  geom_line(data = pred, aes(Length_cm, pred, lty = version), size = 1.2) +
  geom_point(data = pmat, aes(Length_cm, p_mature, col = Strata)) +
  geom_line(data = dat_pred3, aes(Length_cm, pred, col = Strata), size = 0.8) +
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
ggsave(file.path(here::here(), "outputs", "maturity", "head2023_maturity_strata.png"), dpi=300, width=10, height=7, units = "in")


###---------------------------------------###
###-------- ALTERNATIVE METHOD -----------###
###---------------------------------------###

### Define latitude and length data - will just be used to visually explore the predictions 

tab_mat %>%
  mutate(depth_class = Depth %/% 250 * 250,
         lat_class = Latitude %/% 4 * 4) -> tab_mat


### Quick exploration of the data coverage

tab_mat %>%
  mutate(depthbin=floor(Depth)%/%50 * 50) %>%
  group_by(depthbin) %>%
  summarize(nb_spl=n()) %>%
  ggplot(aes(x=depthbin, y=nb_spl)) +
  geom_bar(stat="identity") +
  labs(x="depth", y="number of samples") +
  theme_bw()

tab_mat %>%
  mutate(latbin=floor(Latitude)) %>%
  group_by(latbin) %>%
  summarize(nb_spl=n()) %>%
  ggplot(aes(x=latbin, y=nb_spl)) +
  geom_bar(stat="identity") +
  labs(x="latitude", y="number of samples") +
  theme_bw()

tab_mat %>%
  ggplot(aes(x=Depth, y=Latitude)) +
  geom_point(stat="identity") +
  labs(x="depth", y="latitude") +
  scale_x_reverse() +
  theme_bw()

# It appears that we cover a wide range of depth and latitudinal values, with 

###------------------------------------------###
###------ Parsimonious approach: GLM -----------
###------------------------------------------###


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

# Calculation of the L50 based on the fitted model

L50_numerator = quad_model_matrix %*% quad_coef 
L50_denominator = quad_coef[["Length_cm"]]

L50_quad = - L50_numerator / L50_denominator
dat_pred$L50_quad <- c(L50_quad)

dat_pred$depth_class <- dat_pred$Depth
dat_pred$lat_class <- dat_pred$Latitude
obsfit <- cbind(filter(tab_mat, !is.na(Depth) & !is.na(Functional_maturity)), fitted(l_mat_quad))

###------------------------------------------###
###------ Summarize the model outputs ----------
###------------------------------------------###

tab_mat %>%
  filter(!is.na(depth_class)) %>%
  ggplot(aes(x = Length_cm, y = Functional_maturity))+ 
  facet_grid(factor(lat_class, levels=rev(sort(unique(tab_mat$lat_class)))) ~ factor(depth_class, levels=rev(sort(unique(tab_mat$depth_class))))) +  geom_point(size=1) +
  #geom_line(aes(y=prob), size=1)+
  geom_hline(yintercept = 0.5,linetype=2) +
  geom_vline(data = dat_pred, aes(xintercept = L50_quad), linetype=1, color="red", size=1.2) +
  geom_point(data =obsfit, aes(y= fitted(l_mat_quad)),color="blue", alpha=0.5)+
  labs(x="Length (cm)", y="Depth(m)") +
  theme_bw()+
  theme(panel.grid = element_blank())

ggsave(file.path(here::here(), "outputs", "maturity", "head2023_maturity_latdepth_detailed1.png"), dpi=300, width=10, height=7, units = "in")


# dat_pred %>%
#   ggplot() +
#   geom_tile(aes(x=Depth, y=Latitude, fill = L50_quad)) +
#   scale_x_reverse() +
#   scale_fill_viridis_c() +
#   labs(fill="L50 (cm)") +
#   theme_bw()


###------------------------------------------###
###---- Expansion to the whole population ------
###------------------------------------------###

species <- "shortspine thornyhead"
survey.name <- "NWFSC.Combo"
survey.name.path <- str_replace(tolower(survey.name), "[.]", "_")

data.dir <- here::here("data/") # location of data directory

raw.data.dir <- file.path(data.dir, "raw")
catch.fname <- file.path(raw.data.dir, paste0(survey.name.path, "_survey_catch.csv")) # raw survey catch filename
out.dir <- file.path(outputs.dir, "surveys", survey.name.path) # send all plot/data outputs here

catch <- PullCatch.fn(Name = species, 
                      SurveyName = survey.name)

catch %>%
  mutate(tot_cpue = sum(cpue_kg_km2, na.rm=T)) %>%
  mutate(Depth_m_w = (Depth_m * cpue_kg_km2) / tot_cpue, 
         Latitude_dd_w = (Latitude_dd * cpue_kg_km2) / tot_cpue) %>%
  summarize(mean_depth = sum(Depth_m_w, na.rm=T),
            mean_lat = sum(Latitude_dd_w, na.rm=T)) %>%
  mutate('(Intercept)'=1,
         Length_cm=0, 
         "I(Depth^2)"=mean_depth^2,
         "I(Latitude^2)"=mean_lat^2,
         Functional_maturity=1) %>%
  dplyr::rename("Depth"="mean_depth",
                "Latitude"="mean_lat") %>%
  dplyr::select("(Intercept)", "Length_cm", "Depth", "I(Depth^2)", "Latitude", "I(Latitude^2)", "Functional_maturity") -> mean_env

quad_model_matrix_mean = model.matrix(l_mat_quad$formula, mean_env)
quad_coef_mean = coef(l_mat_quad)

L50_numerator_mean = quad_model_matrix_mean %*% quad_coef_mean 
L50_denominator_mean = quad_coef_mean[["Length_cm"]]

L50_quad_mean = - L50_numerator_mean / L50_denominator_mean

len = 40 # doesn't matter what length you use here
kmat_mean <- ((L50_numerator[,1] + quad_coef[2]*len) / (len - L50_quad[,1]))[1]

# Pearson and Gunderson values
a <- 41.913	
b <- -2.3046
# l50 <- 18.19

pg_l50 <- -a/b
pg_matk <- (a + b*len)/(len-pg_l50)


pmat <- tab_mat %>% 
  filter(!is.na(Functional_maturity)) %>% 
  group_by(depth_class, lat_class, Length_cm) %>% 
  summarise(p_mature = length(which(Functional_maturity == 1)) / n())

pred <- data.frame(Length_cm = seq(6, 72, 0.2)) %>% 
  mutate(pred =  1 / (1 + exp(-kmat_mean * (Length_cm - unique(L50_quad_mean)))),
         version = 'Head 2023 (weighted by CPUE)') %>% 
  bind_rows( data.frame(Length_cm = seq(6, 72, 0.2)) %>% 
               mutate(pred =  1 / (1 + exp(a + b * Length_cm)),
                      version = 'Pearson and Gunderson (2003)'))

dat_pred %>%
  dplyr::select(-Length_cm) %>%
  crossing(Length_cm = seq(6, 72, 0.2)) %>%
  mutate(pred =  1 / (1 + exp(-kmat_mean * (Length_cm - L50_quad))),
         version = 'Head 2023 (weighted by CPUE)') %>%
  filter(lat_class==unique(dat_pred$lat_class)[which.min(abs(unique(dat_pred$lat_class)-mean(tab_mat$Latitude, na.rm=T)))]) %>%
  mutate(grad="Depth") -> dat_pred_depth_class
  
dat_pred %>%
  dplyr::select(-Length_cm) %>%
  crossing(Length_cm = seq(6, 72, 0.2)) %>%
  mutate(pred =  1 / (1 + exp(-kmat_mean * (Length_cm - L50_quad))),
         version = 'Head 2023 (weighted by CPUE)') %>%
  filter(depth_class==unique(dat_pred$depth_class)[which.min(abs(unique(dat_pred$depth_class)-mean(tab_mat$Depth, na.rm=T)))]) %>%
  mutate(grad="Latitude") -> dat_pred_lat_class


ggplot() +
  geom_line(data = pred, aes(Length_cm, pred, lty = version), size = 1.2) +
  geom_point(data = pmat, aes(Length_cm, p_mature, col = factor(depth_class))) +
  geom_line(data = dat_pred_depth_class, aes(Length_cm, pred, col = factor(depth_class)), size=0.8) +
  facet_wrap(~grad) +
  scale_color_colorblind7()+
  scale_fill_colorblind7()+
  scale_y_continuous(labels = scales::comma)+
  labs(x="Year", y="P(mature)", color="Depth", lty = 'Version')+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "right",
    axis.text = element_text(size=12),
    axis.title = element_text(size=12)
  )
ggsave(file.path(here::here(), "outputs", "maturity", "head2023_maturity_latdepth_bydepth.png"), dpi=300, width=10, height=7, units = "in")

ggplot() +
  geom_line(data = pred, aes(Length_cm, pred, lty = version), size = 1.2) +
  geom_point(data = pmat, aes(Length_cm, p_mature, col = factor(lat_class))) +
  geom_line(data = dat_pred_lat_class, aes(Length_cm, pred, col = factor(lat_class)), size=0.8) +
  facet_wrap(~grad) +
  scale_color_colorblind7()+
  scale_fill_colorblind7()+
  scale_y_continuous(labels = scales::comma)+
  labs(x="Year", y="P(mature)", color="Latitude", lty = 'Version')+
  theme_minimal()+
  theme(
    panel.grid.minor = element_blank(),
    axis.line = element_line(),
    legend.position = "right",
    axis.text = element_text(size=12),
    axis.title = element_text(size=12)
  )
ggsave(file.path(here::here(), "outputs", "maturity", "head2023_maturity_latdepth_bylat.png"), dpi=300, width=10, height=7, units = "in")


# Finalize ----

# The preferred option is l_mat_quad but l_mat_strat is likely most
# representative of the population.
AIC(l_mat_strat, l_mat_quad)

data.frame(Method = c('Pearson_and_Gunderson_2003', 'Head_2023_latitude_depth', 'Head_2023_strata'),
           Mat_L50_Fem = c(pg_l50, L50_quad_mean, unique(out$L50)),
           Mat_slope_Fem = c(pg_matk, kmat_mean, unique(out$kmat))) %>% 
  write_csv('data/for_ss/maturity_alternatives_2023.csv')



