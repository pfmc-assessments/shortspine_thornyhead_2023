library(tidyverse)
library(ggplot2)

source(file=file.path(here::here(), "R", "utils", "colors.R"))

load(file=file.path(here::here(), "data", "processed", "wcgbts_index_dg.Rdata"))
indices.dg <- as_tibble(index_areas) %>%
  mutate(
    area=recode_factor(
      area,
      !!!c(
        "coastwide" = "Total",
        "CA" = "California",
        "OR" = "Oregon",
        "WA" = "Washington"
      )
    ),
    method="delta-gamma"
  )

load(file=file.path(here::here(), "data", "processed", "wcgbts_index_dgm.Rdata"))
indices.dgm <- as_tibble(index_areas) %>%
  mutate(
    area=recode_factor(
      area,
      !!!c(
        "coastwide" = "Total",
        "CA" = "California",
        "OR" = "Oregon",
        "WA" = "Washington"
      )
    ),
    method="delta-gamma-mixed"
  )

load(file=file.path(here::here(), "data", "processed", "wcgbts_index_dln.Rdata"))
indices.dln <- as_tibble(index_areas) %>%
  mutate(
    area=recode_factor(
      area,
      !!!c(
        "coastwide" = "Total",
        "CA" = "California",
        "OR" = "Oregon",
        "WA" = "Washington"
      )
    ),
    method="delta-lognormal"
  )

# The delta-lognormal-mixed model is bad. Lots of NaNs. Do not analyze.
#
# load(file=file.path(here::here(), "data", "processed", "wcgbts_index_dlnm.Rdata"))
# indices.dlnm <- as_tibble(index_areas) %>%
#   mutate(
#     area=recode_factor(
#       area,
#       !!!c(
#         "coastwide" = "Total",
#         "CA" = "California",
#         "OR" = "Oregon",
#         "WA" = "Washington"
#       )
#     ),
#     method="delta-lognormal-mixed"
#   )

indices <- bind_rows(indices.dg, indices.dln)

ggplot(indices, aes(x=year, y=est, ymin=lwr, ymax=upr, color=area, fill=area, shape=method, linetype=method))+
  geom_pointrange()+
  geom_line()+
  scale_color_colorblind()+
  scale_fill_colorblind()+
  scale_shape_manual(values=c(16, 1, 100))+
  scale_y_continuous(breaks=seq(0, 125000, 25000), labels=scales::comma)+
  labs(x="Year", y="Estimated Biomass (mt)", title="WCGBTS Model-based Index of Abundance", color="State")+
  guides(fill="none")+
  facet_wrap(~method)+
  theme_classic()+
  theme(
    panel.grid.major.y = element_line()
  )

ggsave(file.path(here::here(), "outputs", "surveys", "wcgbts_geostat_indices_comparison.png"), dpi=300, width=10, height=7, units = "in")
