#######################################################
########## Exploring regime shifts in
########## Recruitment estimates vs observations
#######################################################

#install.packages("rshift")
library(rshift)
library(dplyr)
library(tidyr)
library(ggplot2)

testdata <- read.csv("C:/Users/pyher/Downloads/Index_sdm_short-cpue-delta-gamma-scaleD-PredGrid.csv")
testdata %>%
  dplyr::select(Year, est) %>%
  rename("year"="Year", "val"="est") -> testdata


#testdata <- cbind.data.frame(year=seq(1,100),val=rnorm(100, 0,1))

Rodionov(testdata, col=2, time=1, l=7, prob=0.95) %>%
  dplyr::rename("year_reg"="year") %>%
  mutate(reg_id=paste0("year_reg", seq(1,n()))) %>%
  bind_rows(bind_cols(year_reg=1, val=NA, RSI=NA, reg_id="year_reg0")) %>%
  arrange(year_reg) %>%
  mutate(year=year_reg)-> testRod

testdata %>%
  left_join(testRod, by="year") %>%
  dplyr::rename("val"="val.x","reg_val"="val.y") %>%
  tidyr::fill(year_reg, reg_val, RSI, reg_id, .direction = "down") %>%
  group_by(reg_id) %>%
  mutate(mean_reg_val=mean(val,na.rm=T)) %>%
  mutate(year_reg=ifelse(year_reg==1,NA,year_reg))-> shift_rec

############################


est_rec <- bind_cols(year=new_base$recruit$Yr, val=new_base$recruit$pred_recr)

est_rec %>%
  filter(year %in% seq(1996, 2022)) -> est_rec

Rodionov(est_rec, col=2, time=1, l=7, prob=0.95) %>%
  dplyr::rename("year_reg"="year") %>%
  mutate(reg_id=paste0("year_reg", seq(1,n()))) %>%
  bind_rows(bind_cols(year_reg=1, val=NA, RSI=NA, reg_id="year_reg0")) %>%
  arrange(year_reg) %>%
  mutate(year=year_reg)-> testRodrec

est_rec %>%
  left_join(testRodrec, by="year") %>%
  dplyr::rename("val"="val.x","reg_val"="val.y") %>%
  tidyr::fill(year_reg, reg_val, RSI, reg_id, .direction = "down") %>%
  group_by(reg_id) %>%
  mutate(mean_reg_val=mean(val,na.rm=T)) %>%
  mutate(year_reg=ifelse(year_reg==1,NA,year_reg)) -> shift_rec_est

shift_rec %>%
  mutate(type="obs") %>%
  bind_rows(mutate(shift_rec_est, type="est")) -> shift_rec_plot

shift_rec_plot %>%
  filter(year>=2003) %>%
  mutate(type=ifelse(type=="est","SS3","Tolimieri et al.")) %>%
  ggplot() +
  geom_line(aes(x=year, y=val)) +
  geom_path(aes(x=year, y=mean_reg_val), size=0.8, color="red") +
  geom_vline(aes(xintercept=year_reg), linetype="dashed", size=1) +
  xlim(c(2003,2022)) +
  theme_bw() +
  labs(x="Years", y="Recruits") +
  facet_wrap(~type, ncol=1)
  
  