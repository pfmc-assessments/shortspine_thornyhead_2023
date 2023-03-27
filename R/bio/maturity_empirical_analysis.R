# Shortspine thornyhead maturity-at-length
# Exploratory analysis of updated maturity information
# Adapted from code provided by Melissa Head, Northwest Fisheries Science Center
# For UW Applied Stock Assessment Course
# Winter/Spring 2023
# contact: sgbeyer@uw.edu


# Data Description:
  # updated maturity-at-length information provided by M. Head, NWFSC 
  # biological maturity: presence of yolk in the oocyte (vitellogenesis)
  # function maturity: evidence the fish will spawn or has already spawned
  # M. Head made a request to not share the data set outside of the assessment group
  # Ideas for best ways to do this?

# Discuss with M. Head which maturity data to use:
  # functional vs biological? 
  # M.Head-functional maturity (excludes fish with mass atresia: abortive maturation, skipped spawner)
  # certain vs uncertain data? filtering on Certainty == 1
  # M.Head-Yes!
  # temporal or depth covariates or filters on the data?
  # M.Head- Depth or latitude likely to explain the odd "bump" in the curve
  # however, this is not a spatial assessment

# packages
  library(FSA) # used to get lencat() function, but could probably figure out without the package
  library(tidyverse)

# directories
  # Read in data from local computer? Ideas?
  your.data.path<-"C:/Users/Sabrina/Documents/2023 Applied Stock Assessments/Shortspine Thornyhead"
  
# load data
data <- read.csv(paste(your.data.path,"/SST_maturitydata_forassessment03152023.csv", sep="")) 

names(data)                    # lengths in cm; maturity, 0=immature, 1=mature
unique(data$Sampling_platform) # samples from WCGBTS, ODFW, WDFW

# format and extract date information
data$Date_of_collection <- as.Date(data$Date_of_collection,format = "%Y %m %d")
data$month              <- format(data$Date_of_collection,"%m")
data$month              <- as.numeric(data$month)

# summaries
table(data$Sampling_platform ,data$Year)
table(data$Sampling_platform)

# Filter data, as necessary
# M. Head confirmed to filter by "certainty = 1"
data<-data[data$Certainty==1,]

# Data coverage?
# samples by female length
hist(data$Length_cm)        #range 15 cm to 74 cm (no females under 15 cm, not as many large females)
# samples by latitude
hist(data$Latitude)         #spans the West Coast, more samples in the north (45N-Oregon?)
# samples by depth
hist(data$Depth)            #range 151 m to 1247 m (somewhat bi-modal, largest peak 400-500 m)
# samples by month
hist(data$month, breaks=seq(1,12,1))
# active spawners by month
hist(data[data$Spawning=="Y",]$month, breaks=seq(1,12,1)) # May and June


# which samples are different between the "biological" and "functional" maturity definitions
differences<-data[data$Functional_maturity!= data$Biological_maturity,]
plot(Biological_maturity ~ Length_cm, data= differences, pch="l", main = "SST where bio and func maturity are different", col="red", ylim= c(0,1), xlim=c(6,72))
points(Functional_maturity ~ Length_cm, data= differences, pch="l", col="blue")
legend(5,0.6, legend=c("biological maturity assignment", "functional maturity assignment"), pch="l", col=c("red","blue"))


# choose maturity type here (biological or functional or other)
# choose functional maturity per M. Head (excludes "biologically" mature fish that are not contributing to egg production: abortive maturation and skipped spawning)
mat.df<- data.frame(length = data$Length, 
                    maturity = data$Functional_maturity) 

mat.df<-mat.df[complete.cases(mat.df$maturity),]


# visualize the data
plot(maturity~length, data=mat.df, pch="l", ylim=c(0,1), las=1)

# visualize proportion of fish mature by length bin
# set size of length bins with w =
mat.df <- lencat(~length,data=mat.df,startcat=10,w=2) #lencat()from FSA package

tblLen <- with(mat.df,table(LCat,maturity))
ptblLen <- prop.table(tblLen,margin=1)
ptblLen[1:6,] # only 1st 6 rows to save space

lens.prop <- as.numeric(rownames(ptblLen))
plot(ptblLen[,"1"]~lens.prop,pch=16,xlab="Length (cm) - binned",ylab="Proportion Mature", ylim=c(0,1), las=1)



