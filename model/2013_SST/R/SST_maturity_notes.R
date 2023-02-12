# maturity for shortspine thornyheads

sst_fish <- read.csv('C:/ss/Thornyheads/maturity/FisheryIndices2013_SST_Final_V2_SexedLgthWtAge.csv',
                     skip=8,stringsAsFactors=FALSE)
sst_WL <- sst_fish[!is.na(sst_fish$WEIGHT_KG) &
                   !is.na(sst_fish$LENGTH_CM) &
                   sst_fish$WEIGHT_KG>0,]

# weight-length
sst_lm <- lm(log(sst_WL$WEIGHT_KG) ~ log(sst_WL$LENGTH_CM))
a <- exp(sst_lm$coefficients[1])
b <- sst_lm$coefficients[2]
#plot(sst_WL


sst_maturity <- sst_fish[sst_fish$MATURE_YN!="",]
table(2*round(.5*sst_maturity$LENGTH_CM), sst_maturity$MATURE_YN)
##     M  N  Y
## 16  0  5  0
## 18  0  6  0
## 20  0 21  3
## 22  0  6  6
## 24  1 13 17
## 26  0 12  3
## 28  1 10 10
## 30  1  6  4
## 32  1 18  5
## 34  0  3  1
## 36  0 16  5
## 38  0  1  2
## 40  0  9  5
## 42  0  2  1
## 44  0  8  8
## 46  0  2  1
## 48  1  6  8
## 50  0  3  5
## 52  1  3 11
## 54  0  1  3
## 56  1  1 14
## 58  0  1  2
## 60  0  0  6
## 62  1  1  2
## 64  0  0  5
## 68  0  0  1
sst_maturity2 <- sst_maturity[sst_maturity$MATURE_YN %in% c("Y","N"),]
sst_maturity2$mature <- ifelse(sst_maturity2$MATURE_YN=="Y",1,0)

# plot of distribution
if(doPNG) png("c:/SS/Thornyheads/maturity/maturity/SST_maturity_fig_Depth-vs-Lat.png",
              width=7,height=7,res=300,units='in')
plot(0, type='n', xlim=c(1300,0), ylim=c(32,51), xaxs='i',yaxs='i',
     cex=.1*sst_maturity2$LENGTH_CM, pch=16,
     col=ifelse(sst_maturity2$mature,rgb(0,0,1,.5),rgb(1,0,0,.5)),
     xlab="Depth (m)",ylab="Latitude",axes=FALSE)
points(sst_fish$DEPTH_M,sst_fish$HAUL_LATITUDE_DD,
     cex=.1*sst_fish$LENGTH_CM,pch=1,
     col=rgb(0,0,0,.03))
points(sst_maturity2$DEPTH_M,sst_maturity2$HAUL_LATITUDE_DD,
       cex=.1*sst_maturity2$LENGTH_CM, pch=16,
       col=ifelse(sst_maturity2$mature,rgb(0,0,1,.5),rgb(1,0,0,.5)))
legend(1250,50.8,legend=c(" immature  "," mature   ","20cm"," 40cm","  60cm"),pt.cex=c(4,4,.1*c(20,40,60)),
       ncol=5,pch=c(16,16,1,1,1),col=c(rgb(1,0,0,.5),rgb(0,0,1,.5),rep(rgb(0,0,0,.2),3)),bty='n')
abline(h=49.1,col=1)
axis(1)
latvec <- seq(32,50,2)
axis(2,at=latvec,label=paste(latvec,"°",sep=''),las=1)
box()
if(doPNG) dev.off()

sst_maturity2$lbin <- 2*floor(0.5*sst_maturity2$LENGTH_CM)

# calculating proportions
bins <- seq(min(sst_maturity2$lbin),max(sst_maturity2$lbin),2)
nbins <- length(bins)
n <- prop <- rep(NA,nbins)
for(i in 1:length(bins)){
  tmp <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]]
  prop[i] <- mean(tmp)
  n[i] <- length(tmp)
}

# calculating year-specific proportions
n2011 <- prop2011 <- rep(NA,nbins)
n2012 <- prop2012 <- rep(NA,nbins)
for(i in 1:length(bins)){
  tmp2011 <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                  & sst_maturity2$PROJECT_CYCLE=="Cycle 2011"]
  tmp2012 <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                  & sst_maturity2$PROJECT_CYCLE=="Cycle 2012"]
  prop2011[i] <- mean(tmp2011)
  prop2012[i] <- mean(tmp2012)
  n2011[i] <- length(tmp2011)
  n2012[i] <- length(tmp2012)
}

# calculating deep vs. shallow proportions
n.deep <- prop.deep <- rep(NA,nbins)
n.shallow <- prop.shallow <- rep(NA,nbins)
for(i in 1:length(bins)){
  tmp.deep <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                   & sst_maturity2$DEPTH_M > 500]
  tmp.shallow <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                      & sst_maturity2$DEPTH_M <= 500]
  prop.deep[i] <- mean(tmp.deep)
  prop.shallow[i] <- mean(tmp.shallow)
  n.deep[i] <- length(tmp.deep)
  n.shallow[i] <- length(tmp.shallow)
}


