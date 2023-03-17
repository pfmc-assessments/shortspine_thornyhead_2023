# set up ----

library(tidyverse)
library(ggthemes)
theme_set(theme_classic(base_size = 16))

dat_path <- 'data/experimental_age_data' 
out_path <- file.path('outputs/growth')
dir.create(out_path)

# take black out of colorblind theme
scale_fill_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_fill_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# Color
scale_color_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_color_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# data ----
dat <- bind_rows(expand.grid(Year = 1892:1986, 
            category = "Karnowski", 
            state= "Oregon"), 
            expand.grid(Year = 1981:2022, 
                        category = "PacFIN", 
                        state= c("California","Washington")), 
            expand.grid(Year = 1987:2022, 
                        category = "PacFIN", 
                        state= "Oregon"), 
            expand.grid(Year = 1966:1976, 
                        category = "Rodgers", 
                        state= c("California","Oregon","Washington")),
            expand.grid(Year = 1969:1980, 
                        category = "CALCOM", 
                        state= "California"), 
            expand.grid(Year = 1934:1968, 
                        category = "Ralston", 
                        state= "California"), 
            expand.grid(Year = 1954:1980, 
                        category = "WDFW", 
                        state= "Washington"), 
            expand.grid(Year = 1901:1961, 
                        category = "Imputed(2005)", 
                        state= "California")) %>%
  transform(state=factor(state,levels=c("Washington","Oregon","California")))


dat %>% 
  ggplot(aes(x = Year, y = category, color = category, fill = category)) +
  geom_point(size = 4, shape=15) + 
  facet_wrap(~state, ncol = 1, scales = 'free_y') +
  scale_y_discrete(position = 'right', limits = rev) +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 30) +
  theme(legend.position = 'none')



ggsave('outputs/landings_data_timeseries.jpg', 
       bg='white', dpi=300, height=7, width=16, units="in")
