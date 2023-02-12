if(FALSE){
  setwd('C:/ss/thornyheads/runs/')

  ### jitter
  
  # NOTE!: base model copied into this folder,
  # then starter file changed to have jitter=0.1
  
  dir.jitter = "SST_base_jitter"
  Njitter <- 100
  # run funciton
  SS_RunJitter(mydir=dir.jitter,Njitter=Njitter)
  # read shortcut summary of results
  jitlines <- readLines('c:/SS/Thornyheads/R/shortspine_jitter_results.txt')
  jitlikes <- jitlines[grep("Likelihood",jitlines)]
  jitvals <- as.numeric(substring(jitlikes,1+nchar("Likelihood =  ")))
  
  
  # read models
  jittermodels <- SSgetoutput(dirvec=dir.jitter, keyvec=1:Njitter,
                              getcovar=FALSE,getcomp=FALSE)
  # summarize
  jittersummary <- SSsummarize(jittermodels)
  # Likelihoods
  jittersummary$likelihoods[1,]
  # read base model
  sbase <- SS_output('SST_BASE_pre-STAR')
  (like.base <- sbase$likelihoods_used$values[1])
  ## [1] 602.847
  (like.best <- min(jittersummary$likelihoods[1,1:Njitter]))
  ## [1] 599.172 ## oops, that's smaller
  (models.best <- which(jittersummary$likelihoods[1,1:Njitter]==like.best))
  ## [1]  6 13 17 23   
  (models.base <- which(jittersummary$likelihoods[1,1:Njitter]==like.base))
  ## [1]  2  9 14
  png(file.path(dir.jitter, "SST_jitter_results.png"),res=300,units='in',height=7,width=7)
  plot(as.numeric(jittersummary$likelihoods[1,1:Njitter]) - like.base,
       xlab="Trial number",
       ylab="Neg. log. likelihood in trial - Neg. log. likelihood in base model")
  abline(h=0,lty=3)
  dev.off()

  # shortcut plot
  png(file.path(dir.jitter, "SST_jitter_results.png"),res=300,units='in',height=7,width=7)
  plot(jitvals - sbase$likelihoods_used$values[1],
       xlab="Trial number",
       ylab="Neg. log. likelihood in trial - Neg. log. likelihood in base model")
  abline(h=0,lty=3)
  dev.off()
  
  # Parameters (big table)
  jittersummary$pars[, names(jittersummary$pars) %in%
                     c(models.best[1], models.base[2],"Label")]

### !!! FIX STARTER FILES !!!!

  setwd('c:/SS/Thornyheads/runs/')
  dir.jitter <- 'SST_6.2f_jitter3'
  Njitter <- 25
  # run funciton
  SS_RunJitter(mydir=dir.jitter,
               model="ss3_opt_win64",
               Njitter=Njitter)
  # read models
  jittermodels <- SSgetoutput(dirvec=dir.jitter, keyvec=1:Njitter,
                              getcovar=FALSE,getcomp=FALSE)
  # summarize
  jittersummary <- SSsummarize(jittermodels)
  # Likelihoods
  jittersummary$likelihoods[1,]
  # read base model
  sbase <- SS_output('SST_BASE_pre-STAR')
  (like.base <- sbase$likelihoods_used$values[1])
  ## [1] 602.847
  (like.best <- min(jittersummary$likelihoods[1,1:Njitter]))
  ## [1] 599.172 ## oops, that's smaller
  (models.best <- which(jittersummary$likelihoods[1,1:Njitter]==like.best))
  ## [1]  6 13 17 23   
  (models.base <- which(jittersummary$likelihoods[1,1:Njitter]==like.base))
  ## [1]  2  9 14
  png(file.path(dir.jitter, "SST_jitter_results.png"),res=300,units='in',height=7,width=7)
  plot(as.numeric(jittersummary$likelihoods[1,1:Njitter]) - like.base,
       xlab="Trial number",
       ylab="Neg. log. likelihood in trial - Neg. log. likelihood in base model")
  abline(h=0,lty=3)
  dev.off()
  
  # Parameters (big table)
  jittersummary$pars[, names(jittersummary$pars) %in%
                     c(models.best[1], models.base[2],"Label")]

}
