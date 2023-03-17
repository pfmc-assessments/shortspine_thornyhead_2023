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
  library(FSA) # used to get lencat() function, but could probably figure out without the package
  library(tidyverse)


# Read in data from local computer? Ideas?
data <- read.csv("C:/Users/sgbey/OneDrive/Documents/2023 Applied Stock Assessments/Shortspine Thornyhead/SST_maturitydata_forassessment03152023.csv") #put data set in here

names(data) # lengths in cm; maturity, 0=immature, 1=mature
unique(data$Sampling_platform) # samples from WCGBTS, ODFW, WDFW

# summaries
table(data$Sampling_platform ,data$Year)
table(data$Sampling_platform)

# Filter data, as necessary
data<-data[data$Certainty==1,] #filter only data where maturity is certain

plot(Functional_maturity~Biological_maturity, data=data)
#which samples are different
differences<-data[data$Functional_maturity!= data$Biological_maturity,]
plot(Biological_maturity ~ Length_cm, data= differences, pch="l", main = "SST where bio and func maturity are different", col="red", ylim= c(0,1), xlim=c(6,72))
points(Functional_maturity ~ Length_cm, data= differences, pch="l", col="blue")
legend(5,0.6, legend=c("determined by biological maturity", "determined by function maturity"), pch="l", col=c("red","blue"))


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
mat.SE   <- summary(maturityglm)$coefficients[,2]

A   <- mat.coefs[1] # is this correct?
B   <- mat.coefs[2] # is this correct?
sA  <- mat.SE[1]    # assuming this is standard error??
sB  <- mat.SE[2]
r   <- cor(mat.df$length, mat.df$maturity) # gives you r
n   <- nrow(mat.df)
L50 <- -A/B 

deltamethod <- ((sA^2)/(B^2))- ((2*A*sA*sB*r)/(B^3))+ (((A^2)*(sB^2))/(B^4))
deltamethod #is this a method fo L50?

1.96*(sqrt(deltamethod)/sqrt(n)) ###Gives you 95% CI## #For L50??


#~~~~~~~~~~~~~~~~~~
# code from Jane for plotting maturity curve

a   <- A
b   <- B
l50 <- L50 #use deltamethod estimate instead?

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


# With data plotted
ggplot(mat.df, aes(x=length, y=maturity)) + geom_point() + 
  stat_smooth(method="glm", method.args=list(family="binomial"), se=FALSE) +
  geom_segment(aes(x = l50, y = 0.5, xend = l50, yend = 0), lty = 2) +
  geom_segment(aes(x = l50, y = 0.5, xend = min(lens), yend = 0.5), lty = 2) +
  labs(x = 'Length (cm)', y = 'P(mature)',
       title = 'Shortspine thornyhead female maturity-at-length',
       subtitle = 'Source: M. Head, NWFSC') +
  theme_bw()



# base R plot
mat.glm <- glm(maturity ~ length, data=mat.df, family=binomial(link="logit"))

par(mar = c(4, 4, 1, 1)) # Reduce some of the margins so that the plot fits better
plot(mat.df$length, mat.df$maturity)
curve(predict(mat.glm, data.frame(length=x), type="response"), add=TRUE) 
  
 

# Next steps...

#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Exploratory analyses----
#~~~~~~~~~~~~~~~~~~~~~~~~~~

# Discuss with M. Head which maturity data to use
  # functional vs biological?
  # certain vs uncertain data?
  # temporal or depth covariates or filters on the data?

# 1. Question: Is there difference between functional vs biological?
# Answer: no!
# Plot functional and biological maturity using only "certain" reads

# select data
mat.bio.df<- data.frame(length = data$Length, 
                    maturity = data$Biological_maturity) 

mat.func.df<- data.frame(length = data$Length, 
                        maturity = data$Functional_maturity)
# complete cases
mat.bio.df<-mat.df[complete.cases(mat.df$maturity),]
mat.func.df<-mat.df[complete.cases(mat.df$maturity),]

# estimate parameters, logistic regression 
mat.bio.glm <- glm (maturity ~ 1 +length, data = mat.bio.df,  #why 1 + length??
                    family = binomial(link ="logit"))
mat.func.glm <- glm (maturity ~ 1 +length, data = mat.func.df,  #why 1 + length??
                    family = binomial(link ="logit"))

par(mar = c(4, 4, 1, 1)) # Reduce some of the margins so that the plot fits better
plot(maturity ~ length, data=mat.bio.df, col="blue", pch="l")
points(maturity ~ length, data=mat.func.df, col="red", pch="l")
curve(predict(mat.bio.glm, data.frame(length=x), type="response"), add=TRUE, col="blue") 
curve(predict(mat.func.glm, data.frame(length=x), type="response"), add=TRUE, col="red") 

# coefficients
a.bio   <- coef(mat.bio.glm)[1]
b.bio   <- coef(mat.bio.glm)[2]
l50.bio <- -a.bio/b.bio

a.func   <- coef(mat.func.glm)[1]
b.func   <- coef(mat.func.glm)[2]
l50.func <- -a.func/b.func

# visualize
lens <- seq(6, 72, 2)

matatlength.bio <- data.frame(length = lens) %>% 
  mutate(pmat = 1 / (1 + exp(-(a.bio + b.bio * length))))

matatlength.func <- data.frame(length = lens) %>% 
  mutate(pmat = 1 / (1 + exp(-(a.func + b.func * length))))

matatlength.bio$type<-"bio"
matatlength.func$type<-"func"

mat.func.bio.compare<-rbind(matatlength.bio,matatlength.func)

ggplot(mat.func.bio.compare, aes(x = length, y = pmat, col=type)) +
  geom_line() + 
  geom_segment(aes(x = l50, y = 0.5, xend = l50, yend = 0), lty = 2) +
  geom_segment(aes(x = l50, y = 0.5, xend = min(lens), yend = 0.5), lty = 2) +
  labs(x = 'Length (cm)', y = 'P(mature)',
       title = 'Shortspine thornyhead female maturity-at-length',
       subtitle = 'Source: M. Head, NWFSC') +
  theme_bw() 

# Compare to Pearson and Gunderson 2003 maturity information used in the 
# 2013 assessment
