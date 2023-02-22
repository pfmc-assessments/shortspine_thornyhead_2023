read.index.data <- function(survey.name){
  
  file.path <- file.path(here::here(), "outputs", "surveys", survey.name, "forSS", "design_based_indices.csv")
  
  return(
    read_csv(file.path, show_col_types=FALSE) %>% mutate(survey=survey.name) %>% print(n=100)
  )
  
}

get.survey.data <- function(survey.name, species="shortspine thornyhead", refresh=FALSE, write=TRUE){
  
  survey.name.path <- str_replace(tolower(survey.name), "[.]", "_")
  data.dir <- here::here("data/") # location of data directory
  
  raw.data.dir <- file.path(data.dir, "raw")
  catch.fname <- file.path(raw.data.dir, paste0(survey.name.path, "_survey_catch.csv")) # raw survey catch filename
  
  if(survey.name %in% c("AFSC.Slope", "Triennial")){
    bio.lengths.fname <- file.path(raw.data.dir, paste0(survey.name.path, "_survey_bio_lengths.csv"))     # raw survey bio filename
    bio.ages.fname <- file.path(raw.data.dir, paste0(survey.name.path, "_survey_bio_ages.csv"))     # raw survey bio filename 
  }else{
    bio.lengths.fname <- file.path(raw.data.dir, paste0(survey.name.path, "_survey_bio.csv"))     # raw survey bio filename
    bio.ages.fname <- file.path(raw.data.dir, paste0(survey.name.path, "_survey_bio.csv"))     # raw survey bio filename
  }
  
  if(!file.exists(catch.fname) | !file.exists(bio.lengths.fname) | !file.exists(bio.ages.fname) | refresh){
    
    print("Pulling new data from nwfscSurvey package.")
    
    catch <- PullCatch.fn(Name = species, 
                          SurveyName = survey.name)
    
    bio   <- PullBio.fn(Name = species, 
                        SurveyName = survey.name)
    
    
    if(write){
        write.csv(catch, catch.fname)
        if(is.list(bio)){
          write.csv(bio$Lengths, bio.lengths.fname)
          write.csv(bio$Ages, bio.ages.fname)
        }else{
          write.csv(bio, bio.lengths.fname) 
        }  
    }
    
  }
  
  tryCatch({
    catch <- read.csv(catch.fname)
    
    if(survey.name %in% c("AFSC.Slope", "Triennial")){
      bio <- list()
      bio$Lengths <- read.csv(bio.lengths.fname)
      bio$Ages <- read.csv(bio.ages.fname)
    }else{
      bio <- read.csv(bio.lengths.fname)
    }
  }, error = function(e){
    print("Not reading from file.")
  })
  
  
  return(list(bio=bio, catch=catch))
  
}
