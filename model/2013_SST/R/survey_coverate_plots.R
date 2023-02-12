#########################################################
### AK survey plot
#########################################################

AKall <- read.csv('c:/Data/AFSCsurvey/Tri.and.Slope.AK.Surveys.Catch.kg.All.FMP.Species 09 Jan 2013.csv')
AKslope <- AKall[AKall$SURVEY=="AFSC.Slope",]
AKshelf <- AKall[AKall$SURVEY=="Tri.Shelf",]

# slope survey latitude wide
png('c:/Data/AFSCsurvey/AFSC_slope_survey_coverage.png',width=8,height=6,res=300,units='in')
plot(AKslope$YEAR-.1+.2*runif(nrow(AKslope)),
     AKslope$START_LATITUDE,
     pch=16,cex=1.2,
     col=rgb(0,0,0,.2),las=1,
     main="Spatial coverage of AFSC Slope Survey",
     xlab="Year",ylab="Latitude (°N)")
dev.off()

# slope survey latitude 5x5 figure
png('c:/Data/AFSCsurvey/AFSC_slope_survey_coverage2.png',width=5,height=5,res=300,units='in')
plot(AKslope$YEAR-.1+.2*runif(nrow(AKslope)),
     AKslope$START_LATITUDE,
     pch=16,cex=1.2,
     col=rgb(0,0,0,.2),las=1,
     main="Spatial coverage of AFSC Slope Survey",
     xlab="Year",ylab="Latitude (°N)")
dev.off()

# slope survey depths 5x5 figure
png('c:/Data/AFSCsurvey/AFSC_slope_survey_depth_coverage.png',width=5,height=5,res=300,units='in')
plot(AKslope$YEAR-.15+.3*runif(nrow(AKslope)),
     AKslope$BOTTOM_DEPTH,ylim=c(1500,0),
     pch=16,cex=1.2,
     col=rgb(0,0,0,.2),las=1,yaxs='i',
     main="Depth coverage of AFSC Triennial Slope Survey",
     xlab="Year",ylab="Depth (m)")
dev.off()


# shelf survey latitude 5x5 figure
png('c:/Data/AFSCsurvey/AFSC_shelf_survey_coverage2.png',width=5,height=5,res=300,units='in')
plot(AKshelf$YEAR-.1+.2*runif(nrow(AKshelf)),
     AKshelf$START_LATITUDE,
     pch=16,cex=1.2,
     col=rgb(0,0,0,.2),las=1,
     main="Spatial coverage of AFSC Triennial Shelf Survey",
     xlab="Year",ylab="Latitude (°N)")
dev.off()

# shelf survey depths 5x5 figure
png('c:/Data/AFSCsurvey/AFSC_shelf_survey_depth_coverage.png',width=5,height=5,res=300,units='in')
plot(AKshelf$YEAR-.15+.3*runif(nrow(AKshelf)),
     AKshelf$BOTTOM_DEPTH,ylim=c(500,0),
     pch=16,cex=1.2,
     col=rgb(0,0,0,.2),las=1,yaxs='i',
     main="Depth coverage of AFSC Triennial Shelf Survey",
     xlab="Year",ylab="Depth (m)")
dev.off()
