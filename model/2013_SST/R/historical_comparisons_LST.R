LST.rep.lines <- readLines(file.path('c:/SS/Thornyheads/runs/',
                                     'Longspine Thornyhead_2005/ModelFiles_LST2005/LST_base.rep'))
LST.rep.ts <- read.table(file.path('c:/SS/Thornyheads/runs/',
                               'Longspine Thornyhead_2005/ModelFiles_LST2005/LST_base.rep'),
                      skip=grep("TIME_SERIES",LST.rep.lines),nrows=length(1962:2005),
                      head=TRUE, fill=TRUE)
lbase <- SS_output('C:/ss/Thornyheads/runs/LST_STAR_Base_Model')

sum <- SSsummarize(list(lbase,lbase))
sum$SpawnBio$"2" <- NA
# divide 2005 spawning biomass by 2 since it was a single-sex model
sum$SpawnBio$"2"[sum$SpawnBio$Yr %in% LST.rep.ts$year] <- LST.rep.ts$SpawnBio/2
sum$SpawnBioUpper$"2" <- sum$SpawnBio$"2"
sum$SpawnBioLower$"2" <- sum$SpawnBio$"2"

sum$Bratio$"2" <- sum$SpawnBio$"2"[-(1:3)]/sum$SpawnBio$"2"[1]
sum$BratioUpper$"2" <- sum$Bratio$"2"
sum$BratioLower$"2" <- sum$Bratio$"2"

SSplotComparisons(sum,pheight=5,png=TRUE,plotdir='C:/ss/Thornyheads/runs/LST_STAR_Base_Model',
                  legendlabels=c("Base model", "2005 assessment"),
                  legendorder=c(2,1))
