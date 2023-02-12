dir <- 'C:/ss/thornyheads/runs/SST_BASE_pre-STAR_tables'

dat <- SS_readdat('SST_BASE_pre-STAR/SST_data.ss')
dat$catch
catch.table <- cbind(dat$catch[,c(5,1:4)],total=apply(dat$catch[,c(1:4)],1,sum))
write.csv(catch.table,file.path(dir,'catch.table.csv'),row.names=FALSE)

pars <- sbase$parameters[,c(2,3,5,6,7,8,11,12,13)]
pars.dev <- pars[pars$PR_type=="dev",]
pars     <- pars[pars$PR_type!="dev",]

