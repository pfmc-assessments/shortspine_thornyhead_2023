rc <- function(n,alpha=1){
  # a subset of rich.colors by Arni Magnusson from the gregmisc package
  # a.k.a. rich.colors.short, but put directly in this function
  # to try to diagnose problem with transparency on one computer
  x <- seq(0, 1, length = n)
  r <- 1/(1 + exp(20 - 35 * x))
  g <- pmin(pmax(0, -0.8 + 6 * x - 5 * x^2), 1)
  b <- dnorm(x, 0.25, 0.15)/max(dnorm(x, 0.25, 0.15))
  rgb.m <- matrix(c(r, g, b), ncol = 3)
  rich.vector <- apply(rgb.m, 1, function(v) rgb(v[1], v[2], v[3], alpha=alpha))
}

if(FALSE){
  #library(mapdata)
  sst_fish <- read.csv('C:/ss/Thornyheads/surveys/FisheryIndices2013_SST_Final_V2_SexedLgthWtAge.csv',
                       skip=8,stringsAsFactors=FALSE)
  sst_maturity <- sst_fish[sst_fish$MATURE_YN!="",]
  sst_tows <- read.csv('C:/ss/Thornyheads/Data/NW_Survey/SSPN_NWFSC.Effort.csv',skip=8)

  # add density per tow (in numbers and biomass) for all sampled fish
  sst_fish$HAUL_WT_KG <- NA
  sst_fish$AVG_WT_KG <- NA
  rowvec <- (1:nrow(sst_fish))
  hauls <- unique(sst_fish$HAUL_IDENTIFIER)
  for(ihaul in 1:length(hauls)){
    haul <- hauls[ihaul]
    if(ihaul%%50==0) cat('haul',ihaul,'/',length(hauls),'\n')
    haulrow <- sst_tows[sst_tows$HAUL_IDENTIFIER==haul,]
    fishrows <- rowvec[sst_fish$HAUL_IDENTIFIER==haul]
    sst_fish$HAUL_WT_KG[fishrows] <- haulrow$HAUL_WT_KG
    sst_fish$AVG_WT_KG[fishrows] <- haulrow$AVG_WT_KG
  }
  sst_fish$num <- sst_fish$HAUL_WT_KG/sst_fish$AVG_WT_KG

  sst_fish <- sst_fish[sst_fish$AVG_WT_KG>0 &        #  1 row with 0 for average weight
                       !is.na(sst_fish$AVG_WT_KG) &  # 10 rows with NA for average weight
                       !is.na(sst_fish$HAUL_WT_KG),] #  5 rows with NA for haul weight
  
  
  ## map('worldHires',xlim=c(-126,-115), ylim=c(32,49),fill=TRUE,col='grey')
  ## for(i in 0:7){
  ##   subset <- (floor(sst_fish$LENGTH_CM/10) == i )
  ##   points(sst_fish$HAUL_LONGITUDE_DD[subset],
  ##          sst_fish$HAUL_LATITUDE_DD[subset],col=colvec[i-1],pch=16)
  ##   points(sst_fish$HAUL_LONGITUDE_DD[subset],
  ##          sst_fish$HAUL_LATITUDE_DD[subset],col=colvec[i-1],pch=16)

  ## }

  sst_fish$len.group <- 1 + floor(sst_fish$LENGTH_CM/10)
  table(sst_fish$len.group)
  ##  1    2    3    4    5    6    7    8 
  ## 96 1342 4566 3620 2483 1324  300    9 
  sst_fish$len.group[sst_fish$LENGTH_CM<10] <- 2 # group 96 fish in 0-10 to 20-
  sst_fish$len.group[sst_fish$LENGTH_CM>=60] <- 7 # group 9 fish in 70+ into 60+
  n <- 8
  len.group.names <- paste(10*(1:n - 1),"-",10*(1:n),"cm",sep="")
  len.group.names[2] <- "< 20 cm"
  len.group.names[7] <- "60+ cm"
  # adjust to start at 1
  sst_fish$len.group <- sst_fish$len.group-1
  len.group.names <- len.group.names[2:7]
  n <- length(len.group.names)
  # by depth instead of longitude
  colvec <- rc(n,alpha=0.1)
  
  # mean depth/lat 
  x <- y <- rep(NA,n)
  x.bio <- y.bio <- rep(NA,n)
  x.num <- y.num <- rep(NA,n)
  for(i in 1:n){
    subset <- sst_fish$len.group==i
    # treating all fish equally
    x[i] <- mean(sst_fish$DEPTH_M[subset])
    y[i] <- mean(sst_fish$HAUL_LATITUDE_DD[subset])
    # weighting fish by biomass in tow
    x.bio[i] <- sum(sst_fish$HAUL_WT_KG[subset]*sst_fish$DEPTH_M[subset],na.rm=TRUE)/sum(sst_fish$HAUL_WT_KG[subset],na.rm=TRUE)
    y.bio[i] <- sum(sst_fish$HAUL_WT_KG[subset]*sst_fish$HAUL_LATITUDE_DD[subset],na.rm=TRUE)/sum(sst_fish$HAUL_WT_KG[subset],na.rm=TRUE)
    # weighting fish by number in tow
    x.num[i] <- sum(sst_fish$num[subset]*sst_fish$DEPTH_M[subset],na.rm=TRUE)/sum(sst_fish$num[subset],na.rm=TRUE)
    y.num[i] <- sum(sst_fish$num[subset]*sst_fish$HAUL_LATITUDE_DD[subset],na.rm=TRUE)/sum(sst_fish$num[subset],na.rm=TRUE)
  }

  # fraction north and south of 39 degrees
  Nfrac <- rep(NA,n)
  for(i in 1:n){
    subset  <- sst_fish$len.group==i
    subset2 <- sst_fish$len.group==i & sst_fish$HAUL_LATITUDE_DD > 39
    # weighting fish by biomass in tow
    Nfrac[i] <- sum(sst_fish$HAUL_WT_KG[subset2],na.rm=TRUE)/sum(sst_fish$HAUL_WT_KG[subset],na.rm=TRUE)
  }
  round(Nfrac,3)
  ## [1] 0.913 0.832 0.503 0.434 0.559 0.674

  # fraction north and south of 39 degrees in 2011 and 2012 only
  NfracC <- rep(NA,n)
  for(i in 1:n){
    subset  <- sst_fish$len.group==i
    subset2 <- sst_fish$len.group==i & sst_fish$HAUL_LATITUDE_DD > 39
    subset4 <- sst_fish$PROJECT_CYCLE %in% c("Cycle 2011","Cycle 2012")
    # weighting fish by biomass in tow
    NfracC[i] <- sum(sst_fish$HAUL_WT_KG[subset4 & subset2],na.rm=TRUE)/sum(sst_fish$HAUL_WT_KG[subset4 & subset],na.rm=TRUE)
  }
  round(NfracC,3)
  ## [1] 0.933 0.866 0.529 0.497 0.619 0.833

  NfracB <- rep(NA,n)
  for(i in 1:n){
    subset  <- sst_fish$len.group==i
    subset2 <- sst_fish$len.group==i & sst_fish$HAUL_LATITUDE_DD > 39
    subset3 <- sst_fish$SPAWNING_YN %in% c("Y","N")
    # weighting fish by biomass in tow
    NfracB[i] <- sum(sst_fish$HAUL_WT_KG[subset3 & subset2],na.rm=TRUE)/sum(sst_fish$HAUL_WT_KG[subset3 & subset],na.rm=TRUE)
  }
  round(NfracB,3)
  ## [1] 0.981 0.916 0.785 0.508 0.606 0.864

  small.bin.lo <- seq(4,90,2)
  big.bin.lo <- seq(10,60,10)
  big.bin.hi <- big.bin.lo+10
  big.bin.lo[1] <- 0
  big.bin.hi[6] <- 100

  spawn.frac   <- rep(NA,6)
  spawn.frac.N <- rep(NA,6)
  spawn.frac.S <- rep(NA,6)
  spawn.count   <- rep(NA,6)
  spawn.count.N <- rep(NA,6)
  spawn.count.S <- rep(NA,6)
  spawn.count2   <- rep(NA,6)
  spawn.count2.N <- rep(NA,6)
  spawn.count2.S <- rep(NA,6)
  for(i in 1:6){
    subset1  <- sst_fish$len.group==i
    subset2  <- sst_fish$len.group==i & sst_fish$HAUL_LATITUDE_DD > 39
    subset2b <- sst_fish$len.group==i & sst_fish$HAUL_LATITUDE_DD <= 39
    subset3  <- sst_fish$SPAWNING_YN %in% c("Y","N")
    subset3y  <- sst_fish$SPAWNING_YN %in% c("Y")
    subset3n  <- sst_fish$SPAWNING_YN %in% c("N")
    # weighting fish by biomass in tow
    spawn.frac[i]   <- sum(subset1  & subset3y,na.rm=TRUE)/sum(subset1  & subset3, na.rm=TRUE)
    spawn.frac.N[i] <- sum(subset2  & subset3y,na.rm=TRUE)/sum(subset2  & subset3, na.rm=TRUE)
    spawn.frac.S[i] <- sum(subset2b & subset3y,na.rm=TRUE)/sum(subset2b & subset3, na.rm=TRUE)
    spawn.count[i]   <- sum(subset1  & subset3y,na.rm=TRUE)
    spawn.count.N[i] <- sum(subset2  & subset3y,na.rm=TRUE)
    spawn.count.S[i] <- sum(subset2b & subset3y,na.rm=TRUE)
    spawn.count2[i]   <- sum(subset1  & subset3,na.rm=TRUE)
    spawn.count2.N[i] <- sum(subset2  & subset3,na.rm=TRUE)
    spawn.count2.S[i] <- sum(subset2b & subset3,na.rm=TRUE)
  }  
  spawn.frac.wt <- spawn.count.N*Nfrac/NfracB + spawn.count.N*(1-Nfrac)/(1-NfracB)
  
  # fraction north and south of 39 degrees
  
}

