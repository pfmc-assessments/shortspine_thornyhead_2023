library(sa4ss)
setwd(file.path(here::here(), "doc"))
# sa4ss::draft(authors = c("Madison Shipley", "Joshua Zahner", 
#                          "Sabrina Beyer", "Adam Hayes", "Pierre-Yves Hernvann",
#                          "Andrea Odell", "Haley Oleynik", "Jane Y. Sullivan", "Matthieu Veron"),
#              species = "Shortspine Thornyhead",
#              latin = "Sebastolobus alascanus",
#              coast = "US West",
#              create_dir = FALSE)
bookdown::render_book("00a.Rmd", clean = FALSE, output_dir = getwd())
setwd("..")