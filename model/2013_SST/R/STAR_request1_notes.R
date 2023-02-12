s2.2 <- SS_output("SST_2.2_pre-STAR_flex_selex")
s4.8 <- SS_output("SST_4.8_h0.6",covar=FALSE)
s4.0 <- SS_output("SST_4.0_No_Pikitch_South")
s4.1 <- SS_output("SST_4.1_No_early_Tri")
s4.2 <- SS_output("SST_4.2_No_Pikitch_South_No_early_Tri")
s4.3 <- SS_output("SST_4.3_recdev1930")
s4.4 <- SS_output("SST_4.4_h0.6_No_Pikitch_South")
s4.5 <- SS_output("SST_4.5_h0.6_No_early_Tri")
s4.6 <- SS_output("SST_4.6_h0.6_No_Pikitch_South_No_early_Tri")
s4.7 <- SS_output("SST_4.7_h0.6_recdev1930")


day1sum <- SSsummarize(list(s2.2, s4.0, s4.1, s4.2, s4.3, s4.4, s4.5, s4.6, s4.7))
day1sum <- SSsummarize(list(s2.2, s4.4, s4.5, s4.6, s4.7))
SSplotComparisons(day1sum)

day1sum.r2 <- SSsummarize(list(s2.2, s4.0))
SSplotComparisons(day1sum.r2,legendloc='bottomleft',
                  legendlabels=c("Day 2 base (fixed errors)",
                    "No Pikitch discard rates Trawl South"),
                  png=TRUE,plotdir="SST_4.0_No_Pikitch_South")

SS_plots(s4.4,png=TRUE)
SS_plots(s4.6,png=TRUE)
SS_plots(s4.0,png=TRUE)

day1sum.r3 <- SSsummarize(list(s2.2, s4.1, s4.2, s4.6))
SSplotComparisons(day1sum.r3,legendloc='bottomleft',indexfleets=rep(5,4),
                  indexUncertainty=FALSE,
                  indexQlabel=FALSE,
                  legendlabels=c("Day 2 base (fixed errors)",
                    "Triennial1 only 1995-2004",
                    "Triennial1 only 1995-2004 + No Pikitch South",
                    "Triennial1 only 1995-2004 + No Pikitch South + h=0.6"),
                  png=TRUE,plotdir="SST_4.6_h0.6_No_Pikitch_South_No_early_Tri")

SSplotComparisons(day1sum.r3,legendloc='bottomleft',indexfleets=rep(9,4),
                  indexUncertainty=FALSE,
                  indexQlabel=FALSE,
                  legendlabels=c("Day 2 base (fixed errors)",
                    "Triennial1 only 1995-2004",
                    "Triennial1 only 1995-2004 + No Pikitch South",
                    "Triennial1 only 1995-2004 + No Pikitch South + h=0.6"),
                  png=TRUE,plotdir="SST_4.6_h0.6_No_Pikitch_South_No_early_Tri")




day1sum.r5 <- SSsummarize(list(s2.2, s4.3))
SSplotComparisons(day1sum.r5,legendloc='bottomleft',indexfleets=rep(9,2),
                  indexUncertainty=FALSE,
                  indexQlabel=FALSE,
                  legendlabels=c("Day 2 base (fixed errors)",
                    "Recruit devs start in 1930"),
                  png=TRUE,plotdir="SST_4.3_recdev1930")

s5.0 <- SS_output("SST_5.0_equals4.4")
s5.1 <- SS_output("SST_5.1_block_trawl_South")
s5.1c <- SS_output("SST_5.1c_block_trawl_South2")
s5.2 <- SS_output("SST_5.2_block_trawl_South_fixTriComps")
s5.3 <- SS_output("SST_5.3_block_trawl_South_fixTriComps_oldMat")
s5.3b <- SS_output("SST_5.3b_block_trawl_South_fixTriComps_oldMat_parm")
s5.1b <- SS_output("SST_5.1b_block_trawl_South_weakPrior",covar=FALSE,forecast=FALSE)

s5.5 <- SS_output("SST_5.5_block_trawl_South_fixTriComps_oldMat_noOutlier")
s5.6 <- SS_output("SST_5.6_block_trawl_South_fixTriComps_oldMat_timeSel")
s5.6b <- SS_output("SST_5.6b_block_trawl_South_fixTriComps_oldMat_timeSel2")
s5.7 <- SS_output("SST_5.7_block_trawl_South_fixTriComps_oldMat_asympSel")

s5.9 <- SS_output("SST_5.9_block_trawl_South_fixTriComps_oldMat_goodCatch")
s5.9b <- SS_output("SST_5.9b_block_trawl_South_fixTriComps_oldMat_goodCatch_recon")
s5.9c <- SS_output("SST_5.9c_block_trawl_South_fixTriComps_oldMat_goodCatch_noBallpark")