# Very basic glm maturity analysis (from M. Head)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NOTES: All of this needs to be checked!
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#maturityglm <- glm (maturity ~ 1 + length, data = mat.df,  #why 1 + length??
#                    family = binomial(link ="logit"))
maturityglm <- glm (maturity ~ length, data = mat.df,  
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

# Note, added a negative sign
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

# is there a way to add the data to the plot?

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
plot(mat.df$length, mat.df$maturity, xlab="Length (cm)", ylab="Probability of maturity", pch="l", xlim=c(0,80))
curve(predict(mat.glm, data.frame(length=x), type="response"), add=TRUE) 
points(ptblLen[,"1"]~lens.prop, pch=19, col="gray") #proportion mature by length bin from above (2 cm bins)
# The "hump" around 20-30cm could be a greater number of small fish in the north
# where it seems that the fish in the north potentially mature at a smaller size (see below)




#~~~~~~~~~~~~~~~~~~~~~~~~~~
# Exploratory analyses----
#~~~~~~~~~~~~~~~~~~~~~~~~~~

# 1. Question: Is there difference between functional vs biological?
# Answer: yes
# Plotted functional vs biological maturity using only "Certainty" == 1 reads

# select data
mat.bio.df<- data.frame(length = data$Length, 
                    maturity = data$Biological_maturity) 

mat.func.df<- data.frame(length = data$Length, 
                        maturity = data$Functional_maturity)

# complete cases
mat.bio.df<-mat.bio.df[complete.cases(mat.bio.df$maturity),]
mat.func.df<-mat.func.df[complete.cases(mat.func.df$maturity),]

# estimate parameters, logistic regression 
mat.bio.glm <- glm (maturity ~ length, data = mat.bio.df,  #not using 1 + length
                    family = binomial(link ="logit"))
mat.func.glm <- glm (maturity ~ length, data = mat.func.df,  #not using 1 + length
                    family = binomial(link ="logit"))

# Plot
par(mar = c(4, 4, 1, 1)) # Reduce some of the margins so that the plot fits better
plot(maturity ~ length, data=mat.bio.df, col="blue", pch="l", xlim=c(0,80))
points(maturity ~ length, data=mat.func.df, col="red", pch="l")
curve(predict(mat.bio.glm, data.frame(length=x), type="response"), add=TRUE, col="blue", lwd=2) 
curve(predict(mat.func.glm, data.frame(length=x), type="response"), add=TRUE, col="red", lwd=2) 
abline(h=0, col="lightgrey", lty=2)
abline(h=1, col="lightgrey", lty=2)
legend(0,0.9, bty="n",cex=0.8, legend = c("biological maturity","functional maturity"), col=c("blue","red"), lty=1, lwd=2)

# coefficients
a.bio   <- coef(mat.bio.glm)[1]
b.bio   <- coef(mat.bio.glm)[2]
l50.bio <- -a.bio/b.bio

a.func   <- coef(mat.func.glm)[1]
b.func   <- coef(mat.func.glm)[2]
l50.func <- -a.func/b.func

# Same plot but with ggplot
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
  geom_segment(aes(x = l50.bio, y = 0.5, xend = l50.bio, yend = 0), lty = 2, col="pink") +
  geom_segment(aes(x = l50.bio, y = 0.5, xend = min(lens), yend = 0.5), lty = 2, col="pink") +
  
  geom_line() + 
  geom_segment(aes(x = l50.func, y = 0.5, xend = l50.func, yend = 0), lty = 2, col="lightblue") +
  geom_segment(aes(x = l50.func, y = 0.5, xend = min(lens), yend = 0.5), lty = 2, col="lightblue") +
  
  
  labs(x = 'Length (cm)', y = 'P(mature)',
       title = 'Shortspine thornyhead female maturity-at-length',
       subtitle = 'Source: M. Head, NWFSC') +
  theme_bw() 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# 2. Question:How does WCGBTS maturity information compare to Pearson and Gunderson 2003,
# parameters from Pearson and Gunderson 2003 used in 2013 assessment
# Answer: Really different! Possible reason: Pearson and Gunderson seem to have an
    # earlier stage at which they classified a female as mature (their stage 3,
    # which seems to be the stage right before vitellogenesis)
    # M. Head defined biologically mature when oocytes initiated vitellogenesis

# 2013 assessment
a.2013 <- 41.913	
b.2013 <- -2.3046
l50.2013 <- 18.19

matatlength.2013 <- data.frame(length = lens) %>% 
  mutate(pmat = 1 / (1 + exp(a.2013 + b.2013 * length)))

matatlength.2023.bio <- data.frame(length = lens) %>% 
  mutate(pmat = 1 / (1 + exp(-(a.bio + b.bio * length)))) #need the negative sign!

matatlength.2023.func <- data.frame(length = lens) %>% 
  mutate(pmat = 1 / (1 + exp(-(a.func + b.func * length)))) #need the negative sign!


# Plot (in base R because I am just learning ggplot!)
# Use for data workshop presentation?----

#png("C:/Users/sgbey/OneDrive/Documents/2023 Applied Stock Assessments/Shortspine Thornyhead/SST_maturity_comparison.png", width=6, height=4, units="in", res=300)

par(mar = c(4.5, 4.5, 1, 1)) # Reduce some of the margins so that the plot fits better
plot(maturity~length, data=mat.bio.df, 
     xlab="Length (cm)", ylab="Probability mature", 
     pch="l", xlim=c(6,75), col="pink", las=1, cex.lab=1.2)
points(maturity~length, data=mat.func.df,pch="l",col="lightblue")
abline(h=0, lty=3, col="grey")
abline(h=1, lty=3, col="grey")
lines(pmat~length, data=matatlength.2023.bio, col="pink", lwd=2.5, lty=2) 
lines(pmat~length, data=matatlength.2023.func, col="lightblue", lwd=2.5, lty=2) 
lines(pmat~length, data=matatlength.2013,     col="black",     lwd=2.5)
legend(40,0.4, bty="n", cex=0.8, legend=c("Pearson and Gunderson 2003","WCGBTS (biological maturity)","WCGBTS (functional maturity)"), col=c("black","pink","lightblue"), lty=c(1,2,2), lwd=2)

#dev.off()
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Question 3: Difference in maturity by depth? 
# Split depth at 800 m
# Used "functional" maturity
# Answer: not much difference (note, not many small fish in deep)

# select data, use function maturity
func.shallow.df<- data.frame(length = data[data$Depth< 800,]$Length, 
                          maturity = data[data$Depth< 800,]$Functional_maturity) 

func.deep.df<- data.frame(length = data[data$Depth>= 800,]$Length, 
                         maturity = data[data$Depth>= 800,]$Functional_maturity)

# complete cases
func.shallow.df<-func.shallow.df[complete.cases(func.shallow.df$maturity),]
func.deep.df   <-func.deep.df[complete.cases(func.deep.df$maturity),]
nrow(func.shallow.df)
nrow(func.deep.df)
par(mfrow=c(1,2))
hist(func.shallow.df$length, seq(10,80,10), xlab="Shallow", main="", ylim=c(0,150))
hist(func.deep.df$length, seq(10,80,10), xlab="Deep", main="", ylim=c(0,150))
# CAUTION: not many small females in the deep to "anchor" the curve

# estimate parameters, logistic regression 
func.shallow.glm <- glm (maturity ~ length, data = func.shallow.df,  #not using 1 + length
                    family = binomial(link ="logit"))
func.deep.glm <- glm (maturity ~ length, data = func.deep.df,  #not using 1 + length
                     family = binomial(link ="logit"))

# Plot
par(mar = c(4, 4, 1, 1),
    mfrow=c(1,1)) # Reduce some of the margins so that the plot fits better
plot(maturity ~ length, data=func.shallow.df, col="green", pch="l", xlim=c(0,75))
points(maturity ~ length, data=func.deep.df, col="dark blue", pch="l")
curve(predict(func.shallow.glm, data.frame(length=x), type="response"), add=TRUE, col="green", lwd=2) 
curve(predict(func.deep.glm, data.frame(length=x), type="response"), add=TRUE, col="dark blue", lwd=2) 
abline(h=0, col="lightgrey", lty=2)
abline(h=1, col="lightgrey", lty=2)
legend(0,0.9, bty="n",cex=0.8, legend = c("Shallow<800 m","Deep>800 m"), col=c("green","dark blue"), lty=1, lwd=2)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Question 4: Difference in maturity by latitude/state? 
# Split at OR/CA border (OR and WA north, CA south, N42)
# Used "functional" maturity
# Answer: Hmmm...the curves are different, but not sure there was enough information
  # to fit a separate curve for OR/WA (not many small immature females)

# select data, use functional maturity
func.north.df<- data.frame(length = data[data$Latitude>= 42.0,]$Length, 
                             maturity = data[data$Latitude>= 42.0,]$Functional_maturity) 

func.south.df<- data.frame(length = data[data$Latitude< 42.0,]$Length, 
                          maturity = data[data$Latitude< 42.0,]$Functional_maturity)

# complete cases
func.north.df   <-func.north.df[complete.cases(func.north.df$maturity),]
func.south.df   <-func.south.df[complete.cases(func.south.df$maturity),]
nrow(func.north.df)
nrow(func.south.df)
par(mfrow=c(1,2))
hist(func.north.df$length, seq(10,80,10), xlab="north (WA/OR)", main="", ylim=c(0,100))
hist(func.south.df$length, seq(10,80,10), xlab="south (CA)", main="", ylim=c(0,100))
#somewhat smaller fish in north

# estimate parameters, logistic regression 
func.north.glm <- glm (maturity ~ length, data = func.north.df,  #not using 1 + length
                         family = binomial(link ="logit"))
func.south.glm <- glm (maturity ~ length, data = func.south.df,  #not using 1 + length
                      family = binomial(link ="logit"))

# Plot
par(mar = c(4, 4, 1, 1),
    mfrow=c(1,1)) # Reduce some of the margins so that the plot fits better
plot(maturity ~ length, data=func.north.df, col="purple", pch="l", xlim=c(0,75))
points(maturity ~ length, data=func.south.df, col="orange", pch="l")
curve(predict(func.north.glm, data.frame(length=x), type="response"), add=TRUE, col="purple", lwd=2) 
curve(predict(func.south.glm, data.frame(length=x), type="response"), add=TRUE, col="orange", lwd=2) 
abline(h=0, col="lightgrey", lty=2)
abline(h=1, col="lightgrey", lty=2)
legend(0,0.9, bty="n",  cex=0.8, legend = c("north (WA/OR)","south (CA)"), col=c("purple","orange"), lty=1, lwd=2)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
