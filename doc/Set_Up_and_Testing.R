#sa4ss set-up

# pak::pkg_install("rstudio/tinytex")
# pak::pkg_install("pfmc-assessments/sa4ss")

setwd("C:\\GitHub\\Official_shortspine_thornyhead_2023")

library(sa4ss)
#sa4ss::draft(authors = c("Madison Shipley", 
#              "Joshua Zahner", 
#              "Sabrina Beyer", 
#              "Adam Hayes", 
#              "Pierre-Yves Hernvann", 
#              "Andrea Odell", 
#              "Haley Oleynik", 
#              "Jane Y. Sullivan", 
#              "Matthieu Veron"), create_dir = TRUE)

setwd("doc")


#bookdown::render_book("00a.Rmd", clean = FALSE, output_dir = getwd())

bookdown::render_book("20data.Rmd", clean = TRUE, output_dir = getwd())
bookdown::render_book("00a.Rmd", clean = TRUE, output_dir = getwd())


