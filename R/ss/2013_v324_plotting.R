if(FALSE){
  model.dir <- file.path(here::here(), "model", "2013_SST")
  sbase <- SS_output(model.dir,covar=TRUE)

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

  # comparisons plots
  SSplotComparisons(SSsummarize(list(sbase)),plotdir=file.path(sbasedir,'plots'),
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
    SSplotIndices(sbase,fleets=f,subplot=1,datplot=TRUE,fleetnames=fleets)
  }
  mtext(side=1,line=1,outer=TRUE,'Year')
  mtext(side=2,line=1,outer=TRUE,'Index')
  dev.off()

  # index fits
  pngfun('SST_index_fits.png',h=8.5)
  par(mfrow=c(3,2),mar=c(2,2,2,1),oma=c(2,2,0,0)+.1)
  for(f in 5:9){
    SSplotIndices(sbase,fleets=f,subplot=2,fleetnames=fleets)
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
  mtext(side=2,line=1,outer=TRUE,'Discard fraction')
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
  SS_plots(sbase,bub.scale.dat=6,plot=13,datplot=TRUE,printfolder='length_comps',
           png=TRUE,pheight=8.5,fleetnames=fleets)
  #residuals
  SS_plots(sbase,plot=16,datplot=FALSE,printfolder='risiduals',
           png=TRUE,pheight=8.5,fleetnames=fleets)
  # fisheries with lots of rows
  SS_plots(sbase,plot=16,datplot=FALSE,printfolder='plots2',printfolder="length_comp_fits",
           png=TRUE,pheight=7,pwidth=6,fleetnames=fleets,maxrows=7)
  # surveys as tall skinny plots
  SS_plots(sbase,plot=16,datplot=FALSE,printfolder='plots2',printfolder="length_comp_fits",
           png=TRUE,pheight=5.5,pwidth=2.5,fleetnames=fleets,maxrows=5,maxcols=2,fleets=5:9)
  # aggregate plots
  SS_plots(sbase,plot=16,datplot=FALSE,printfolder='plots2',printfolder="aggregate_comp_fits",
           png=TRUE,pheight=4,pwidth=6,fleetnames=fleets,showsampsize=FALSE,showeffN=FALSE)


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
  grid()
  par(mar=c(4,4,1,1))
  SSplotSelex(sbase,fleets=5:9,infotable=test2$infotable,subplot=1,legendloc='topright',showmain=FALSE)
  grid()
  dev.off()

  tmp <- list()
  for(f in 1:4){
    tmp[[f]] <- SSplotSelex(sbase,years=seq(1981,2012,2),sizefactors="Ret",subplot=1,fleets=f,
                            fleetnames=fleets)
  }
  pngfun("SST_retention.png")
  par(mfrow=c(2,2),mar=c(2,2,2,1),oma=c(2,2,0,0))
  for(f in 1:4){
    labs <- c("", "Age (yr)", "Year", 
              "Retention", "Retention", "Discard mortality")
    info <- tmp[[f]]$infotable
    info$year_range[info$year_range=="2011"] <- "2011-2012"
    info$longname <- info$year_range
    info$pch <- 1:nrow(info)
    info$col <- c(1,2,4)[1:nrow(info)]
    SSplotSelex(sbase,years=seq(1981,2012,2),labels=labs,sizefactors="Ret",
                subplot=1,fleets=f,
                showmain=FALSE,fleetnames=fleets, infotable=info)
    grid()
    mtext(side=3,line=0,fleets[f],outer=FALSE)
  }
  mtext(side=1,line=.8,"Length (cm)",outer=TRUE)
  mtext(side=2,line=.8,"Retention",outer=TRUE)
  dev.off()


}
