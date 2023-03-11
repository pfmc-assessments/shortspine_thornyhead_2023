# load packages ----
library(kableExtra)


# Basic functions ----
.an <- function(x){return(as.numeric(x))}
.ac <- function(x){return(as.character(x))}
.af <- function(x){return(as.factor(x))}



#' 1. Function to update the SA table ----
#' ----------------------------------------------------------- #
#' 
#' @param SA_info (data frame)- Contains the info about the SA already done.
#' @param dir_SensAnal (character string)- path to the Sensitivity Analysis 
#' folder.
#
update_SA_table <- function(SA_info, dir_SensAnal) {
  
  
  Topic <- data.frame(
    Topic = c(
      "landings",
      "discards",
      "surveys",
      "biological_Info",
      "model"
    ),
    Nam = c(
      "1. Landings",
      "2. Discards",
      "3. Surveys",
      "4. Biological Info",
      "5. Model"
    ),
    ID = 1:5
  )
  
  SA_info <- merge(SA_info, Topic, by = "Topic")
  rownames(SA_info) <- SA_info$Object
  
  SA_info <- SA_info[order(SA_info$ID), ]
  
  row_top <- NULL
  for (i in 1:dim(SA_info)[1]) {
    t <- unique(SA_info$Topic)[i]
    tmpL <- length(which(SA_info$Topic == t))
    row_top <- rbind(row_top,
                     c(which(SA_info$Topic == t)[1],
                       which(SA_info$Topic == t)[tmpL]))
    rownames(row_top)[i] <- t
  }
  
  
  table <-
    kbl(SA_info[, !colnames(SA_info) %in% c("Topic", "Nam", "ID", "Object")],
        caption = "Sensitivity analyses summary.", booktabs = T, align = "c", digits = 3) %>%
    kable_styling(
      full_width = FALSE,
      font_size = 20,
      position = "left",
      latex_options = c("repeat_header",
                        "striped",
                        "hold_position")
    ) %>% landscape()
  
  for (i in 1:length(Topic$Topic)) {
    Nam <- Topic$Nam[i]
    item <- Topic$Topic[i]
    if(item %in% SA_info$Topic)
      eval(parse(
        text = paste0(
          "table <- table %>% pack_rows('",
          Nam,
          "', row_top['",
          item,
          "',1], row_top['",
          item,
          "', 2])"
        )
      ))
  }
  
  SA_info <- SA_info[, !colnames(SA_info) %in% c("Nam", "ID")]
  rownames(SA_info) <- NULL
  kableExtra::save_kable(table, 
                         file = file.path(dir_SensAnal, "Sensitivity_analysis.pdf", fsep = fsep))
  return(SA_info)
}



#' 2. Function to start a new sensitivity analysis ----
#' ----------------------------------------------------------- #
#' 
#' @param topic (character string)- Indicates the main topic of the sensitivity 
#' analysis. This HAS to be either "landings", "discards", "surveys",
#' "biological_Info", or "model".
#' @param object (character string)- Indicates a specific item of 
#' the main topic. For example, "Length_Comp", "Age_comp", "Growth", "Fecundity",...
#' @param author (character string)- Who leads the sensitivity analysis and runs
#' the model.
#' @param folder_name (character string)- name of the folder to create for that 
#' particular sensitivity analysis. This folder will be housed in the root folder 
#' 'Sensitivity_Anal' and will hold the scipts  used to set up the model and both 
#' models input and output files for this analysis.
#' @param script_model (character string)- Name of the script used to create the 
#' model.
#' @param script_results (character string)- Name of the script used to analyze 
#' the results from that sensitivty analysis.
#' @param base_model (character string)- which model has been used as the basis 
#' of this analysis (before any modification).
#' @param new_model (character string)- name of the model you're gonna develop for
#' this analysis.
#' 
#' @details
#' The function creates:
#' 1. one folder named as \code{folder_name} in the 
#'    "shortspine_thornyhead_2023/model/Sensitivity_Anal" repertory. This folder will
#'    house model input and output files,
#' 2. the "Sensitivity_Analysis_Features.txt" file (in the previously created folder).
#'    This file summaryzes the features of the sensitivity analysis 
#'    (\code{topic}, \code{object}, \code{author}, ...)
#' 3. Update the "Sensitivity_analysis.pdf" file housed in the root folder.
#

