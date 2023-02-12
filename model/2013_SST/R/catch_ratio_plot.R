png('c:/SS/Thornyheads/figs/catch_ratios.png',height=5,width=7,res=300,units='in')
par(mar=c(4,4,1,1)+.1)
catch.ratio.dat <- read.csv('C:/SS/Thornyheads/catch/catch_ratios_for_R_figure.csv')
plot(catch.ratio.dat$Year, catch.ratio.dat$Ratio, xlim=c(1981,2012),
     xaxs='i',yaxs='i',ylim=c(0,1),type='l',pch=16,las=1,lwd=3,
     xlab="Year",ylab="Ratio")
unspec.ratio <- catch.ratio.dat$Unspecified.sum/(catch.ratio.dat$Unspecified.sum+catch.ratio.dat$Specified.sum)
lines(catch.ratio.dat$Year, unspec.ratio, col=2,pch=16,type='l',lwd=3,lty=3)
legend('topright',col=c(1,NA,2),lwd=3,lty=c(1,NA,3),
       legend=c("shortspine /\n(shortspine + longspine)","",
         "unspecified thornyhead /\n(shortspine + longspine + unspecified)"),bty='n')
dev.off()


# caption option:
# Figure X: Ratio of longspine to shortspine in the landings for which the species
# was identified (solid black line), and the ratio of unspecified landings to
# total landings of both thornyhead species (dotted red line).
# The ratio of specified thornyheads was used to apportion the unspecified landings
# into estimates of the landings for each species.
