read.index.data <- function(survey.name){
  
  file.path <- file.path(here::here(), "outputs", "surveys", survey.name, "forSS", "design_based_indices.csv")
  
  return(
    read_csv(file.path, show_col_types=FALSE) %>% mutate(survey=survey.name) %>% print(n=100)
  )
  
}