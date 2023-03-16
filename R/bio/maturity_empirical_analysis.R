# Shortspine thornyhead maturity-at-length
# Exploratory analysis of updated maturity information
# Adapted from code provided by Melissa Head, Northwest Fisheries Science Center
# For UW Applied Stock Assessment Course
# Winter/Spring 2023
# contact: sgbeyer@uw.edu


# Data Description:
  # updated maturity-at-length information provided by M. Head, NWFSC 
  # M. Head made a request to not share the data set outside of the assessment group
  # Ideas for best ways to do this?

# packages
  library(FSA) # used to get lencat() function, but could probably figure this 
                # this out without the package


# Read in data from local computer? Ideas?
data <- read.csv("C:/Users/Sabrina/Documents/2023 Applied Stock Assessments/Shortspine Thornyhead/SST_maturitydata_forassessment03152023.csv") #put data set in here

names(data) # lengths in cm; maturity, 0=immature, 1=mature
unique(data$Sampling_platform) # samples from WCGBTS, ODFW, WDFW

# summaries
table(data$Sampling_platform ,data$Year)
table(data$Sampling_platform)

# Filter data, as necessary
data<-data[data$Certainty==1,] #filter only data where maturity is certain

# choose maturity type here (biological or functional or other)
# Biological_maturity: 
# Functional_maturity:
mat.df<- data.frame(length = data$Length, 
                    maturity = data$Biological_maturity) 

mat.df<-mat.df[complete.cases(mat.df$maturity),]


# visualize the data
plot(maturity~length, data=mat.df, pch="l", ylim=c(0,1), las=1)
#hist(mat.df$length)

# visualize proportion of fish mature by length bin
# set size of length bins with w =
mat.df <- lencat(~length,data=mat.df,startcat=10,w=2) #from FSA package

tblLen <- with(mat.df,table(LCat,maturity))
ptblLen <- prop.table(tblLen,margin=1)
ptblLen[1:6,] # only 1st 6 rows to save space

lens <- as.numeric(rownames(ptblLen))
plot(ptblLen[,"1"]~lens,pch=16,xlab="Length (cm) - binned",ylab="Proportion Mature", ylim=c(0,1), las=1)



# Very basic glm maturity analysis (from M. Head)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NOTES: All of this needs to be checked!
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

maturityglm <- glm (maturity ~ 1 + length, data = mat.df,  #why 1 + length??
                    family = binomial(link ="logit"))


# data$Length and data$Maturity are just calling length and maturity columns in your dataset. 
# So just make sure you column names match these or change naming in script
# You can change Length to Age

summary(maturityglm) ###give you A, B, SA, SB, and n ###
mat.coefs<- coef(maturityglm)
mat.coefs

A   <- mat.coefs[1] # is this correct?
B   <- mat.coefs[2] # is this correct?
sA  <-              # fill in
sB  <-
r   <- cor(mat.df$length, mat.df$maturity) # gives you r
n   <- nrow(mat.df)
L50 <- -A/B 

deltamethod <- ((sA^2)/(B^2))- ((2*A*sA*sB*r)/(B^3))+ (((A^2)*(sB^2))/(B^4))
deltamethod

1.96*(sqrt(deltamethod)/sqrt(n)) ###Gives you 95% CI##


#~~~~~~~~~~~~~~~~~~
# code from Jane for plotting maturity curve

a   <- A
b   <- B
l50 <- L50

lens <- seq(6, 72, 2)

# not working
#matatlength <- data.frame(length = lens) %>% 
#  mutate(pmat = 1 / (1 + exp(a + b * length)))

# does this work? yes, why? added a negative sign
# need to check this
matatlength <- data.frame(length = lens) %>% 
  mutate(pmat = 1 / (1 + exp(-(a + b * length))))

ggplot(matatlength, aes(x = length, y = pmat)) +
  geom_line() + 
  geom_segment(aes(x = l50, y = 0.5, xend = l50, yend = 0), lty = 2) +
  geom_segment(aes(x = l50, y = 0.5, xend = min(lens), yend = 0.5), lty = 2) +
  labs(x = 'Length (cm)', y = 'P(mature)',
       title = 'Shortspine thornyhead female maturity-at-length',
       subtitle = 'Source: M. Head, NWFSC') +
  theme_bw() 

# is there a way to add the data to the plot? I've seen this as hash marks
# on top and bottom. I've also seen plotted proportions at length by length bins,
# although that can sometimes be confusing as to what data the curve is fit to.

# Next steps...

# Discuss with M. Head which maturity data to use
  #functional vs biological?
  #certain vs uncertain data?

# Compare to Pearson and Gunderson 2003 maturity information used in the 
# 2013 assessment
