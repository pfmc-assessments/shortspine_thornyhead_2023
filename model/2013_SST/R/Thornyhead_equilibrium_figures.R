#dont source this entire file!

### note: this code is thanks to Allan Hicks

#setwd("C:/NOAA2013/SST")

#library(r4ss)
#update_r4ss_files()

#base <- tmp <- SS_output(dir="base\\",covar=T,verbose=F)

if(FALSE){
  lbase <- SS_output('LST_Base_Lmax_Est')
  base <- lbase

  # shortspine
  sbasedir <- 'SST_base_FINAL'
  sbase <- SS_output(sbasedir)
  base <- sbase
}

figDir <- "../figs"

targetSPR <- 0.5
btarg <- 0.4; minbthresh<-0.25

doPNG <- TRUE

#Equilibrium yield
ht <- 3.8; wd<- 6.5
if(doPNG) {png(filename = paste(figDir,"SST_equilibriumPlot.png",sep="\\"), width = wd, height = ht,units="in",res=300, pointsize = 11)}
if(!doPNG) {windows(height=ht,width=wd)}
par(mfrow=c(1,1),mar=c(4,4,1,1)+0.1,las=1)
textcex <- 0.6
findCatch.fn <- function(x,Catches,Depletion) {
    out <- Catches[abs(x-Depletion)==min(abs(x-Depletion),na.rm=T)]
    return(out[!is.na(out)])
}
tmp <- base$equil_yield[order(base$equil_yield$Depletion,base$equil_yield$Catch),]
tmp <- rbind(c(0,0),tmp)
ind <- tmp$Depletion>=0 & tmp$Depletion<=1
#base$equil_yield[ind,]
plot(tmp$Depletion[ind],tmp$Catch[ind],xlab="Relative depletion",ylab="",type="l",lwd=2,col="black",xaxs="i",yaxs="i",ylim=c(0,max(tmp$Catch[ind],na.rm=T)*1.05),xaxp=c(0,1,10),cex.axis=0.9,cex.lab=0.9)
mtext("Equilibrium yield (mt)",side=2,line=3.2,las=0)
Bmsy <- base$derived_quants[substring(base$derived_quants$LABEL,1,7)=="SSB_MSY","Value"]
B0 <- base$derived_quants[substring(base$derived_quants$LABEL,1)=="SSB_Unfished","Value"]
currdepl <- base$derived_quants[match("Bratio_2013",base$derived_quants$LABEL),"Value"]
uppLim <- findCatch.fn(currdepl,tmp$Catch[ind],tmp$Depletion[ind])
segments(rep(currdepl,2),c(0,uppLim/2+uppLim/3.5),rep(currdepl,2),c(uppLim/2-uppLim/3.0,uppLim/1.05),col=1,lwd=2)
#shift <- -0.01
shift <- 0
text(currdepl + shift,uppLim/2.1,"Current depletion",srt=90,cex=textcex)
depl <- 0.40
uppLim <- findCatch.fn(depl,tmp$Catch[ind],tmp$Depletion[ind])[1]
segments(rep(depl,2),c(0,uppLim/3+uppLim/6),rep(depl,2),c(uppLim/3-uppLim/6,uppLim),lwd=1,col="darkgreen")
text(depl,uppLim/3,"Proxy Target Level",srt=90,col="darkgreen",cex=textcex)
depl <- 0.25
uppLim <- findCatch.fn(depl,tmp$Catch[ind],tmp$Depletion[ind])[1]
segments(rep(depl,2),c(0,uppLim/3+uppLim/5),rep(depl,2),c(uppLim/3-uppLim/5,uppLim),lwd=1,col="red")
text(depl,uppLim/3,"Proxy Overfished Level",srt=90,col="red",cex=textcex)
#depl <- Bmsy/B0
#uppLim <- findCatch.fn(depl,tmp$Catch[ind],tmp$Depletion[ind])[1]
#segments(rep(depl,2),c(0,uppLim/1.4+uppLim/7),rep(depl,2),c(uppLim/1.4-uppLim/7,uppLim),lwd=1,col="darkgreen",lty=2)
#text(depl,uppLim/1.4,"Bmsy Target Level",srt=90,col="darkgreen",cex=textcex)
#depl <- 0.5*Bmsy/B0
#uppLim <- findCatch.fn(depl,tmp$Catch[ind],tmp$Depletion[ind])[1]
#segments(rep(depl,2),c(0,uppLim/1.4+uppLim/9),rep(depl,2),c(uppLim/1.4-uppLim/9,uppLim),lwd=1,col="red",lty=2)
#text(depl,uppLim/1.4,"50% of Bmsy",srt=90,col="red",cex=textcex)
if(doPNG) {dev.off()}
