if(FALSE){
  NWFSC_combo_SST_yr.strata <- read.csv(file.path("C:/ss/Thornyheads/GLMM_results/NWSurveys_2e5_iter/SSPN_Late/shortspine thornyhead_FinalDiagnostics/Model=1/",
                                              "ResultsByYearAndStrata.csv"))
  NWFSC_combo_LST_yr.strata <- read.csv(file.path("C:/ss/Thornyheads/GLMM_results/NWSurveys_2e5_iter/LSPN_Late/longspine thornyhead_FinalDiagnostics/Model=1/",
                                                  "ResultsByYearAndStrata.csv"))
}

new.indices <- function(ind,Strata.N=c("A","B"),scale=1e6){
  # create a new design-based index, combining across strata
  yrs <- sort(unique(ind$Year))
  nyrs <- length(yrs)
  raw.N <- raw.S <- rep(NA,nyrs)
  rawCV.N <- rawCV.S <- rep(NA,nyrs)
  for(i in 1:nyrs){
    y <- yrs[i]
    raws.N <- ind$Raw[ind$Year==y & ind$Strata %in% Strata.N]
    raws.S <- ind$Raw[ind$Year==y & !ind$Strata %in% Strata.N]
    rawCVs.N <- ind$RawCV[ind$Year==y & ind$Strata %in% Strata.N]
    rawCVs.S <- ind$RawCV[ind$Year==y & !ind$Strata %in% Strata.N]
    raw.N[i] <- sum(raws.N)/scale
    raw.S[i] <- sum(raws.S)/scale
    rawCV.N[i] <- sqrt(sum((raws.N*rawCVs.N)^2))/sum(raws.N)
    rawCV.S[i] <- sqrt(sum((raws.S*rawCVs.S)^2))/sum(raws.S)
  }
  df <- rbind(data.frame(Year=yrs,Raw=raw.N,RawCV=rawCV.N,area="North"),
              data.frame(Year=yrs,Raw=raw.S,RawCV=rawCV.S,area="South"))
  df$Raw   <- round(df$Raw,1)
  df$RawCV <- round(df$RawCV,3)
  return(df)
}

