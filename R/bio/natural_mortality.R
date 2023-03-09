# Shortspine Thornyhead Natural Mortality
# March 2023
# contact: sgbeyer@uw.edu

# References: Hamel, O.S., Cope, J.M. 2022 Development and considerations for
# application of a longevity-based prior for the natural mortality
# rate. Fisheries Research 256: 106477


# History: 2013 Assessment
# "Butler et al. (1995) estimated the lifespan of shortspine thornyhead to 
# exceed 100 years, and suggested that M was likely less than 0.05. M may 
# decrease with age as shortspine migrate ontogenetically down the slope to 
# the oxygen minimum zone, which is largely devoid of predators for fish of 
# their body size. The previous assessment fixed the natural mortality 
# parameter at 0.05. For this (2013) assessment, a prior on natural mortality was 
# developed based on a maximum age of 100 years which had a mean of 0.0505 
# and a standard deviation on a log scale of 0.5361 (Hamel, pers. comm.). 
# For the base case, natural mortality was fixed at the mean of this 
# prior distribution." page 22


# 2023 Assessment Prior on M
# Hamel and Cope 2022
# M = 5.40/ Amax 
# SD (in log-space) = 0.31; 

Amax  <- 100            # Amax in 2013 assessment

M = 5.40/Amax
round(M, digits=3)      # M = 0.054; median; median value = point estimate; 
                        # report 3 significant digits
log.M <-log(M)          
log.M                   # mean of prior in natural log-space

log.sd <- 0.44/sqrt(2)  # SD of prior in natural log-space = 0.31; Hamel and Cope 2022
round(log.sd, digits=2)



