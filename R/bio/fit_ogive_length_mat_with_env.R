########################################################################
######## Test ogive with environmental covariates

library(dplyr)   #for working with data frames
library(tidyr)   #for working with data frames
library(ggplot2) #for generating plots
library(mgcv)
library(nwfscSurvey)
library(tidyverse)

###------------------------------------------###
###----------- Maturity data -------------------
###------------------------------------------###

### Load maturity data

tab_mat <- read.csv("C:/Users/pyher/Downloads/SST_maturitydata_forassessment03152023.csv")

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



# Creating a matrix for performing predictions

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

dat_pred_continuous %>%
  ggplot() +
  geom_tile(aes(x=Depth, y=Latitude, fill = L50_quad)) +
  scale_x_reverse() +
  scale_fill_viridis_c() +
  labs(fill="L50 (cm)") +
  theme_bw()

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
  mutate(Depth_m_w = Depth_m * cpue_kg_km2 / tot_cpue, Latitude_dd_w = Latitude_dd * cpue_kg_km2 / tot_cpue) %>%
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


