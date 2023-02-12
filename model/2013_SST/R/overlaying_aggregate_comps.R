# read in three models
b1 <- SS_output('C:/ss/bluemarlin/CVcpue0.14splitF1splineearly190_fixP3HWspline200')
b2 <- SS_output('C:/ss/bluemarlin/CVcpue0.14splitF1splineearly190_fixP3HWspline200_test')
b3 <- SS_output('C:/ss/bluemarlin/CVcpue0.14splitF1splineearly190_fixP3HWspline200_test2 - Copy')

# get aggretated comps using modified functions
source("http://r4ss.googlecode.com/svn/branches/testing/make_multifig_Hoo.R")
source("http://r4ss.googlecode.com/svn/branches/testing/SSplotComps_Hoo.R")

# make plots and get aggregated comp data
agg1 <- SSplotComps_Hoo(b1,subplots=9) # first one makes plot
agg2 <- SSplotComps_Hoo(b2,subplots=9,plot=FALSE,print=FALSE) # just getting data
agg3 <- SSplotComps_Hoo(b3,subplots=9,plot=FALSE,print=FALSE) # just getting data

# get vector of fleets
(fleets <- unique(agg1$f))
#[1]  1  2  7 10 14

# define colors
col1 <- 2 # red
col2 <- rgb(0,0,1,.5) # blue (partially transparent)
col3 <- rgb(0,.7,0,.5) # green (partially transparent)

# loop over panels
for(i in 1:length(fleets)){
  # choose which panel to write over
  if(i<=3){
    par(mfg=c(i,   1, 3, 2)) # first column
  }else{
    par(mfg=c(i-3, 2, 3, 2)) # second column
  }
  # add lines for 2nd model
  lines(agg2$bin[agg2$f==fleets[i]], agg2$exp[agg2$f==fleets[i]],
        col=col2, lwd=2)
  # add lines for 3rd model
  lines(agg3$bin[agg3$f==fleets[i]], agg3$exp[agg3$f==fleets[i]],
        col=col3, lwd=2)
}

# add legend in bottom right
par(mfg=c(3,2,3,2))
plot(0,type='n',axes=FALSE,xlab="",ylab="")
legend('center',lwd=2,col=c(col1, col2, col3),
       legend=c("Model 1","Model 2","Model 3"),bty='n')
