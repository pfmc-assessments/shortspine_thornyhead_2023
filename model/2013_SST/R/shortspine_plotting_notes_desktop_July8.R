if(FALSE){
  setwd('c:/SS/Thornyheads/runs/')
  sbasedir <- 'SST_BASE_pre-STAR'
  sbase <- SS_output(sbasedir,covar=TRUE)

  sbase2dir <- 'SST_2.4_len_outliers'
  sbase2 <- SS_output(sbase2dir,covar=TRUE)
  
  fleets <- c("Trawl North",
              "Trawl South",
              "Non-trawl North",
              "Non-trawl South",
              "AFSC Triennial Shelf Survey 1",
              "AFSC Triennial Shelf Survey 2",
              "AFSC Slope Survey",
              "NWFSC Slope Survey",
              "NWFSC Combo Survey")

  # make all plots
  SS_plots(sbase,png=TRUE,datplot=TRUE,
           fleetnames=fleets)

  # remake timeseries with less height
  SS_plots(sbase,png=TRUE,datplot=TRUE,pheight=5,plot=3,
           fleetnames=fleets)

  catlabels <- c("Harvest rate/Year",  #1
                 "Continuous F",              #2
                 "Landings",                  #3
                 "Total catch",               #4
                 "Predicted Discards",        #5  # should add units
                 "Discard fraction",          #6  # need to add by weight or by length
                 "(mt)",                      #7
                 "(numbers x1000)",           #8
                 "Observed and expected",     #9
                 "aggregated across seasons")

  # remake catch with less height
  SSplotCatch(sbase,plot=FALSE,print=TRUE,pheight=5,
              addmax=TRUE,plotdir=file.path(sbasedir,'plots'),
              fleetnames=fleets,labels=catlabels)

  # remake SPR with less height
  SSplotComparisons(SSsummarize(list(sbase)),plotdir=file.path(basedir,'plots'),
                    legend=FALSE,pheight=5,png=TRUE)

  SS_plots(sbase,png=TRUE,plot=8)
}

# specialized stuff
pngfun <- function(file,w=7,h=7,pt=12){
  file <- file.path(sbasedir,'plots',file)
  cat('writing PNG to',file,'\n')
  png(filename=file,
      width=w,height=h,
      units='in',res=300,pointsize=pt)
}

