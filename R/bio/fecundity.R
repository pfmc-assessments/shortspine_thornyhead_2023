# Shortspine thornyhead fecundity-at-length
# Feb 2023
# Contact: sgbeyer@uw.edu
# Code adapted from maturity.R, contact: Jane Sullivan (jane.sullivan@noaa.gov)

# Reference: Cooper, D.W., Pearson, K.E., and D.R. Gunderson, 2005. Fecundity of
# shortspine thornyhead (Sebastolobus alascanus) and longspine thornyhead
# (S. altivelis) from the northeastern Pacific Ocean, determined by stereological
# and gravimetric techniques. Fishery Bulletin 103: 15-22 

# Notes: 
# Cooper et al. (2005) found no difference in the fecundity-at-length
# relationship between SST off Alaska and the West Coast of the United States. 
# The fecundity parameters were reported for pooled Alaska and West Coast SST.

library(dplyr); library(ggplot2)

# fecundity-at-length----
# equation: fecundity = a*length^b
# length type: fork length in cm

lens <- seq(6, 72, 0.1)

a <- 0.0544
b <- 3.978

fecatlength <- data.frame(length = lens) %>% 
  mutate(fec = a * length ^ b)

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


# assessment vector (not sure this is needed)
# lens <- seq(6, 72, 2)

# fecatlength <- data.frame(length = lens) %>% 
#   mutate(fec = a * length ^ b)

# fecatlength %>% write_csv('outputs/fecundity/cooper_fecundity_length.csv')
