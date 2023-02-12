if(FALSE){
  NWFSC_combo_yr.strata <- read.csv(file.path("C:/ss/Thornyheads/GLMM_results/NWSurveys_2e5_iter/SSPN_Late/shortspine thornyhead_FinalDiagnostics/Model=1/",
                                              "ResultsByYearAndStrata.csv"))

  Tri_yr.strata <- read.csv(file.path("C:/ss/Thornyheads/GLMM_results/New.SST.Tri.1980-2004_3strata",
                                      "shortspine_thornyhead_FinalDiagnostics/Model=1",
                                      "ResultsByYearAndStrata.csv"))

  Tri_yr <- read.csv(file.path("C:/ss/Thornyheads/GLMM_results/New.SST.Tri.1980-2004_3strata",
                               "shortspine_thornyhead_FinalDiagnostics/Model=1",
                               "ResultsByYear.csv"))


  subset <- Tri_yr.strata$Year==1980
  means <- Tri_yr.strata$IndexMean[Tri_yr.strata$Year==1980]
  meds <- Tri_yr.strata$IndexMedian[Tri_yr.strata$Year==1980]
  raws <- Tri_yr.strata$Raw[Tri_yr.strata$Year==1980]
  rawCVs <- Tri_yr.strata$RawCV[Tri_yr.strata$Year==1980]

  sqrt(sum((raws*rawCVs)^2))/sum(raws)
  # [1] 0.1658544
  Tri_yr$RawCV[Tri_yr$Year==1980]
  # [1] 0.1658544
  sum(raws)
  # [1] 1879506271
  Tri_yr$Raw[Tri_yr$Year==1980]
  # [1] 1879506271
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
  new.indices(Tri_yr.strata)
  ##    Year    Raw RawCV  area
  ## 1  1980 1653.8 0.174 North
  ## 2  1983 1764.0 0.120 North
  ## 3  1986 1697.0 0.188 North
  ## 4  1989 1666.0 0.148 North
  ## 5  1992 1785.6 0.161 North
  ## 6  1995 2086.5 0.181 North
  ## 7  1998 2296.9 0.203 North
  ## 8  2001 2289.4 0.135 North
  ## 9  2004 2870.2 0.178 North
  ## 10 1980  225.7 0.525 South
  ## 11 1983  240.1 0.216 South
  ## 12 1986  286.2 0.353 South
  ## 13 1989  455.6 0.239 South
  ## 14 1992  233.8 0.252 South
  ## 15 1995  485.1 0.266 South
  ## 16 1998  197.5 0.242 South
  ## 17 2001  313.2 0.221 South
  ## 18 2004  229.0 0.256 South

  new.indices(NWFSC_combo_yr.strata, Strata.N=c("E","F","G"),scale=1e3) 
  ##    Year     Raw RawCV  area
  ## 1  2003 16525.1 0.089 North
  ## 2  2004 21064.0 0.129 North
  ## 3  2005 17979.8 0.082 North
  ## 4  2006 16851.7 0.090 North
  ## 5  2007 19952.0 0.086 North
  ## 6  2008 17510.2 0.074 North
  ## 7  2009 17369.0 0.084 North
  ## 8  2010 16579.1 0.084 North
  ## 9  2011 21165.0 0.107 North
  ## 10 2012 18355.2 0.081 North
  ## 11 2003 35140.8 0.151 South
  ## 12 2004 32117.3 0.129 South
  ## 13 2005 30182.1 0.079 South
  ## 14 2006 30680.2 0.096 South
  ## 15 2007 29082.9 0.123 South
  ## 16 2008 26264.7 0.090 South
  ## 17 2009 40904.1 0.266 South
  ## 18 2010 29649.5 0.122 South
  ## 19 2011 26930.1 0.088 South
  ## 20 2012 35070.9 0.122 South

  split_combo <- new.indices(NWFSC_combo_yr.strata, Strata.N=c("C","D","E","F","G"),scale=1e3)
  split_combo$Lo <- qlnorm(.025,meanlog=log(split_combo$Raw),sdlog=split_combo$RawCV)
  split_combo$Hi <- qlnorm(.975,meanlog=log(split_combo$Raw),sdlog=split_combo$RawCV)
  split_combo$uiw <- split_combo$Hi - split_combo$Raw
  split_combo$liw <- split_combo$Raw - split_combo$Lo
  survN <- split_combo[split_combo$area=="North",]
  survS <- split_combo[split_combo$area=="South",]

  LST_survN <- split_combo[split_combo$area=="North",]
  LST_survS <- split_combo[split_combo$area=="South",]
  
  
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

  png("c:/SS/Thornyheads/GLMM_results/GLMM_plots/north_south_index_figure2.png",width=8,height=8,res=300,units='in')
  plot(0,type='n',xlim=c(2002.5,2012),ylim=c(0,6e4),xlab='Year',ylab='Index',yaxs='i',axes=FALSE)
  plotCI(x=survN$Year, y=survN$Raw,sfrac=0.005,uiw=survN$uiw,liw=survN$liw,
         ylo=0,col=1,lty=1,add=TRUE,pch=21,bg='white')
  plotCI(x=survS$Year+.1, y=survS$Raw,sfrac=0.005,uiw=survS$uiw,liw=survS$liw,
         ylo=0,col=2,lty=1,add=TRUE,pch=21,bg='white')
  axis(1,2003:2012)
  axis(2)
  box()
  dev.off()

  png("c:/SS/Thornyheads/GLMM_results/GLMM_plots/north_south_index_figure_LST.png",width=8,height=8,res=300,units='in')
  plot(0,type='n',xlim=c(2002.5,2012),ylim=c(0,6e4),xlab='Year',ylab='Index',yaxs='i',axes=FALSE)
  plotCI(x=LST_survN$Year, y=LST_survN$Raw,sfrac=0.005,uiw=LST_survN$uiw,liw=LST_survN$liw,
         ylo=0,col=1,lty=1,add=TRUE,pch=21,bg='white')
  plotCI(x=LST_survS$Year+.1, y=LST_survS$Raw,sfrac=0.005,uiw=LST_survS$uiw,liw=LST_survS$liw,
         ylo=0,col=2,lty=1,add=TRUE,pch=21,bg='white')
  axis(1,2003:2012)
  axis(2)
  box()
  dev.off()
  
  png("c:/SS/Thornyheads/GLMM_results/GLMM_plots/strata_index_figure.png",width=8,height=6,res=300,units='in')
  plot(0,type='n',xlim=c(2002.5,2012),ylim=c(0,3e4),xlab='Year',ylab='Index',yaxs='i',axes=FALSE)
  strats <- unique(NWFSC_combo_yr.strata$Strata)
  nstrat <- length(strats)
  colvec <- rich.colors.short(nstrat)
  for(i in 1:nstrat){
    subset <- NWFSC_combo_yr.strata$Strata==strats[i]
    lines(NWFSC_combo_yr.strata$Year[subset],
          1e-3*NWFSC_combo_yr.strata$Raw[subset],col=colvec[i],
          lwd=5)
    text(x=2002.7,y=1e-3*NWFSC_combo_yr.strata$Raw[subset][1],
         strats[i],col=colvec[i],cex=1.5)
  }
  axis(1,2003:2012)
  axis(2)
  box()
  dev.off()

  png("c:/SS/Thornyheads/GLMM_results/GLMM_plots/strata_index_CVs_figure.png",width=8,height=6,res=300,units='in')
  plot(0,type='n',xlim=c(2002.5,2012),ylim=c(0,1),xlab='Year',ylab='Index CV',yaxs='i',axes=FALSE)
  strats <- unique(NWFSC_combo_yr.strata$Strata)
  nstrat <- length(strats)
  colvec <- rich.colors.short(nstrat)
  for(i in 1:nstrat){
    subset <- NWFSC_combo_yr.strata$Strata==strats[i]
    lines(NWFSC_combo_yr.strata$Year[subset],
          NWFSC_combo_yr.strata$RawCV[subset],col=colvec[i],
          lwd=5)
    text(x=2002.7,y=NWFSC_combo_yr.strata$RawCV[subset][1],
         strats[i],col=colvec[i],cex=1.5)
  }
  axis(1,2003:2012)
  axis(2)
  box()
  dev.off()

  
}
