#Selectivity blocks

dir<-"C:\\GitHub\\Official_shortspine_thornyhead_2023\\R"
setwd(dir)
dat<-read.csv("SelRet.csv")



dat %>% 
  mutate(blocks=factor(Block, levels=c("HistoricalRet", "Ret1", "Ret2", "Ret3", "Ret4", "Ret5", "Ret6", 
                                       "HistoricalSel", "Sel1", "Sel2", "Sel3","Sel4", "Sel5"), order = TRUE))%>%
  mutate(Fleet=recode_factor(Fleet, !!!c(TrawlN="North Trawl", TrawlS="South Trawl")))%>%
  ggplot(aes(x = Years, y = blocks, col = Fleet, fill = blocks)) +
  geom_point(size = 5, shape=15) + 
  facet_wrap(~Fleet, ncol = 1, scales = 'free_y') +
  scale_y_discrete(position = 'right', limits = rev) +
  scale_color_manual(values = c("#56B4E9","#F0E442"))+
  scale_alpha_manual(values = c(0, 1)) +
  labs(x = NULL, y = "Blocks for Selectivity and Retention")+
  theme_minimal(base_size = 20) +
  theme(legend.position = 'none', 
        legend.title=element_text(size=14), axis.text = element_text(size=14), axis.title.x = element_text(size=14), axis.title.y = element_text(size=14))


#Spawning Plot
dat2<-read.csv("Index_sdm_short-cpue-delta-gamma-scaleD-PredGrid.csv")
baseRec<-read.csv("recdevs_base.csv")

plot(dat2$Year, dat2$est, type = "l", main= "Juv IDX 2003-2021")

plot(dat2$Year, dat2$log_est, type = "l", main= "log Juv IDX 2003-2021")

plot(baseRec$Year, baseRec$Rec, type = "l", xlim=c(2003,2021))

par(mfrow=c(2,1))

plot(dat2$Year, dat2$est, type = "l", main= "Juv IDX 2003-2021", xlab= "Year", ylab="Estimate")
plot(baseRec$Year, baseRec$Rec, type = "l", xlim=c(2003,2021), main= "Base Model RecDevs", xlab = "Year", ylab="Deviation")
abline(v=2018, lty=3)
abline(h=0, lty=2)

newdat<-ts(dat2)
acf(newdat)
acf(diff(newdat))

crosscor(newdat)
crosscor(baseRec)

newdat<-dat2[,1:2]
baseRec_cor<-baseRec[103:122,]

par(mfrow=c(1,1))
ccf(newdat$est, baseRec$Rec, main = "Juv IDX & RecDevs Base Model 2003-2021" )

mainrecdevs<-baseRec[96:118,3]

aveRecDev<-mean(mainrecdevs)
