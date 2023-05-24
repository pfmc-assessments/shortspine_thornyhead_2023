# Shortspine thornyhead fecundity-at-length
# Feb 2023
# Contact: sgbeyer@uw.edu

# Reference: Cooper, D.W., Pearson, K.E., and D.R. Gunderson, 2005. Fecundity of
# shortspine thornyhead (Sebastolobus alascanus) and longspine thornyhead
# (S. altivelis) from the northeastern Pacific Ocean, determined by stereological
# and gravimetric techniques. Fishery Bulletin 103: 15-22 

# Notes: 
# Cooper et al. (2005) found no difference in the fecundity-at-length
# relationship between SST off Alaska and the West Coast of the United States. 
# The fecundity parameters pooled Alaska and West Coast SST.

library(dplyr); library(ggplot2)

# fecundity-at-length----
# equation: fecundity = a*length^b
# length type: fork length in cm
# Fecundity = 0.0544*length^3.978

lens <- seq(6, 72, 0.1)

a <- 0.0544
b <- 3.978

fecatlength <- data.frame(length = lens) %>% 
  mutate(fec = a * length ^ b)

options(scipen = 999) #turn off scientific notation

ggplot(fecatlength, aes(x = length, y = fec)) +
  geom_line() + 
  labs(x = 'Length (cm)', y = 'Fecundity',
       title = 'Shortspine thornyhead fecundity-at-length ',
       subtitle = 'Source: Cooper et al. 2005') +
  geom_text(aes(15,1300000, 
            label=(paste(expression("Fec = 0.0544 L "^3.978*"")))),
            parse = TRUE) +
  theme_bw() 

ggsave('outputs/fecundity/cooper_fecundity_length.png', height = 4,
       width = 6, dpi = 300)


# Saving parameters for SS----

# Notes on scaling: The "unofficial groundfish stock assessment handbook" 
# has guidance on how to set up the fecundity parameters for SS
# (Sabrina thinks the scale can be off because SS estimates recruits in 1000s)

# For SST: model fecundity as a power function of length in SS
# F = a L^b
# The SST fecundity-length relationship is already in cm (not mm)
# So only need to divide the a parameter by 1000 for SS to get eggs in thousands
# b parameter stays the same

a.param.SST<- a/1000
b.param.SST<- b

# Alternative scaling for SS3: https://github.com/EJDick-NOAA/Rockfish-Fecundity
# note, SST length is ALREADY in cm and does not need the (a*10^b) conversion from mm to cm
# NOTE from the link if using the alternative scaling: SS3 tracks numbers of fish in 1000s, 
# so the reported spawning output will be in units of billions 
# of eggs if the fecundity-length relationship is in millions of eggs per fish

# This is the right one we thinK!
a.param.SST.million.eggs<- a/1000000
b.param.SST.million.eggs<- b


# Save 2023 growth parameters for the assessment----
# save the parameters for SS
# NOTE which scale is used (i.e. eggs in thousands or eggs in millions)

Fecundity <- data.frame(Param = c("Eggs_alpha_Fem_GP_1","Eggs_beta_Fem_GP_1"),
                        Value = c(a.param.SST.million.eggs,b.param.SST.million.eggs))

write_csv(Fecundity, 'data/for_ss/fecundity_2023.csv')