if(FALSE){
  SSplotData(sbase, print=TRUE, fleetnames=fleets, margins = c(5.1, 2.1, 4.1, 13.1),ptsize=9)

  # index data
  pngfun('SST_index_data.png',h=8.5)
  par(mfrow=c(3,2),mar=c(2,2,2,1),oma=c(2,2,0,0)+.1)
  for(f in 5:9){
    SSplotIndices(sbase,fleets=f,subplot=1,datplot=TRUE)
  }
  mtext(side=1,line=1,outer=TRUE,'Year')
  mtext(side=2,line=1,outer=TRUE,'Index')
  dev.off()

  # index fits
  pngfun('SST_index_fits.png',h=8.5)
  par(mfrow=c(3,2),mar=c(2,2,2,1),oma=c(2,2,0,0)+.1)
  for(f in 5:9){
    SSplotIndices(sbase,fleets=f,subplot=2)
  }
  mtext(side=1,line=1,outer=TRUE,'Year')
  mtext(side=2,line=1,outer=TRUE,'Index')
  dev.off()


  # mean bodyweight fits
  pngfun('SST_bodywt_fits.png')
  par(mfcol=c(2,2),mar=c(2,2,2,1),oma=c(2,2,0,0)+.1)
  for(f in 1:4){
    SSplotMnwt(sbase,fleets=f,subplot=2,ymax=4,fleetnames=fleets)
  }
  mtext(side=1,line=1,outer=TRUE,'Year')
  mtext(side=2,line=1,outer=TRUE,'Mean individual body weight (kg)')
  dev.off()




  # discard fits
  pngfun('SST_discard_fits.png')
  par(mfcol=c(2,2),mar=c(2,2,2,1),oma=c(2,2,0,0)+.1)
  for(f in 1:4){
    SSplotDiscard(sbase,fleets=f,subplot=2,fleetnames=fleets)
  }
  mtext(side=1,line=1,outer=TRUE,'Year')
  mtext(side=2,line=1,outer=TRUE,'Mean individual body weight (kg)')
  dev.off()


  ### biology stuff
  # see function maturity/SST_maturity_notes.R
  pngfun('SST_weight_vs_fecundity.png',h=5,w=6.5)
  par(mar=c(5,4,1,1))
  plot(0, type='n', ylim=c(0,5.5),xlim=c(10,70),xaxs='r',axes=FALSE,
       xlab='Length (cm)',ylab="Weight or  Fecundity x Maturity")
  abline(h=0,col='grey')
  lines(sbase$biology$Mean_Size, sbase$biology$Wt_len_F,
        type='o', lwd=3, pch=16, col=1)
  lines(sbase$biology$Mean_Size, sbase$biology$Spawn,
        type='o', lwd=3, pch=16, col=2, lty=2, ylim=c(0,8),xlim=c(0,80))
  legend('topleft',lwd=3,pch=16,col=1:2,c("Weight","Fecundity x Maturity"),lty=1:2)
  axis(1)
  axis(2)
  box()
  dev.off()

  ### length comps
  SS_plots(sbase,bub.scale.dat=6,plot=13,datplot=TRUE,dir='plots2',
           png=TRUE,pheight=8.5,fleetnames=fleets)
  #residuals
  SS_plots(sbase,plot=16,datplot=FALSE,dir='plots2',
           png=TRUE,pheight=8.5,fleetnames=fleets)
  # fisheries with lots of rows
  SS_plots(sbase,plot=16,datplot=FALSE,dir='plots2',printfolder="length_comp_fits",
           png=TRUE,pheight=7,pwidth=6,fleetnames=fleets,maxrows=7)
  # surveys as tall skinny plots
  SS_plots(sbase,plot=16,datplot=FALSE,dir='plots2',printfolder="length_comp_fits",
           png=TRUE,pheight=5.5,pwidth=2.5,fleetnames=fleets,maxrows=5,maxcols=2,fleets=5:9)
  # aggregate plots
  SS_plots(sbase,plot=16,datplot=FALSE,dir='plots2',printfolder="aggregate_comp_fits",
           png=TRUE,pheight=4,pwidth=6,fleetnames=fleets,showsampsize=FALSE,showeffN=FALSE)

  # 5x5 plots
  SS_plots(sbase,png=TRUE,datplot=FALSE,pwidth=5,pheight=5,
           printfolder="plots_5x5",fleetnames=fleets)

  # separate sexes
  SS_plots(sbase,bub.scale.dat=6,fleets=9,plot=13,datplot=TRUE,dir='plots2',
           png=TRUE,pheight=4,fleetnames=fleets)
  SS_plots(sbase,fleets=9,plot=16,dir='plots2',
           png=TRUE,pheight=4,fleetnames=fleets)

  # jitter
  jit.best <- SS_output(dir.jitter,repfile="Report6.sso",compfile="CompReport6.sso",covar=FALSE)
  SSplotSelex(jit.best,years=seq(1981,2012,2),sizefactors="Ret",subplot=1,fleets=2)
  SSplotSelex(sbase,years=seq(1981,2012,2),sizefactors="Ret",subplot=1,fleets=2)

  # selectivity curves
  test <- SSplotSelex(sbase, fleets=1:4, fleetnames=fleets, subplot=1)
  test$infotable$col <- rich.colors.short(5)[c(1:3,5)]
  test2 <- SSplotSelex(sbase, fleets=5:9, fleetnames=fleets, subplot=1)
  test2$infotable$col[4] <- "orange2"
  pngfun("SST_selectivity.png")
  par(mfrow=c(2,1),mar=c(2,4,3,1))
  SSplotSelex(sbase,fleets=1:4,infotable=test$infotable,subplot=1,legendloc='topright',showmain=FALSE)
  par(mar=c(4,4,1,1))
  SSplotSelex(sbase,fleets=5:9,infotable=test2$infotable,subplot=1,legendloc='topright',showmain=FALSE)
  dev.off()


  # common deepwater stuff
  
  # read data
  NWFSCsurv2 <- read.csv("c:/Data/NWFSCsurvey/_Biomass w substrate bathymetry temperature DATA 2003 - 2011.csv")
  NWFSCsurv2$BEST_LAT_DD <- NWFSCsurv2$Lat_mid
  NWFSCsurv2$BEST_DEPTH_M <- NWFSCsurv2$Depth_m
  NWFSCsurv2$AREA_SWEPT_HA <- NWFSCsurv2$Trawl_km * NWFSCsurv2$Netwidth_m /10

  NWFSCsurv2[NWFSCsurv2==-9999] <- NA
  # get frequency of occurence
  test <- apply(NWFSCsurv2[deep,],2,function(x){mean(!is.na(x))})
  # names
  names(NWFSCsurv2)[which(as.numeric(test)>0.75)]
## [33] "Temp10krig"       "Temp11krig"       "Tempallkrig"      "Anop_fimb"       
## [37] "Apri_brun"        "Micr_paci"        "Seba_alas"        "Seba_alti"       
  Sablefish, Anoplopoma fimbria, "Anop_fimb"
  California slickhead, Alepocephalus tenebrosus, "Alep_tene"
  Pacific grenadier, Coryphaenoides acrolepis, "Cory_acro"
  Pacific flatnose (finescale codline), Antimora microlepis, "Anti_micr"

  names(NWFSCsurv2)[which(as.numeric(test)>0.7)][36:40]
  "Anop_fimb" "Apri_brun" "Micr_paci" "Seba_alas" "Seba_alti"
  sable        Brown cat  Dover      SST         LST
  "Alep_tene"     "Anop_fimb"     "Apri_brun"     "Chio_tann"     "Cory_acro"     
  Cal. slick      sable           brn cat         tanner crab     pac gren
  "Emba_bath"     "Micr_paci"     "Seba_alas"     "Seba_alti"
  deepsea sole    dover sole      SST             LST

  rbind(names(NWFSCsurv2)[which(as.numeric(test)>0.6)][36:50],
        round(100*as.numeric(test)[which(as.numeric(test)>0.6)][36:50],1))
}
