# load packages ----
library(kableExtra)


# Basic functions ----
.an <- function(x){return(as.numeric(x))}
.ac <- function(x){return(as.character(x))}
.af <- function(x){return(as.factor(x))}



#' 1. Function to update the SA table ----
#' ----------------------------------------------------------- #
#' 
#' @param SumUp (data frame)- Contains the info about the SA already done.
#' @param dir_SensAnal (character string)- path to the Sensitivity Analysis 
#' folder.
#
update_SA_table <- function(SumUp, dir_SensAnal) {
  
  Topic <- data.frame(
    Topic = c(
      "transition",
      "landings",
      "discards",
      "surveys",
      "biological_Info",
      "model"
    ),
    Nam = c(
      "0. Transition",
      "1. Landings",
      "2. Discards",
      "3. Surveys",
      "4. Biological Info",
      "5. Model"
    ),
    ID = 0:5
  )
  
  SumUp <- merge(SumUp, Topic, by = "Topic")
  SumUp <- SumUp[order(SumUp$ID), ]
  rownames(SumUp) <- NULL
  
  row_top <- NULL
  for (i in 1:dim(SumUp)[1]) {
    t <- unique(SumUp$Topic)[i]
    tmpL <- length(which(SumUp$Topic == t))
    row_top <- rbind(row_top,
                     c(which(SumUp$Topic == t)[1],
                       which(SumUp$Topic == t)[tmpL]))
    rownames(row_top)[i] <- t
  }
  
  
  row_group_label_fonts <- list(
    list(bold = T, italic = T),
    list(bold = F, italic = F)
  )
  
  tmpTable <- SumUp[, !colnames(SumUp) %in% c("Topic", "Nam", "ID")]
  colnames(tmpTable)[1] <- ""
  names(tmpTable)[4] <- paste0(colnames(tmpTable)[4], footnote_marker_alphabet(1))
  names(tmpTable)[5] <- paste0(colnames(tmpTable)[5], footnote_marker_alphabet(2))
  names(tmpTable)[6] <- paste0(colnames(tmpTable)[6], footnote_marker_alphabet(2))
  names(tmpTable)[7] <- paste0(colnames(tmpTable)[7], footnote_marker_alphabet(3))
  names(tmpTable)[8] <- paste0(colnames(tmpTable)[8], footnote_marker_alphabet(3))
  
  table <-
    kbl(tmpTable,
        caption = "Sensitivity analyses summary.", booktabs = T,
        align = "r",
        digits = 3,
        escape = F) %>%
    kable_styling(
      full_width = FALSE,
      font_size = 20,
      position = "left",
      latex_options = c("repeat_header",
                        "striped",
                        "hold_position")) %>% 
    landscape() %>%
    kable_paper(full_width = F) %>%
    collapse_rows(columns = c(1:6,10), 
                  row_group_label_position = 'stack', 
                  valign = "middle",
                  row_group_label_fonts = row_group_label_fonts)
  
  for (i in 1:length(Topic$Topic)) {
    Nam <- Topic$Nam[i]
    item <- Topic$Topic[i]
    if(item %in% SumUp$Topic)
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
  table <- table %>% 
    footnote(general = "\nHere is a general comments where to find scripts, folders, and models. \n",
             alphabet = c("The **Folder** is housed in the 'model/Sensitivity_Anal' repertory; \n",
                          "The scripts are housed in the 'R/Sensitivity_Anal' repertory; \n",
                          "The models are housed in the 'model/Sensitivity_Anal/**Folder**' repertory"),
             footnote_as_chunk = T)
  
  
  SumUp <- SumUp[, !colnames(SumUp) %in% c("Nam", "ID")]
  rownames(SumUp) <- NULL
  kableExtra::save_kable(table, 
                         file = file.path(dir_SensAnal, "Summary_Sensitivity_analysis.pdf", fsep = fsep))
  return(SumUp)
}

#' 2. Function to update the summary of models table ----
#' ----------------------------------------------------------- #
#' 
#' @param Models_SA (data frame)- Contains the info about the SA already done.
#' @param dir_SensAnal (character string)- path to the Sensitivity Analysis 
#' folder.
#
update_Models_SA_table <- function(Models_SA, dir_SensAnal) {
  
  Topic <- data.frame(
    Topic = c(
      "transition",
      "landings",
      "discards",
      "surveys",
      "biological_Info",
      "model"
    ),
    Nam = c(
      "0. Transition",
      "1. Landings",
      "2. Discards",
      "3. Surveys",
      "4. Biological Info",
      "5. Model"
    ),
    ID = 0:5
  )
  
  baseModel <- Models_SA[Models_SA$Topic=="",]
  baseModel <- baseModel %>%
    dplyr::mutate(Topic ="",
                  Nam = "",
                  ID = "")
  
  Models_SA <- merge(Models_SA, Topic, by = "Topic")
  Models_SA <- rbind(baseModel, Models_SA)
  rownames(Models_SA) <- NULL
  Models_SA <- Models_SA[order(Models_SA$ID), ]
  
  row_top <- NULL
  for (i in 1:dim(Models_SA)[1]) {
    t <- unique(Models_SA$Topic)[i]
    if (!is.na(t)) {
      tmpL <- length(which(Models_SA$Topic == t))
      row_top <- rbind(row_top,
                       c(which(Models_SA$Topic == t)[1],
                         which(Models_SA$Topic == t)[tmpL]))
      rownames(row_top)[i] <- t
    }
  }
  
  tmpTable <- Models_SA[, !colnames(Models_SA) %in% c("Topic", "Nam", "ID")]
  colnames(tmpTable)[1] <- ""
  table <-
    kbl(tmpTable,
        caption = "Sensitivity analyses models.", booktabs = T,
        align = "r",
        digits = 3) %>%
    kable_styling(
      full_width = FALSE,
      font_size = 20,
      position = "left",
      latex_options = c("repeat_header",
                        "striped",
                        "hold_position")
    ) %>% landscape() %>%
    kable_paper(full_width = F) %>%
    collapse_rows(columns = c(1), 
                  row_group_label_position = 'stack', 
                  valign = "middle")
  
  for (i in 1:length(Topic$Topic)) {
    Nam <- Topic$Nam[i]
    item <- Topic$Topic[i]
    if(item %in% Models_SA$Topic)
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
  
  Models_SA <- Models_SA[, !colnames(Models_SA) %in% c("Nam", "ID")]
  rownames(Models_SA) <- NULL
  kableExtra::save_kable(table, 
                         file = file.path(dir_SensAnal, "Models_Sensitivity_analysis.pdf", fsep = fsep))
  return(Models_SA)
}

#' 2. Function to start a new sensitivity analysis ----
#' ----------------------------------------------------------- #
#' 
#' @param topic (character string)- Indicates the main topic of the sensitivity 
#' analysis. This HAS to be either"transition",  "landings", "discards", "surveys",
#' "biological_Info", or "model".
#' @param object (character string)- Indicates a specific item of 
#' the main topic/model. For example, "Length_Comp", "Age_comp", "Growth", "Fecundity",...
#' If multiple models are built, the length of \code{object} equals the numder of
#' models with a specific input for each model.
#' @param author (character string)- Who leads the sensitivity analysis and runs
#' the model.
#' @param folder_name (character string)- name of the folder to create for that 
#' particular sensitivity analysis. This folder will be housed in the root folder 
#' 'Sensitivity_Anal' and will hold the scripts  used to set up the model and both 
#' models input and output files for this analysis.
#' @param script_model (character string)- Name of the script used to create the 
#' model (without extension).
#' @param script_results (character string)- Name of the script used to analyze 
#' the results from that sensitivity analysis  (without extension).
#' @param base_model (character string)- which model has been used as the basis 
#' of this analysis (before any modification). By default, the function considers
#' the 2013 Assessment model transitioned to the 3.30 version of SS with all
#' parameters estimated i.e., \code{"23.sq.est"}(See "Models_Sensitivity_analysis.pdf")
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
#' 3. Update the "Summary_Sensitivity_analysis.pdf" file housed in the root folder.
#' 4. Update the "Models_Sensitivity_analysis.pdf" file housed in the root folder.
#

NewSensAnal <- function(topic = NULL,
                        object = NULL,
                        author = NULL,
                        folder_name = NULL,
                        script_model = NULL,
                        script_results = NULL,
                        base_model = "23.sq.est",
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
  SumUp <- SA_info$SumUp
  Models_SA <- SA_info$Models_SA
  
  
  
  # 1. Check the input arguments
  if(!topic %in%c("transition", "landings", "discards", "surveys","biological_Info","model")){
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
  } else if(length(new_model)>1 && length(unique(object))==1){
    cat('\n')
    cat('=> The "object" argument is dentic for several models. Please indicate a
 specific item for each model.\n')
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
  } else if(folder_name %in% SumUp$Folder && 
            length(unique(new_model %in% Models_SA$`Model name`))==1 && 
            unique(new_model %in% Models_SA$`Model name`)){
    cat('\n')
    # cat('=> This "folder_name": ',folder_name,' already exist for another sensitivity analysis:\n',
    #     '\t => Please enter a different folder name for your analysis.\n')
    cat('=> This(ese) new model name(s_: ',new_model,' already exist in the folder ',folder_name,':\n',
        '\t => Please enter different model name(s) for your analysis.\n')
    stop()
  }
  if(is.null(script_model)){
    cat('\n')
    cat('=> The "script_model" argument has to be defined. Please provide the name 
 of the script used to implement the SS model used for this sensitivity analysis.\n')
    stop()
  } else if(script_model %in% SumUp$`Script model`){
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
  } else if(script_results %in% SumUp$`Script results`){
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
  } else {
    if(length(new_model)==1){
      if(new_model %in% Models_SA$`Model name`){
        cat('\n')
        cat('=> This "new_model": ',new_model,' already exists for another sensitivity analysis:\n',
            "\t => Please enter a different name for the model you are building for this analysis.\n")
        stop()
      }
    } else { #length(new_model)>1
      if(length(unique(new_model %in% Models_SA$`Model name`))>1){
        wrong <- which(new_model %in% Models_SA$`Model name`)
        cat('\n')
        cat('This "new_model": ',new_model[wrong],' already exists for another sensitivity analysis:\n',
            "\t => Please enter a different name for this new model.\n")
        stop()
      } else if(unique(new_model %in% Models_SA$`Model name`)){
        cat('\n')
        cat('These "new_model": ',new_model,' already exist for another sensitivity analysis:\n',
            "\t => Please enter a different name for the model you are building for this analysis.\n")
        stop()
      } else if(length(base_model)==1){
        cat("\nYou entered only one model as base model for this analysis. The new",
            " created models will therefore be based on the model:",base_model,"\n")
      }
      
    }
  }
  
  # 2. Set an ID for this sensitivity analysis
  Topic <- data.frame(
    Topic = c(
      "transition",
      "landings",
      "discards",
      "surveys",
      "biological_Info",
      "model"
    ),
    Nam = c(
      "0. Transition",
      "1. Landings",
      "2. Discards",
      "3. Surveys",
      "4. Biological Info",
      "5. Model"
    ),
    ID = 0:5
  )
  
  tmpSumUp <- SumUp[SumUp$Topic==topic,]
  ID_topic <- Topic[Topic$Topic==topic,"ID"]
  
  if(dim(tmpSumUp)[1]==0){
    SA_ID <- paste0("Item ",ID_topic, ".1")
  } else {
    IDs <- max(.an(stringr::str_split_fixed(string = tmpSumUp$`SA number`,
                              pattern=paste0(ID_topic,"."), n = 2)[,2]))
    IDs <- IDs +1
    SA_ID <- paste0("Item ",ID_topic, ".",IDs)
  }

  # 3. Create the root folder for the analysis
  baseWD <- paste0(ID_topic, ".",IDs,"_",folder_name)
  WD <- file.path(dir_SensAnal, baseWD, fsep = fsep)
  if(dir.exists(WD)){ # double check
    cat("The specified folder name (",folder_name," already exist for a sensitivity
 analysis. Please set another name.\n")
    stop()
  } else {
    dir.create(WD)
  }
  
  # 3. Create a descriptive .txt file for this analysis
  
  out <- file.path(WD, "Sensitivity_Analysis_Features.txt", fsep = fsep)
  fs::file_create(path = out)
  
  # 3. Create the root folder for each model and copy and paste 
  # the input files from the base model
  if (length(new_model) > 1)
    if(length(base_model)==1)
      base_model <- rep(base_model, length(new_model))
  pathMod <- NULL
  
  for(m in 1:length(new_model)){
    tmpWD <- file.path(WD, new_model[m],fsep = fsep)
    # Create directory
    dir.create(tmpWD)
    # Save the directory
    pathMod <- c(pathMod, file.path("model", "Sensitivity_Anal", baseWD, new_model[m]))
    
    # Copy SS input files from the base model
    modelFrom <- Models_SA[Models_SA$`Model name`==base_model[m], "path"]
    modelFrom <- file.path(here::here(), modelFrom, fsep = fsep)
    SS.files <- dir(modelFrom, "*.ss", ignore.case = TRUE, all.files = TRUE)
    file.copy(
      from = file.path(modelFrom, SS.files, fsep = fsep),
      to = file.path(tmpWD, SS.files, fsep = fsep),
      overwrite = TRUE, copy.date = TRUE
    )
    if(m==1)
      cat("- Copying SS input files from :\n")
    cat("=>",modelFrom, "\t for the model :",new_model[m],"\n")
  }
  
  
  # Ask the user for a description of the sensitivity analysis
  Features <- NULL
  if (length(new_model) > 1){
    Mod_Feat <- NULL
    cat("\nYou are going to build different models for this sensitivity analysis.\n")
    cat("\nPlease first provide a global description of this analysis and then a description of each model.\n")
  } else {
    cat("Please first provide a global description of this analysis.")
  }
  
  # Get the global description of the sensitivity analysis
  while (is.null(Features)) {
    Impl <-
      readline(prompt = "Please describe the general features of this sensistivity analysis:")
    Features <- Impl
    Sys.sleep(0.1)
  }
  
  # Get a description of each model
  if (length(new_model) > 1) {
    
    Nimpl <- length(new_model)
    
    while (is.null(Mod_Feat)) {
      
      for (i in 1:Nimpl) {
        
        eval(parse(text = paste0(
          "Mod_", i, " <- readline(prompt = 'Please describe the ", new_model[i], " model: ')"
        )))
        
        eval(parse(text = paste0(
          "Mod_", i, " <- paste0('\n# - Model ", new_model[i], ":\n# ', Mod_", i, "\n)"
        )))
        
      }
      if (i == Nimpl)
        eval(parse(text =
                     paste0(
                       'Mod_Feat <-paste(',
                       paste(' Mod_', 1:Nimpl, sep = '', collapse = ','),
                       ')'
                     )))
      
      Sys.sleep(0.1)
    }
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
  if (length(new_model) > 1) {
    cat("# Names of the models created:\n")
    for(m in 1:length(new_model))
      cat("# - ", new_model[m], "\n")
  } else {
    cat("# Name of the model created:", new_model, "\n")
  }
  cat("# *** \n")
  cat("# \n")
  if (length(new_model) > 1) {
    cat("# This analysis has been developped based on the following models: \n")
    cat("# New model \t Base model\n")
    for(m in 1:length(new_model))
      cat("#", new_model[m], "\t",base_model[m],"\n")
  } else {
    cat("# This analysis has been developped based on the following model: ", base_model, "\n")
  }
  cat("# \n")
  cat("# Results are stored in the following foler: \n")
  cat("#\t", file.path(dir_SensAnal,folder_name,fsep = fsep), "\n")
  cat("# Name of the script used to build the new model: \n")
  cat("#\t",file.path(dirScript_SensAnal,script_model, fsep = fsep), ".R\n")
  cat("# Name of the script used to analyze the results from this model: \n")
  cat("#\t",file.path(dirScript_SensAnal,script_results, fsep = fsep), ".R\n")
  cat("# \n")
  if(length(new_model) > 1){
    cat("# General features: \n")
    cat("#",Features,"\n")
    cat("# \n")
    cat("# Model features:")
    # cat("#", Mod_Feat, "\n")
    cat(Mod_Feat)
  } else {
    cat("# Features: \n")
    cat(Features)
  }
  cat("\n")
  base::sink()
  

  # 3. Update the "Summary_Sensitivity_analysis.pdf"
  cat("- Now updating the 'Summary_Sensitivity_analysis.pdf' file.\n")
  script_model <- paste0(script_model,".R")
  script_results <- paste0(script_results,".R")
  
  SumUp <- SumUp %>% 
    tibble::add_row('SA number' = SA_ID,
            Topic = topic,
            Object = object,
            Author = author,
            Date = timeSA,
            Folder = folder_name,
            'Script model' = script_model,
            'Script results' = script_results,
            'Base model' = base_model,
            'New model' = new_model,
            Features = Features)
  suppressMessages(SumUp <- update_SA_table(SumUp = SumUp, dir_SensAnal = dir_SensAnal))
  
  
  
  # 3. Update the "Models_Sensitivity_analysis.pdf"
  cat("- Now updating the 'Models_Sensitivity_analysis.pdf' file.\n")
  cat("Please provide a short description for each model you're gonna implement.
\t => Refer to the 'Models_Sensitivity_analysis.pdf' for example.")

  # Get a description of each model
    Nimpl <- length(new_model)
    Mod_dsc <- NULL
    while (is.null(Mod_dsc)) {
      
      for (i in 1:Nimpl) {
        
        eval(parse(text = paste0(
          "dsc_", i, " <- readline(prompt = 'Short description for the ", new_model[i], " model: ')"
        )))
      }
      if (i == Nimpl)
        Mod_dsc <- "ok"
      Sys.sleep(0.1)
    }
    Desc <- NULL
    for(m in 1:Nimpl){
      eval(parse(text=paste0(
        "Desc <- c(Desc, dsc_",m,")"
      )))
    }
  Models_SA <- Models_SA %>% 
    tibble::add_row('SA number' = SA_ID,
                    Topic = topic,
                    Object = object,
                    'Model name' = new_model,
                    Description = Desc,
                    path = pathMod
                    )
  suppressMessages(SumUp <- update_Models_SA_table(Models_SA = Models_SA, dir_SensAnal = dir_SensAnal))

  # 4. Update SA_info
  SA_info <- NULL
  SA_info <- list(SumUp = SumUp, Models_SA = Models_SA)
  save(SA_info, file = file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
}
# ----------------------------------------------------------