# calculating depth bin proportions
n.600plus <- prop.600plus <- rep(NA,nbins)
n.400minus <- prop.400minus <- rep(NA,nbins)
n.400to600 <- prop.400to600 <- rep(NA,nbins)
for(i in 1:length(bins)){
  tmp.600plus <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                      & sst_maturity2$DEPTH_M > 600]
  tmp.400minus <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                       & sst_maturity2$DEPTH_M <= 400]
  tmp.400to600 <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                       & sst_maturity2$DEPTH_M > 400
                                       & sst_maturity2$DEPTH_M <= 600]
  prop.600plus[i] <- mean(tmp.600plus)
  prop.400minus[i] <- mean(tmp.400minus)
  prop.400to600[i] <- mean(tmp.400to600)
  n.600plus[i] <- length(tmp.600plus)
  n.400minus[i] <- length(tmp.400minus)
  n.400to600[i] <- length(tmp.400to600)
}

# calculating latitude proportions
n.north <- prop.north <- rep(NA,nbins)
n.south <- prop.south <- rep(NA,nbins)
for(i in 1:length(bins)){
  tmp.north <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                    & sst_maturity2$HAUL_LATITUDE > 39]
  tmp.south <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                    & sst_maturity2$HAUL_LATITUDE <= 39]
  prop.north[i] <- mean(tmp.north)
  prop.south[i] <- mean(tmp.south)
  n.north[i] <- length(tmp.north)
  n.south[i] <- length(tmp.south)
}

# calculating latitude x depth proportions
n.north.deep <- prop.north.deep <- rep(NA,nbins)
n.south.deep <- prop.south.deep <- rep(NA,nbins)
n.north.shallow <- prop.north.shallow <- rep(NA,nbins)
n.south.shallow <- prop.south.shallow <- rep(NA,nbins)
for(i in 1:length(bins)){
  tmp.north.deep <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                         & sst_maturity2$DEPTH_M > 600
                                         & sst_maturity2$HAUL_LATITUDE > 39]
  tmp.south.deep <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                         & sst_maturity2$DEPTH_M > 600
                                         & sst_maturity2$HAUL_LATITUDE <= 39]
  tmp.north.shallow <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                            & sst_maturity2$DEPTH_M <= 600
                                            & sst_maturity2$HAUL_LATITUDE > 39]
  tmp.south.shallow <- sst_maturity2$mature[sst_maturity2$lbin==bins[i]
                                            & sst_maturity2$DEPTH_M <= 600
                                            & sst_maturity2$HAUL_LATITUDE <= 39]
  prop.north.deep[i] <- mean(tmp.north.deep)
  prop.south.deep[i] <- mean(tmp.south.deep)
  prop.north.shallow[i] <- mean(tmp.north.shallow)
  prop.south.shallow[i] <- mean(tmp.south.shallow)
  n.north.deep[i] <- length(tmp.north.deep)
  n.south.deep[i] <- length(tmp.south.deep)
  n.north.shallow[i] <- length(tmp.north.shallow)
  n.south.shallow[i] <- length(tmp.south.shallow)
}


if(doPNG) png("c:/SS/Thornyheads/maturity/maturity/SST_maturity_fig_depth_bins.png",
              width=7,height=7,res=300,units='in')
### option two with circles proportional to sample size
# make empty plot
plot(0, type='n', xlim=c(10,70),ylim=c(0,1),las=1,
     xlab="Length (in 2cm bins)",ylab="Proportion mature")
abline(h=c(0,1),col=1,lty=3)
# add text with sample sizes
scale <- 1.5
points(x=bins,y=prop.600plus,cex=scale*sqrt(n.600plus),pch=16,col=rgb(0,0,1,.2))
points(x=bins,y=prop.400minus,cex=scale*sqrt(n.400minus),pch=16,col=rgb(1,0,0,.2))
points(x=bins,y=prop.400to600,cex=scale*sqrt(n.400to600),pch=16,col=rgb(0,1,0,.2))
legend(53,.18,legend=c("Shallow (< 400 m)","Middle (400-600 m)","Deep (>600 m)"),bty='n',
       col=c(rgb(1,0,0,.2),rgb(0,1,0,.2),rgb(0,0,1,.2)),pch=16,pt.cex=2)
text(x=bins,y=prop.600plus,labels=n.600plus,cex=.7,col=4)
text(x=bins,y=prop.400minus,labels=n.400minus,cex=.7,col=2)
text(x=bins,y=prop.400to600,labels=n.400to600,cex=.7,col=3)
box() # replace black border around plot that got covered up by grey circles
if(doPNG) dev.off()

if(doPNG) png("c:/SS/Thornyheads/maturity/maturity/SST_maturity_fig_North-South.png",
              width=7,height=7,res=300,units='in')
### option two with circles proportional to sample size
# make empty plot
plot(0, type='n', xlim=c(10,70),ylim=c(0,1),las=1,
     xlab="Length (in 2cm bins)",ylab="Proportion mature")