comp1 <- SSsummarize(list(s5.0,s5.1,s5.1c,s5.2,s5.3))
comp2 <- SSsummarize(list(s5.3,s5.5,s5.6,s5.6b,s5.7))
comp3 <- SSsummarize(list(s5.3,s5.9,s5.9b))
comp4 <- SSsummarize(list(s5.3,s5.9,s5.9c))

likenames <-c("TOTAL","Survey","Length_comp","Discard","Mean_body_wt","priors")
names <- c("Q_calc", "SPB_Virg", "Bratio_2013", "SPRratio_2012","TotYield_SPRtgt")

SStableComparisons(comp1,likenames=likenames,names=names)
SStableComparisons(comp2,likenames=likenames,names=names)
SStableComparisons(comp3,likenames=likenames,names=names)
SStableComparisons(comp4,likenames=likenames,names=names)


SSplotComparisons(comp1,legendlabels=c("Day2base","R1","R1b","R1+R2","R1+R2+R3"),
                  pheight=5,pwidth=5,plotdir="C:/ss/Thornyheads/STAR/Day2_requests1-4",
                  png=TRUE,plot=FALSE,legendloc='bottomleft')
SSplotComparisons(comp2,legendlabels=c("R1+R2+R3","R1+R2+R3+R5","R1+R2+R3+R6","R1+R2+R3+R6b","R1+R2+R3+R7"),
                  pheight=5,pwidth=5,plotdir="C:/ss/Thornyheads/STAR/Day2_requests5-7",
                  png=TRUE,plot=FALSE,legendloc='bottomleft')
SSplotComparisons(comp3,legendlabels=c("R1+R2+R3","+ correct catch","+ correct catch + reconstruction"),
                  pheight=5,pwidth=5,plotdir="C:/ss/Thornyheads/STAR/Day2_request9",
                  png=TRUE,plot=FALSE,legendloc='bottomleft')
SSplotComparisons(comp4,legendlabels=c("R1+R2+R3","+ correct catch","+ correct catch + remove 'ballpark F'"),
                  pheight=5,pwidth=5,plotdir="C:/ss/Thornyheads/STAR/Day2_bad_news",
                  png=TRUE,plot=FALSE,legendloc='bottomleft')

source('c:/SS/R/r4ss/branches/testing/SSplotDomeBio.R')
SSplotDomeBio(s5.6,fleet=1)
SSplotDomeBio(s5.6,fleet=9)


s6.1  <- SS_output("SST_6.1_WednesdayR1")
s6.2  <- SS_output("SST_6.2_WednesdayR2_newblocks")
s6.2b <- SS_output("SST_6.2b_WednesdayR2_newblocks_double_check",covar=FALSE,forecast=FALSE)
s6.3  <- SS_output("SST_6.3_WednesdayR4_newblocks+block92")
s6.4  <- SS_output("SST_6.4_WednesdayR4_newblocks+block92_noOutliers")

comp5 <- SSsummarize(list(s5.3,s5.9c, s6.1, s6.2, s6.3))
SSplotComparisons(comp5,legendlabels=c("Before the fall from grace about ballpark F",
                          "Remove ballpark F",
                          "+ catch reconstruction (no ballpark)",
                          "+ Meisha's awesome blocking (no ballpark)",
                          "+ split Trawl North in 1991/1992"),
                  pheight=5,pwidth=5,ptsize=11,plotdir="C:/ss/Thornyheads/STAR/Day3_good_news",
                  png=TRUE,plot=FALSE,legendloc='bottomleft')


par(mfcol=c(2,2))
for(f in 1:4) SSplotSelex(s6.2,subplot=1,sizefactors="Ret",fleets=f,years=1901:2011,fleetnames=fleets,legendloc='bottomright')
par(mfrow=c(1,1))
SSplotSelex(s6.2,subplot=1,fleetnames=fleets)
par(mfcol=c(2,2))
for(f in 1:4) SSplotDiscard(s6.2,fleetnames=fleets)

par(mfcol=c(2,2))
for(f in 1:4) SSplotSelex(s6.3,subplot=1,sizefactors="Ret",fleets=f,years=1901:2011,fleetnames=fleets,legendloc='bottomright')

SStableComparisons(comp5,likenames=likenames,names=names)

SSplotComparisons(SSsummarize(list(s6.2)),plotdir=s6.2$inputs$dir,png=TRUE)

s6.2$derived_quants[s6.2$derived_quants$LABEL=="SSB_SPRtgt",]
s6.2$derived_quants[s6.2$derived_quants$LABEL=="SSB_Unfished",]
  
