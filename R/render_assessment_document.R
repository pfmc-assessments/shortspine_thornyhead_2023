library(sa4ss)
library(here)
library(float)
library(flextable)
library(kableExtra)
library(tidyverse)

fig_dir1 <- here::here("doc", "FinalFigs", "Intro")
fig_dir2 <- here::here("doc", "FinalFigs", "Data")
fig_dir3 <- here::here("doc", "FinalFigs", "Base")
fig_dir4 <- here::here("doc", "FinalFigs", "Sensitivities")
fig_dir5 <- here::here("doc", "FinalFigs", "Retros")
fig_dir6 <- here::here("doc", "FinalFigs", "Profiles")
fig_dir7 <- here::here("doc", "FinalFigs", "Jitters")
fig_dir8 <- here::here("doc", "FinalFigs", "bridging")

tab_dir1 <- here::here("doc", "FinalTables", "Summary")
#tab_dir1 <- here::here("model", "Sensitivity_Anal", "5.8_Francis_Reweighting_2", "1_23.model.francis_2", "run", "tables")
tab_dir2 <- here::here("doc", "FinalTables", "Data")
tab_dir3 <- here::here("doc", "FinalTables", "Sensitivities")
tab_dir4 <- here::here("doc", "FinalTables", "Model")
#Insert figure 
#Figure \caption{(\#tab:catch_tab)Catches by fleet.} 

#if wanting a new page \newpage

comma <- function(x, digits = 0) {
  formatC(x, big.mark = ",", digits, format = "f")
}

print.numeric <- function(x, digits) {
  formatC(x, digits = digits, format = "f")
}

setwd(file.path(here::here(), "doc"))
# sa4ss::draft(authors = c("Madison Shipley", "Joshua Zahner", 
#                          "Sabrina Beyer", "Adam Hayes", "Pierre-Yves Hernvann",
#                          "Andrea Odell", "Haley Oleynik", "Jane Y. Sullivan", "Matthieu Veron"),
#              species = "Shortspine Thornyhead",
#              latin = "Sebastolobus alascanus",
#              coast = "US West",
#              create_dir = FALSE)
bookdown::render_book("00a.Rmd", clean = TRUE, output_dir = getwd())
setwd("..")