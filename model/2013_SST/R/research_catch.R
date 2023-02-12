SST.NWsurv <- read.csv('C:/SS/Thornyheads/Data/NW_Survey/SSPN_NWFSC.Effort.csv',skip=8)
LST.NWsurv <- read.csv('C:/SS/Thornyheads/Data/NW_Survey/LSPN_NWFSC.Effort.csv',skip=8)

SST.NWsurv$year <- as.numeric(substring(SST.NWsurv$PROJECT_CYCLE,6))
LST.NWsurv$year <- as.numeric(substring(LST.NWsurv$PROJECT_CYCLE,6))
SST.NWcatch_mt <- aggregate(SST.NWsurv$HAUL_WT_KG/1e3, by=list(SST.NWsurv$year), FUN=sum, na.rm=TRUE)
LST.NWcatch_mt <- aggregate(LST.NWsurv$HAUL_WT_KG/1e3, by=list(LST.NWsurv$year), FUN=sum, na.rm=TRUE)

AKall <- read.csv('c:/Data/AFSCsurvey/Tri.and.Slope.AK.Surveys.Catch.kg.All.FMP.Species 09 Jan 2013.csv')
aggregate(AKall$shortspine_thornyhead/1e3,by=list(AKall$YEAR),FUN=sum,na.rm=TRUE)
##    Group.1        x
## 1     1977 2.167048
## 2     1980 0.653673
## 3     1983 1.329841
## 4     1984 2.738518
## 5     1986 0.632901
## 6     1988 2.955246
## 7     1989 0.785527
## 8     1990 2.711397
## 9     1991 2.324069
## 10    1992 2.264741
## 11    1993 3.007507
## 12    1995 5.610222
## 13    1996 3.946485
## 14    1997 3.326530
## 15    1998 2.662254
## 16    1999 3.542878
## 17    2000 4.383819
## 18    2001 7.101427
## 19    2004 2.484083

aggregate(AKall$longspine_thornyhead/1e3,by=list(AKall$YEAR),FUN=sum,na.rm=TRUE)

##    Group.1         x
## 1     1977  0.000000
## 2     1980  0.000000
## 3     1983  0.000000
## 4     1984  2.006921
## 5     1986  0.000000
## 6     1988  7.140817
## 7     1989  0.000000
## 8     1990 11.262246
## 9     1991  8.580152
## 10    1992  7.576171
## 11    1993  9.694045
## 12    1995  9.101568
## 13    1996 12.288922
## 14    1997 12.754341
## 15    1998  0.325701
## 16    1999 13.740421
## 17    2000 14.553062
## 18    2001 14.514103
## 19    2004  0.417810