if(FALSE){
  split_combo_SST <- new.indices(NWFSC_combo_SST_yr.strata, Strata.N=c("C","D","E","F","G"),scale=1e3)
  split_combo_SST$Lo <- qlnorm(.025,meanlog=log(split_combo_SST$Raw),sdlog=split_combo_SST$RawCV)
  split_combo_SST$Hi <- qlnorm(.975,meanlog=log(split_combo_SST$Raw),sdlog=split_combo_SST$RawCV)
  split_combo_SST$uiw <- split_combo_SST$Hi - split_combo_SST$Raw
  split_combo_SST$liw <- split_combo_SST$Raw - split_combo_SST$Lo
  survN <- split_combo_SST[split_combo_SST$area=="North",]
  survS <- split_combo_SST[split_combo_SST$area=="South",]

  split_combo_LST <- new.indices(NWFSC_combo_LST_yr.strata, Strata.N=c("C","D","E","F","G","H"),scale=1e3)
  split_combo_LST$Lo <- qlnorm(.025,meanlog=log(split_combo_LST$Raw),sdlog=split_combo_LST$RawCV)
  split_combo_LST$Hi <- qlnorm(.975,meanlog=log(split_combo_LST$Raw),sdlog=split_combo_LST$RawCV)
  split_combo_LST$uiw <- split_combo_LST$Hi - split_combo_LST$Raw
  split_combo_LST$liw <- split_combo_LST$Raw - split_combo_LST$Lo
  LST_survN <- split_combo_LST[split_combo_LST$area=="North",]
  LST_survS <- split_combo_LST[split_combo_LST$area=="South",]
  

  # shortspine figure
  png("c:/SS/Thornyheads/GLMM_results/GLMM_plots/north_south_index_figure1.png",width=8,height=8,res=300,units='in')
  plot(0,type='n',xlim=c(2002.5,2012),ylim=c(0,6e4),xlab='Year',ylab='Index',yaxs='i',axes=FALSE)
  lines(x=survN$Year, y=survN$Raw,col=1,lwd=5)
  lines(x=survS$Year, y=survS$Raw,col=2,lwd=5)
  text(x=2002.7,y=1.15*survN$Raw[1],"C+D+E+F+G",adj=0)
  text(x=2002.7,y=1.15*survS$Raw[1],"A+B",col=2,adj=0)
  axis(1,2003:2012)
  axis(2)
  box()
  dev.off()

  # shortspine figure with alternative formatting
  png("c:/SS/Thornyheads/GLMM_results/GLMM_plots/north_south_index_figure2.png",width=8,height=8,res=300,units='in')
  plot(0,type='n',xlim=c(2002.5,2012),ylim=c(0,6e4),xlab='Year',ylab='Index',yaxs='i',axes=FALSE)
  plotCI(x=survN$Year, y=survN$Raw,sfrac=0.005,uiw=survN$uiw,liw=survN$liw,
         ylo=0,col=1,lty=1,add=TRUE,pch=21,bg='white')
  plotCI(x=survS$Year+.1, y=survS$Raw,sfrac=0.005,uiw=survS$uiw,liw=survS$liw,
         ylo=0,col=2,lty=1,add=TRUE,pch=23,bg='white')
  legend('topleft',pch=c(21,23),col=1:2,pt.bg='white',lty=1,bty='n',
         legend=c("North of Point Conception","South of Point Conception"))
  axis(1,2003:2012)
  axis(2)
  box()
  dev.off()

  # longspine figure
  png("c:/SS/Thornyheads/GLMM_results/GLMM_plots/north_south_index_figure_LST.png",width=8,height=8,res=300,units='in')
  plot(0,type='n',xlim=c(2002.5,2012),ylim=c(0,1.6e5),xlab='Year',ylab='Index',yaxs='i',axes=FALSE)
  plotCI(x=LST_survN$Year, y=LST_survN$Raw,sfrac=0.005,uiw=LST_survN$uiw,liw=LST_survN$liw,
         ylo=0,col=1,lty=1,add=TRUE,pch=21,bg='white')
  plotCI(x=LST_survS$Year+.1, y=LST_survS$Raw,sfrac=0.005,uiw=LST_survS$uiw,liw=LST_survS$liw,
         ylo=0,col=2,lty=1,add=TRUE,pch=23,bg='white')
  legend('topleft',pch=c(21,23),col=1:2,pt.bg='white',lty=1,bty='n',
         legend=c("North of Point Conception","South of Point Conception"))
  axis(1,2003:2012)
  axis(2)
  box()
  dev.off()

  # shortspine fig for all strata 
  png("c:/SS/Thornyheads/GLMM_results/GLMM_plots/strata_index_figure.png",width=8,height=6,res=300,units='in')
  plot(0,type='n',xlim=c(2002.5,2012),ylim=c(0,3e4),xlab='Year',ylab='Index',yaxs='i',axes=FALSE)
  strats <- unique(NWFSC_combo_SST_yr.strata$Strata)
  nstrat <- length(strats)
  colvec <- rich.colors.short(nstrat)
  for(i in 1:nstrat){
    subset <- NWFSC_combo_SST_yr.strata$Strata==strats[i]
    lines(NWFSC_combo_SST_yr.strata$Year[subset],
          1e-3*NWFSC_combo_SST_yr.strata$Raw[subset],col=colvec[i],
          lwd=5)
    text(x=2002.7,y=1e-3*NWFSC_combo_SST_yr.strata$Raw[subset][1],
         strats[i],col=colvec[i],cex=1.5)
  }
  axis(1,2003:2012)
  axis(2)
  box()
  dev.off()

  # longspine fig for all strata 
  png("c:/SS/Thornyheads/GLMM_results/GLMM_plots/LST_strata_index_figure.png",width=8,height=6,res=300,units='in')
  plot(0,type='n',xlim=c(2002.5,2012),ylim=c(0,6e4),xlab='Year',ylab='Index',yaxs='i',axes=FALSE)
  strats <- unique(NWFSC_combo_LST_yr.strata$Strata)
  nstrat <- length(strats)
  colvec <- rich.colors.short(nstrat)
  for(i in 1:nstrat){
    subset <- NWFSC_combo_LST_yr.strata$Strata==strats[i]
    lines(NWFSC_combo_LST_yr.strata$Year[subset],
          1e-3*NWFSC_combo_LST_yr.strata$Raw[subset],col=colvec[i],
          lwd=5)
    text(x=2002.7,y=1e-3*NWFSC_combo_LST_yr.strata$Raw[subset][1],
         strats[i],col=colvec[i],cex=1.5)
  }
  axis(1,2003:2012)
  axis(2)
  box()
  dev.off()

  png("c:/SS/Thornyheads/GLMM_results/GLMM_plots/strata_index_CVs_figure.png",width=8,height=6,res=300,units='in')
  plot(0,type='n',xlim=c(2002.5,2012),ylim=c(0,1),xlab='Year',ylab='Index CV',yaxs='i',axes=FALSE)
  strats <- unique(NWFSC_combo_SST_yr.strata$Strata)
  nstrat <- length(strats)
  colvec <- rich.colors.short(nstrat)
  for(i in 1:nstrat){
    subset <- NWFSC_combo_SST_yr.strata$Strata==strats[i]
    lines(NWFSC_combo_SST_yr.strata$Year[subset],
          NWFSC_combo_SST_yr.strata$RawCV[subset],col=colvec[i],
          lwd=5)
    text(x=2002.7,y=NWFSC_combo_SST_yr.strata$RawCV[subset][1],
         strats[i],col=colvec[i],cex=1.5)
  }
  axis(1,2003:2012)
  axis(2)
  box()
  dev.off()

  
}
