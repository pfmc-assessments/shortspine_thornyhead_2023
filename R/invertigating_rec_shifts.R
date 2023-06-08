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

shift_rec %>%
  ggplot() +
  geom_line(aes(x=year, y=val)) +
  geom_path(aes(x=year, y=mean_reg_val), size=0.8, color="red") +
  geom_vline(aes(xintercept=year_reg), linetype="dashed", size=1) +
  theme_bw()
  facet_wrap(~type, ncol=1)
  
  