abline(h=c(0,1),col=1,lty=3)
# add text with sample sizes
scale <- 1.5
points(x=bins,y=prop.north,cex=scale*sqrt(n.north),pch=16,col=rgb(0,0,1,.2))
points(x=bins,y=prop.south,cex=scale*sqrt(n.south),pch=16,col=rgb(1,0,0,.2))
legend(53,.18,legend=c("North of 39°","South of 39°"),bty='n',
       col=c(rgb(0,0,1,.2),rgb(1,0,0,.2)),pch=16,pt.cex=2)
text(x=bins,y=prop.north,labels=n.north,cex=.7,col=4)
text(x=bins,y=prop.south,labels=n.south,cex=.7,col=2)
box() # replace black border around plot that got covered up by grey circles
if(doPNG) dev.off()

if(doPNG) png("c:/SS/Thornyheads/maturity/maturity/SST_maturity_fig_Depth_X_N-S.png",
              width=7,height=7,res=300,units='in')
### option two with circles proportional to sample size
# make empty plot
plot(0, type='n', xlim=c(10,70),ylim=c(0,1),las=1,
     xlab="Length (in 2cm bins)",ylab="Proportion mature")
abline(h=c(0,1),col=1,lty=3)
# add text with sample sizes
scale <- 1.5
colvec <- 
points(x=bins,y=prop.north.deep,cex=scale*sqrt(n.north.deep),pch=16,col=rgb(0,0,1,.2))
points(x=bins,y=prop.south.deep,cex=scale*sqrt(n.south.deep),pch=16,col=rgb(1,0,0,.2))
points(x=bins,y=prop.north.shallow,cex=scale*sqrt(n.north.shallow),pch=18,col=rgb(0,0,1,.2))
points(x=bins,y=prop.south.shallow,cex=scale*sqrt(n.south.shallow),pch=18,col=rgb(1,0,0,.2))
legend(50,.3,legend=
       c("North of 39°, > 600m",
         "South of 39°, > 600m",
         "North of 39°, < 600m",
         "South of 39°, < 600m"),bty='n',
       col=c(rgb(0,0,1,.2),rgb(1,0,0,.2),rgb(0,0,1,.2),rgb(1,0,0,.2)),
       pch=c(16,16,18,18),pt.cex=2)
text(x=bins,y=prop.north.deep,labels=n.north.deep,cex=.7,col=4)
text(x=bins,y=prop.north.shallow,labels=n.north.shallow,cex=.7,col=4)
text(x=bins,y=prop.south.deep,labels=n.south.deep,cex=.7,col=2)
text(x=bins,y=prop.south.shallow,labels=n.south.shallow,cex=.7,col=2)
box() # replace black border around plot that got covered up by grey circles
if(doPNG) dev.off()



if(FALSE){

  sst_glm <- glm(mature ~ LENGTH_CM, data=sst_maturity2, family='binomial')
  sst_glm.shallow <- glm(mature ~ LENGTH_CM, data=sst_maturity2[sst_maturity2$DEPTH_M<500,], family='binomial')
  sst_glm.deep    <- glm(mature ~ LENGTH_CM, data=sst_maturity2[sst_maturity2$DEPTH_M>=500,], family='binomial')
  sst_glm.400minus <- glm(mature ~ LENGTH_CM, data=sst_maturity2[sst_maturity2$DEPTH_M<400,], family='binomial')
  sst_glm.600plus    <- glm(mature ~ LENGTH_CM, data=sst_maturity2[sst_maturity2$DEPTH_M>=600,], family='binomial')
  x <- data.frame(LENGTH_CM=seq(0,90,1))
  prediction <- predict(sst_glm,newdata=x,type='response')
  prediction.shallow <- predict(sst_glm.shallow,newdata=x,type='response')
  prediction.deep <- predict(sst_glm.deep,newdata=x,type='response')
  prediction.400minus <- predict(sst_glm.400minus,newdata=x,type='response')
  prediction.600plus <- predict(sst_glm.600plus,newdata=x,type='response')
  #lines(x$LENGTH_CM,as.numeric(prediction),col=2,lwd=5)
  #lines(x$LENGTH_CM,as.numeric(prediction.shallow),col=2,lwd=5)
  #lines(x$LENGTH_CM,as.numeric(prediction.deep),col=4,lwd=5)
  lines(x$LENGTH_CM,as.numeric(prediction.400minus),col=2,lwd=5)
  lines(x$LENGTH_CM,as.numeric(prediction.600plus),col=4,lwd=5)

  # from 2005 assessment, based on Pearson and Gunderson
  lines(x=0:80,y=1/(1+exp(-2.3*(0:80 - 18.2))),col=4,lwd=5)

  #dev.off()
  # this line from Thorson's model with extra parameter for the asymptote
  # calculated in c:/SS/Thornyheads/maturity/Maturity_at_age_2013-04-25_IGT.R
  lines(y=Output$MatHat, x=Output$Ages,col=3,lwd=5)

}

#if(doPNG) dev.off()
