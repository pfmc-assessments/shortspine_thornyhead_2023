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


1) Species names both capitalized 
2) nothing working with glossary 
3) When I render 00a.Rmd get:
  
  [WARNING] Citeproc: citation ref not found
! Paragraph ended before \align* was complete.
<to be read again> 
  \par 
l.446 

Error: LaTeX failed to compile _main.tex. See https://yihui.org/tinytex/r/#debugging for debugging tips. See _main.log for more info.
  