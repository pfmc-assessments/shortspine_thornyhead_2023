# Fishery landings and discard length distributions from PacFIN for the 2023 SST stock assessment
# Contact: Haley Oleynik, Jane Sullivan
# Last updated March 2023

# Plot fishery landings and discard length distributions by fleet   

# set up ---- 
discards <- read_csv("outputs/fishery_data/discard_lengths.csv")
landings <- read_csv("outputs/fishery_data/fishery_lengths.csv")

# take black out of colorblind theme
scale_fill_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_fill_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

scale_color_colorblind7 = function(.ColorList = 2L:8L, ...){
  scale_color_discrete(..., type = colorblind_pal()(8)[.ColorList])
}

# combine dataframes -----
all_lens <- landings %>% 
  select(Year = SAMPLE_YEAR, fleet, lengthcm) %>%
  mutate(length2 = ifelse(lengthcm < 6, 6,
                          ifelse(lengthcm > 72, 72, lengthcm)),
         Lenbin = cut(length2, breaks = seq(4.9, 72.9, 2),
                      labels = paste(seq(6, 72, 2)))) %>% 
  mutate(Lenbin = as.numeric(as.character(Lenbin)),
         meanLen = Lenbin + 1,
         Disposition = "Landed") %>%
  select(-length2) %>%
  group_by(Disposition, fleet, meanLen) %>%
  summarise(Nfish = n()) %>%
  bind_rows(discards %>%
              mutate(meanLen = Lenbin + 1) %>% # center
              group_by(meanLen, fleet) %>%
              summarize(Nfish = sum(N_Fish)) %>%
              mutate(Disposition = "Discarded")) %>%
  mutate(fleet=factor(fleet, levels=c("NTrawl", "NOther", "STrawl", "SOther")))
  
# plot -----
all_lens %>%
ggplot(aes(x = meanLen, y = Nfish, fill = forcats::fct_rev(Disposition))) +
  geom_col(position = "identity", alpha = 0.5, col = NA) +
  #scale_fill_manual(values = c("#009E73" ,"#56B4E9","#F0E442","#E69F00"),
  #                  breaks = c("NTrawl", "NOther", "STrawl", "SOther"), name = "Fleet") +
  scale_fill_colorblind7() + 
  #scale_color_manual(values = c("#009E73" ,"#56B4E9","#F0E442","#E69F00"),
  #                   breaks = c("NTrawl", "NOther", "STrawl", "SOther"), name = "Fleet") +
  xlab("Length (cm)") + ylab("Number of fish") +
  facet_wrap(~fleet, nrow =1) + 
  theme_classic(base_size = 15) +
  labs(x = "Length (cm)", y = "Number of fish", fill = "") + 
  scale_y_continuous(labels = scales::comma, expand = c(0, NA), limits = c(0,6000))

ggsave("outputs/fishery_data/summary_fishery_lengths.png", dpi=300, height=6, width=10, units='in')
