# Shortspine thornyhead maturity-at-length
# Feb 2023
# Contact: jane.sullivan@noaa.gov

# Reference: Pearson, K.E., and D.R. Gunderson, 2003. Reproductive biology and
# ecology of shortspine thornyhead rockfish (Sebastolobus alascanus) and
# longspine thornyhead rockfish (S. altivelis) from the northeastern Pacific
# Ocean. Environ. Biol. Fishes 67:11-136.

# Note: Note: Melissa Head (NWFSC) is providing us updated maturity-at-length
# data (by year and state) in late Feb to mid-March. Samples come from WCGBT and
# port samples.

library(dplyr); library(ggplot2)

lens <- seq(12, 25, 0.01)

a <- 41.913	
b <- -2.3046
l50 <- 18.19

matatlength <- data.frame(length = lens) %>% 
  mutate(pmat = 1 / (1 + exp(a + b * length)))

ggplot(matatlength, aes(x = length, y = pmat)) +
  geom_line() + 
  geom_segment(aes(x = l50, y = 0.5, xend = l50, yend = 0), lty = 2) +
  geom_segment(aes(x = l50, y = 0.5, xend = min(lens), yend = 0.5), lty = 2) +
  labs(x = 'Length (cm)', y = 'P(mature)',
       title = 'Shortspine thornyhead female maturity-at-length (L50 = 18.19 cm)',
       subtitle = 'Source: Pearson and Gunderson 2003') +
  theme_bw() 

ggsave('outputs/maturity/pearson_maturity_length.png', height = 4,
       width = 6, dpi = 300)

# length at 75% maturity
matatlength %>% filter(pmat >= 0.745 & pmat <= 0.76) # L75 = 18.67

# assessment vector
lens <- seq(6, 72, 2)

matatlength <- data.frame(length = lens) %>% 
  mutate(pmat = 1 / (1 + exp(a + b * length)))

matatlength %>% write_csv('outputs/maturity/pearson_maturity_length.csv')
