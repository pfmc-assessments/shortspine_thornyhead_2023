if(FALSE){
  # comparing thornyhead assessments for the SSC presentation
  setwd('C:/ss/thornyheads/runs/')
  sbase <- SS_output('SST_base_FINAL')
  lbase <- SS_output('LST_STAR_Base_Model')
}
lst.catch <- lbase$timeseries$"retain(B):_1"
lst.catch.tot <- lbase$timeseries$"dead(B):_1"
sst.catch <- as.numeric(apply(sbase$timeseries[,grep("retain(B)",
                                                     names(sbase$timeseries),
                                                     fixed=TRUE)],
                              1, sum))
lst.catch.yr <- lbase$timeseries$Yr
sst.catch.yr <- sbase$timeseries$Yr

lst.catch <- c(rep(0,length(sst.catch.yr)-length(lst.catch.yr)),lst.catch)

if(FALSE){
  plot(sst.catch.yr, sst.catch/(sst.catch+lst.catch),
       ylim=c(0,1),xlim=c(1950,2013),xaxs='i',yaxs='i',type='l',lwd=3,las=1,
       xlab='Year',ylab='Ratio of shortspine catch to total thornyhead catch')
  grid()
  box()
}

#plot(0,xlim=c(-4,117),ylim=c(0,6000),type='n',xlab="Year",ylab="Landings (mt)",axes=FALSE,yaxs='i')
png('c:/SS/thornyheads/figs/compare_catch.png',width=8,height=5,res=300,units='in')
SSplotCatch(sbase,subplot=2,ymax=6000,addmax=FALSE,fleetnames=
            c("Shortspine Trawl North",
              "Shortspine Trawl South",
              "Shortspine Non-trawl North",
              "Shortspine Non-trawl South"))
#points(0:113-.5,lst.catch[sst.catch.yr<2013],lend=3,col=rgb(0,0,0,.5),type='h',lwd=4)
axis(2,at=seq(0,6000,1000))      
lines(c(-10,113),rep(6000,2),lty=3,col=rgb(0,0,0,.3),lwd=1)
dev.off()


#plot(0,xlim=c(-4,117),ylim=c(0,6000),type='n',xlab="Year",ylab="Landings (mt)",axes=FALSE,yaxs='i')
png('c:/SS/thornyheads/figs/compare_catch2.png',width=8,height=5,res=300,units='in')
SSplotCatch(sbase,subplot=2,ymax=6000,addmax=FALSE,fleetnames=
            c("Shortspine Trawl North",
              "Shortspine Trawl South",
              "Shortspine Non-trawl North",
              "Shortspine Non-trawl South"))
#points(0:113-.5,lst.catch[sst.catch.yr<2013],lend=3,col=rgb(0,0,0,.5),type='h',lwd=4)
ord <- sort(rep(1:114,2))
#lines(c(ord-2,113,113),c(0,lst.catch[sst.catch.yr<2013],0)[c(ord[-1],115,115,116)],col=2)
polygon(c(ord-2,113,113),c(0,lst.catch[sst.catch.yr<2013],0)[c(ord[-1],115,115,116)],
        lwd=2,col=rgb(0,0,0,.2),border=1)
polygon(c(ord-2,113,113),c(0,lst.catch[sst.catch.yr<2013],0)[c(ord[-1],115,115,116)],
        lwd=1,col=rgb(0,0,0,.4),border=1,density=25)
#polygon(c(1,1:114,114),c(0,lst.catch[sst.catch.yr<2013],0),lwd=1,col=rgb(0,0,0,.5),border=NA)
axis(2,at=seq(0,6000,1000))      
lines(c(-10,113),rep(6000,2),lty=3,col=rgb(0,0,0,.3),lwd=1)
legend(-4.5,4500,"Longspine coastwide total",fill=rgb(0,0,0,.4),
       density=25,bty='n')
dev.off()y
