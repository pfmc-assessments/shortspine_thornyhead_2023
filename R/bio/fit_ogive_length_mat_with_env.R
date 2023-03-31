########################################################################
######## Test ogive with environmental covariates

library(dplyr)   #for working with data frames
library(tidyr)   #for working with data frames
library(ggplot2) #for generating plots
library(mgcv)

### Load maturity data

tab_mat <- read.csv("C:/Users/pyher/Downloads/SST_maturitydata_forassessment03152023.csv")

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

# Mtrix that will be used for predictyions

quad_model_matrix = model.matrix(l_mat_quad$formula, dat_pred)
quad_coef = coef(l_mat_quad)

# Calculatin of L50 

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












