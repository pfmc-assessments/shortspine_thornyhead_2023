# Creating Numbers at Age table which perhaps only Jim Hastie will look at
# code from Ian Taylor on July 10, 2013 written for shortspine thornyheads

# get stuff from base model ("sbase" in the output from SS_output for shortspine)
natage  <- sbase$natage
maxage  <- sbase$accuage
startyr <- sbase$startyr
endyr   <- sbase$endyr
# vector of years to report
yrvec <- startyr:(endyr+1)
# subset females and males from beginning of year
natage.f <- natage[natage$Yr %in% yrvec & natage$Gender==1 & natage$"Beg/Mid"=="B",]
natage.m <- natage[natage$Yr %in% yrvec & natage$Gender==2 & natage$"Beg/Mid"=="B",]
# remove extra columns
natage.f <- natage.f[ , names(natage.f) %in% c("Yr",0:maxage)]
natage.m <- natage.m[ , names(natage.m) %in% c("Yr",0:maxage)]
# divide by 1000
natage.f[ , -1] <- 1e-3*natage.f[ , -1]
natage.m[ , -1] <- 1e-3*natage.m[ , -1]

# combine males and females
# Note! no column identifying which rows are males or females
#       first range of years is females, second range is males
natage <- rbind(natage.f,natage.m)

# define ranges for accummulating groups of ages
colnames <- c("10-19","20-29","30-39","40-49","50-59","60-69","70-79","80-89","90+")
colranges <- matrix(c(10,19,20,29,30,39,40,49,50,59,60,69,70,79,80,89,90,200),nrow=2)

# start with non-accumulated ages
natage2 <- cbind(natage$Yr,round(natage[,names(natage) %in% 0:9],1))

# accumulate
for(i in 1:length(colnames)){
  temp <- apply(natage[names(natage) %in%
                       paste(colranges[1,i]:colranges[2,i])],1,sum)
  natage2[[colnames[i]]] <- round(temp,1)
}

# write files
filename <- paste("c:/SS/Thornyheads/tables/numbers_at_age.csv",sep="")
write.csv(natage2,filename,row.names=FALSE)

