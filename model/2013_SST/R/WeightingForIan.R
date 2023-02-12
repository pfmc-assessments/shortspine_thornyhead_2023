library(r4ss)
update_r4ss_files(local="C:/NOAA2013/Rougheye/Models/Rcode/r4ss")

source("c:/SS/Thornyheads/R/TA1.8_IGT.R")

base <- SS_output(dir="C:\\NOAA2013\\SST\\SST_BASE_pre-STAR",covar=T,verbose=F)
base <- sbase
base <- sbase2

sbase2dir <- 'SST_2.4_len_outliers'
sbase2 <- SS_output(sbase2dir,covar=TRUE)

# comparing fleet 1 with and without outliers
tmp <- SSMethod.TA1.8(sbase2,type="len",fleet=1,part=2,plotit=TRUE)
SSMethod.TA1.8(sbase,type="len",fleet=1,part=2,plotit=TRUE,new=TRUE,ylim=c(0,72),yaxs='i')
lines(tmp$x[tmp$x<1995],tmp$exp[tmp$x<1995],col=4,lwd=2,lty=2)
lines(tmp$x[tmp$x>1995],tmp$exp[tmp$x>1995],col=4,lwd=2,lty=2)

sbase.test  <- sbase
sbase2.test <- sbase2
sbase.test$lendbase <- sbase.test$lendbase[sbase.test$lendbase$Fleet==1 & sbase.test$lendbase$Part==2,]
sbase2.test$lendbase <- sbase2.test$lendbase[sbase2.test$lendbase$Fleet==1 & sbase2.test$lendbase$Part==2,]
SSplotComps(sbase.test,fleets=1,subplot=1,maxcols=5)
par(mfcol=c(6,5),mar=rep(0,4),oma=c(5,5,5,2)+.1)
for(i in 1:25){
  j <- i
  y <- sort(unique(sbase2.test$lendbase$Yr))[i]
  if(y>1995) j <- i+2
  row <- j%%6
  if(row==0) row <- 6
  col <- floor(j/6)+1
  if(row==6) col <- col-1
  par(mfg=c(row, col))
  tmp <- sbase2.test$lendbase[sbase2.test$lendbase$Yr==y,]
  lines(tmp$Bin, tmp$Exp, col=4, lty='33', lwd=1)
}




#Data weighting
par(mfrow=c(4,2),mar=c(2,2,1,1)+0.1,mgp=c(0,0.5,0),
    oma=c(1.2,1.2,0,0),las=1)
for(f in 1:4){
  for(part in 2:1){
    SSMethod.TA1.8(sbase,type="len",fleet=f,part=part,plotit=TRUE,new=FALSE)
  }
}

par(mfrow=c(3,3),mar=c(2,2,1,1)+0.1,mgp=c(0,0.5,0),
    oma=c(1.2,1.2,0,0),las=1)
for(f in 5:9){
  SSMethod.TA1.8(sbase,type="len",fleet=f,part=0,plotit=TRUE,new=FALSE)
}

## > SSMethod.TA1.8(sbase,type="len",fleet=1,part=1:2,plotit=T)
##         w   lo.2.5%  hi.97.5% 
## 0.4755029 0.2920009 0.9067461 
## > SSMethod.TA1.8(sbase,type="len",fleet=2,part=1:2,plotit=T)
##         w   lo.2.5%  hi.97.5% 
## 0.3584433 0.2466855 0.7057701 
## > SSMethod.TA1.8(sbase,type="len",fleet=3,part=1:2,plotit=T)
##        w  lo.2.5% hi.97.5% 
## 1.446485 0.829295 9.435576 
## > SSMethod.TA1.8(sbase,type="len",fleet=4,part=1:2,plotit=T)
##         w   lo.2.5%  hi.97.5% 
## 1.2351125 0.7914637 2.8381939 
## > SSMethod.TA1.8(sbase,type="len",fleet=5,part=0,plotit=T)
##        w  lo.2.5% hi.97.5% 
## 0.448474 0.311757 1.248533 
## > SSMethod.TA1.8(sbase,type="len",fleet=6,part=0,plotit=T)
##         w   lo.2.5%  hi.97.5% 
##  1.857878  1.331949 14.772898 
## > SSMethod.TA1.8(sbase,type="len",fleet=7,part=0,plotit=T)
##          w    lo.2.5%   hi.97.5% 
##   9.750384   5.913916 701.427906 
## > SSMethod.TA1.8(sbase,type="len",fleet=8,part=0,plotit=T)
##          w    lo.2.5%   hi.97.5% 
##  0.2092907  0.1375456 34.4030622 
## > SSMethod.TA1.8(sbase,type="len",fleet=9,part=0,plotit=T)
##         w   lo.2.5%  hi.97.5% 
## 0.5842175 0.2991559 3.4710656 



SSMethod.TA1.8(base,type="len",fleet=1,part=1,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=2,part=1,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=3,part=1,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=4,part=1,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=1,part=2,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=2,part=2,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=3,part=2,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=4,part=2,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=5,part=0,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=6,part=0,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=7,part=0,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=8,part=0,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=9,part=0,plotit=T)


#You can combine fleets and/or partitions
SSMethod.TA1.8(base,type="len",fleet=1:4,part=1,plotit=T)
windows()
SSMethod.TA1.8(base,type="len",fleet=1:4,part=2,plotit=T)
SSMethod.TA1.8(base,type="len",fleet=5:9,part=0,plotit=T)



#Data weighting
SSMethod.TA1.8(lbase,type="len",fleet=1,part=1,plotit=T)
SSMethod.TA1.8(lbase,type="len",fleet=1,part=2,plotit=T)
SSMethod.TA1.8(lbase,type="len",fleet=2,part=0,plotit=T)
SSMethod.TA1.8(lbase,type="len",fleet=3,part=0,plotit=T)
SSMethod.TA1.8(lbase,type="len",fleet=4,part=0,plotit=T)
