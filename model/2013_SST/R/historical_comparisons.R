std05  <- read.table(file.path('c:/SS/Thornyheads/runs',
                               'SST_2005/SST_ModelFiles_2005/SS2.std'),
                     fill=TRUE,head=TRUE)
B0.05 <- std05[std05$name=="spbio_std",]
depl.05 <- std05[std05$name=="depletion",]

sum <- SSsummarize(list(sbase,sbase))
sum$SpawnBio$"2" <- c(B0.05$value,rep(NA,length(2006:2024)))
sum$SpawnBioSD$"2" <- c(B0.05$std,rep(NA,length(2006:2024)))
sum$SpawnBioUpper$"2" <- sum$SpawnBio$"2" + 1.96*sum$SpawnBioSD$"2"
sum$SpawnBioLower$"2" <- sum$SpawnBio$"2" - 1.96*sum$SpawnBioSD$"2"

## sum$Bratio$"2" <- c(depl.05$value,rep(NA,length(2006:2024)))
## sum$BratioSD$"2" <- c(depl.05$std,rep(NA,length(2006:2024)))
## sum$BratioUpper$"2" <- sum$Bratio$"2" + 1.96*sum$BratioSD$"2"
## sum$BratioLower$"2" <- sum$Bratio$"2" - 1.96*sum$BratioSD$"2"

sum$Bratio$"2" <- c(sum$SpawnBio$"2"[sum$SpawnBio$Yr %in% sum$Bratio$Yr]/
                    sum$SpawnBio$"2"[1])

## SSplotComparisons(sum,subplot=2)

## #vals.01 <- read.csv("C:/SS/Thornyheads/old_assessments/SST_2001/numbers from Model d outpout.doc.csv")

## sum2 <- SSsummarize(list(sbase,sbase,sbase))
## sum2$SpawnBio$"1" <-
##   c(vals.01$SP.BIO[1:2],rep(NA,length(1901:1961)),vals.01$SP.BIO[vals.01$YEAR%in%62:100],rep(NA,length(2001:2024)))
## sum2$SpawnBioUpper$"1" <- NA
## sum2$SpawnBioLower$"1" <- NA
## sum2$SpawnBioSD$"1" <- NA

## sum2$SpawnBio$"2" <- c(B0.05$value,rep(NA,length(2006:2024)))
## sum2$SpawnBioSD$"2" <- c(B0.05$std,rep(NA,length(2006:2024)))
## sum2$SpawnBioUpper$"2" <- sum2$SpawnBio$"2" + 1.96*sum2$SpawnBioSD$"2"
## sum2$SpawnBioLower$"2" <- sum2$SpawnBio$"2" - 1.96*sum2$SpawnBioSD$"2"

dir.create('../figs/historical_FINAL/')


SSplotComparisons(sum,plotdir='../figs/historical_FINAL/',
                  legendlabel=c("Base model","2005 assessment"),
                  subplot=1:2,models=1:2,
                  pheight=4.5,png=TRUE,legendloc='bottomleft')
SSplotComparisons(sum,plotdir='../figs/historical_FINAL/',
                  legendlabel=c("Base model","2005 assessment"),
                  subplot=3,models=1:2,
                  pheight=4.5,png=TRUE,legendloc='bottomleft')


SSplotComparisons(sum2,plotdir='../figs/historical/',
                  legendlabel=c(
                    "2005 assessment",
                    "Base model"),
                  subplot=1:2,legendorder=c(2,3,1),
                  pheight=5,png=TRUE,legendloc='topright')

for(i in 1:3) sum2$Bratio[,i] <- sum2$SpawnBio[-(1:3),i]/sum2$SpawnBio[1,i]
SSplotComparisons(sum2,plotdir='../figs/historical/',
                  legendlabel=c("2001 assessment",
                    "2005 assessment",
                    "Base model"),
                  subplot=3,legendorder=c(2,3,1),
                  pheight=5,png=TRUE,legendloc='topright')