NewSensAnal <- function(topic = NULL,
                        object = NULL,
                        author = NULL,
                        folder_name = NULL,
                        script_model = NULL,
                        script_results = NULL,
                        base_model = NULL,
                        new_model = NULL
){
  
  # local declarations
  fsep <- .Platform$file.sep
  
  dir_model <- file.path(here::here(), "model", fsep = fsep)
  dir_script <- file.path(here::here(), "R", fsep = fsep)
  dir_SensAnal <- file.path(dir_model, "Sensitivity_Anal", fsep = fsep)
  dirScript_SensAnal  <- file.path(dir_script, "Sensitivity_Anal", fsep = fsep)
  
  # load the SA_info dataframe
  load(file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
  
  # 1. Check the input arguments
  if(!topic %in%c("landings", "discards", "surveys","biological_Info","model")){
    cat('\n')
    cat('=> The "topic" argument has to be defined as either  "landings", "discards", 
 "surveys","biological_Info", or "model".\n')
    stop()
  }
  if(is.null(object)){
    cat('\n')
    cat('=> The "object" argument has to be defined. Please indicate the item of
 your sensitivity analysis (e.g., "Length_Comp", "Age_comp", "Growth", "Fecundity",...)\n')
    stop()
  }
  if(is.null(author)){
    cat('\n')
    cat('=> The "author" argument has to be defined. Please provide an author name
 (leader of the sensitivity analysis).\n')
    stop()
  }
  if(is.null(folder_name)){
    cat('\n')
    cat('=> The "folder_name" argument has to be defined. Please provide a name
 for the folder where model input and output files will be save for this analyisis.\n')
    stop()
  } else if(folder_name %in% SA_info$Folder){
    cat('\n')
    cat('=> This "folder_name": ',folder_name,' already exist for another sensitivity analysis:\n',
        '\t => Please enter a different folder name for your analysis.\n')
    stop()
  }
  if(is.null(script_model)){
    cat('\n')
    cat('=> The "script_model" argument has to be defined. Please provide the name 
 of the script used to implement the SS model used for this sensitivity analysis.\n')
    stop()
  } else if(script_model %in% SA_info$`Script model`){
    cat('\n')
    cat('=> This "script_model": ',script_model,' already exist for another sensitivity analysis:\n',
        "\t => Please enter a different name for the script used to create the model for this analysis.\n")
    stop()
  }
  
  if(is.null(script_results)){
    cat('\n')
    cat('=> The "script_results" argument has to be defined. Please provide the name 
 of the script used to analyze the results of this sensitivity analysis.\n')
    stop()
  } else if(script_results %in% SA_info$`Script results`){
    cat('\n')
    cat('=> This "script_results": ', script_results ,' already exist for another sensitivity analysis:\n',
        "\t => Please enter a different name for the script used to analyze the
 outputs of the model for this analysis.\n")
    stop()
  }
  
  if(is.null(base_model)){
    cat('\n')
    cat('=> The "base_model" argument has to be defined. Please provide the name 
 of the model used as a basis for this sensitivity analysis.\n')
    stop()
  }
  
  if(is.null(new_model)){
    cat('\n')
    cat('=> The "new_model" argument has to be defined. Please provide the name 
 of the model you are building for this sensitivity analysis.\n')
    stop()
  } else if(new_model %in% SA_info$`New model`){
    cat('\n')
    cat('=> This "new_model": ',new_model,' already exist for another sensitivity analysis:\n',
        "\t => Please enter a different name for the model you are building for this analysis.\n")
    stop()
  }
  
  # 2. Create the folder for the analysis
  WD <- file.path(dir_SensAnal, folder_name, fsep = fsep)
  if(dir.exists(WD)){ # double check
    cat("The specified folder name (",folder_name," already exist for a sensitivity
 analysis. Please set another name.")
    stop()
  } else {
    dir.create(WD)
  }
  
  # 3. Create a descriptive .txt file for this analysis
  
  out <- file.path(WD, "Sensitivity_Analysis_Features.txt", fsep = fsep)
  fs::file_create(path = out)
  
  # Ask the user for a description of the sensitivity analysis
  Features <- NULL
  
  while (is.null(Features)) {
    Impl <- readline(prompt = "Please describe the features of this sensistivity analysis.")
    Features <- Impl
    Sys.sleep(0.1)
  }
  
  timeSA <- as.character(Sys.time())
  
  base::sink(out)
  cat("# ============================================================ #\n")
  cat("#              Sensitivity analysis description \n")
  cat("# ============================================================ #\n")
  cat("# \n")
  cat("# *** \n")
  cat("# Topic of the sensitivity analysis: ", topic, "\n")
  cat("# Specific item in that topic: ", object, "\n")
  cat("# Author: ", author, "\n")
  cat("# Date:", timeSA, "\n")
  cat("# Model name:", new_model, "\n")
  cat("# *** \n")
  cat("# \n")
  cat("# This analysis has been developped based on the following model: ", base_model, "\n")
  cat("# Results are stored in the following foler: ", folder_name, "\n")
  cat("# Name of the script used to build the new model: ", script_model, "\n")
  cat("# Name of the script used to analyze the results from this model: ", script_results, "\n")
  cat("# \n")
  cat("# Features: \n")
  cat(Features)
  cat("\n")
  base::sink()
  
  # 3. Update the "Sensitivity_analysis.pdf"
  
  # SA_info %<>%
  #   dplyr::summarise(Topic = topic,
  #             Object = object,
  #             Author = author,
  #             Date = timeSA,
  #             Folder = folder_name,
  #             'Script model' = script_model,
  #             'Script results' = script_results,
  #             'Base model' = base_model,
  #             'New model' = new_model,
  #             Features = Features
  #             ) %>%
  #   dplyr::bind_rows(SA_info, .)
  # 
  tmp <- data.frame(Topic = topic,
                    Object = object,
                    Author = author,
                    Date = timeSA,
                    Folder = folder_name,
                    'Script model' = script_model,
                    'Script results' = script_results,
                    'Base model' = base_model,
                    'New model' = new_model,
                    Features = Features
  )
  colnames(tmp) <- colnames(SA_info)
  SA_info <- rbind(SA_info,tmp)
  
  SA_info <- update_SA_table(SA_info = SA_info, dir_SensAnal = dir_SensAnal)
  save(SA_info, file = file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
}
# ----------------------------------------------------------