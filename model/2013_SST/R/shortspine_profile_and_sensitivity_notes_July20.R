if(FALSE){
  setwd('C:/ss/thornyheads/runs/')
  sbase <- SS_output('SST_BASE_pre-STAR')

  #########################################################
  ### steepness profile
  #########################################################
  # vector of values to profile over
  h.vec <- seq(0.3,0.9,.1)
  Nprofile <- length(h.vec)

  setwd('C:/ss/thornyheads/runs/')
  mydir <- "SST_2.11_profile.h"
  starter <- SS_readstarter(file.path(mydir, 'starter.ss'))
  # change control file name in the starter file
  starter$ctlfile <- "control_modified.ss"
  # make sure the prior likelihood is calculated
  # for non-estimated quantities
  starter$prior_like <- 1
  # write modified starter file
  SS_writestarter(starter, dir=mydir, overwrite=TRUE)
  # run SS_profile command
  profile <- SS_profile(dir=getwd(), # directory
                        model="ss3",
                        masterctlfile="control.ss_new",
                        newctlfile="control_modified.ss",
                        string="steep",
                        profilevec=h.vec)

  
  
  # read the output files (with names like Report1.sso, Report2.sso, etc.)
  setwd('C:/ss/thornyheads/runs/')
  prof.h.models <- SSgetoutput(dirvec=mydir, keyvec=1:Nprofile)
  # summarize output
  prof.h.summary <- SSsummarize(prof.h.models)

  #sbase <- SS_output('SST_BASE_pre-STAR')
  #prof.h.models$MLE <- sbase
  prof.h.summary <- SSsummarize(prof.h.models)
  
  # plot profile using summary created above
  SSplotProfile(prof.h.summary,           # summary object
                minfraction=0.001,
                profile.string = "steep", # substring of profile parameter
                profile.label="Stock-recruit steepness (h)",
                pheight=4.5,print=TRUE,plotdir=mydir) # axis label
  
  # make timeseries plots comparing models in profile
  SSplotComparisons(prof.h.summary,legendlabels=c(paste("h =",h.vec)),
                    pheight=4.5,png=TRUE,plotdir=mydir,legendloc='bottomleft')

  round(range(prof.h.summary$quants[prof.h.summary$quants$Label=="SPB_Virgin",1:7]))
  ## [1] 85323 94355
  round(100*range(prof.h.summary$quants[prof.h.summary$quants$Label=="Bratio_2013",1:7]),1)
  ## [1] 49.1 61.0

  # stock-recruit comparison
  png(file.path(mydir,"stock_recruit_h_profile_plot_SST_2.11.png"),width=7,height=7,res=300,units='in')
  SSplotSpawnrecruit(s2.11,line2=NA,line3='red',ptcol=rgb(1,0,0,.5))
  SSplotSpawnrecruit(prof.h.models[[4]],add=TRUE,line3='blue',ptcol=rgb(0,0,1,.5),line2=NA)
  SSplotSpawnrecruit(prof.h.models[[1]],add=TRUE,line3='green3',ptcol=rgb(0,.7,0,.5),line2=NA)
  legend(0,7e4,lwd=3,col=c('red','blue','green3'),bty='n',
         legend=c("Alternate model (h=0.779)","Alternate + h=0.6","Alternate + h=0.3"))
  dev.off()
  #########################################################
  ### M profile
  #########################################################

  setwd('C:/ss/thornyheads/runs/')

  # vector of values to profile over
  M.vec <- seq(0.02,0.08,.01)
  Nprofile <- length(M.vec)

  mydir <- "SST_2.11_profile.M"

  starter <- SS_readstarter(file.path(mydir, 'starter.ss'))
  # change control file name in the starter file
  starter$ctlfile <- "control_modified.ss"
  # make sure the prior likelihood is calculated
  # for non-estimated quantities
  starter$prior_like <- 1
  # write modified starter file
  SS_writestarter(starter, dir=mydir, overwrite=TRUE)
  # run SS_profile command
  setwd(mydir)
  profile <- SS_profile(dir=getwd(), # directory
                        model="ss3",
                        masterctlfile="control.ss_new",
                        newctlfile="control_modified.ss",
                        string="NatM_p_1_Fem",
                        profilevec=M.vec)


  # read the output files (with names like Report1.sso, Report2.sso, etc.)
  setwd('C:/ss/thornyheads/runs/')
  prof.M.models <- SSgetoutput(dirvec=mydir, keyvec=1:Nprofile)
  # summarize output
  prof.M.summary <- SSsummarize(prof.M.models)
  
  #  sbase <- SS_output('SST_BASE_pre-STAR')
  ## prof.M.models$MLE <- sbase
  prof.M.summary <- SSsummarize(prof.M.models)
  # END OPTIONAL COMMANDS
  
  # plot profile using summary created above
  SSplotProfile(prof.M.summary,           # summary object
                profile.string = "NatM_p_1_Fem", # substring of profile parameter
                profile.label="Natural mortality (M)",
                pheight=4.5,print=TRUE,plotdir=mydir) # axis label
  
  # make timeseries plots comparing models in profile
  SSplotComparisons(prof.M.summary,legendlabels=c(paste("M =",M.vec),"base"),
                    pheight=4.5,png=TRUE,plotdir=mydir,legendloc='bottomleft')

  round(range(prof.M.summary$quants[prof.M.summary$quants$Label=="SPB_Virgin",1:7]))
  ## [1]  86164 375008
  round(100*range(prof.M.summary$quants[prof.M.summary$quants$Label=="Bratio_2013",1:7]),1)
  ## [1] 39.8 87.5

  #########################################################
  ### Lmax profile
  #########################################################

  setwd('C:/ss/thornyheads/runs/')

  # vector of values to profile over
  Lmax.vec <- seq(65,85,2.5)
  Nprofile <- length(Lmax.vec)

  mydir <- "SST_2.11_profile.Lmax"

  starter <- SS_readstarter(file.path(mydir, 'starter.ss'))
  # change control file name in the starter file
  starter$ctlfile <- "control_modified.ss"
  # make sure the prior likelihood is calculated
  # for non-estimated quantities
  starter$prior_like <- 1
  # write modified starter file
  SS_writestarter(starter, dir=mydir, overwrite=TRUE)
  # run SS_profile command
  setwd(mydir)
  profile <- SS_profile(dir=getwd(), # directory
                        model="ss3",
                        masterctlfile="control.ss_new",
                        newctlfile="control_modified.ss",
                        string="L_at_Amax_Fem",
                        profilevec=Lmax.vec)


  # read the output files (with names like Report1.sso, Report2.sso, etc.)
  setwd('C:/ss/thornyheads/runs/')
  prof.Lmax.models <- SSgetoutput(dirvec=mydir, keyvec=1:Nprofile)
  # summarize output
  prof.Lmax.summary <- SSsummarize(prof.Lmax.models)
  
  ## #  sbase <- SS_output('SST_BASE_pre-STAR')
  ## prof.Lmax.models$MLE <- sbase
  ## prof.Lmax.summary <- SSsummarize(prof.Lmax.models)
  ## # END OPTIONAL COMMANDS
  
  # plot profile using summary created above
  SSplotProfile(prof.Lmax.summary,           # summary object
                profile.string = "L_at_Amax_Fem", # substring of profile parameter
                profile.label="Mean length at age 100 for females (cm)",
                pheight=4.5,print=TRUE,plotdir=mydir) # axis label
  
  # make timeseries plots comparing models in profile
  SSplotComparisons(prof.Lmax.summary,legendlabels=c(paste("L =",Lmax.vec[seq(1,9,2)],"cm")),
                    models=seq(1,9,2),
                    pheight=4.5,png=TRUE,plotdir=mydir,legendloc='bottomleft')

  round(range(prof.Lmax.summary$quants[prof.Lmax.summary$quants$Label=="SPB_Virgin",1:7]))
  ## [1]  90750 151447
  round(100*range(prof.Lmax.summary$quants[prof.Lmax.summary$quants$Label=="Bratio_2013",1:7]),1)
  ## [1] 54.1 77.7


  #########################################################
  ### R0 profile
  #########################################################

  setwd('C:/ss/thornyheads/runs/')

  # vector of values to profile over
  R0.vec <- seq(9,12,.2)
  Nprof.R0 <- length(R0.vec)

  mydir <- "SST_2.11_profile.R0"

  starter <- SS_readstarter(file.path(mydir, 'starter.ss'))
  # change control file name in the starter file
  starter$ctlfile <- "control_modified.ss"
  # make sure the prior likelihood is calculated
  # for non-estimated quantities
  starter$prior_like <- 1
  # write modified starter file
  SS_writestarter(starter, dir=mydir, overwrite=TRUE)
  # run SS_profile command
#  profile <- SS_profile(dir=mydir, # directory

  # note! had to change phase of SelPar1 from 2 to 1
  
  profile <- SS_profile(dir=getwd(), # directory
                        model="ss3",
                        masterctlfile="control.ss_new",
                        newctlfile="control_modified.ss",
                        string="R0",
                        profilevec=R0.vec)


  # read the output files (with names like Report1.sso, Report2.sso, etc.)
  setwd('C:/ss/thornyheads/runs/')
  prof.R0.models <- SSgetoutput(dirvec=mydir, keyvec=1:Nprof.R0)
  # summarize output
  prof.R0.summary <- SSsummarize(prof.R0.models)
  
  #  sbase <- SS_output('SST_BASE_pre-STAR')
  s2.11 <- SS_output('C:/ss/Thornyheads/runs/SST_2.11_flex_selex_newTri')
  ref <- s2.11
  prof.R0.models$MLE <- ref
  prof.R0.summary <- SSsummarize(prof.R0.models)
  # END OPTIONAL COMMANDS
  
  # plot profile using summary created above
  png(file.path(mydir,"R0_profile_plot_SST_2.11.png"),width=7,height=4.5,res=300,units='in')
  par(mar=c(5,4,1,1))
  SSplotProfile(prof.R0.summary,           # summary object
                profile.string = "R0", # substring of profile parameter
                profile.label=expression(log(italic(R)[0])),ymax=15,
                pheight=4.5,print=FALSE,plotdir=mydir) # axis label
  baseval <- round(ref$parameters$Value[grep("R0",ref$parameters$Label)],2)
  baselab <- paste(baseval,sep="")
  axis(1,at=baseval,label=baselab)
  dev.off()
  # make timeseries plots comparing models in profile
  labs <- paste("log(R0) =",R0.vec[c(1,3,5,7,9,11)])
  labs[3] <- paste("log(R0) =",baseval,"(Base model)")
  SSplotComparisons(prof.R0.summary,legendlabels=labs,
                    models=c(1,3,12,7,9,11),
                    pheight=4.5,png=TRUE,plotdir=mydir,legendloc='bottomleft')

  round(range(prof.R0.summary$quants[prof.R0.summary$quants$Label=="SPB_Virgin",1:11]))
  ## 42263 312282
  round(100*range(prof.R0.summary$quants[prof.R0.summary$quants$Label=="Bratio_2013",1:11]),1)
  ## 39.2 87.9

  # create vector of catchability values (just from fleet 9 = NWFSC Combo Survey)
  Qvec <- rep(NA,prof.R0.summary$n)
  for(i in 1:length(Qvec))
    Qvec[i] <- unique(prof.R0.summary$indices$Calc_Q[prof.R0.summary$indices$FleetNum==9 &
                                                     prof.R0.summary$indices$imodel==i])
  # add base model R0 estimate to vector of R0 values
  R0.vec2 <- c(R0.vec,baseval)
  # get vectors of depletion and B0 (base model is already at the end
  deplvec <- prof.R0.summary$quants[prof.R0.summary$quants$Label=="Bratio_2013",1:prof.R0.summary$n]
  B0vec <- prof.R0.summary$quants[prof.R0.summary$quants$Label=="SPB_Virgin",1:prof.R0.summary$n]/1e3

  # make plot showing B0, depletion, and Q as a function of R0
  png(file.path(mydir,"R0_profile_dependencies_SST_2.11.png"),width=7,height=9,res=300,units='in')
  par(mfrow=c(3,1),mar=c(1,4,1,1),oma=c(4,0,0,0),cex=.8)
  plot(R0.vec2[1:Nprof.R0],B0vec[1:Nprof.R0],type='l',lwd=3,ylim=c(0,max(B0vec)),las=1,yaxs='i',
       xlab="",ylab=expression(paste(italic(B)[0]," (1000 mt)")))
  points(R0.vec2[prof.R0.summary$n],B0vec[prof.R0.summary$n],pch=16,cex=2)
  abline(h=B0vec[prof.R0.summary$n],lty=3)
  axis(2,at=round(B0vec[prof.R0.summary$n],2),las=1,padj=0)
  axis(1,at=baseval,label=baselab)
  abline(v=baseval,lty=3,col='grey')

  plot(R0.vec2[1:Nprof.R0],deplvec[1:Nprof.R0],type='l',lwd=3,ylim=c(0,1),las=1,yaxs='i',
       xlab=expression(log(italic(R)[0])),ylab="Spawning depletion")
  points(R0.vec2[prof.R0.summary$n],deplvec[prof.R0.summary$n],pch=16,cex=2)
  abline(h=deplvec[prof.R0.summary$n],lty=3)
  axis(1,at=baseval,label=baselab)
  abline(v=baseval,lty=3,col='grey')

  plot(R0.vec2[1:Nprof.R0],Qvec[1:Nprof.R0],type='l',lwd=3,ylim=c(0,2),las=1,yaxs='i',
       xlab=expression(log(italic(R)[0])),ylab="Catchability of NWFSC Combo Survey")
  points(R0.vec2[prof.R0.summary$n],Qvec[prof.R0.summary$n],pch=16,cex=2)
  axis(1,at=baseval,label=baselab)
  axis(2,at=round(Qvec[prof.R0.summary$n],2),las=1)
  abline(h=Qvec[prof.R0.summary$n],lty=3,col='grey')
  abline(v=baseval,lty=3,col='grey')
  dev.off()
  
  #########################################################
  ### Retrospective
  #########################################################
  SS_doRetro(masterdir="c:/SS/Thornyheads/runs/",
             oldsubdir='SST_BASE_pre-STAR',
             newsubdir='retrospectives',
             subdirstart='retro', years=0:-5, overwrite=TRUE, extras="-nox",
             intern=FALSE)

  mydir <- "c:/SS/Thornyheads/runs/SST_BASE_pre-STAR_retro"
  retroModels <- SSgetoutput(dirvec=file.path(mydir, "retrospectives",
                               paste("retro",0:-5,sep="")))
  retroSummary <- SSsummarize(retroModels)
  endyrvec <- retroSummary$endyrs + 0:-5
  namevec <- c("Base model (2013)",paste("Retro -",1:5," (",2012:2008,")",sep=""))
  SSplotComparisons(retroSummary, endyrvec=endyrvec,
                    legendlabels=namevec,staggerpoints=-1,spacepoints=11,
                    pheight=4.5,plot=FALSE,png=TRUE,plotdir=mydir,legendloc='bottomleft',
                    indexfleets=9,indexUncertainty=TRUE,indexQlabel=TRUE)
  SSplotComparisons(retroSummary, endyrvec=endyrvec,
                    legendlabels=namevec,staggerpoints=-1,spacepoints=11,
                    pheight=4.5,plot=FALSE,png=TRUE,plotdir=mydir,legend=FALSE,
                    indexfleets=5,indexUncertainty=TRUE,subplot=11:12)

  #########################################################
  ### Figs showing priors
  #########################################################
  
  pngfun <- function(file,w=7,h=7,pt=12){
    png(filename=file.path(sbasedir,'plots',file),
        width=w,height=h,
        units='in',res=300,pointsize=pt)
  }

  png(file.path(getwd(), "SST_priors.png"),res=300,units='in',height=4,width=7)
  par(mfrow=c(1,2),mar=c(2,1,2,1),oma=c(2,2,0,0))
  SSplotPars("SST_2.11_profile.M",string="NatM",xlab="",showlegend=FALSE,showinit=FALSE,showmle=FALSE,showpost=FALSE,showrecdev=FALSE,new=FALSE)
  abline(v=0.0505,col=2)
  mtext(side=1,line=3,"Natural mortality (M)")
  SSplotPars("SST_2.11_profile.h",string="steep",xlab="",showlegend=FALSE,showinit=FALSE,showmle=FALSE,showpost=FALSE,showrecdev=FALSE,new=FALSE)
  abline(v=0.779,col=2)
  mtext(side=1,line=3,"Steepness (h)")
  dev.off()

  #########################################################
  ### Sensitivity to alternative maturity ogives
  #########################################################

  mat.old <- SS_output('SST_2.11_maturity.old')
  mat.crazy <- SS_output('SST_2.11_maturity.crazy')
  mat.summary <- SSsummarize(list(mat.old,sbase,mat.crazy))
  dir.create('../figs/SST_maturity_sensitivity')
  SSplotComparisons(mat.summary, png=TRUE, plotdir='../figs/SST_maturity_sensitivity',
                    pheight=4.5,pwidth=7,legendloc='bottomleft',
                    legendlabels=c("Maturity from previous assessment","Base model","Empirical maturity"))

  #########################################################
  ### Sensitivity to no recruit devs
  #########################################################

  rec.none <- SS_output('SST_2.3_no_recdevs')
  rec.summary <- SSsummarize(list(sbase,rec.none))
  dir.create('../figs/SST_no_recdev_sensitivity')
  SSplotComparisons(rec.summary, png=TRUE, plotdir='../figs/SST_no_recdev_sensitivity',
                    pheight=4.5,pwidth=7,legendloc='bottomleft',
                    legendlabels=c("Base model","No recruitment deviations"))
  SSplotComparisons(rec.summary, png=TRUE, plotdir='../figs/SST_no_recdev_sensitivity',
                    pheight=4.5,pwidth=7,legendloc='topleft',
                    subplot=7:8,
                    legendlabels=c("Base model","No recruitment deviations"))

  #########################################################
  ### Sensitivity to early catch all in the North or South
  #########################################################
  setwd('C:/ss/thornyheads/runs/')
  sbase_dat <- SS_readdat('SST_BASE_pre-STAR/SST_data.ss')
  earlySouth <- earlyNorth <- sbase_dat
  trawl.total <- sbase_dat$catch$Trawl_N + sbase_dat$catch$Trawl_S

  earlyNorth$catch$Trawl_N[earlyNorth$catch$year<1981] <- trawl.total[earlyNorth$catch$year<1981]
  earlyNorth$catch$Trawl_S[earlyNorth$catch$year<1981] <- 0
  earlySouth$catch$Trawl_S[earlySouth$catch$year<1981] <- trawl.total[earlySouth$catch$year<1981]
  earlySouth$catch$Trawl_N[earlySouth$catch$year<1981] <- 0
  SS_writedat(earlyNorth,'SST_2.5_early_catch_North/earlyNorth_SST_data.ss')
  SS_writedat(earlySouth,'SST_2.6_early_catch_South/earlySouth_SST_data.ss')

  s_earlyNorth <- SS_output('SST_2.5_early_catch_North')
  s_earlySouth <- SS_output('SST_2.6_early_catch_South')

  # almost no difference
  SSplotComparisons(SSsummarize(list(sbase,s_earlyNorth,s_earlySouth)),
                    legendlabels=c("base","early catch North","early catch South"),
                    png=TRUE,plotdir='SST_2.5_early_catch_North')

  # now doubling, halving
  earlyHalf <- earlyDouble <- sbase_dat
  earlyDouble$catch$Trawl_N[earlyDouble$catch$year<1981] <- 2*sbase_dat$catch$Trawl_N[sbase_dat$catch$year<1981]
  earlyDouble$catch$Trawl_S[earlyDouble$catch$year<1981] <- 2*sbase_dat$catch$Trawl_S[sbase_dat$catch$year<1981]
  earlyHalf$catch$Trawl_N[earlyHalf$catch$year<1981] <- 0.5*sbase_dat$catch$Trawl_N[sbase_dat$catch$year<1981]
  earlyHalf$catch$Trawl_S[earlyHalf$catch$year<1981] <- 0.5*sbase_dat$catch$Trawl_S[sbase_dat$catch$year<1981]
  SS_writedat(earlyDouble,'SST_2.7_early_catch_double/earlyDouble_SST_data.ss')
  SS_writedat(earlyHalf,'SST_2.8_early_catch_half/earlyHalf_SST_data.ss')
  start.double <- start.half <- SS_readstarter('SST_2.7_early_catch_double/starter.ss')
  start.double$datfile <- 'earlyDouble_SST_data.ss'
  start.half$datfile <- 'earlyHalf_SST_data.ss'
  SS_writestarter(start.double, dir='SST_2.7_early_catch_double',overwrite=TRUE)
  SS_writestarter(start.half, dir='SST_2.8_early_catch_half',overwrite=TRUE)

  s_earlyDouble <- SS_output('SST_2.7_early_catch_double')
  s_earlyHalf <- SS_output('SST_2.8_early_catch_half')

  SSplotComparisons(SSsummarize(list(sbase,s_earlyDouble,s_earlyHalf)),
                    legendlabels=c("base","double early catch","half of early catch"),
                    png=TRUE,plotdir='SST_2.7_early_catch_double')

  #########################################################
  ### Sensitivity to better model found with the jitter and the Mac
  #########################################################

  sbase_Mac <- SS_output('C:/SS/Thornyheads/runs/SST_BASE_Mac')
  SSplotComparisons(SSsummarize(list(sbase,sbase_Mac)),
                    pheight=4.5,pwidth=5,legendloc='bottomleft',
                    legendlabels=c("base","better likelihood model"),
                    png=TRUE,plotdir='../figs/better_model_plots/')

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
  SSplotCatch(sbase_Mac,plot=FALSE,print=TRUE,pheight=5,pwidth=5,
              addmax=TRUE,plotdir='../figs/better_model_plots/',
              fleetnames=fleets,labels=catlabels)

  SSplotCatch(sbase,plot=FALSE,print=TRUE,pheight=5,pwidth=5,
              addmax=TRUE,plotdir='../figs/better_model_plots/base/',
              fleetnames=fleets,labels=catlabels)

  SS_plots(sbase_Mac, png=TRUE, fleetnames=fleets,pwidth=5,pheight=5,
           printfolder="plots_5x5")


  
  #########################################################
  ### Sensitivity to model with more flexible selectivity
  #########################################################
  s2.2 <- SS_output('C:/ss/Thornyheads/runs/SST_2.2_pre-STAR_flex_selex')
  SS_plots(s2.2, png=TRUE, fleetnames=fleets,
           printfolder="plots")
  SS_plots(s2.2, png=TRUE, fleetnames=fleets,pwidth=5,pheight=5,
           printfolder="plots_5x5")

  # selectivity curves
  test <- SSplotSelex(s2.2, fleets=1:4, fleetnames=fleets, subplot=1)
  test$infotable$col <- rich.colors.short(5)[c(1:3,5)]
  test2 <- SSplotSelex(s2.2, fleets=5:9, fleetnames=fleets, subplot=1)
  test2$infotable$col[4] <- "orange2"
  png("SST_2.2_selectivity.png", width=7,height=7,res=300,units='in') 
  par(mfrow=c(2,1),mar=c(2,4,3,1))
  SSplotSelex(s2.2,fleets=1:4,infotable=test$infotable,subplot=1,legendloc='topright',showmain=FALSE)
  par(mar=c(4,4,1,1))
  SSplotSelex(s2.2,fleets=5:9,infotable=test2$infotable,subplot=1,legendloc='topright',showmain=FALSE)
  dev.off()
  
  #########################################################
  ### Sensitivity to model with more flexible selectivity and new triennial
  #########################################################
  sbase_Mac <- SS_output('C:/SS/Thornyheads/runs/SST_BASE_Mac')
  s2.2 <- SS_output('C:/ss/Thornyheads/runs/SST_2.2_pre-STAR_flex_selex')
  s2.11 <- SS_output('C:/ss/Thornyheads/runs/SST_2.11_flex_selex_newTri')

  s2.12 <- SS_output('C:/ss/Thornyheads/runs/SST_2.12_flex_selex_newTri_walkQ')
  sumtest <- SSsummarize(list(sbase,s2.2,s2.11))
  SSplotComparisons(sumtest,indexUncertainty=TRUE,indexfleets=rep(9,3),subplot=11,indexPlotEach=FALSE)

  sumtest <- SSsummarize(list(sbase,s2.2,s2.11,s2.12))
  SSplotComparisons(sumtest,indexUncertainty=TRUE,indexfleets=rep(5,4),indexPlotEach=TRUE)

  sumtest <- SSsummarize(list(s2.11,s2.12))
  SSplotComparisons(sumtest,indexUncertainty=TRUE,indexfleets=rep(5,2),indexPlotEach=TRUE)

  SSplotIndices(sbase,fleets=5,subplot=1,dat=TRUE,print=TRUE,pwidth=5,pheight=5)
  for(i in 5:9) SSplotIndices(sbase,fleets=i,subplot=1,dat=TRUE,print=TRUE,pwidth=5,pheight=5)
  SSplotIndices(s2.11,fleets=5,subplot=1,dat=TRUE,print=TRUE,pwidth=5,pheight=5)
  
  #########################################################
  ### Cumulative sensitvities
  #########################################################
  sbase_Mac <- SS_output('C:/SS/Thornyheads/runs/SST_BASE_Mac')
  s2.2 <- SS_output('C:/ss/Thornyheads/runs/SST_2.2_pre-STAR_flex_selex')
  s2.11 <- SS_output('C:/ss/Thornyheads/runs/SST_2.11_flex_selex_newTri')
  sumtest <- SSsummarize(list(sbase,sbase_Mac,s2.2,s2.11))
  SSplotComparisons(sumtest,indexUncertainty=TRUE,indexfleets=rep(9,4),subplot=11,indexPlotEach=FALSE)

  tab1 <-
    SStableComparisons(sumtest, models = "all",
                       likenames = c("TOTAL", "Survey", "Length_comp", "Discard", "mean_body_wt", "priors"), 
                       names = c("R0", "Q_calc", "SPB_Virg", "Bratio_2013", "SPRratio_2012"), 
                       digits = NULL, modelnames = "default", csv = FALSE, csvdir = "workingdirectory", 
                       csvfile = "parameter_comparison_table.csv", verbose = TRUE, 
                       mcmc = FALSE) 

  tab2 <- tab1
  names(tab2) <- c("Label", "Base", "Better likelihood", "+Better selectivity", "+Survey stratification")
  for(icol in 2:5){
    tab2[1:5,icol] <- tab2[1:5,icol] - tab2[1:5,2]
  }
  tab2[tab2$Label=="R0_billions",2:5] <- 1e3*tab2[tab2$Label=="R0_billions",2:5]
  tab2$Label[tab2$Label=="R0_billions"] <- "R0_millions"
  
  modnames <- c("Base", "Better likelihood", "+Better selectivity", "+Survey stratification")

  SSplotComparisons(sumtest,pheight=4.5,
                    legendlabels=modnames,legendloc='bottomleft',
                    png=TRUE,plotdir='../figs/comparisons_for_STAR')

  sumtest2 <- sumtest
  sumtest2$SpawnBioSD$"2" <- NA
  sumtest2$SpawnBioSD$"3" <- NA
  sumtest2$BratioSD$"2" <- NA
  sumtest2$BratioSD$"3" <- NA
  sumtest2$SpawnBioLower$"2" <- NA
  sumtest2$SpawnBioLower$"3" <- NA
  sumtest2$BratioLower$"2" <- NA
  sumtest2$BratioLower$"3" <- NA
  sumtest2$SpawnBioUpper$"2" <- NA
  sumtest2$SpawnBioUpper$"3" <- NA
  sumtest2$BratioUpper$"2" <- NA
  sumtest2$BratioUpper$"3" <- NA
  
  SSplotComparisons(sumtest2,pheight=4.5,models=c(1,4),pch=c(1,4),
                    legendlabels=modnames[c(1,4)],legendloc='bottomleft',uncertainty=c(TRUE,FALSE,FALSE,TRUE),
                    png=TRUE,plotdir='../figs/comparisons_for_STAR_uncertainty2')
  SSplotComparisons(sumtest2,pheight=4.5,models=c(1,4),pch=c(1,4),
                    legendlabels=modnames[c(1,4)],subplots=5:6,legendloc='topleft',uncertainty=c(TRUE,FALSE,FALSE,TRUE),
                    png=TRUE,plotdir='../figs/comparisons_for_STAR_uncertainty2')



  source("http://r4ss.googlecode.com/svn/branches/testing/make_multifig_Hoo.R")
  source("http://r4ss.googlecode.com/svn/branches/testing/SSplotComps_Hoo.R")


  # define colors
  col1 <- 4 # blue
  col2 <- rgb(1,0,0,.7) # red (partially transparent)

  # make plots and get aggregated comp data
  png('../figs/aggregated_comps_comparisons.png',width=7,height=5,pointsize=12,res=300,units='in')
  agg1 <- SSplotComps_Hoo(sbase,subplots=9,datonly=TRUE,fleetnames=fleets,
                          partitions=2,showsampsize=FALSE, showeffN=FALSE) # first one makes plot
  agg2 <- SSplotComps_Hoo(s2.11,partitions=2,subplots=9,plot=FALSE,print=FALSE) # just getting data

  # get vector of fleets
  (fleetnums <- unique(agg1$f))
  #[1]  1  2  3  4
  # loop over panels
  for(i in 1:length(fleetnums)){
    # choose which panel to write over
    if(i<=2){
      par(mfg=c(i,   1)) # first column
    }else{
      par(mfg=c(i-2, 2)) # second column
    }
    # add lines for 2nd model
    lines(agg1$bin[agg1$f==fleetnums[i]], agg1$exp[agg1$f==fleetnums[i]],
          col=col1, lwd=2)
    lines(agg2$bin[agg2$f==fleetnums[i]], agg2$exp[agg2$f==fleetnums[i]],
          col=col2, lwd=3)
  }
  dev.off()

  # make plots and get aggregated comp data
  png('../figs/aggregated_comps_comparisons_discards.png',width=7,height=5,pointsize=12,res=300,units='in')
  agg1 <- SSplotComps_Hoo(sbase,subplots=9,datonly=TRUE,fleetnames=fleets,
                          partitions=1,showsampsize=FALSE, showeffN=FALSE) # first one makes plot
  agg2 <- SSplotComps_Hoo(s2.11,partitions=1,subplots=9,plot=FALSE,print=FALSE) # just getting data

  # get vector of fleets
  (fleetnums <- unique(agg1$f))
  #[1]  1  2  3  4
  # loop over panels
  for(i in 1:length(fleetnums)){
    # choose which panel to write over
    if(i<=2){
      par(mfg=c(i,   1)) # first column
    }else{
      par(mfg=c(i-2, 2)) # second column
    }
    # add lines for 2nd model
    lines(agg1$bin[agg1$f==fleetnums[i]], agg1$exp[agg1$f==fleetnums[i]],
          col=col1, lwd=2)
    lines(agg2$bin[agg2$f==fleetnums[i]], agg2$exp[agg2$f==fleetnums[i]],
          col=col2, lwd=3)
  }
  dev.off()
  
  # make plots and get aggregated comp data
  png('../figs/aggregated_comps_comparisons_surveys.png',width=7,height=5,pointsize=12,res=300,units='in')
  agg1 <- SSplotComps_Hoo(sbase,subplots=9,datonly=TRUE,fleetnames=fleets,
                          partitions=0,sex_codes=1,
                          showsampsize=FALSE, showeffN=FALSE) # first one makes plot
  agg2 <- SSplotComps_Hoo(s2.11,subplots=9,partitions=0,sex_codes=1,plot=FALSE,print=FALSE) # just getting data

  # get vector of fleets
  (fleetnums <- unique(agg1$f))
  #[1]  1  2  3  4
  # loop over panels
  for(i in 1:length(fleetnums)){
    # choose which panel to write over
    if(i<=3){
      par(mfg=c(i,   1)) # first column
    }else{
      par(mfg=c(i-3, 2)) # second column
    }
    # add lines for 2nd model
    lines(agg1$bin[agg1$f==fleetnums[i]], agg1$exp[agg1$f==fleetnums[i]],
          col=col1, lwd=2)
    lines(agg2$bin[agg2$f==fleetnums[i]], agg2$exp[agg2$f==fleetnums[i]],
          col=col2, lwd=3)
  }
  dev.off()

  
  # add legend in bottom right
  par(mfg=c(3,2,3,2))
  plot(0,type='n',axes=FALSE,xlab="",ylab="")
  legend('center',lwd=2,col=c(col1, col2, col3),
         legend=c("Model 1","Model 2","Model 3"),bty='n')


}
