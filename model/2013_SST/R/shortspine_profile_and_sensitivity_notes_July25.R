if(FALSE){
  # august 19
  load("C:/SS/Thornyheads/runs/August8_2013.Rdata")

  
  setwd('C:/ss/thornyheads/runs/')
  sbase <- SS_output('SST_BASE_pre-STAR')


  s8.0 <- SS_output("SST_8.0_Thursday6pm")
  s8.1 <- SS_output("SST_8.1_no_outliers",covar=FALSE)
  s8.2 <- SS_output("SST_8.2_no_outliers_no_recon")
  s8.3 <- SS_output("SST_8.3_no_recon",covar=FALSE)

  
  #########################################################
  ### R0 profile
  #########################################################

  setwd('C:/ss/thornyheads/runs/')

  # vector of values to profile over
  R0.vec.up <- seq(10,12,.2)
  Nprof.R0.up <- length(R0.vec.up)

  R0.vec.up <- seq(10.3,12,.1)
  Nprof.R0.up <- length(R0.vec.up)
  
  R0.vec.down <- seq(10.3,8.8,-.1)
  Nprof.R0.down <- length(R0.vec.down)
  
  dir.R0prof.up <- "SST_base_profile.R0.up"
  dir.R0prof.up <- "SST_base10.0_profile.R0.up"
  dir.R0prof.down <- "SST_base10.0_profile.R0.down"

  #### UPWARD
  starter <- SS_readstarter(file.path(dir.R0prof.up, 'starter.ss'))
  # change control file name in the starter file
  starter$ctlfile <- "control_modified.ss"
  # make sure the prior likelihood is calculated
  # for non-estimated quantities
  starter$prior_like <- 1
  # write modified starter file
  SS_writestarter(starter, dir=dir.R0prof.up, overwrite=TRUE)
  # run SS_profile command

  # note! had to change phase of SelPar1 from 2 to 1
  setwd(dir.R0prof.up)
  profile <- SS_profile(dir=getwd(), # directory
                        model="ss3_opt_win64",
                        #model="ss3",
                        masterctlfile="control.ss_new",
                        newctlfile="control_modified.ss",
                        string="R0",
                        profilevec=R0.vec.up)


  #### DOWNWARD
  starter <- SS_readstarter(file.path(dir.R0prof.down, 'starter.ss'))
  # change control file name in the starter file
  starter$ctlfile <- "control_modified.ss"
  # make sure the prior likelihood is calculated
  # for non-estimated quantities
  starter$prior_like <- 1
  # write modified starter file
  SS_writestarter(starter, dir=dir.R0prof.down, overwrite=TRUE)
  # run SS_profile command

  # note! had to change phase of SelPar1 from 2 to 1
  setwd(dir.R0prof.down)
  profile <- SS_profile(dir=getwd(), # directory
                        model="ss3_opt_win64",
                        #model="ss3",
                        masterctlfile="control.ss_new",
                        newctlfile="control_modified.ss",
                        string="R0",
                        profilevec=R0.vec.down)

  for(i in 1:16){
    file.copy(file.path(dir.R0prof.down,paste("Report",i,".sso",sep="")),
              file.path("SST_base10.0_profile.R0.combined",paste("Report",18+i,".sso",sep="")))
    file.copy(file.path(dir.R0prof.down,paste("covar",i,".sso",sep="")),
              file.path("SST_base10.0_profile.R0.combined",paste("covar",18+i,".sso",sep="")))
    file.copy(file.path(dir.R0prof.down,paste("CompReport",i,".sso",sep="")),
              file.path("SST_base10.0_profile.R0.combined",paste("CompReport",18+i,".sso",sep="")))
  }

  
  prof.R0.models <- SSgetoutput(dirvec="SST_base10.0_profile.R0.combined",
                                keyvec=1:31)
  prof.R0.summary <- SSsummarize(prof.R0.models)

  # combo summary
  png(file.path("../figs/R0_profile_plot_SST_base_FINAL.png"),width=8,height=5.5,res=300,units='in')
  par(mar=c(5,4,1,1))
  SSplotProfile(prof.R0.summary,           # summary object
                profile.string = "R0", # substring of profile parameter
                profile.label=expression(log(italic(R)[0])),ymax=4.5,
                models=1:25,
                pheight=4.5,print=FALSE) # axis label
  baseval <- round(sbase$parameters$Value[grep("R0",sbase$parameters$Label)],2)
  abline(v=baseval,lty=2)
  abline(v=c(lowval,baseval,highval),lty=2)
  baselab <- paste(baseval,sep="")
  lowval <- round(low.mod$parameters$Value[grep("R0",low.mod$parameters$Label)],2)
  highval <- round(high.mod$parameters$Value[grep("R0",high.mod$parameters$Label)],2)
  axis(1,at=c(lowval,baseval,highval),label=c(lowval,baseval,highval))
  par(mgp=c(3,2,0))
  axis(1,at=c(lowval,baseval,highval),label=c("(low)","(base)","(high)"))
  par(mgp=c(3,1,0))
  dev.off()

  PinerPlot(prof.R0.summary,print=TRUE,pwidth=8,pheight=5.5,plotdir="../figs/FridayMorning/",
            fleetnames=fleets,
            models=1:25)
  PinerPlot(prof.R0.summary,print=TRUE,
            component="Surv_like",fleets=5:9,
            fleetnames=fleets,
            models=1:25,
            main="Changes in survey likelihoods by fleet",
            pwidth=8,pheight=5.5,plotdir="../figs/FridayMorning/")
  
  

  # read the output files (with names like Report1.sso, Report2.sso, etc.)
  setwd('C:/ss/thornyheads/runs/')
  dir.R0prof <- "SST_6.2_profile.R0"
  prof.R0.models <- SSgetoutput(dirvec=dir.R0prof, keyvec=1:Nprof.R0)
  # summarize output
  prof.R0.summary <- SSsummarize(prof.R0.models)

  #  sbase <- SS_output('SST_BASE_pre-STAR')
  #s2.11 <- SS_output('C:/ss/Thornyheads/runs/SST_2.11_flex_selex_newTri')
  ref <- s6.2
  prof.R0.models$MLE <- ref
  prof.R0.summary <- SSsummarize(prof.R0.models)
  # END OPTIONAL COMMANDS


  R0.vec2 <- c(10.3,seq(10.2,9,-.2))
  Nprof.R02 <- length(R0.vec2)

  dir.R0prof2 <- "SST_6.2e_profile.R0_downward"

  starter <- SS_readstarter(file.path(dir.R0prof2, 'starter.ss'))
  # change control file name in the starter file
  starter$ctlfile <- "control_modified.ss"
  # make sure the prior likelihood is calculated
  # for non-estimated quantities
  starter$prior_like <- 1
  # write modified starter file
  SS_writestarter(starter, dir=dir.R0prof2, overwrite=TRUE)
  # run SS_profile command
#  profile <- SS_profile(dir=dir.R0prof, # directory

  # note! had to change phase of SelPar1 from 2 to 1

  profile <- SS_profile(dir=getwd(), # directory
                        model="ss3_opt_win64",
                        #model="ss3",
                        masterctlfile="control.ss_new",
                        newctlfile="control_modified.ss",
                        string="R0",
                        profilevec=R0.vec2)

  prof.R0.models.up <- SSgetoutput(dirvec=dir.R0prof.up, keyvec=1:Nprof.R0.up)
  # 2nd to last down models didn't converge
  prof.R0.models.down <- SSgetoutput(dirvec=dir.R0prof.down, keyvec=1:(Nprof.R0.down-2))

  prof.R0.summary.up <- SSsummarize(prof.R0.models.up)
  prof.R0.summary.down <- SSsummarize(prof.R0.models.down)


  # UP summary
#  png(file.path(dir.R0prof,"R0_profile_plot_SST_6.2.png"),width=8,height=5.5,res=300,units='in')
  par(mar=c(5,4,1,1))
  SSplotProfile(prof.R0.summary.up,           # summary object
                profile.string = "R0", # substring of profile parameter
                profile.label=expression(log(italic(R)[0])),ymax=5,
                pheight=4.5,print=FALSE,plotdir=dir.R0prof.up) # axis label


  # DOWN summary
#  png(file.path(dir.R0prof,"R0_profile_plot_SST_6.2.png"),width=8,height=5.5,res=300,units='in')
  par(mar=c(5,4,1,1))
  SSplotProfile(prof.R0.summary.down,           # summary object
                profile.string = "R0", # substring of profile parameter
                profile.label=expression(log(italic(R)[0])),ymax=5,
                pheight=4.5,print=FALSE,plotdir=dir.R0prof.down) # axis label
  
  
  PinerPlot(prof.R0.summary3,print=TRUE,pwidth=8,pheight=5.5,plotdir=dir.R0prof)
  PinerPlot(prof.R0.summary3,print=TRUE,
            component="Surv_like",fleets=5:9,
            main="Changes in survey likelihoods by fleet",
            pwidth=8,pheight=5.5,plotdir=dir.R0prof)


  # make timeseries plots comparing models in profile
  labs <- paste("log(R0) =",R0.vec[c(1,3,5,7,9,11)])
  labs[3] <- paste("log(R0) =",baseval,"(Base model)")
  SSplotComparisons(prof.R0.summary,legendlabels=labs,
                    models=c(1,3,12,7,9,11),
                    pheight=4.5,png=TRUE,plotdir=dir.R0prof,legendloc='bottomleft')

  round(range(prof.R0.summary$quants[prof.R0.summary$quants$Label=="SPB_Virgin",1:11]))
  ## 42263 312282
  round(100*range(prof.R0.summary$quants[prof.R0.summary$quants$Label=="Bratio_2013",1:11]),1)
  ## 39.2 87.9

  prof.R0.summary <- SSsummarize(c(prof.R0.models[1:25],list(sbase)))

  # create vector of catchability values (just from fleet 9 = NWFSC Combo Survey)
  Qvec <- rep(NA,prof.R0.summary$n)
  for(i in 1:length(Qvec))
    Qvec[i] <- unique(prof.R0.summary$indices$Calc_Q[prof.R0.summary$indices$FleetNum==9 &
                                                     prof.R0.summary$indices$imodel==i])
  # add base model R0 estimate to vector of R0 values
  #R0.vec3 <- c(R0.vec3,baseval)
  # get vectors of depletion and B0 (base model is already at the end
  R0.vec <- as.numeric(prof.R0.summary$pars[grep("R0",prof.R0.summary$pars$Label),1:prof.R0.summary$n])
  deplvec <- as.numeric(prof.R0.summary$quants[prof.R0.summary$quants$Label=="Bratio_2013",1:prof.R0.summary$n])
  B0vec   <- as.numeric(prof.R0.summary$quants[prof.R0.summary$quants$Label=="SPB_Virgin",1:prof.R0.summary$n]/1e3)
  B2013vec   <- as.numeric(prof.R0.summary$quants[prof.R0.summary$quants$Label=="SPB_2013",1:prof.R0.summary$n])

  mods <- order(R0.vec)
  # make plot showing B0, depletion, and Q as a function of R0
  png(file.path("../figs/","R0_profile_dependencies_SST_FINAL.png"),width=7,height=9,res=300,units='in')
  par(mfrow=c(3,1),mar=c(1,4,1,1),oma=c(4,0,0,0),cex=.8)
  plot(R0.vec[mods],B0vec[mods],type='l',lwd=3,ylim=c(0,600),las=1,yaxs='i',xlim=c(9.7,11.5),
       xlab="",ylab=expression(paste(italic(B)[0]," (1000 mt)")))
  points(R0.vec[prof.R0.summary$n],B0vec[prof.R0.summary$n],pch=16,cex=2)
  abline(h=B0vec[prof.R0.summary$n],lty=3)
#  axis(2,at=round(B0vec[prof.R0.summary$n],2),las=1,padj=0)
  #axis(1,at=baseval,label=baselab)
  axis(1,at=c(lowval,baseval,highval),label=c(lowval,baseval,highval))
  #abline(v=baseval,lty=3,col='grey')
  abline(v=c(lowval,baseval,highval),lty=3)

  plot(R0.vec[mods],deplvec[mods],type='l',lwd=3,ylim=c(0,1),las=1,yaxs='i',xlim=c(9.7,11.5),
       xlab=expression(log(italic(R)[0])),ylab="Spawning depletion")
  points(R0.vec[prof.R0.summary$n],deplvec[prof.R0.summary$n],pch=16,cex=2)
  abline(h=deplvec[prof.R0.summary$n],lty=3)
  #axis(1,at=baseval,label=baselab)
  axis(1,at=c(lowval,baseval,highval),label=c(lowval,baseval,highval))
  #abline(v=baseval,lty=3,col='grey')
  abline(v=c(lowval,baseval,highval),lty=3)

  plot(R0.vec[mods],Qvec[mods],type='l',lwd=3,ylim=c(0,1.2),las=1,yaxs='i',xlim=c(9.7,11.5),
       xlab=expression(log(italic(R)[0])),ylab="Catchability of NWFSC Combo Survey")
  points(R0.vec[prof.R0.summary$n],Qvec[prof.R0.summary$n],pch=16,cex=2)
#  axis(1,at=baseval,label=baselab)
  axis(1,at=c(lowval,baseval,highval),label=c(lowval,baseval,highval))
  par(mgp=c(3,2,0))
  axis(1,at=c(lowval,baseval,highval),label=c("(low)","(base)","(high)"))
  par(mgp=c(3,1,0))
#  axis(2,at=round(Qvec[prof.R0.summary$n],2),las=1)
  abline(h=Qvec[prof.R0.summary$n],lty=3)
  abline(v=c(lowval,baseval,highval),lty=3)
  #abline(v=baseval,lty=3,col='grey')
  dev.off()


  #########################################################
  ### States of nature from spawning biomass and R0 profile
  #########################################################
  B2013.row <- sbase$derived_quants[sbase$derived_quants$LABEL=="SPB_2013",]
  ##        LABEL  Value  StdDev
  ## 533 SPB_2013 140753 66878.6
  B2013.val <- B2013.row$Value
  B2013.sd  <- B2013.row$StdDev
  B2013.low <- qnorm(p=0.125, mean=B2013.row$Value, sd=B2013.row$StdDev)
  ## [1] 63819.24
  B2013.sd/B2013.val
  ## [1] 0.4751487
  B2013.high2 <- qnorm(p=0.875, mean=B2013.row$Value, sd=B2013.row$StdDev)

  R0.vec3 <- prof.R0.summary$pars[grep("R0",prof.R0.summary$pars$Label),1:25]
  B2013vec <- prof.R0.summary$quants[grep("SPB_2013",prof.R0.summary$quants$Label),1:25]
  Likevec <- prof.R0.summary$likelihoods[1,1:25]

  low.mod <- SS_output("SST_base10.0_profile.R0.combined",repfile="Report25.sso",covarfile="covar25.sso",compfile="CompReport25.sso",forecast=FALSE)
  high.mod <- SS_output("SST_base10.0_profile.R0.combined",repfile="Report10.sso",covarfile="covar10.sso",compfile="CompReport10.sso",forecast=FALSE)

  
  mods <- order(R0.vec3)
  plot(as.numeric(R0.vec3[mods]),as.numeric(B2013vec[mods]),type='o',
       lwd=3,ylim=c(0,4e5),
       xlab=expression(log(italic(R)[0])),
       ylab="Spawning biomass in 2013",yaxs='i',axes=FALSE)
  #axis(1,at=seq(9.6,12,.2))
  axis(1,at=c(9.8,10.32,10.8),labels=c("9.8","10.33","10.8"))
  axis(2)
  box()
  abline(h=B2013.val,lty=2)
  abline(h=B2013.low,col=2,lty=2)
  abline(h=B2013.high2,col=4,lty=2)
  abline(v=10.32,lty=2)
  abline(v=9.8,col=2,lty=2)
  abline(v=10.8,col=4,lty=2)

  # visual examination indicates that model with R0=9.8 is close to value
  low.state <- prof.R0.models2[[4]]
  low.state$derived_quants[low.state$derived_quants$LABEL=="SPB_2013",]
  ##          LABEL Value  StdDev
  ## 539 SPB_2013 66195 3293.08

  low.state$likelihoods_used$values[1] - sbase$likelihoods_used$values[1]
  #[1] 2.2
  high.state <- prof.R0.models[[16]]
  high.state$parameters[grep("R0",high.state$parameters$Label),1:5]
  high.state$derived_quants[high.state$derived_quants$LABEL=="SPB_2013",]
  ##        LABEL  Value  StdDev
  ## 539 SPB_2013 963707 31342.2
  high.state2$derived_quants[high.state2$derived_quants$LABEL=="SPB_2013",]

  high.state2 <- prof.R0.models[[10]]
  high.state2$parameters[grep("R0",high.state2$parameters$Label),1:5]
  ##       Num     Label Value Active_Cnt Phase
  ## 140  27 SR_LN(R0)  10.8         NA    -1

  high.state$likelihoods_used$values[1] - sbase$likelihoods_used$values[1]
  #[1] 2.12
  high.state2$likelihoods_used$values[1] - sbase$likelihoods_used$values[1]
  #[1] 0.509

  SSplotComparisons(SSsummarize(list(sbase)),legend=FALSE,
                    plotdir=file.path('..',sbase$inputs$dir,'plots'))

#  SSplotComparisons(states,png=TRUE,

  sbase <- SS_output('SST_base10.2_new_init2/')
  low.mod.no.covar <- SS_output("SST_base10.0_profile.R0.combined",repfile="Report25.sso",covar=FALSE,compfile="CompReport25.sso",forecast=FALSE)
  high.mod.no.covar <- SS_output("SST_base10.0_profile.R0.combined",repfile="Report10.sso",covar=FALSE,compfile="CompReport10.sso",forecast=FALSE)
  states <- SSsummarize(list(low.mod.no.covar,sbase,high.mod.no.covar))
  # redoing low and high in their own folders
  low.mod2 <- SS_output("SST_low_state1")
  high.mod2 <- SS_output("SST_high_state1")
  states <- SSsummarize(list(sbase,low.mod2,high.mod2))

  states$SpawnBioUpper[,c(2,3)] <- states$SpawnBio[,c(2,3)]
  states$SpawnBioLower[,c(2,3)] <- states$SpawnBio[,c(2,3)]
  states$BratioUpper[,c(2,3)] <- states$Bratio[,c(2,3)]
  states$BratioLower[,c(2,3)] <- states$Bratio[,c(2,3)]
  states$SPRratioUpper[,c(2,3)] <- states$SPRratio[,c(2,3)]
  states$SPRratioLower[,c(2,3)] <- states$SPRratio[,c(2,3)]

  states$btargs <- rep(0.4,3)
  states$sprtargs <- rep(0.5,3)

  SSplotComparisons(states,pheight=4.5,pwidth=7,
                    legendlabels=c("Base","Low state","High state"),
                    #legendlabels=c("Base, log(R0)=10.32","Low state, log(R0)=9.7","High state, log(R0)=11.2"),
                    legendloc='bottomleft',legendorder=c(3,1,2),
                    densitynames=c("OFLCatch_2013"),
                    png=TRUE,plotdir='../figs/FridayMorning')

  SSplotComparisons(states,pheight=5,pwidth=7,subplot=14,
                    legendlabels=c("Base","Low state","High state"),
                    legendloc='topright',legendorder=c(3,1,2),
                    densitynames=c("OFLCatch_2013"),
                    densityxlabs=c("2013 OFL (x 1000 mt)"),
                    png=TRUE,plotdir='../figs/FridayMorning')

  #########################################################
  ### Forecasts for states of nature
  #########################################################
  basedat <- SS_readdat('SST_base_FINAL/SST_data.ss')

  ### landed catch
  basedat$catch[basedat$catch$year %in% 2011:2012,]
  ##       Trawl_N Trawl_S Non-trawl_N Non-trawl_S year seas
  ## 111   424.3   286.5        24.3       237.0 2011    1
  ## 112   380.5   322.5        35.7       155.1 2012    1
  apply(basedat$catch[basedat$catch$year %in% 2011:2012,1:4],2,mean)
  ##  Trawl_N     Trawl_S Non-trawl_N Non-trawl_S 
  ## 402.40      304.50       30.00      196.05 

  ### dead catch
  sbase$timeseries[sbase$timeseries$Yr%in%2011:2012,grep("dead(B)",names(sbase$timeseries),fixed=TRUE)]
  ##        dead(B):_1 dead(B):_2 dead(B):_3 dead(B):_4
  ## 2927    427.238    289.043    26.3897    250.870
  ## 2928    383.121    325.341    38.7680    164.146
  round(apply(sbase$timeseries[sbase$timeseries$Yr%in%2011:2012,grep("dead(B)",names(sbase$timeseries),fixed=TRUE)],2,mean),1)
  ## dead(B):_1 dead(B):_2 dead(B):_3 dead(B):_4 
  ##      405.2      307.2       32.6      207.5 
  base.Bratio_2013 <- sbase$derived_quants$Value[sbase$derived_quants$LABEL=="Bratio_2013"]
  base.Bratio_2013_SD <- sbase$derived_quants$StdDev[sbase$derived_quants$LABEL=="Bratio_2013"]
  base.SPB_2013 <- sbase$derived_quants$Value[sbase$derived_quants$LABEL=="SPB_2013"]
  base.SPB_2013_SD <- sbase$derived_quants$StdDev[sbase$derived_quants$LABEL=="SPB_2013"]
  (sig <- base.SPB_2013_SD/base.SPB_2013)
  ## [1] 0.4751487  
  qlnorm(0.45, 0, sig)
  ## [1] 0.9420397
  (sig2 <- sqrt(log((base.SPB_2013_SD/base.SPB_2013)^2+1)))
  ## [1] 0.4511831
  # confirming that this is the same
  (sqrt(log((sig)^2+1)))
  ## [1] 0.4511831
  base.SPB_2013
  ## [1] 140753  
  round(qnorm(c(0.025, 0.975), base.SPB_2013, base.SPB_2013_SD),0)
  ## [1]   9673 271833
  qlnorm(0.45, 0, sig2)
  ## [1] 0.944881
  
  fore.base <- SS_readforecast("forecasts/SST_base_SPR_0.5/forecast.ss",
                              Nfleets=4,Nareas=1)
  fore.fixed <- fore.base
  fixed2013 <- fore.base$ForeCatch[fore.base$ForeCatch$Year==2013,]
  for(y in 2015:2024){
    newcat <- fixed2013
    newcat$Year <- y
    fore.fixed$ForeCatch <- rbind(fore.fixed$ForeCatch, newcat)
  }
  fore.fixed$Ncatch <- nrow(fore.fixed$ForeCatch)
  SS_writeforecast(fore.fixed,
                   dir="forecasts/SST_base_Average_catch",overwrite=TRUE)

  setwd('C:/ss/thornyheads/runs/')
  fore.base.SPR <- SS_output("forecasts/SST_base_SPR_0.5",covar=FALSE)
  fore.base.Ave <- SS_output("forecasts/SST_base_Average_catch",covar=FALSE)
  fore.base.SPR.65long <- SS_output("forecasts/SST_base_SPR_0.65_long",covar=FALSE)
  fore.base.SPR.6long <- SS_output("forecasts/SST_base_SPR_0.6_long",covar=FALSE)
  fore.base.SPR.5long <- SS_output("forecasts/SST_base_SPR_0.5_long",covar=FALSE)
  fore.base.SPR.65 <- SS_output("forecasts/SST_base_SPR_0.65",covar=FALSE)
  fore.base.SPR.5  <- SS_output("forecasts/SST_base_SPR_0.5",covar=FALSE)

  # get catch timeseries from base model alternative catch streams
  file.copy("forecasts/SST_base_Average_catch/forecast.ss",
            "forecasts/SST_low_state_Average_catch/forecast.ss",overwrite=TRUE)
  file.copy("forecasts/SST_base_Average_catch/forecast.ss",
            "forecasts/SST_high_state_Average_catch/forecast.ss",overwrite=TRUE)
  fore.fixed <- SS_readforecast("forecasts/SST_base_Average_catch/forecast.ss",
                                Nfleets=4,Nareas=1)
  base.catch.by.fleet.65 <- fore.base.SPR.65
  fore.fixed.65.catch <-
    data.frame(yr=2013:2024,
               fore.base.SPR.65$timeseries[fore.base.SPR.65$timeseries$Yr %in% 2013:2024,
                                           grep("dead(B)",
                                                names(fore.base.SPR.65$timeseries),
                                                fixed=TRUE)])
  fore.fixed.5.catch <-
    data.frame(yr=2013:2024,
               fore.base.SPR.5$timeseries[fore.base.SPR.5$timeseries$Yr %in% 2013:2024,
                                          grep("dead(B)",
                                               names(fore.base.SPR.5$timeseries),
                                               fixed=TRUE)])

  fore.fixed.65 <- fore.fixed.5 <- fore.fixed
  # set fixed catch for SPR = 65% forecasts
  for(f in 1:4){
    fore.fixed.65$ForeCatch$Catch_or_F[fore.fixed.65$ForeCatch$Fleet==f] <-
      round(fore.fixed.65.catch[[paste("dead.B.._",f,sep="")]],1)
  }
  # set fixed catch for SPR = 50% forecasts
  for(f in 1:4){
    fore.fixed.5$ForeCatch$Catch_or_F[fore.fixed.5$ForeCatch$Fleet==f] <-
      round(fore.fixed.5.catch[[paste("dead.B.._",f,sep="")]])
  }

  # write revised forecast files with fixed catches
  SS_writeforecast(fore.fixed.5,
                   dir="forecasts/SST_high_state_SPR_0.5_catch",overwrite=TRUE)
  SS_writeforecast(fore.fixed.5,
                   dir="forecasts/SST_low_state_SPR_0.5_catch",overwrite=TRUE)
  
  SS_writeforecast(fore.fixed.65,
                   dir="forecasts/SST_high_state_SPR_0.65_catch",overwrite=TRUE)
  SS_writeforecast(fore.fixed.65,
                   dir="forecasts/SST_low_state_SPR_0.65_catch",overwrite=TRUE)

  # read model output
  fore.low.Ave    <- SS_output("forecasts/SST_low_state_Average_catch",covar=FALSE)
  fore.low.SPR.65 <- SS_output("forecasts/SST_low_state_SPR_0.65_catch",covar=FALSE)
  fore.low.SPR.5  <- SS_output("forecasts/SST_low_state_SPR_0.5_catch",covar=FALSE)

  fore.high.Ave    <- SS_output("forecasts/SST_high_state_Average_catch",covar=FALSE)
  fore.high.SPR.65 <- SS_output("forecasts/SST_high_state_SPR_0.65_catch",covar=FALSE)
  fore.high.SPR.5  <- SS_output("forecasts/SST_high_state_SPR_0.5_catch",covar=FALSE)

  # confirm matching catch series:
  cbind(2012:2024,
        round(tail(apply(fore.base.Ave$timeseries[,grep("dead(B)",names(fore.base.Ave$timeseries),fixed=TRUE)],1,sum),13)),
        round(tail(apply(fore.low.Ave$timeseries[,grep("dead(B)",names(fore.low.Ave$timeseries),fixed=TRUE)],1,sum),13)),
        round(tail(apply(fore.high.Ave$timeseries[,grep("dead(B)",names(fore.high.Ave$timeseries),fixed=TRUE)],1,sum),13)))
  ##      [,1] [,2] [,3] [,4]
  ## 2932 2012  911  911  911
  ## 2933 2013  952  952  952
  ## 2934 2014  952  952  952
  ## 2935 2015  952  952  952
  ## 2936 2016  952  952  952
  ## 2937 2017  952  952  952
  ## 2938 2018  952  952  952
  ## 2939 2019  952  952  952
  ## 2940 2020  952  952  952
  ## 2941 2021  952  952  952
  ## 2942 2022  952  952  952
  ## 2943 2023  952  952  952
  ## 2944 2024  952  952  952
  cbind(2012:2024,
        round(tail(apply(fore.base.SPR.65$timeseries[,grep("dead(B)",names(fore.base.SPR.65$timeseries),fixed=TRUE)],1,sum),13)),
        round(tail(apply(fore.low.SPR.65$timeseries[,grep("dead(B)",names(fore.low.SPR.65$timeseries),fixed=TRUE)],1,sum),13)),
        round(tail(apply(fore.high.SPR.65$timeseries[,grep("dead(B)",names(fore.high.SPR.65$timeseries),fixed=TRUE)],1,sum),13)))
  ##      [,1] [,2] [,3] [,4]
  ## 2929 2012  911  911  911
  ## 2930 2013  952  952  952
  ## 2931 2014  952  952  952
  ## 2932 2015 1828 1828 1828
  ## 2933 2016 1819 1819 1819
  ## 2934 2017 1812 1812 1812
  ## 2935 2018 1804 1804 1804
  ## 2936 2019 1797 1797 1797
  ## 2937 2020 1790 1790 1790
  ## 2938 2021 1784 1784 1784
  ## 2939 2022 1778 1778 1778
  ## 2940 2023 1773 1773 1773
  ## 2941 2024 1768 1768 1768
  cbind(2012:2024,
        round(tail(apply(fore.base.SPR.5$timeseries[,grep("dead(B)",names(fore.base.SPR.5$timeseries),fixed=TRUE)],1,sum),13)),
        round(tail(apply(fore.low.SPR.5$timeseries[,grep("dead(B)",names(fore.low.SPR.5$timeseries),fixed=TRUE)],1,sum),13)),
        round(tail(apply(fore.high.SPR.5$timeseries[,grep("dead(B)",names(fore.high.SPR.5$timeseries),fixed=TRUE)],1,sum),13)))
  ##      [,1] [,2] [,3] [,4]
  ## 2929 2012  911  911  911
  ## 2930 2013  952  953  953
  ## 2931 2014  952  953  953
  ## 2932 2015 3017 3016 3016
  ## 2933 2016 2983 2984 2984
  ## 2934 2017 2950 2950 2950
  ## 2935 2018 2918 2919 2919
  ## 2936 2019 2887 2887 2887
  ## 2937 2020 2857 2856 2856
  ## 2938 2021 2828 2828 2828
  ## 2939 2022 2800 2800 2800
  ## 2940 2023 2774 2774 2774
  ## 2941 2024 2748 2748 2748

  get.decision.stuff <- function(replist,nyrs=12){
    # a function to return catch, year, spawning biomass, and depletion
    # for forecast period.
    # note: catch is total dead catch, not retained catch
    data.frame(catch = round(tail(apply(replist$timeseries[,grep("dead(B)",
                 names(replist$timeseries),fixed=TRUE)],1,sum),nyrs),0),
               year = tail(replist$timeseries$Yr,nyrs),
               SpawnBioThousands = round(tail(replist$timeseries$SpawnBio,nyrs)/1e3,1),
               depl = round(tail(replist$timeseries$SpawnBio,nyrs)/replist$timeseries$SpawnBio[1],3))
  }
  big.table.low <- rbind(get.decision.stuff(fore.low.Ave),
                         get.decision.stuff(fore.low.SPR.65),
                         get.decision.stuff(fore.low.SPR.5))
  big.table.base <- rbind(get.decision.stuff(fore.base.Ave),
                          get.decision.stuff(fore.base.SPR.65),
                          get.decision.stuff(fore.base.SPR.5))
  big.table.high <- rbind(get.decision.stuff(fore.high.Ave),
                          get.decision.stuff(fore.high.SPR.65),
                          get.decision.stuff(fore.high.SPR.5))
  big.table <- data.frame(big.table.low,
                          big.table.base,
                          big.table.high)
  write.csv(big.table, "forecasts/SST_decision_table_inputs.csv")

  # table for exec summary
  cbind(tail(apply(fore.base.SPR$timeseries[,grep("dead(B)",names(fore.base.SPR$timeseries),fixed=TRUE)],1,sum),12),
        tail(apply(fore.base.SPR$timeseries[,grep("retain(B)",names(fore.base.SPR$timeseries),fixed=TRUE)],1,sum),12))
  
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


  # post-STAR with jitter
  mydir <- "C:/SS/Thornyheads/runs/SST_base_retro"
  like <- matrix(NA,nrow=21,ncol=5)
  for(j in 1:5){
    setwd(mydir);
    setwd(paste("retro-",j,sep=""))
    for(i in c(1:20,0)){
      cat('i =',i,'j =',j,'\n')
      lines <- readLines(paste("Report",i,".sso",sep=""),n=100)
      i2 <- i
      if(i==0) i2 <- 21
      tmp <- as.numeric(substring(lines[grep("Component logL*Lambda Lambda",lines,fixed=TRUE)-1],11))
      print(tmp)
      like[i2,j] <- tmp
    }
  }
  apply(like,2,function(x){min(which(x==min(x)))})
  ##[1]  1  2  8 20  7
  setwd(mydir);
  retro1 <- SS_output('retro-1',repfile="Report1.sso",compfile='test',NoCompOK=TRUE,covar=FALSE)
  retro2 <- SS_output('retro-2',repfile="Report0.sso",compfile='test',NoCompOK=TRUE,covar=FALSE)
  retro3 <- SS_output('retro-3',repfile="Report0.sso",compfile='test',NoCompOK=TRUE,covar=FALSE)
  retro4 <- SS_output('retro-4',repfile="Report0.sso",compfile='test',NoCompOK=TRUE,covar=FALSE)
  retro5 <- SS_output('retro-5',repfile="Report0.sso",compfile='test',NoCompOK=TRUE,covar=FALSE)

  retroSummary <- SSsummarize(list(sbase,retro1,retro2,retro3,retro4,retro5))
  retroSummary$SpawnBio[[3]] <- retro2$timeseries$SpawnBio
  retroSummary$SpawnBio[[4]] <- retro3$timeseries$SpawnBio
  retroSummary$SpawnBio[[5]] <- retro4$timeseries$SpawnBio
  retroSummary$SpawnBio[[6]] <- retro5$timeseries$SpawnBio

  for(i in 2:6){
    retroSummary$SpawnBioUpper[[i]] <- retroSummary$SpawnBio[[i]]
    retroSummary$SpawnBioLower[[i]] <- retroSummary$SpawnBio[[i]]
  }

  
  endyrvec <- retroSummary$endyrs + 0:-5
  namevec <- c("Base model (2013)",paste("Retro -",1:5," (",2012:2008,")",sep=""))
  SSplotComparisons(retroSummary, endyrvec=endyrvec,uncertainty=TRUE,
                    legendlabels=namevec,staggerpoints=-1,spacepoints=11,
                    legendncol=2,
                    pheight=4.8,pwidth=7.5,plot=FALSE,png=TRUE,plotdir=mydir,legendloc='bottomleft',
                    indexfleets=9,indexUncertainty=TRUE,indexQlabel=TRUE)

  SSplotComparisons(retroSummary, endyrvec=endyrvec,uncertainty=TRUE,
                    legendlabels=namevec,staggerpoints=-1,spacepoints=11,
                    pheight=4.5,plot=FALSE,png=TRUE,plotdir=mydir,legend=FALSE,
                    indexfleets=5,indexUncertainty=TRUE,subplot=11:12)
  
  #########################################################
  ### steepness profile
  #########################################################
  # vector of values to profile over
  h.vec <- seq(0.3,0.9,.1)
  Nprofile <- length(h.vec)

  setwd('C:/ss/thornyheads/runs/')
  mydir <- "SST_base_FINAL_profile.h"
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
                        model="ss3_opt_win64",
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
  labs <- c(paste("h =",h.vec[c(4,2,6)]))
  labs[1] <- paste(labs[1],"(base model)")
  SSplotComparisons(prof.h.summary,legendlabels=labs,
                    models=c(4,2,6),legendorder=c(3,1,2),
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

  mydir <- "SST_base_FINAL_profile.M"

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
                        masterctlfile="control_master_base_FINAL.ss",
                        newctlfile="control_modified.ss",
                        string="NatM_p_1_Fem",
                        profilevec=M.vec)


  # read the output files (with names like Report1.sso, Report2.sso, etc.)
  setwd('C:/ss/thornyheads/runs/')
  prof.M.models <- SSgetoutput(dirvec=mydir, keyvec=1:Nprofile, getcovar=FALSE, getcomp=FALSE)
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
                models=1:5,
                legendloc='topleft',
                pheight=4.5,print=TRUE,plotdir=mydir) # axis label

  prof.M.models2 <- SSgetoutput(dirvec=mydir, keyvec=c(3,5))
  # make timeseries plots comparing models in profile
  SSplotComparisons(SSsummarize(list(sbase,prof.M.models2[[1]],prof.M.models2[[2]])),
                    legendlabels=c("Base (M = 0.0505)", paste("M =",M.vec[c(3,5)])),
                    pheight=4.5,png=TRUE,legendorder=c(2,1,3),
                    plotdir=mydir,legendloc='bottomleft')

  round(range(prof.M.summary$quants[prof.M.summary$quants$Label=="SPB_Virgin",1:7]))
  ## [1]  86164 375008
  round(100*range(prof.M.summary$quants[prof.M.summary$quants$Label=="Bratio_2013",1:7]),1)
  ## [1] 39.8 87.5

  #########################################################
  ### Lmax profile
  #########################################################

  setwd('C:/ss/thornyheads/runs/')
 
  # vector of values to profile over
  Lmax.vec <- seq(65,85,5)
  Nprofile <- length(Lmax.vec)

  mydir <- "SST_base_FINAL_profile.Lmax"

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
                        masterctlfile="control_master_base_FINAL.ss",
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
  ### Sensitivities to alternative sigmaR or no recdevs
  #########################################################
  sigR.0 <- SS_output('SST_base_FINAL_4_sens_nodevs')
  sigR.25 <- SS_output('SST_base_FINAL_5_sens_sigmaR_0.25')
  sigR.75 <- SS_output('SST_base_FINAL_6_sens_sigmaR_0.75')

  sigR.summary <- SSsummarize(list(sbase,sigR.0,sigR.25,sigR.75))
  SSplotComparisons(sigR.summary,legendlabels=c("Base model (sigmaR = 0.5)",
                                   "No recruitment deviations (sigmaR = 0)",
                                   "Lower recruitment variability (sigmaR = 0.25)",
                                   "Higher recruitment variability (sigmaR = 0.75)"),
                    pheight=4.5,png=TRUE,plotdir='SST_base_FINAL_4_sens_nodevs',
                    legendloc='bottomleft')

  
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

  mat.middle <- SS_output("SST_base_FINAL_2_sens_maturity",covar=FALSE,forecast=FALSE)
  mat.crazy <- SS_output("SST_base_FINAL_3_sens_maturity_crazy",covar=FALSE,forecast=FALSE)
  mat.summary <- SSsummarize(list(sbase,mat.middle,mat.crazy))
  #dir.create('../figs/SST_maturity_sensitivity')
  SSplotComparisons(mat.summary, png=TRUE, plotdir='../figs/SST_maturity_sensitivity',
                    pheight=4.5,pwidth=7,legendloc='bottomleft',
                    legendlabels=c("Base model","Sensitivity 1","Sensitivity 2"))

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
