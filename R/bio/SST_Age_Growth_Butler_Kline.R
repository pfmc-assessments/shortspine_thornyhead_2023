#Shortspine Thornyhead
#Age and Growth information
#Data source: Donna Skaggs-Kline for Kline 1996 and Butler et al 1995 data
#description: 
  # Data provided by Donna Skaggs-Kline, Masters thesis, Moss Landing Marine Labs, California
  # Documentation: 
      #Kline 1996 (no sex data); central California 1991 
      #Butler et al. 1995 (sex information available); John Butler study, SWFSC retired; Oregon and northern California 1978-87, 1988, 1990 (missing some data from this study)  

      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # 1. set-up workspace----
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #clears all previous variables and functions
      rm(list=ls(all=TRUE)) 
      
      #packages
      library("plyr")
      library("ggplot2")
      
      #set working directory
      #setwd("C:/Users/Sabrina/Documents/2023 Applied Stock Assessments/Shortspine Thornyhead/SST.Life.History/Donna Kline SST Age Data")

     dirData <- file.path(getwd(), "data/Age Data")
     dirPlots <- file.path(dirData, "plots") #use this with ggsave
     if(!dir.exists(dirPlots))  #creates a file if not already there
       dir.create(dirPlots)
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # 2. Load data----
      #~~~~~~~~~~~~~~~~~~~~~~~~~~
      Butler.SST.dat <-read.csv(file.path(dirData, "Original NMFS S. alascanus data_1991_formatted.csv")) 
      Kline.SST.dat  <-read.csv(file.path(dirData, "S. alascanus_Kline 1996_formatted.csv"))

      # Check the data
      names(Butler.SST.dat)
      dim(Butler.SST.dat)
      names(Kline.SST.dat)
      dim(Kline.SST.dat)
      
      # append dataframes that have some common and some different columns
      SST.dat<- rbind.fill(Butler.SST.dat,Kline.SST.dat)
      
      names(SST.dat)
      dim(SST.dat)
      
      
      # Modify data
      
        #Which age to use in the analysis?
        SST.dat$Age_for_analysis <- NA  #create a new column
        #Butler et al. 1995
        SST.dat[SST.dat$Data_source=="Butler et al. 1995",]$Age_for_analysis <- SST.dat[SST.dat$Data_source=="Butler et al. 1995",]$mean_AGE_AR_JB #Butler study used the mean age of readers AR and JB
        #Kline 1996
        SST.dat[SST.dat$Data_source=="Kline 1996",]$Age_for_analysis         <- SST.dat[SST.dat$Data_source=="Kline 1996",]$AGE_2nd_read           #Kline 1996 used the 2nd age read in the analysis
      
        #rename columns
        SST.dat$length_mm <-SST.dat$LEN_mm
        SST.dat$weight_g  <-SST.dat$WT_g
        SST.dat$age       <-SST.dat$Age_for_analysis
        SST.dat$sex       <-SST.dat$SEX
        
        #clean up "sex" column
        SST.dat[SST.dat$sex=="",]$sex  <- "U" #label U for unknown
        SST.dat[SST.dat$sex=="M",c("Data_source","SPECIMEN")] #likely error input; no fish from Kline 1996 were sexed
        SST.dat[SST.dat$sex=="F",c("Data_source","SPECIMEN")] #likely error input; no fish from Kline 1996 were sexed
          SST.dat[SST.dat$sex=="M",]$sex  <- "U" #label U for unknown
          SST.dat[SST.dat$sex=="F",]$sex  <- "U" #label U for unknown
        unique(SST.dat$sex)
        
        
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
      # 3. Weight-length parameters for Butler et al. 1995----
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #From "W_L_code_example_expanded.r" in class
      #note, Kline 1996 does NOT have weight data
      
      #rename data
      wl <- SST.dat
      
      names(wl)
      str(wl)
      
      #format
     # wl$length_mm <-as.numeric(wl$length_mm)
     # wl$weight_g  <-as.numeric(wl$weight_g)
      
      #subset data that has both length and fish_weight_g information
      wl <- wl[!is.na(wl$length_mm) & !is.na(wl$weight_g),]
      wl <- wl[wl$weight_g>0,]
  
      # subset based on sex
      unique(wl$sex)
      wlF <- wl[wl$sex=="2",]    
      wlM <- wl[wl$sex=="1",]
      wlB <- wl[wl$sex%in%c("2","1"),]
      #wlU <- wl[wl$sex=="U",] #note, not neede since there are no unsexed fish in Butler et al. 1995
      
      #What about unsexed fish?
        #note, no unsexed fish in Butler et al. 1995
      
      #visualize
      hist(wlB$length_mm, breaks=20)
      
      # apply linear models in log-log space
      lmF <- lm(log(weight_g)~log(length_mm),data=wlF)
      lmM <- lm(log(weight_g)~log(length_mm),data=wlM)
      lmB <- lm(log(weight_g)~log(length_mm),data=wlB)
      
      # get output, including correction for median vs. mean in lognormal distribution
      getline <- function(model){
        Amed <- exp(model$coefficients[1])
        B <- model$coefficients[2]
        sdres <- sd(model$residuals)
        Amean <- Amed*exp(0.5*sdres^2)
        return(as.numeric(c(Amed,sdres,Amean,B)))
      }
      
      # get parameter values for each model
      resultsF <- getline(lmF)
      resultsM <- getline(lmM)
      resultsB <- getline(lmB)
      
      # make table of all models
      results <- data.frame(rbind(resultsF,resultsM,resultsB))
      names(results) <- c("median_intercept","SD_resids","A","B")
      print(results)
      
      #        median_intercept   SD_resids            A        B
      #resultsF     1.954448e-06 0.09248597 1.962824e-06 3.314758
      #resultsM     2.594882e-06 0.09509090 2.606640e-06 3.267368
      #resultsB     2.196060e-06 0.09402127 2.205788e-06 3.295315
      
      #Real space view of data and fits
      # make empty plot
      plot(wlB$length_mm, wlB$weight_g,type='n',las=1,
           xlab="Length (mm)", ylab="Weight(g)",ylim=c(0,1.1*max(wlF$weight_g))) 
      # add line at 0
      abline(h=0,col='grey',lty=3)
      # add points
      #points(wlF$weight_g~wlF$length_mm,pch=16,col=rgb(1,0,0,.1))
      #points(wlM$weight_g~wlM$length_mm,pch=16,col=rgb(0,0,1,.1))
      points(wlB$weight_g~wlB$length_mm,pch=16,
             col=ifelse(wlB$sex=="2",rgb(1,0,0,.1),rgb(0,0,1,.1)))
      
      # get sequences of x-values spanning range of data for females and males
      xF <- seq(min(wlF$length_mm),max(wlF$length_mm),length=200) 
      xM <- seq(min(wlM$length_mm),max(wlM$length_mm),length=200) 
      # add lines to plot
      lines(xF,results$A[1]*xF^results$B[1],col=rgb(1,0,0,0.5),lwd=5)
      lines(xM,results$A[2]*xM^results$B[2],col=rgb(0,0,1,0.5),lwd=5)
      legend("topleft", bty="n", legend = c("Females", "Males"), pch=19, col=c(rgb(1,0,0,.1),rgb(0,0,1,.1)))
      
      #log-log view of data and fit
      # make empty plot
      plot(log(wlB$length_mm), log(wlB$weight_g),type='n',las=1,  
           xlab="log Length (mm)", ylab="log weight (g)")
      # add line at 0
      #abline(h=0,col='grey',lty=3)
      # add points
      #points(wlF$weight_g~wlF$length_mm,pch=16,col=rgb(1,0,0,.1))
      #points(wlM$weight_g~wlM$length_mm,pch=16,col=rgb(0,0,1,.1))
      points(log(wlB$weight_g)~log(wlB$length_mm),pch=16,
             col=ifelse(wlB$sex=="2",rgb(1,0,0,.1),rgb(0,0,1,.1)))
      abline(log(results$median_intercept[1]),results$B[1],col=rgb(1,0,0,0.5),lwd=5)
      abline(log(results$median_intercept[2]),results$B[2],col=rgb(0,0,1,0.5),lwd=5)
      legend("topleft", bty="n", legend = c("Females", "Males"), pch=19, col=c(rgb(1,0,0,.1),rgb(0,0,1,.1)))
      
      
      #~~~~~~~~~~~~~~~~~~~~~~~  
      # 4. Growth----
      #~~~~~~~~~~~~~~~~~~~~~~~
      #lecture W03_growth.pdf
      #from W03_growth.R
      
      ##packages needed
      #library(ggplot2)
      library(magrittr)
      theme_set(theme_classic(base_size = 16))
      
      #select data
      fish.bio <- SST.dat

      #~~~~~~~~~~~~~~~~~~~~~~~
      ###Unsexed fish?----
    
      #Kline 1996 all fish unsexed
      #Because growth appears different between males and females, it is not recommended to randomly split these adult fish
      #~~~~~~~~~~~~~~~~~~~~~~
      
      #subset only fish with age and length data
        #fish.bio2.ages <- fish.bio2[!is.na(fish.bio2$Age),]
        fish.bio2.ages <- fish.bio[!is.na(fish.bio$age),]
        fish.bio2.ages <- fish.bio2.ages[!is.na(fish.bio2.ages$length_mm),]

        #switch length to cm
        fish.bio2.ages$length_cm<-fish.bio2.ages$length_mm/10
        
        #length range
        range(fish.bio2.ages$length_cm)
        
        #age range
        range(fish.bio2.ages$age)
        
        #unique sexes
        unique(fish.bio2.ages$sex) #U are Kline 1996 unsexed fish
        fish.bio2.ages$sex <- factor(fish.bio2.ages$sex) #set as factor
        
        #Visualize
        #growth_scatter, fig.show='hide'   
        ggplot(fish.bio2.ages) +
          geom_point(aes(x = age, y = length_cm, col = sex),
                     alpha = 0.25 ) + 
          scale_color_manual(values = c('1' = 'blue', '2' = 'red', 'U' = 'green')) +
          NULL
        
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ###VBGF fit----
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
      vbgf.nls <- nls(length_cm ~ linf[sex]*(1-exp(-k[sex]*(age-t0[sex]))), 
                      data = fish.bio2.ages, 
                      start = list(linf = rep(74,3),    #change reps to 2 if 2 sexes
                                   k    = rep(0.01,3),  #change reps to 2 if 2 sexes
                                   t0   = rep(10,3)))   #change reps to 2 if 2 sexes
      
      summary(vbgf.nls)
      
      #check for high correlation among estimated parameters (don't want!)
      summary(vbgf.nls, cor=TRUE)$correlation %>%
        round(2)
      
      nls1.m <- coef(vbgf.nls)[c(1,4,7)] #males=1
      nls1.f <- coef(vbgf.nls)[c(2,5,8)] #females=2
      nls1.U <- coef(vbgf.nls)[c(3,6,9)] #unknown=U
      
      ###VBGF plot----
      ggplot(fish.bio2.ages) +
        geom_point(aes(x = age, y = length_cm, col = sex), alpha = 0.25) +
        geom_line( aes(x = age, y = nls1.m[1] * (1-exp(-nls1.m[2]*(age-nls1.m[3]))), linetype='normal'), col = 'blue') +
        geom_line( aes(x = age, y = nls1.f[1] * (1-exp(-nls1.f[2]*(age-nls1.f[3]))), linetype='normal'), col = 'red') +
        geom_line( aes(x = age, y = nls1.U[1] * (1-exp(-nls1.U[2]*(age-nls1.U[3]))), linetype='normal'), col = 'green') +
        scale_color_manual(values = c('1' = 'blue', '2' = 'red', 'U' = 'green')) +
        NULL
      
      #save last plot
      ggsave("SST.VBGF.Kline.Butler.png", plot = last_plot(),width=6, height= 4,path=getwd())
      

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ###Schnute re-parameterization----
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      unique(fish.bio2.ages$sex) #categories modeled
      
      #choose a_1 = 2 and a_2 = 100
      
      vbgf.nls2 <- nls(length_cm ~ la1[sex] + (la2[sex] - la1[sex]) * 
                         (1-exp(-k[sex]*(age-1))) / 
                         (1-exp(-k[sex]*99)), 
                       data = fish.bio2.ages, 
                       start = list(la1 = rep(7,3),     #rep 2 for 2 sexes
                                    la2 = rep(75,3),    #rep 2 for 2 sexes
                                    k   = rep(0.01,3))) #rep 2 for 2 sexes
      
      
      summary(vbgf.nls2)
      
      #check for high correlation among estimated parameters (don't want!)
      summary(vbgf.nls2, cor=TRUE)$correlation %>%
        round(2)
      
      ###check residuals----
      plot(fitted(vbgf.nls2), resid(vbgf.nls2))
      abline(h=0)
      #don't want "fanning"
      #if there is fanning-transform the data
      
      #~~~~~~~~~~~~~~~~~~~~~~~~
      ###Lognormal errors----
      #~~~~~~~~~~~~~~~~~~~~~~~~
      #write own likelihood function for bias correction (back transform to mean instead of median)
      
      ###NLL function----
      vbgf.loglik <- function(log.pars, dat.m, dat.f, dat.U, a1, a2) {
        pars <- exp(log.pars)
        
        l.pred.m <- pars['la1.m'] + (pars['la2.m'] - pars['la1.m']) * 
          (1-exp(-pars['k.m']*(dat.m$age - a1))) / 
          (1-exp(-pars['k.m']*(a2-a1)))
        
        l.pred.f <- pars['la1.f'] + (pars['la2.f'] - pars['la1.f']) * 
          (1-exp(-pars['k.f']*(dat.f$age - a1))) / 
          (1-exp(-pars['k.f']*(a2-a1)))
        
        l.pred.U <- pars['la1.U'] + (pars['la2.U'] - pars['la1.U']) * 
          (1-exp(-pars['k.U']*(dat.U$age - a1))) / 
          (1-exp(-pars['k.U']*(a2-a1)))
        
        nll <- -dlnorm(x = c(dat.m$length_cm, dat.f$length_cm, dat.U$length_cm), 
                       meanlog = log(c(l.pred.m, l.pred.f, l.pred.U)) -
                         pars['cv']^2/3,   #divide by 2 for 2 sexes
                       sdlog = pars['cv'], log = TRUE) %>%
          sum()
        return(nll)
      }
      
      
      #filter data by sex
      dat.m <- dplyr::filter(fish.bio2.ages, sex == '1', !is.na(age)) #Males
      dat.f <- dplyr::filter(fish.bio2.ages, sex == '2', !is.na(age)) #Females
      dat.U <- dplyr::filter(fish.bio2.ages, sex == 'U', !is.na(age)) #Unknown-Kline 1996-central CA
      
      pars.init <- log(c(la1.m = 7,  la1.f = 9,  la1.U = 9,  #change for 2 or 3 sex categories
                         la2.m = 65, la2.f = 73, la2.U = 73, 
                         k.m = .018, k.f = .01,  k.U = 0.1,
                         cv = .2))
      
      #estimate with "optim"
      vbgf.optim <- optim(pars.init, vbgf.loglik, 
                          dat.m = dat.m, dat.f = dat.f, dat.U = dat.U,
                          a1 = 2, a2 = 100)  #pick age 1 and age 2
      
      #~~~~~~~~~~~~~~~
      ###Results----
      #~~~~~~~~~~~~~~
      #Lognormal, bias corrected, Schnute reparameterization
      exp(vbgf.optim$par)
      
      #name parameters
      nls.m <- coef(vbgf.nls2)[c(1,4,7)] #males = 1
      nls.f <- coef(vbgf.nls2)[c(2,5,8)] #females = 2
      nls.U <- coef(vbgf.nls2)[c(3,6,9)] #unknown/Kline 1996 = U
      optim.m  <- exp(vbgf.optim$par)[c(1,4,7)]
      optim.f  <- exp(vbgf.optim$par)[c(2,5,8)]
      optim.U  <- exp(vbgf.optim$par)[c(3,6,9)]
      optim.cv <- exp(vbgf.optim$par)[10]
     
      ###VBGF, Schnute, bias correction plot, compare models----
      ggplot(fish.bio2.ages) +
        geom_point(aes(x = age, y = length_cm, col = sex), alpha = 0.25) +
        geom_line( aes(x = age, y = nls.f[1] + (nls.f[2] - nls.f[1]) * (1-exp(-nls.f[3]*(age-1))) / (1-exp(-nls.f[3]*99)), linetype='Schnute normal'), col = 'red') +
        geom_line( aes(x = age, y = nls.m[1] + (nls.m[2] - nls.m[1]) * (1-exp(-nls.m[3]*(age-1))) / (1-exp(-nls.m[3]*99)), linetype='Schnute normal'), col = 'blue') +
        geom_line( aes(x = age, y = nls.U[1] + (nls.U[2] - nls.U[1]) * (1-exp(-nls.U[3]*(age-1))) / (1-exp(-nls.U[3]*99)), linetype='Schnute normal'), col = 'green') +
        
        geom_line( aes(x = age, y = optim.f[1] + (optim.f[2] - optim.f[1]) * (1-exp(-optim.f[3]*(age-1))) / (1-exp(-optim.f[3]*99)), linetype='Schnute lognormal'), col = 'red') +
        geom_line( aes(x = age, y = optim.m[1] + (optim.m[2] - optim.m[1]) * (1-exp(-optim.m[3]*(age-1))) / (1-exp(-optim.m[3]*99)), linetype='Schnute lognormal'), col = 'blue') +
        geom_line( aes(x = age, y = optim.U[1] + (optim.U[2] - optim.U[1]) * (1-exp(-optim.U[3]*(age-1))) / (1-exp(-optim.U[3]*99)), linetype='Schnute lognormal'), col = 'green') +
        scale_color_manual(values = c('1' = 'blue', '2' = 'red', 'U' = 'green' )) +
        NULL
      
      #save last plot
      ggsave("SST.Schnute.bias.correction.Kline.Butler.png", plot = last_plot(),width=6, height= 4,path=getwd())
 
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # 5. compare to 2013 assessment----
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #2013, VBGF, Schnute, bias correction plot, compare models
      
      x_2013     <-seq(0,100, by=1)   #x's to plot 2013 curve
      par.2013.m <-c(7, 67.5, 0.018)  #la1, la2, k a1=2, a2=100
      par.2013.f <-c(7, 75  , 0.018)
      
      
      ggplot(fish.bio2.ages) +
        geom_point(aes(x = age, y = length_cm, col = sex), alpha = 0.25) +
        geom_line( aes(x = age, y = nls.f[1] + (nls.f[2] - nls.f[1]) * (1-exp(-nls.f[3]*(age-1))) / (1-exp(-nls.f[3]*99)), linetype='Schnute normal'), col = 'red') +
        geom_line( aes(x = age, y = nls.m[1] + (nls.m[2] - nls.m[1]) * (1-exp(-nls.m[3]*(age-1))) / (1-exp(-nls.m[3]*99)), linetype='Schnute normal'), col = 'blue') +
        geom_line( aes(x = age, y = nls.U[1] + (nls.U[2] - nls.U[1]) * (1-exp(-nls.U[3]*(age-1))) / (1-exp(-nls.U[3]*99)), linetype='Schnute normal'), col = 'green') +
 
        geom_line( aes(x = age, y = optim.f[1] + (optim.f[2] - optim.f[1]) * (1-exp(-optim.f[3]*(age-1))) / (1-exp(-optim.f[3]*99)), linetype='Schnute lognormal'), col = 'red') +
        geom_line( aes(x = age, y = optim.m[1] + (optim.m[2] - optim.m[1]) * (1-exp(-optim.m[3]*(age-1))) / (1-exp(-optim.m[3]*99)), linetype='Schnute lognormal'), col = 'blue') +
        geom_line( aes(x = age, y = optim.U[1] + (optim.U[2] - optim.U[1]) * (1-exp(-optim.U[3]*(age-1))) / (1-exp(-optim.U[3]*99)), linetype='Schnute lognormal'), col = 'green') +
        
        geom_line( aes(x = age, y = par.2013.f[1] + (par.2013.f[2] - par.2013.f[1]) * (1-exp(-par.2013.f[3]*(age-1))) / (1-exp(-par.2013.f[3]*99)), linetype='2013'), col = 'black') +
        geom_line( aes(x = age, y = par.2013.m[1] + (par.2013.m[2] - par.2013.m[1]) * (1-exp(-par.2013.m[3]*(age-1))) / (1-exp(-par.2013.m[3]*99)), linetype='2013'), col = 'black') +
        
        scale_color_manual(values = c('1' = 'blue','2' = 'red', 'U' = 'green' )) +
        NULL
      
      #save last plot
      ggsave("SST.2013.compare.to.Schnute.bias.correction.Kline.Butler.png", plot = last_plot(),width=6, height= 4,path=getwd())
      
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # 6. summary dataset information----
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
      #max age
      max(fish.bio2.ages[fish.bio2.ages$sex=="2",]$age) #females
      max(fish.bio2.ages[fish.bio2.ages$sex=="1",]$age) #males
      max(fish.bio2.ages[fish.bio2.ages$sex=="U",]$age) #unknown-Kline 1996
      
      #max length
      max(fish.bio2.ages[fish.bio2.ages$sex=="2",]$length_cm) #females
      max(fish.bio2.ages[fish.bio2.ages$sex=="1",]$length_cm) #males
      max(fish.bio2.ages[fish.bio2.ages$sex=="U",]$length_cm) #unknown-Kline 1996
      
      #sample size (fish with age and length data)
      nrow(fish.bio2.ages[fish.bio2.ages$sex=="2",]) #females
      nrow(fish.bio2.ages[fish.bio2.ages$sex=="1",]) #males
      nrow(fish.bio2.ages[fish.bio2.ages$sex=="U",]) #unknown-Kline 1996

      