# make figure
png("c:/SS/Thornyheads/figs/SST_distribution_by_size_group.png",width=9,height=7,res=300,units='in')
par(mfrow=c(2,3),mar=rep(1,4),oma=c(5,4,4,1))
for(i in 1:n){
  plot(0,xlim=c(1280,0),ylim=c(32,50),xaxs='i',yaxs='i',axes=FALSE)
  # title for each panel
  latvec <- seq(32,50,2)
  mtext(side=3,line=.5,len.group.names[i],font=1)
  abline(h=latvec,lty=3,col='grey')
  abline(v=seq(0,1200,200),lty=3,col='grey')
  
  subset <- sst_fish$len.group==i
  # add all points
  points(sst_fish$DEPTH_M[subset],
         sst_fish$HAUL_LATITUDE_DD[subset],col=colvec[2],pch=16)
  points(sst_fish$DEPTH_M[subset],
         sst_fish$HAUL_LATITUDE_DD[subset],col=colvec[2],pch=16)
  # add means
  ## points(x,       y,       col=2,type='o',pch=16,lwd=3)
  ## points(x[i],    y[i],    col=2,bg='white',pch=23,cex=2,lwd=3)
  points(x.bio,   y.bio,   col=2,type='o',pch=16,cex=2,lwd=5)
  points(x.bio[i],y.bio[i],col=2,bg=1,pch=23,cex=3,lwd=3)
  ## points(x.num,   y.num,   col=2,type='o',pch=16,lwd=3)
  ## points(x.num[i],y.num[i],col=2,bg='white',pch=23,cex=2,lwd=3)
  # add axes
  if(par()$mfg[2]==1) axis(2,at=latvec,label=paste(latvec,"°",sep=''),las=1)
  if(par()$mfg[1]==par()$mfg[3]) axis(1)
  box()
  mtext(side=1,line=2.5,outer=TRUE,"Depth (m)")
  mtext(side=2,line=2.5,outer=TRUE,"Latitude (°N)")
  
}
dev.off()

