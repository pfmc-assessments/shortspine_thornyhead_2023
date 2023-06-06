# load packages ----
library(kableExtra)


# Basic functions ----
an <- function(x) {
  return(as.numeric(x))
}
ac <- function(x) {
  return(as.character(x))
}
af <- function(x) {
  return(as.factor(x))
}


#' 0. Function to Create a dialogue box ----
#' ----------------------------------------------------------- #
#'
#' @param message (character string)- Message to print in the dialogue box
#' @param type (character string)- Type of box
#'
#' @return "yes", "no", "ok", "cancel"
#
# RStudio version (need at least version 1.1.67)
# No yesnocancel box => ask in two stages (ugly, but what to do?)
DialogBox <- function(message,
                      type = c("ok", "okcancel", "yesno",
                               "yesnocancel")) {
  if (rstudioapi::getVersion() < '1.1.67')
    return(NULL)
  type <- match.arg(type)
  if (type == "ok") {
    alarm()
    rstudioapi::showDialog(title = "R Message",
                           message = message,
                           url = "")
    return(invisible("ok"))
  } else if (type == "yesnocancel") {
    type <- "yesno"
    confirm <- TRUE
  } else
    confirm <- FALSE
  # Now, we have only "okcancel" or "yesno"
  if (type == "okcancel") {
    res <-
      rstudioapi::showQuestion(
        title = "R Question",
        message = message,
        ok = "OK",
        cancel = "Cancel"
      )
    if (res)
      res <- "ok"
    else
      res <- "cancel"
  } else {
    res <-
      rstudioapi::showQuestion(
        title = "R Question",
        message = message,
        ok = "Yes",
        cancel = "No"
      )
    if (res)
      res <- "yes"
    else
      res <- "no"
  }
  # Do we ask to continue (if was yesnocancel)?
  if (confirm) {
    res2 <- rstudioapi::showQuestion(
      title = "R Question",
      message = "Continue?",
      ok = "Yes",
      cancel = "No"
    )
    if (!res2)
      res <- "cancel"
  }
  res
}
# ----------------------------------------------------------

#' 0.1 Function to ask the user if he wants to restart from scratch the SA ----
#' ----------------------------------------------------------- #
#' @details
#' This offers the user the possibility to copy again from the base model directory
#' one or several SS input files. This is useful if a new input file has already been
#' implemented and the user wants to make new modifications starting on the same
#' basis of input values.
#'
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
#' @return copy one or several SS input files based on the base model, the new model
#' and the SS file asked.
#
Restart_SA_modeldvpt <-
  function(base.model = NULL,
           curr.model = NULL,
           files = NULL) {
    mess1 <-
      "Do you want rebuild from scratch one (or several) SS input file(s) for this sensitivity analysis?
This ensures that you start from the same basis as your base model if you already have
written one or several new input files for your new model."
    restart <- ifelse(is.null(base.model),
                      DialogBox(message = mess1, type = 'yesno'),
                      "yes")
    
    if (restart == 'yes') {
      title <- "Name of the base model"
      mess2 <- "Please indicate the name of your base model."
      modelBase <- ifelse(
        is.null(base.model),
        rstudioapi::showPrompt(title, message = mess2, default = "(e.g., 23.sq.fixQ)"),
        base.model
      )
      if (!is.null(modelBase)) {
        title <- "Name of the new model"
        mess3 <-
          "Please indicate the name of the model you're currently developing."
        modelDvpt <- ifelse(
          is.null(curr.model),
          rstudioapi::showPrompt(title, message = mess3, default = "(e.g., 23.sq.fix)"),
          curr.model
        )
      }
      if (!is.null(modelDvpt)) {
        title <- "Stock Synthesis Input files"
        
        mess4 <-
          paste(
            "Please indicate the SS input file(s) you would like to copy from the your base model:",
            modelBase,
            ". Options are: 'starter','control', 'data','forecast', 'data.ss_new', 'data_echo.ss_new', or 'all'"
          )
        SSfiles <- ifelse(
          is.null(files),
          rstudioapi::showPrompt(title, message = mess4, default = "(e.g., control)"),
          files
        )
      }
      if (!is.null(SSfiles))
        copy_BaseModel_SSinputs(base_model = modelBase,
                                Dvpt_model = modelDvpt,
                                SS_file = SSfiles)
    }
  }
# ----------------------------------------------------------


#' 1. Function to update the SA table ----
#' ----------------------------------------------------------- #
#'
#' @param SumUp (data frame)- Contains the info about the SA already done.
#' @param dir_SensAnal (character string)- path to the Sensitivity Analysis
#' folder.
#
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
update_SA_table <- function(SumUp, dir_SensAnal) {
  # local declarations
  fsep <- .Platform$file.sep
  
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
  SumUp <- SumUp[order(SumUp$ID),]
  tmpOrder <- gsub(x = SumUp$`SA number`, pattern = "Item ", replacement = "")
  tmpOrdered <- NULL
  for(i in 1:length(tmpOrder)){
    tmpOrdered <- rbind(tmpOrdered, 
                        c(i,
                          an(unlist(strsplit(tmpOrder[i], "[.]"))[1]),
                          an(unlist(strsplit(tmpOrder[i], "[.]"))[2]))
    )
  }
  tmpOrdered <- as.data.frame(tmpOrdered)
  tmpOrdered <- tmpOrdered[
    with(tmpOrdered, order(tmpOrdered[,2], tmpOrdered[,3])),
  ]
  SumUp <- SumUp[tmpOrdered$V1,]
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
  
  
  row_group_label_fonts <- list(list(bold = T, italic = T),
                                list(bold = F, italic = F))
  
  tmpTable <- SumUp[,!colnames(SumUp) %in% c("Topic", "Nam", "ID")]
  colnames(tmpTable)[1] <- ""
  names(tmpTable)[4] <-
    paste0(colnames(tmpTable)[4], footnote_marker_alphabet(1))
  names(tmpTable)[5] <-
    paste0(colnames(tmpTable)[5], footnote_marker_alphabet(2))
  names(tmpTable)[6] <-
    paste0(colnames(tmpTable)[6], footnote_marker_alphabet(2))
  names(tmpTable)[7] <-
    paste0(colnames(tmpTable)[7], footnote_marker_alphabet(3))
  names(tmpTable)[8] <-
    paste0(colnames(tmpTable)[8], footnote_marker_alphabet(3))
  
  table <-
    kbl(
      tmpTable,
      caption = "Sensitivity analyses summary.",
      booktabs = T,
      align = "r",
      digits = 3,
      escape = F
    ) %>%
    kable_styling(
      full_width = FALSE,
      font_size = 20,
      position = "left",
      latex_options = c("repeat_header",
                        "striped",
                        "hold_position")
    ) %>%
    landscape() %>%
    kable_paper(full_width = F) %>%
    # collapse_rows(columns = c(1:6,10),
    #               row_group_label_position = 'stack',
    #               valign = "middle",
    #               row_group_label_fonts = row_group_label_fonts)
    collapse_rows(
      columns = c(1, 10),
      row_group_label_position = 'stack',
      valign = "middle",
      row_group_label_fonts = row_group_label_fonts
    )
  #
  for (i in 1:length(Topic$Topic)) {
    Nam <- Topic$Nam[i]
    item <- Topic$Topic[i]
    if (item %in% SumUp$Topic)
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
    footnote(
      general = "\nHere is a general comments where to find scripts, folders, and models. \n",
      alphabet = c(
        "The **Folder** is housed in the 'model/Sensitivity_Anal' repertory; \n",
        "The scripts are housed in the 'R/ss/Sensitivity_Anal' repertory; \n",
        "The models are housed in the 'model/Sensitivity_Anal/**Folder**' repertory"
      ),
      footnote_as_chunk = T
    )
  
  
  SumUp <- SumUp[,!colnames(SumUp) %in% c("Nam", "ID")]
  rownames(SumUp) <- NULL
  fileNam1 <-
    file.path(dir_SensAnal, "Summary_Sensitivity_analysis.pdf", fsep = fsep)
  base::unlink(fileNam1, recursive = TRUE, force = TRUE)
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
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
update_Models_SA_table <- function(Models_SA, dir_SensAnal) {
  # local declarations
  fsep <- .Platform$file.sep
  
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
  
  baseModel <- Models_SA[Models_SA$Topic == "", ]
  baseModel <- baseModel %>%
    dplyr::mutate(Topic = "",
                  Nam = "",
                  ID = "")
  
  Models_SA <- merge(Models_SA, Topic, by = "Topic")
  Models_SA <- rbind(baseModel, Models_SA)
  Models_SA <- Models_SA[order(Models_SA$ID),]
  
  tmpOrder <- gsub(x = Models_SA$`SA number`, pattern = "Item ", replacement = "")
  tmpOrdered <- NULL
  for(i in 1:length(tmpOrder)){
    tmpOrdered <- rbind(tmpOrdered, 
                        c(i,
                          an(unlist(strsplit(tmpOrder[i], "[.]"))[1]),
                          an(unlist(strsplit(tmpOrder[i], "[.]"))[2]))
    )
  }
  tmpOrdered <- as.data.frame(tmpOrdered)
  tmpOrdered <- tmpOrdered[
    with(tmpOrdered, order(tmpOrdered[,2], tmpOrdered[,3])),
  ]
  tmpOrderedNA <- tmpOrdered[which(is.na(tmpOrdered$V2)),]
  tmpOrderedNA <- tmpOrderedNA[order(tmpOrderedNA$V1),]
  tmpOrdered <- rbind(tmpOrderedNA,
                      tmpOrdered[which(!is.na(tmpOrdered$V2)),]
  )
  Models_SA <- Models_SA[tmpOrdered$V1,]
  
  row_top <- NULL
  for (i in 1:dim(Models_SA)[1]) {
    t <- unique(Models_SA$Topic)[i]
    if (!is.na(t)) {
      tmpL <- length(which(Models_SA$Topic == t))
      row_top <- rbind(row_top,
                       c(
                         which(Models_SA$Topic == t)[1],
                         which(Models_SA$Topic == t)[tmpL]
                       ))
      rownames(row_top)[i] <- t
    }
  }
  
  tmpTable <-
    Models_SA[,!colnames(Models_SA) %in% c("Topic", "Nam", "ID")]
  colnames(tmpTable)[1] <- ""
  table <-
    kbl(
      tmpTable,
      row.names = FALSE,
      caption = "Sensitivity analyses models.",
      booktabs = T,
      align = "r",
      digits = 3
    ) %>%
    kable_styling(
      full_width = FALSE,
      font_size = 20,
      position = "left",
      latex_options = c("repeat_header",
                        "striped",
                        "hold_position")
    ) %>% landscape() %>%
    kable_paper(full_width = F) %>%
    collapse_rows(
      columns = c(1),
      row_group_label_position = 'stack',
      valign = "middle"
    )
  
  for (i in 1:length(Topic$Topic)) {
    Nam <- Topic$Nam[i]
    item <- Topic$Topic[i]
    if (item %in% Models_SA$Topic)
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
  
  Models_SA <- Models_SA[,!colnames(Models_SA) %in% c("Nam", "ID")]
  unlink(
    x = file.path(dir_SensAnal, "Models_Sensitivity_analysis.pdf", fsep = fsep),
    recursive = TRUE,
    force = TRUE
  )
  kableExtra::save_kable(table,
                         file = file.path(dir_SensAnal, "Models_Sensitivity_analysis.pdf", fsep = fsep))
  return(Models_SA)
}

#' 3. Function to start a new sensitivity analysis ----
#' ----------------------------------------------------------- #
#'
#' @param pool (character string) - Indicates in which pool of the workflow 
#' the sensitivity analysis is developed. When working on bridging model, 
#' \code{pool = ''}, when working on sensitivity analyses for the 
#' "Base Model" chosen for the year of the assessment, \code{pool = 'base_model'} 
#' and, when working on sensitivity analyses realized during the STAR Panel, 
#' \code{pool = 'star_panel'}. 
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
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
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
#' 5. Generate SA-specific templates for the scripts to build and analyze the models
#

NewSensAnal <- function(pool = "",
                        topic = NULL,
                        object = NULL,
                        author = NULL,
                        folder_name = NULL,
                        script_model = NULL,
                        script_results = NULL,
                        base_model = "23.sq.est",
                        new_model = NULL) {
  # local declarations
  fsep <- .Platform$file.sep
  
  dir_model <- file.path(here::here(), "model", fsep = fsep)
  dir_script <- file.path(here::here(), "R", fsep = fsep)
  # dir_SensAnal <-
  #   file.path(dir_model, "Sensitivity_Anal", fsep = fsep)
  if(pool == ""){
    tmpDirPool <- ""
  } else if (pool == "base_model"){
    tmpDirPool <- "Base_Model"
  } else if (pool == "star_panel"){
    tmpDirPool <- "STAR_Panel"
  } else {
    stop("This pool('",pool,"')does not exist in the workflow")
  }
  dir_SensAnal <- file.path(dir_model, "Sensitivity_Anal", tmpDirPool, fsep = fsep)
  
  dirScript_SensAnal  <-
    file.path(dir_script, "ss", "Sensitivity_Anal", fsep = fsep)
  
  # load the SA_info dataframe
  load(file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
  SumUp <- SA_info$SumUp
  Models_SA <- SA_info$Models_SA
  
  
  # 1. Set an ID for this sensitivity analysis ----
  # ======================================================== #
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
  
  tmpSumUp <- SumUp[SumUp$Topic == topic, ]
  ID_topic <- Topic[Topic$Topic == topic, "ID"]
  
  if (dim(tmpSumUp)[1] == 0) {
    SA_ID <- paste0("Item ", ID_topic, ".1")
    IDs <- 1
  } else {
    IDs <-
      max(an(
        stringr::str_split_fixed(
          string = tmpSumUp$`SA number`,
          pattern = paste0(ID_topic, "."),
          n = 2
        )[, 2]
      ))
    IDs <- IDs + 1
    SA_ID <- paste0("Item ", ID_topic, ".", IDs)
  }
  
  # Update both the folder_name and scripts names with the SA ID
  folder_name <- paste0(ID_topic, ".", IDs, "_", folder_name)
  script_model <- paste0(ID_topic, ".", IDs, "_", script_model, ".R")
  script_results <-
    paste0(ID_topic, ".", IDs, "_", script_results, ".R")
  # ========================================================
  
  # 2. Check the input arguments ----
  # ======================================================== #
  if (!topic %in% c("transition",
                    "landings",
                    "discards",
                    "surveys",
                    "biological_Info",
                    "model")) {
    cat('\n')
    cat(
      '=> The "topic" argument has to be defined as either  "landings", "discards",
 "surveys","biological_Info", or "model".\n'
    )
    stop()
  }
  if (is.null(object)) {
    cat('\n')
    cat(
      '=> The "object" argument has to be defined. Please indicate the item of
 your sensitivity analysis (e.g., "Length_Comp", "Age_comp", "Growth", "Fecundity",...)\n'
    )
    stop()
  } else if (length(new_model) > 1 && length(unique(object)) == 1) {
    cat('\n')
    cat(
      '=> The "object" argument is dentic for several models. Please indicate a
 specific item for each model.\n'
    )
    stop()
  } else if (length(new_model) < length(unique(object))) {
    cat('\n')
    cat(
      '=> The number of "object" argument is lower than the numbder of models.
 Please provide an object for all models you are going to develop for this sensitivity
 analysis..\n'
    )
    stop()
  }
  if (is.null(author)) {
    cat('\n')
    cat(
      '=> The "author" argument has to be defined. Please provide an author name
 (leader of the sensitivity analysis).\n'
    )
    stop()
  }
  if (is.null(folder_name)) {
    cat('\n')
    cat(
      '=> The "folder_name" argument has to be defined. Please provide a name
 for the folder where model input and output files will be save for this analyisis.\n'
    )
    stop()
  } else if (folder_name %in% SumUp$Folder &&
             length(unique(new_model %in% Models_SA$`Model name`)) == 1 &&
             unique(new_model %in% Models_SA$`Model name`)) {
    cat('\n')
    # cat('=> This "folder_name": ',folder_name,' already exist for another sensitivity analysis:\n',
    #     '\t => Please enter a different folder name for your analysis.\n')
    cat(
      '=> This(ese) new model name(s_: ',
      new_model,
      ' already exist in the folder ',
      folder_name,
      ':\n',
      '\t => Please enter different model name(s) for your analysis.\n'
    )
    stop()
  }
  if (is.null(script_model)) {
    cat('\n')
    cat(
      '=> The "script_model" argument has to be defined. Please provide the name
 of the script used to implement the SS model used for this sensitivity analysis.\n'
    )
    stop()
  } else if (script_model %in% SumUp$`Script model`) {
    cat('\n')
    cat(
      '=> This "script_model": ',
      script_model,
      ' already exist for another sensitivity analysis:\n',
      "\t => Please enter a different name for the script used to create the model for this analysis.\n"
    )
    stop()
  }
  
  if (is.null(script_results)) {
    cat('\n')
    cat(
      '=> The "script_results" argument has to be defined. Please provide the name
 of the script used to analyze the results of this sensitivity analysis.\n'
    )
    stop()
  } else if (script_results %in% SumUp$`Script results`) {
    cat('\n')
    cat(
      '=> This "script_results": ',
      script_results ,
      ' already exist for another sensitivity analysis:\n',
      "\t => Please enter a different name for the script used to analyze the
 outputs of the model for this analysis.\n"
    )
    stop()
  }
  
  if (is.null(base_model)) {
    cat('\n')
    cat(
      '=> The "base_model" argument has to be defined. Please provide the name
 of the model used as a basis for this sensitivity analysis.\n'
    )
    stop()
  }
  
  if (is.null(new_model)) {
    cat('\n')
    cat(
      '=> The "new_model" argument has to be defined. Please provide the name
 of the model you are building for this sensitivity analysis.\n'
    )
    stop()
  } else {
    if (length(new_model) == 1) {
      if (new_model %in% Models_SA$`Model name`) {
        cat('\n')
        cat(
          '=> This "new_model": ',
          new_model,
          ' already exists for another sensitivity analysis:\n',
          "\t => Please enter a different name for the model you are building for this analysis.\n"
        )
        stop()
      }
    } else {
      #length(new_model)>1
      if (length(unique(new_model %in% Models_SA$`Model name`)) > 1) {
        wrong <- which(new_model %in% Models_SA$`Model name`)
        cat('\n')
        cat(
          'This "new_model": ',
          new_model[wrong],
          ' already exists for another sensitivity analysis:\n',
          "\t => Please enter a different name for this new model.\n"
        )
        stop()
      } else if (unique(new_model %in% Models_SA$`Model name`)) {
        cat('\n')
        cat(
          'These "new_model": ',
          new_model,
          ' already exist for another sensitivity analysis:\n',
          "\t => Please enter a different name for the model you are building for this analysis.\n"
        )
        stop()
      } else if (length(base_model) == 1) {
        cat(
          "\nYou entered only one model as base model for this analysis. The new",
          " created models will therefore be based on the model:",
          base_model,
          "\n"
        )
      }
      
    }
  }
  # ========================================================
  
  # 2.1 Detect if a base model does not exist yet ----
  # Set the base_model for each model
  if (length(new_model) > 1)
    if (length(base_model) == 1)
      base_model <- rep(base_model, length(new_model))
  # Store the models comparison details
  Modcomp <- data.frame(base_model = base_model,
                        new_model = new_model,
                        warning = 0)
  ModcompWARNING <- FALSE
  for (m in 1:dim(Modcomp)[1]) {
    if (!Modcomp$base_model[m] %in% Models_SA$`Model name`) {
      if (!ModcompWARNING) {
        cat("*************************************\n")
        cat("---           WARNINGS            ---\n")
        cat("*************************************\n")
      }
      ModcompWARNING <- TRUE
      Modcomp$warning[m] <- 1
      cat("\n")
      cat(
        "\n\t=> The base model specified for the new model:",
        Modcomp$new_model[m],
        " does not exist yet. This means you'll have to start by creating this base model (",
        Modcomp$base_model[m],
        ") before creating your new model !!!!\n"
        ,
        sep = ""
      )
      cat("\n")
      if (m == dim(Modcomp)[1]) {
        cat("*************************************\n")
        cat("*************************************\n")
      }
    }
  }
  # ========================================================
  
  # 3. Create the root folders for the analysis----
  # ======================================================== #
  # Create the root repertory
  WD <- file.path(dir_SensAnal, folder_name, fsep = fsep)
  if (dir.exists(WD)) {
    # double check
    cat(
      "The specified folder name (",
      folder_name,
      ") already exist for a sensitivity
 analysis. Please set another name.\n",
      sep = ""
    )
    stop()
  } else {
    dir.create(WD, recursive = TRUE)
  }
  # Create directory for plots (comparison of models)
  dir.create(file.path(WD, "SA_plots", fsep = fsep))
  
  # Create the root folder for each model and copy and paste
  # the input files from the base model
  pathMod <- NULL
  
  for (m in 1:length(new_model)) {
    cat("\n")
    tmpWD <-
      file.path(WD, paste0(m, "_", new_model[m]), fsep = fsep)
    # Create directory
    dir.create(tmpWD)
    # Save the directory
    # pathMod <-
    #   c(pathMod,
    #     file.path(
    #       "model",
    #       "Sensitivity_Anal",
    #       folder_name,
    #       paste0(m, "_", new_model[m])
    #     ))
    if(pool == ""){
      pathMod <-
        c(pathMod,
          file.path("model", "Sensitivity_Anal", folder_name, paste0(m, "_", new_model[m])))
    } else if (pool == "base_model"){
      pathMod <-
        c(pathMod,
          file.path("model", "Sensitivity_Anal", "Base_Model", folder_name, paste0(m, "_", new_model[m])))
    } else if (pool == "star_panel"){
      pathMod <-
        c(pathMod,
          file.path("model", "Sensitivity_Anal", "STAR_Panel", folder_name, paste0(m, "_", new_model[m])))
    }

    if (m == 1)
      cat("- Copying SS input files from :\n")
    
    # Copy SS input files from the base model
    if (Modcomp$warning[m] != 1) {
      modelFrom <-
        Models_SA[Models_SA$`Model name` == base_model[m], "path"]
      modelFrom <- file.path(here::here(), modelFrom, fsep = fsep)
      SS.files <-
        dir(modelFrom,
            "*.ss",
            ignore.case = TRUE,
            all.files = TRUE)
      data_echo <- file.path("run", "data_echo.ss_new", fsep = fsep)
      file.copy(
        from = file.path(modelFrom, SS.files, fsep = fsep),
        to = file.path(tmpWD, SS.files, fsep = fsep),
        overwrite = TRUE,
        copy.date = TRUE
      )
      cat("\t=>",
          modelFrom,
          "\n for the model :",
          paste0(m, "_", new_model[m]),
          "\n")
      
      if (file.exists(file.path(modelFrom, data_echo, fsep = fsep))) {
        if (!dir.exists(dirname(file.path(tmpWD, data_echo, fsep = fsep))))
          dir.create(dirname(file.path(tmpWD, data_echo, fsep = fsep)))
        file.copy(
          from = file.path(modelFrom, data_echo, fsep = fsep),
          to = file.path(tmpWD, data_echo, fsep = fsep),
          overwrite = TRUE,
          copy.date = TRUE
        )
      } else {
        cat("WARNING\n")
        cat(
          "- The 'data_echo.ss_new' file does not exist in the directory of the following base model:\n"
        )
        cat(file.path(modelFrom, "run", fsep = fsep), "\n")
        cat(
          "\t=> If you are planning to modify the 'control file' of your new model, you will first need to run again your
 base model to get its 'data_echo.ss_new' file.\n"
        )
        cat("\n")
      }
      if (length(new_model) > 1 && m < length(new_model))
        cat("- Copying SS input files from :")
    } else {
      cat(
        "\n\n !!! The SS input files have not been copied in the repertory of the model: ",
        Modcomp$new_model[m],
        " since the based model considered here (",
        Modcomp$base_model[m],
        ") does not exist yet !!!",
        sep = ""
      )
    }
  }
  # ========================================================
  
  # 4. Create a descriptive .txt file for this analysis ----
  # ======================================================== #
  # Ask the user for a description of the sensitivity analysis
  Features <- NULL
  if (length(new_model) > 1) {
    Mod_Feat <- NULL
    cat("\nYou are going to build different models for this sensitivity analysis.\n")
    cat(
      "\nPlease first provide a global description of this analysis and then a description of each model.\n"
    )
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
        eval(parse(
          text = paste0(
            "Mod_",
            i,
            " <- readline(prompt = 'Please describe the ",
            new_model[i],
            " model: ')"
          )
        ))
        
        eval(parse(
          text = paste0(
            "Mod_",
            i,
            " <- paste0('\n# - Model ",
            new_model[i],
            ":\n# ', Mod_",
            i,
            "\n)"
          )
        ))
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
  
  timeSA <- ac(Sys.time())
  out <-
    file.path(WD, "Sensitivity_Analysis_Features.txt", fsep = fsep)
  
  environment(write_SA_files) <- environment()
  write_SA_files(out = out)
  cat(
    "=> The 'Sensitivity_Analysis_Features.txt' file has been created in the",
    paste0("'", folder_name, "'"),
    "folder.\n"
  )
  # ========================================================
  
  # 5. Update the "Summary_Sensitivity_analysis.pdf" ----
  # ======================================================== #
  cat("=> Now updating the 'Summary_Sensitivity_analysis.pdf' file.\n")
  SumUp <- SumUp %>%
    tibble::add_row(
      'SA number' = SA_ID,
      Topic = topic,
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
  
  suppressMessages(SumUp <-
                     update_SA_table(SumUp = SumUp, dir_SensAnal = dir_SensAnal))
  # ========================================================
  
  # 6. Update the "Models_Sensitivity_analysis.pdf" ----
  # ======================================================== #
  cat("=> Now updating the 'Models_Sensitivity_analysis.pdf' file.\n")
  cat(
    "Please provide a short description for each model you're gonna implement.
\t => Refer to the 'Models_Sensitivity_analysis.pdf' for example."
  )
  
  # Get a description of each model
  Nimpl <- length(new_model)
  Mod_dsc <- NULL
  while (is.null(Mod_dsc)) {
    for (i in 1:Nimpl) {
      eval(parse(
        text = paste0(
          "dsc_",
          i,
          " <- readline(prompt = 'Short description for the ",
          new_model[i],
          " model: ')"
        )
      ))
    }
    if (i == Nimpl)
      Mod_dsc <- "ok"
    Sys.sleep(0.1)
  }
  
  Desc <- NULL
  for (m in 1:Nimpl) {
    eval(parse(text = paste0("Desc <- c(Desc, dsc_", m, ")")))
  }
  Models_SA <- Models_SA %>%
    tibble::add_row(
      'SA number' = SA_ID,
      Topic = topic,
      Object = object,
      'Model name' = new_model,
      Description = Desc,
      path = pathMod
    )
  suppressMessages(
    Models_SA <-
      update_Models_SA_table(Models_SA = Models_SA, dir_SensAnal = dir_SensAnal)
  )
  # ========================================================
  
  # 7. Build the scripts for this sensitivity analysis ----
  # ======================================================== #
  out <- file.path(dirScript_SensAnal, script_model, fsep = fsep)
  write_SA_files(out = out, do_model = TRUE)
  cat(
    "- The",
    paste0("'", script_model, "'"),
    " file has been created in the",
    paste0("'", dirScript_SensAnal, "'"),
    "folder.\n"
  )
  
  out <- file.path(dirScript_SensAnal, script_results, fsep = fsep)
  write_SA_files(out = out, do_results = TRUE)
  cat(
    "- The",
    paste0("'", script_results, "'"),
    " file has been created in the",
    paste0("'", dirScript_SensAnal, "'"),
    "folder.\n"
  )
  # ========================================================
  
  # 8. Update SA_info ----
  # ======================================================== #
  SA_info <- NULL
  SA_info <- list(SumUp = SumUp, Models_SA = Models_SA)
  save(SA_info,
       file = file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
  # ========================================================
}


#' 4. Function to automatically build the template scripts for the SA ----
#' ----------------------------------------------------------- #
#'
#' @param out (character string)- Name of the file created.
#' @param do_model (logical)- if \code{TRUE}, the function will build the
#' template script to develop the models considered in the SA. \code{default = FALSE}
#' @param do_results (logical)- if \code{TRUE}, the function will build the
#' template script to analyze (plot) the models considered in the SA. \code{default = FALSE}
#'
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
#' @details
#' By default the function is set to build the 'Sensitivity_Analysis_Features.txt'
#' file.
#
write_SA_files <- function(out = NULL,
                           do_model = FALSE,
                           do_results = FALSE) {
  #' 4.1. Internal Function to automatically write scripts header ----
  #' ----------------------------------------------------------- #
  #'
  #' @param do_model (logical)- if \code{TRUE}, the function will build the
  #' template script to develop the models considered in the SA. \code{default = FALSE}
  #' @param do_results (logical)- if \code{TRUE}, the function will build the
  #' template script to analyze (plot) the models considered in the SA. \code{default = FALSE}
  #' @param ModcompWARNING (logical)- Does the base model exist before the development
  #' of the new model?
  #'
  #' @author Matthieu Veron
  #  Contact: mveron@uw.edu
  #'
  #' @details
  #' By default the function is set to build the 'Sensitivity_Analysis_Features.txt'
  #' file.
  #
  set_script_header <- function(do_model = NULL,
                                do_results = NULL,
                                ModcompWARNING = NULL) {
    cat("# ------------------------------------------------------------ #\n")
    cat("# ------------------------------------------------------------ #\n")
    cat("\n")
    
    if (do_model) {
      cat(
        "# This script holds the code used to develop the models considered in this sensitivity analysis.\n"
      )
      cat(
        "# For each model, the base model is modified using the r4ss package.
# The new input files are then written in the root directory of each model and the
# model outputs are stored in the '/run/' folder housed in that directory.\n"
      )
      cat(
        "# The results of this sensitivity analysis are analyzed using the following script:\n"
      )
      cat("#",
          file.path(dirScript_SensAnal, script_results, fsep = fsep),
          "\n")
      cat("\n")
      
      if (ModcompWARNING) {
        cat("# *************************************\n")
        cat("# ---           WARNINGS            ---\n")
        cat("# *************************************\n")
        cat("# \n")
        warnMod_New <-
          Modcomp[which(Modcomp$warning == 1), "new_model"]
        warnMod_Base <-
          Modcomp[which(Modcomp$warning == 1), "base_model"]
        cat("# => The base model(s) you specified for the following new model(s):\n")
        cat("# \t", paste(warnMod_New, collapse = ", "), "\n")
        cat(
          "# do(es) not exist yet. This means you'll have to start by developping its/their own base model before creating your new model !!!!\n"
        )
        cat("# Specifically, you must first develop the following model(s):\n")
        cat("# \t", paste(warnMod_Base, collapse = ", "), "\n")
        cat("# \n")
        cat("# *************************************\n")
        cat("# *************************************\n")
        cat("\n")
      }
      cat("# ------------------------------------------------------------ #\n")
      cat("# ------------------------------------------------------------ #\n")
      cat("\n")
    } else {
      cat(
        "# The results of the model run have been plot in the 'plots' sub-directory of
# the 'run' folder. The comparison plots between models for the sensitivity analysis will be
# stored in the 'SA_plots' folder housed in the root directory of this sensitivity analysis.\n"
      )
      cat("\n")
      cat("# ------------------------------------------------------------ #\n")
      cat("# ------------------------------------------------------------ #\n")
    }
    cat("\n")
    cat("rm(list = ls(all.names = TRUE))", "\n")
    cat("\n")
    cat("# 1. Update r4ss ----\n")
    cat("\n")
    cat("update <- FALSE", "\n")
    cat("\n")
    cat("if (update) {", "\n")
    cat("# Indicate the library directory to remove the r4ss package from\n")
    cat("mylib <- '~/R/win-library/4.1'", "\n")
    cat("remove.packages('r4ss', lib = mylib)", "\n")
    cat("# Install r4ss from GitHub", "\n")
    cat("pak::pkg_install('r4ss/r4ss')", "\n")
    cat("}", "\n")
    cat("# -----------------------------------------------------------",
        "\n")
    cat("\n")
    cat("# 2. Set up ----", "\n")
    cat("\n")
    cat("rm(list = ls(all.names = TRUE))", "\n")
    cat("# Local declaration", "\n")
    cat("fsep <- .Platform$file.sep #easy for file.path() function",
        "\n")
    cat("\n")
    cat("# packages", "\n")
    cat("library(r4ss)", "\n")
    cat("library(dplyr)", "\n")
    cat("library(reshape2)", "\n")
    cat("library(stringr)", "\n")
    cat("\n")
    cat("# Directories", "\n")
    cat("# Path to the model folder", "\n")
    cat("dir_model <- file.path(here::here(), 'model', fsep = fsep)\n")
    cat("\n")
    cat("# Path to the Executable folder", "\n")
    cat("Exe_path <- file.path(dir_model, 'ss_executables')", "\n")
    cat("\n")
    cat("# Path to the R folder", "\n")
    cat("dir_script <- file.path(here::here(), 'R', fsep = fsep)\n")
    cat("\n")
    cat("# Path to the Sensitivity analysis folder", "\n")
    # cat("dir_SensAnal <- file.path(dir_model, 'Sensitivity_Anal', fsep = fsep)\n")
    if(pool == ""){
      cat("dir_SensAnal <- file.path(dir_model, 'Sensitivity_Anal', fsep = fsep)\n")
    } else if (pool == "base_model"){
      cat("dir_SensAnal <- file.path(dir_model, 'Sensitivity_Anal', 'Base_Model', fsep = fsep)\n")
    } else if(pool == "star_panel"){
      cat("dir_SensAnal <- file.path(dir_model, 'Sensitivity_Anal', 'STAR_Panel', fsep = fsep)\n")
    }
    cat("\n")
    cat("# Path to data folder", "\n")
    cat("dir_data <- file.path(here::here(), 'data', 'for_ss', fsep = fsep)\n")
    cat("\n")
    cat("# Useful function\n")
    cat(
      "source(file=file.path(dir_script,'utils','clean_functions.R', fsep = fsep))\n"
    )
    cat("source(file=file.path(dir_script,'utils','ss_utils.R', fsep=fsep))\n")
    cat(
      "source(file=file.path(dir_script,'utils','sensistivity_analysis_utils.R', fsep=fsep))\n"
    )
    cat("\n")
    cat("# Load the .Rdata object with the parameters and data for 2023\n")
    cat("load(file.path(dir_data,'SST_SS_2023_Data_Parameters.RData', fsep = fsep))")
    cat("\n")
    cat("# Save directories and function\n")
    cat(
      "# var.to.save <- c('dir_model',
        # 'Exe_path',
        # 'dir_script',
        # 'dir_SensAnal')",
      "\n"
    )
    
    if (do_model) {
      cat("\n")
      cat("\n")
      cat("# Compute the hessian matrix", "\n")
      cat(
        "# For each model, indicate if you want to compute the Hessian matrix.
# If noHess = TRUE for a given model, then the Hessian matrix
# won't be estimated.\n"
      )
      cat("# Reminder - The following models are considered:\n")
      for (m in 1:length(Modcomp[, 'new_model']))
        cat("# \t- ", Modcomp[, 'new_model'][m], "\n")
      tmpHess <- rep(FALSE, length(Modcomp[, 'new_model']))
      cat("noHess <- c(",
          paste(tmpHess, sep = "", collapse = ","),
          ")\n",
          sep = "")
      cat("\n")
    }
    cat("\n")
    cat("var.to.save <- ls()\n")
    cat("# -----------------------------------------------------------",
        "\n")
    cat("\n")
  }
  
  # timeSA <- as.character(Sys.time())
  
  fs::file_create(path = out)
  base::sink(out)
  
  if (!do_model && !do_results) {
    cat("# ============================================================ #\n")
    cat("#              Sensitivity analysis description \n")
    cat("# ============================================================ #\n")
  } else if (do_model) {
    cat("# ============================================================ #\n")
    cat(
      "# Script used to develop the model(s) considered in the
# sensitivity analysis:",
      SA_ID,
      "\n"
    )
    cat("# ============================================================ #\n")
    cat("# \n")
    cat("# Sensitivity analysis summary\n")
  } else {
    cat("# ============================================================ #\n")
    cat(
      "# Script used to analyze and compare the model(s) considered in the
# sensitivity analysis:",
      SA_ID,
      "\n"
    )
    cat("# ============================================================ #\n")
    cat("# \n")
    cat("# Sensitivity analysis summary\n")
  }
  cat("# \n")
  cat("# *** \n")
  cat("# Topic of the sensitivity analysis: ", topic, "\n")
  cat("# Specific item in that topic: \n")
  # cat("# Specific item in that topic: ", object, "\n")
  for (i in 1:length(object))
    cat("# \t-", object[i], "\n")
  cat("# Author: ", author, "\n")
  cat("# Date:", timeSA, "\n")
  if (!do_model && !do_results)
    cat("# Sensitivity Analysis ID:", SA_ID, "\n")
  if (length(new_model) > 1) {
    cat("# Names of the models created:\n")
    for (m in 1:length(new_model))
      cat("# \t-", new_model[m], "\n")
  } else {
    # cat("# Name of the model created:", new_model, "\n")
    cat("# Name of the model created:\n")
    cat("# \t-", new_model, "\n")
  }
  cat("# *** \n")
  cat("# \n")
  if (length(new_model) > 1) {
    cat("# This analysis has been developed based on the following model(s): \n")
    cat("# New model \t\t\t\t\t Base model\n")
    for (m in 1:length(new_model))
      cat("#", new_model[m], "\t\t\t\t", base_model[m], "\n")
  } else {
    # cat(
    #   "# This analysis has been developped based on the following model: \n",
    #   base_model,
    #   "\n"
    # )
    cat("# This analysis has been developped based on the following model: \n")
    cat("#", base_model, "\n")
  }
  cat("# \n")
  cat("# Results are stored in the following foler: \n")
  cat("#\t", file.path(dir_SensAnal, folder_name, fsep = fsep), "\n")
  if (!do_model && !do_results) {
    cat("# Name of the script used to build the new model: \n")
    cat("#\t",
        file.path(dirScript_SensAnal, script_model, fsep = fsep),
        ".R\n")
    cat("# Name of the script used to analyze the results from this model: \n")
    cat("#\t",
        file.path(dirScript_SensAnal, script_results, fsep = fsep),
        ".R\n")
  }
  cat("# \n")
  if (length(new_model) > 1) {
    cat("# General features: \n")
    cat("#", Features, "\n")
    cat("# \n")
    cat("# Model features:")
    # cat("#", Mod_Feat, "\n")
    cat(Mod_Feat, "\n")
  } else {
    cat("# Features: \n")
    cat("# ",Features, "\n")
  }
  cat("# ============================================================ #\n")
  cat("\n")
  if (do_model || do_results) {
    set_script_header(
      do_model = do_model,
      do_results = do_results,
      ModcompWARNING = ModcompWARNING
    )
    stp <- 3
  }
  
  if (do_model) {
    for (m in 1:dim(Modcomp)[1]) {
      Dirmod <- NULL
      ModelName <- Modcomp[m, "new_model"]
      
      cat("# ",
          paste0(stp, "."),
          "Developing model",
          Modcomp[m, "new_model"],
          " ----\n")
      cat("# ----------------------------------------------------------- #\n")
      cat("\n")
      cat("# Path to the", Modcomp[m, "new_model"], "repertory\n")
      # tmp <-
      #   gsub(
      #     pattern = file.path("model", "Sensitivity_Anal", fsep = fsep),
      #     replacement = "",
      #     x = Models_SA[Models_SA$`Model name` == Modcomp[m, "new_model"], "path"]
      #   )
      # tmp <-
      #   stringr::str_split_fixed(string = tmp,
      #                            pattern = fsep,
      #                            n = 3)
      # cat(
      #   paste0("Dir_", gsub('\\.', '_', Modcomp[m, "new_model"])),
      #   "<- file.path(dir_SensAnal,",
      #   paste0("'", paste(tmp[2], tmp[3], sep = "','"), "'"),
      #   ",fsep = fsep)\n"
      # )
      if(pool == ""){
        tmp <-
          gsub(
            pattern = file.path("model", "Sensitivity_Anal", fsep = fsep),
            replacement = "",
            x = Models_SA[Models_SA$`Model name` == Modcomp[m, "new_model"], "path"]
          )
        tmp <-
          stringr::str_split_fixed(string = tmp,
                                   pattern = fsep,
                                   n = 3)
        cat(
          paste0("Dir_", gsub('\\.', '_', Modcomp[m, "new_model"])),
          "<- file.path(dir_SensAnal,",
          paste0("'", paste(tmp[2], tmp[3], sep = "','"), "'"),
          ",fsep = fsep)\n"
        )
      } else if(pool == "base_model" || pool == "star_panel"){
        tmp <-
          gsub(
            pattern = file.path("model", "Sensitivity_Anal", fsep = fsep),
            replacement = "",
            x = Models_SA[Models_SA$`Model name` == Modcomp[m, "new_model"], "path"]
          )
        tmp <-
          stringr::str_split_fixed(string = tmp,
                                   pattern = fsep,
                                   n = 4)
        cat(
          paste0("Dir_", gsub('\\.', '_', Modcomp[m, "new_model"])),
          "<- file.path(dir_SensAnal,",
          paste0("'", paste(tmp[3], tmp[4], sep = "','"), "'"),
          ",fsep = fsep)\n"
        )
      }

      Dirmod <-
        paste0("Dir_", gsub('\\.', '_', Modcomp[m, "new_model"]))
      cat("\n")
      cat("# Add the model directory to the saved variables\n")
      cat("var.to.save <- c(var.to.save,",
          paste0("'", Dirmod, "')"),
          "\n")
      cat("\n")
      cat("\n")
      ext <- gsub(pattern = "\\.",
                  replacement = "_",
                  x = ModelName)
      ext <- paste0(c("Start", "Dat", "Ctl", "Fore"), ext)
      namFiles <-
        c("Starter file",
          "Data file",
          "Control file",
          "Forecast file")
      cat("# For each SS input file, the following variable names will be used:\n")
      for (d in 1:4)
        cat("#",
            namFiles[d],
            ifelse(m == 2, yes = ":\t\t\t\t\t", no = ":\t\t\t"),
            ext[d],
            "\n")
      cat("\n")
      cat("\n")
      cat("# Do you want to copy the SS input files from the base model?\n")
      cat(
        "# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same\n"
      )
      cat("# basis of comparison.\n")
      # cat("Restart_SA_modeldvpt()\n")
      cat("Restart_SA_modeldvpt(
      base.model = '",Modcomp[m, "base_model"],"',
      curr.model = '",Modcomp[m, "new_model"],"',
      files = 'all')\n", sep = "")
      cat("\n")
      cat("\n")
      
      # Starter file
      cat("#", paste0(stp, ".1"), " Work on the Starter file ----\n")
      cat("# ======================= #")
      cat("\n")
      cat("# Read in the file\n")
      cat(
        "StarterFile <-",
        paste0("file.path(", Dirmod, ","),
        "'starter.ss', fsep = fsep)\n"
      )
      cat(ext[1],
          "<- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )\n")
      cat("\n")
      cat("# Make your modification if applicable\n")
      cat("# Code modifying the starter file\n")
      cat("# ..... \n")
      cat("# ..... \n")
      cat("\n")
      cat("\n")
      cat("# Save the starter file for the model\n")
      cat(
        "SS_writestarter(
      mylist = ",
        ext[1],
        ",
      dir = ",
        paste0(Dirmod, ","),
        "
      overwrite = TRUE,
      verbose = TRUE
      )\n"
      )
      cat("\n")
      cat("# Check file structure\n")
      cat("# StarterFile <-",
          paste0("file.path(", Dirmod, ","),
          "'starter.ss')\n")
      cat("# ",
          ext[1],
          "<- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )\n")
      cat("\n")
      cat("# clean environment\n")
      cat("var.to.save <- c(var.to.save, '", ext[1], "')\n", sep = "")
      cat("rm(list = setdiff(ls(), var.to.save))\n")
      cat("var.to.save <- ls()\n")
      cat("# =======================")
      cat("\n")
      cat("\n")
      
      # Data file
      cat("#", paste0(stp, ".2"), " Work on the data file ----\n")
      cat("# ======================= #")
      cat("\n")
      cat("# Read in the file\n")
      cat(
        "DatFile <-",
        paste0("file.path(", Dirmod, ","),
        ext[1],
        "$datfile, fsep = fsep)\n",
        sep = ""
      )
      cat(ext[2],
          "<- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )\n")
      cat("\n")
      cat("# Make your modification if applicable\n")
      cat("# Code modifying the data file \n")
      cat("# ..... \n")
      cat("# ..... \n")
      cat("\n")
      cat("\n")
      cat("# Save the data file for the model\n")
      cat(
        "SS_writedat(
      datlist = ",
        ext[2],
        ",
      outfile =",
        paste0("file.path(", Dirmod, ","),
        "'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )\n"
      )
      cat("\n")
      cat("# Check file structure\n")
      cat(
        "# DatFile <-",
        paste0("file.path(", Dirmod, ","),
        "'SST_data.ss', fsep = fsep)\n"
      )
      cat(
        "# ",
        ext[2],
        "<-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )\n"
      )
      cat("\n")
      cat("# clean environment\n")
      cat("var.to.save <- c(var.to.save, '", ext[2], "')\n", sep = "")
      cat("rm(list = setdiff(ls(), var.to.save))\n")
      cat("var.to.save <- ls()\n")
      cat("# =======================")
      cat("\n")
      cat("\n")
      
      # Control file
      cat("#", paste0(stp, ".3"), " Work on the control file ----\n")
      cat("# ======================= #")
      cat("\n")
      cat(
        "# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS
# in a designated file.\n"
      )
      cat("\n")
      cat("# Read in the file\n")
      cat(
        "Ctlfile <-",
        paste0("file.path(", Dirmod, ","),
        ext[1],
        "$ctlfile, fsep = fsep)\n",
        sep = ""
      )
      
      cat(
        ext[3],
        "<- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist =",
        paste0("file.path(", Dirmod, ","),
        "'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )\n"
      )
      cat("\n")
      cat("# Make your modification if applicable\n")
      cat("# Code modifying the control file \n")
      cat("# ..... \n")
      cat("# ..... \n")
      cat("\n")
      cat("\n")
      cat("# Save the control file for the model\n")
      cat(
        "SS_writectl(
      ctllist = ",
        ext[3],
        ",
      outfile =",
        paste0("file.path(", Dirmod, ","),
        "'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )\n"
      )
      cat("# Check file structure\n")
      cat("# We actually need to run the model to check the file structure\n")
      
      cat("\n")
      cat("# clean environment\n")
      cat("var.to.save <- c(var.to.save, '", ext[3], "')\n", sep = "")
      cat("rm(list = setdiff(ls(), var.to.save))\n")
      cat("var.to.save <- ls()\n")
      cat("# =======================")
      cat("\n")
      cat("\n")
      
      
      # Forecast file
      cat("#", paste0(stp, ".4"), " Work on the forecast file ----\n")
      cat("# ======================= #\n")
      cat("\n")
      cat("# Read in the file\n")
      cat(
        "ForeFile <-",
        paste0("file.path(", Dirmod, ","),
        "'forecast.ss', fsep = fsep)\n"
      )
      cat(
        ext[4],
        "<-SS_readforecast(
      file = ForeFile,
      version = '3.30',
      verbose = T,
      readAll = T
      )\n"
      )
      cat("\n")
      cat("# Make your modification if applicable\n")
      cat("# Code modifying the forecast file \n")
      cat("# ..... \n")
      cat("# ..... \n")
      cat("\n")
      cat("\n")
      cat("# Save the forecast file for the model\n")
      cat(
        "SS_writeforecast(
      mylist = ",
        ext[4],
        ",
      dir =",
        paste0(Dirmod, ","),
        "
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )\n"
      )
      cat("\n")
      cat("# Check file structure\n")
      cat(
        "# ForeFile <-",
        paste0("file.path(", Dirmod, ","),
        "'forecast.ss', fsep = fsep)\n"
      )
      cat(
        "# ",
        ext[4],
        "<-SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )\n"
      )
      
      cat("\n")
      cat("# clean environment\n")
      cat("var.to.save <- c(var.to.save, '", ext[4], "')\n", sep = "")
      cat("rm(list = setdiff(ls(), var.to.save))\n")
      cat("var.to.save <- ls()\n")
      cat("# =======================\n")
      cat("\n")
      cat("# If you are done with your implementations, you can now run this new model\n")
      cat("\n")
      cat("# *********************************************************** #\n")
      cat("#",
          paste0(stp, ".5"),
          " Run the new model using the new input files ----\n")
      cat("# ======================= #")
      cat("\n")
      cat(
        "run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =",
        paste0(Dirmod, ","),
        "
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the",
        ModelName ,
        "folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[",
        m,
        "], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )\n",
        sep = ""
      )
      cat("\n")
      cat("#",
          paste0(stp, ".6"),
          " Let's plot the outputs from this model ----\n")
      cat("# ======================= #\n")
      cat("# read the model output and print diagnostic messages\n")
      cat("Dirplot <-",
          paste0("file.path(", Dirmod, ","),
          "'run', fsep = fsep)\n")
      cat("\n")
      cat("replist <- SS_output(
      dir = Dirplot,
      verbose = TRUE,
      printstats = TRUE
      )\n")
      cat("\n")
      cat("# plots the results (store in the 'plots' sub-directory)\n")
      cat("SS_plots(replist,
      dir = Dirplot,
      printfolder = 'plots'
      )\n")
      cat("\n")
      cat("# =======================\n")
      cat("\n")
      cat("\n")
      #       if (m == dim(Modcomp)[1]) {
      #         cat("# -----------------------------------------------------------\n")
      #         cat("# -----------------------------------------------------------\n")
      #         cat("\n")
      #         cat(
      #           "# You are ready to analyze differences between the models
      # # considered in this sensitivity analysis.\n"
      #         )
      #         cat("# You can now use the",script_results,"script to realize the comparison between models.\n")
      #         cat("\n")
      #         cat("# -----------------------------------------------------------\n")
      #         cat("# -----------------------------------------------------------\n")
      #       } else {
      #         cat("# -----------------------------------------------------------\n")
      #         cat("# -----------------------------------------------------------\n")
      #         cat("\n")
      #         cat("# End development for model", ModelName,"\n")
      #         if(m != dim(Modcomp)[1]){
      #           cat("# You can now develop the next 'new model'.\n")
      #           cat("# Let's remove the input files for this from the 'var.to.save' variable\n")
      #           cat("var.to.save <- var.to.save[!var.to.save %in% c('",ext[1],"','",ext[2],"','",ext[3],"','",ext[4],"')]\n", sep = "")
      #           cat("rm(list = setdiff(ls(), var.to.save))\n")
      #           cat("var.to.save <- ls()\n")
      #           stp <- stp +1
      #         } else {
      #           cat("# You can now use the",script_results,"script to realize the comparison between models.\n")
      #         }
      #         cat("\n")
      #         cat("# -----------------------------------------------------------\n")
      #         cat("# -----------------------------------------------------------\n",sep = "")
      #         cat("\n")
      #         cat("\n")
      #       }
      cat("# -----------------------------------------------------------\n")
      cat("# -----------------------------------------------------------\n")
      cat("\n")
      if (m == dim(Modcomp)[1]) {
        cat("## End section ##\n")
        cat("\n")
        cat(
          "# You are ready to analyze the differences between the models
# considered in this sensitivity analysis.\n"
        )
        cat("# This can be done using the",
            script_results,
            "script.\n")
        cat("\n")
        cat("# !!!!! WARNING !!!!!\n")
        cat("# ------------------- #\n")
        cat("# Please do not develop any script that you want to keep after this 
# warning section - It might be overwritten in the case you add a new 
# model to this SA.\n")
        # cat("# !!! END WARNING !!!\n")
        cat("# ------------------- #\n")
        cat("\n")
        cat("## End script to develop SA models ##\n")
      } else {
        cat("# End development for model", ModelName, "\n")
        cat("# You can now develop the next 'new model'.\n")
        cat("# Let's remove the input files for this from the 'var.to.save' variable\n")
        cat(
          "var.to.save <- var.to.save[!var.to.save %in% c('",
          ext[1],
          "','",
          ext[2],
          "','",
          ext[3],
          "','",
          ext[4],
          "')]\n",
          sep = ""
        )
        cat("rm(list = setdiff(ls(), var.to.save))\n")
        cat("var.to.save <- ls()\n")
        stp <- stp + 1
      }
      cat("\n")
      cat("# -----------------------------------------------------------\n")
      cat("# -----------------------------------------------------------\n",
          sep = "")
      cat("\n")
      cat("\n")
    } # end loop on m
  } else if (do_results) {
    cat("#",
        paste0(stp, ".4"),
        " Make comparison plots between models ----\n")
    cat("# ======================= #\n")
    cat("\n")
    
    cat("# Use the SSgetoutput() function that apply the SS_output()\n")
    cat("# to get the outputs from different models\n")
    cat("\n")
    
    # path to the base model directory
    SaveDir <- NULL
    SaveMod <- NULL
    
    ModcompBase <-
      Modcomp[which(!Modcomp$base_model %in% Modcomp$new_model), ]
    # for (m in 1:dim(ModcompBase)[1]) {
    for (m in 1:length(unique(ModcompBase$base_model))) {
      cat("\n")
      cat("# Path to the base model (",
          ModcompBase[m, "base_model"],
          ") repertory\n",
          sep =
            "")
      tmp <-
        gsub(
          pattern = file.path("model", "Sensitivity_Anal", fsep = fsep),
          replacement = "",
          x = Models_SA[Models_SA$`Model name` == ModcompBase[m, "base_model"], "path"]
        )
      tmp <-
        stringr::str_split_fixed(string = tmp,
                                 pattern = fsep,
                                 n = 3)
      tmp <- tmp[!tmp %in% ""]
      
      # if (ModcompBase[m, "base_model"] %in% c("13.sq", "23.sq.fixQ")) {
      #   cat(
      #     paste0("Dir_", gsub('\\.', '_', ModcompBase[m, "base_model"])),
      #     " <- file.path(here::here(), ",
      #     paste0("'", paste(tmp, collapse = "', '"), "'"),
      #     ", 'run', fsep = fsep)\n"
      #   )
      # } else {
      #   cat(
      #     paste0("Dir_", gsub('\\.', '_', ModcompBase[m, "base_model"])),
      #     " <- file.path(dir_SensAnal, ",
      #     paste0("'", paste(tmp, collapse = "', '"), "'"),
      #     ", 'run', fsep = fsep)\n",
      #     sep = ""
      #   )
      # }
      if (ModcompBase[m, "base_model"] %in% c("13.sq", "23.sq.fixQ")) {
        cat(
          paste0("Dir_", gsub('\\.', '_', ModcompBase[m, "base_model"])),
          " <- file.path(here::here(), ",
          paste0("'", paste(tmp, collapse = "', '"), "'"),
          ", 'run', fsep = fsep)\n"
        )
      } else if(pool ==""){
        cat(
          paste0("Dir_", gsub('\\.', '_', ModcompBase[m, "base_model"])),
          " <- file.path(dir_SensAnal, ",
          paste0("'", paste(tmp, collapse = "', '"), "'"),
          ", 'run', fsep = fsep)\n",
          sep = ""
        )
      } else if ((pool == "base_model" && ModcompBase[m, "base_model"] == "23.model.francis_2") || pool == "star_panel"){
        cat(
          paste0("Dir_", gsub('\\.', '_', ModcompBase[m, "base_model"])),
          " <- file.path(dirname(dir_SensAnal), ",
          paste0("'", paste(tmp, collapse = "', '"), "'"),
          ", 'run', fsep = fsep)\n",
          sep = ""
        )
      }
      
      cat("\n")
      SaveDir <-
        c(SaveDir, paste0("Dir_", gsub('\\.', '_', ModcompBase[m, "base_model"])))
      SaveMod <- c(SaveMod, ModcompBase[m, "base_model"])
    }
    
    for (m in 1:dim(Modcomp)[1]) {
      if (m == 1) {
        cat("# Root directory for this sensitivity analysis\n")
        tmp_SA <-
          unlist(stringr::str_split(string = Models_SA[Models_SA$`Model name` == Modcomp[m, "new_model"], "path"], pattern = fsep))
        tmp_SA <- tmp_SA[1:(length(tmp_SA) - 1)]
        cat(
          "SA_path <- file.path('",
          paste(tmp_SA, sep = "'", collapse = "','"),
          "',fsep = fsep)",
          sep = ""
        )
        cat("\n")
        cat("\n")
      }
      # Check if the new model is already in the base model
      if (!Modcomp[m, "new_model"] %in% Modcomp[m, "base_model"]) {
        # Path to each new model directory
        Dirmod <- NULL
        cat("# Path to the", Modcomp[m, "new_model"], "repertory\n")
        
        # tmp <-
        #   gsub(
        #     pattern = file.path("model", "Sensitivity_Anal", fsep = fsep),
        #     replacement = "",
        #     x = Models_SA[Models_SA$`Model name` == Modcomp[m, "new_model"], "path"]
        #   )
        # tmp <-
        #   stringr::str_split_fixed(string = tmp,
        #                            pattern = fsep,
        #                            n = 3)
        # cat(
        #   paste0("Dir_", gsub('\\.', '_', Modcomp[m, "new_model"])),
        #   "<- file.path(dir_SensAnal,",
        #   paste0("'", paste(tmp[2], tmp[3], sep = "','"), "'"),
        #   ", 'run',fsep = fsep)\n"
        # )
        if(pool == ""){
          tmp <-
            gsub(
              pattern = file.path("model", "Sensitivity_Anal", fsep = fsep),
              replacement = "",
              x = Models_SA[Models_SA$`Model name` == Modcomp[m, "new_model"], "path"]
            )
          tmp <-
            stringr::str_split_fixed(string = tmp,
                                     pattern = fsep,
                                     n = 3)
          cat(
            paste0("Dir_", gsub('\\.', '_', Modcomp[m, "new_model"])),
            "<- file.path(dir_SensAnal,",
            paste0("'", paste(tmp[2], tmp[3], sep = "','"), "'"),
            ", 'run',fsep = fsep)\n"
          )
        } else if(pool == "base_model" || pool == "star_panel"){
          if(pool == "base_model"){
            tmp <-
              gsub(
                pattern = file.path("model", "Sensitivity_Anal", "Base_Model", fsep = fsep),
                replacement = "",
                x = Models_SA[Models_SA$`Model name` == Modcomp[m, "new_model"], "path"]
              )
          } else {
            tmp <-
              gsub(
                pattern = file.path("model", "Sensitivity_Anal", "STAR_Panel", fsep = fsep),
                replacement = "",
                x = Models_SA[Models_SA$`Model name` == Modcomp[m, "new_model"], "path"]
              )
          }
          tmp <-
            stringr::str_split_fixed(string = tmp,
                                     pattern = fsep,
                                     n = 3)
          cat(
            paste0("Dir_", gsub('\\.', '_', Modcomp[m, "new_model"])),
            "<- file.path(dir_SensAnal,",
            paste0("'", paste(tmp[2], tmp[3], sep = "','"), "'"),
            ", 'run',fsep = fsep)\n"
          )
        }
        
        cat("\n")
        SaveDir <-
          c(SaveDir, paste0("Dir_", gsub('\\.', '_', Modcomp[m, "new_model"])))
        SaveMod <- c(SaveMod, Modcomp[m, "new_model"])
      }
    }
    
    cat("# Extract the outputs for all models\n")
    cat(
      "SensiMod <- SSgetoutput(dirvec = c(\n\t",
      paste0(SaveDir, sep = '', collapse = ',\n\t'),
      "))\n",
      sep = ""
    )
    cat("\n")
    
    cat("# Rename the list holding the report files from each model\n")
    cat("names(SensiMod)\n")
    cat("names(SensiMod) <- c(\n\t",
        paste0("'", paste(SaveMod, collapse = "',\n\t'"), "'"),
        ")\n",
        sep = "")
    cat("\n")
    
    cat("# summarize the results\n")
    cat("Version_Summary <- SSsummarize(SensiMod)\n")
    cat("\n")
    
    cat("# make plots comparing the models\n")
    
    cat(
      "SSplotComparisons(
      Version_Summary,
      # print = TRUE,
      pdf = TRUE,
      plotdir = file.path(SA_path, 'SA_plots', fsep = fsep),
      legendlabels = c(\n\t",
      paste0("'", paste(SaveMod, collapse = "',\n\t'"), "'"),
      ")
    )\n",
      sep = ""
    )
    cat("\n")
    cat("# Create comparison table for this analisys\n")
    cat("# ####################################### #\n")
    cat("\n")
    cat("SStableComparisons(Version_Summary)\n")
    cat("\n")
    cat(
      "tmp <- purrr::transpose(SensiMod)$parameters %>%
  purrr::map_df(~dplyr::as_tibble(.x), .id = 'Model') %>%
  dplyr::select(Model, Label, Value, Phase, Min, Max, Init,
                Gradient, Pr_type, Prior, Pr_SD, Pr_Like,
                LCI95 = `Value-1.96*SD`, UCI95 = `Value+1.96*SD`)\n"
    )
    cat("\n")
    cat(
      "tmp %>%
    readr::write_csv(paste(SA_path, 'Update_Data_comparison_table_all_params.csv', sep = fsep))\n"
    )
    cat("\n")
    cat(
      "tmp %>%
  dplyr::filter(grepl('LnQ|R0', Label)) %>%
  tidyr::pivot_wider(id_cols = c(Label, Phase), names_from = Model, values_from = Value) %>%
  readr::write_csv(paste(SA_path, 'Update_Data_comparison_table_lnQ_SRlnR0.csv', sep = fsep))\n"
    )
    cat("\n")
    cat("out <- SStableComparisons(Version_Summary)\n")
    cat("names(out) <- c('Label', unique(tmp$Model))\n")
    cat("\n")
    cat(
      "out %>%
  readr::write_csv(paste(SA_path, 'Update_Data_comparison_table_likelihoods_and_brps.csv', sep = fsep))\n"
    )
  } # if(do_results)
  base::sink()
}

# ----------------------------------------------------------

#' 5. Function to delete one or several SA ----
#' ----------------------------------------------------------- #
#'
#' @param SA_ID (character string)- Name(s) of the Sensitivity analysis(es) to
#' delete (e.g., "Item 0.1"). Please refer to the "Summery_sensitivity_analysis.pdf" file for the
#' name. If \code{SA_ID = "all}, then all sensitivity analyses (except the one called "Item 0.0")
#' will be deleted.
#' @param pool (character string) - Indicates in which pool of the workflow 
#' the sensitivity analysis is developed. When working on bridging model, 
#' \code{pool = ''}, when working on sensitivity analyses for the 
#' "Base Model" chosen for the year of the assessment, \code{pool = 'base_model'}
#' and, when working on sensitivity analyses for the STAR Panel,
#' \code{pool = 'star_panel'}.
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
remove_SA <- function(SA_ID = NULL, 
                      pool = '') {
  # local declarations
  fsep <- .Platform$file.sep
  
  dir_model <- file.path(here::here(), "model", fsep = fsep)
  dir_script <- file.path(here::here(), "R", fsep = fsep)
  # dir_SensAnal <-
  #   file.path(dir_model, "Sensitivity_Anal", fsep = fsep)
  if(pool == ""){
    tmpDirpool <- ""
  } else if(pool == "base_model"){
    tmpDirpool <- "Base_Model"
  } else if(pool == "star_panel"){
    tmpDirpool <- "STAR_Panel"
  } else {
    stop("This pool ('",pool,"') does not exist in the workflow.")
  }
  dir_SensAnal <- file.path(dir_model, "Sensitivity_Anal", tmpDirpool, fsep = fsep)
  
  dirScript_SensAnal  <-
    file.path(dir_script, "ss", "Sensitivity_Anal", fsep = fsep)
  
  # load the SA_info dataframe
  load(file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
  SumUp <- SA_info$SumUp
  colSumUp <-
    colnames(SumUp)
  colnames(SumUp) <- gsub(" ", "_", colnames(SumUp))
  Models_SA <- SA_info$Models_SA
  colMod_SA <-
    colnames(Models_SA)
  colnames(Models_SA) <- gsub(" ", "_", colnames(Models_SA))
  
  # Internal function to loop over SA_ID
  interRemov <- function(SA_Num, SumUp, Models_SA) {
    # Delete directory and Rscripts
    DelFold <- unique(SumUp %>%
                        dplyr::filter(SA_number == SA_Num) %>%
                        dplyr::select(Folder))
    DelFold <- file.path(dir_SensAnal, DelFold, fsep = fsep)
    unlink(DelFold, recursive = TRUE)
    cat("\n \t=> Deleting the following folder:\n", DelFold, "\n")
    
    DelScripts <- unique(
      SumUp %>%
        dplyr::filter(SA_number == SA_Num) %>%
        dplyr::select(Script_model , Script_results)
    )
    DelScripts <-
      file.path(dirScript_SensAnal, DelScripts, fsep = fsep)
    file.remove(DelScripts)
    cat("\n \t=> Deleting the following Rscripts:\n",
        DelScripts[1],
        "\n",
        DelScripts[2],
        "\n")
    
    # Remove the SA from both the SumUp and Models_SA dataframe
    SumUp <- SumUp %>%
      dplyr::filter(SA_number != SA_Num)
    Models_SA <- Models_SA %>%
      dplyr::filter(SA_number != SA_Num)
    
    out <- list(SumUp = SumUp, Models_SA = Models_SA)
    return(out)
  }
  
  # Loop on SA_ID
  
  if (SA_ID == "all") {
    mess <-
      paste0(
        "!!!!! WARNING !!!!!\n\n",
        "You're gonna delete all the sensitivity analyses' in the folder:\n\n",
        dir_SensAnal,
        "\n\n Do you want to continue?"
      )
    deleteSA <- DialogBox(message = mess, type = "yesno")
    if (deleteSA == "yes") {
      SA_ID <- unique(SA_info$SumUp$`SA number`)
      SA_ID <- SA_ID[!SA_ID %in% "Item 0.0"]
      
      for (sa in 1:length(SA_ID)) {
        SA_info <- interRemov(SA_Num = SA_ID[sa], SumUp, Models_SA)
        SumUp <- SA_info$SumUp
        Models_SA <- SA_info$Models_SA
      }
    }
    cat("\n\nAll sensitivity analysis have been deleted !\n")
  } else {
    if (length(SA_ID) >= 1)
      for (sa in 1:length(SA_ID)) {
        # Ask user for sure
        deleteSA <- NULL
        
        SAtoRemove <- unique(SumUp %>%
                               dplyr::filter(SA_number == SA_ID[sa]) %>%
                               dplyr::select(Features))
        mess <-
          paste0(
            "You're gonna delete the sensitivity analysis' ",
            SA_ID[sa],
            " 'which features were about:\n\n",
            ac(paste0("\t", SAtoRemove)),
            "\n\n Do you want to continue?"
          )
        deleteSA <- DialogBox(message = mess, type = "yesno")
        if (deleteSA == "yes") {
          SA_info <- interRemov(SA_Num = SA_ID[sa], SumUp, Models_SA)
          SumUp <- SA_info$SumUp
          Models_SA <- SA_info$Models_SA
        }
      }
    
    # Rename columns of SumUp and Models_SA
    colnames(SumUp) <- colSumUp
    colnames(Models_SA) <- colMod_SA
    
    # Update the Summary_Sensitivity_analysis.pdf file
    suppressMessages(SumUp <-
                       update_SA_table(SumUp = SumUp, dir_SensAnal = dir_SensAnal))
    # Update the "Models_Sensitivity_analysis.pdf" file
    suppressMessages(
      Models_SA <-
        update_Models_SA_table(Models_SA = Models_SA, dir_SensAnal = dir_SensAnal)
    )
    # Update SA_info ----
    # ======================================================== #
    SA_info <- list(SumUp = SumUp, Models_SA = Models_SA)
    save(SA_info,
         file = file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
  }
}
# ----------------------------------------------------------

#' 6. Copy specific SS input files from the base model directory to the one of the development model----
#' ----------------------------------------------------------- #
#'
#' Reads the starter.ss file to figure out the names of the control and
#' data files, then copies those files along with starter.ss, forecast.ss.
#'
#' @param base_model (character string)- name of the base model from which
#' copy the input files.
#' @param Dvpt_model (character string)- name of the model you're currently
#' developping.
#' @param SS_file (character string)- name of the SS input file you want to
#' get from the base model. Options for \code{SS_file} are: 'starter','control',
#' 'forecast','data','data_echo.ss_new', 'data.ss_new' or 'all'.
#' If \code{SS_file="all"}, then the function will copy
#' and paste all the input files (starter.ss, forecast.ss, control.ss, data.ss
#' and either 'data_echo.ss_new' or 'data.ss_new')
#' from the base model directory to your current model in development.
#'
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
copy_BaseModel_SSinputs <- function(base_model = NULL,
                                    Dvpt_model = NULL,
                                    SS_file = NULL) {
  # local declarations
  fsep <- .Platform$file.sep
  # Directories
  dir_model <- file.path(here::here(), "models", fsep = fsep)
  dir_script <- file.path(here::here(), "R", fsep = fsep)
  dir_SensAnal <-
    file.path(dir_model, "Sensitivity_Anal", fsep = fsep)
  dirScript_SensAnal  <-
    file.path(dir_script, "ss", "Sensitivity_Anal", fsep = fsep)
  
  # load the SA_info dataframe
  load(file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
  SumUp <- SA_info$SumUp
  colSumUp <-
    colnames(SumUp)
  colnames(SumUp) <- gsub(" ", "_", colnames(SumUp))
  Models_SA <- SA_info$Models_SA
  colMod_SA <-
    colnames(Models_SA)
  colnames(Models_SA) <- gsub(" ", "_", colnames(Models_SA))
  
  # check the inputs
  if (dim(dplyr::filter(SumUp, Base_model == base_model &
                        New_model == Dvpt_model))[1] == 0) {
    stop(
      "This sensitivty analysis has not been implemented. Please check the definition
of both your 'base mode' and 'development model.\n"
    )
  }
  
  # check for presence of SS files
  if (is.null(SS_file))
    stop("Please provide a name for the input file(s) to copy from the base model:",
         base_model)
  # Check consistency of SS file
  if (!SS_file %in% c("starter",
                      "control",
                      "data",
                      "forecast",
                      "data_echo.ss_new",
                      "data.ss_new",
                      "all"))
    stop(
      "The specified SS input file(s) do(es) not exist.\n
=> Please provide a name among the following options: 'starter','control', 'data',
'data_echo.ss_new', 'data.ss_new', 'forecast','all'"
    )
  
  # Set up the directories
  # Copy SS input files from the base model
  modelFrom <- Models_SA[Models_SA$Model_name == base_model, "path"]
  modelFrom <- file.path(here::here(), modelFrom, fsep = fsep)
  modelTo <- Models_SA[Models_SA$Model_name == Dvpt_model, "path"]
  modelTo <- file.path(here::here(), modelTo, fsep = fsep)
  
  # read starter file
  if (SS_file %in% c("control", "data", "all")) {
    starter_file <- file.path(modelFrom,
                              "starter.ss")
    if (file.exists(starter_file)) {
      starter <- r4ss::SS_readstarter(starter_file, verbose = FALSE)
    } else {
      warning(
        "The starter file for the base model:",
        base_model,
        " is not found in the following directory:\n=>",
        file.path(modelFrom)
      )
      return(FALSE)
    }
  }
  cat("- Copying SS input files from :\n")
  cat("\t=>", modelFrom, "\n to \n :", modelTo, "\n")
  
  overwrite <- TRUE
  cop_Done <- NULL
  
  if (SS_file == "all") {
    cop <- file.copy(
      from = file.path(modelFrom, starter[["ctlfile"]]),
      to = file.path(modelTo, starter[["ctlfile"]]),
      overwrite = overwrite
    )
    cop_Done <- c(cop_Done, cop)
    cop <- file.copy(
      from = file.path(modelFrom, starter[["datfile"]]),
      to = file.path(modelTo, starter[["datfile"]]),
      overwrite = overwrite
    )
    cop_Done <- c(cop_Done, cop)
    cop <- file.copy(
      from = file.path(modelFrom, "forecast.ss"),
      to = file.path(modelTo, "forecast.ss"),
      overwrite = overwrite
    )
    cop_Done <- c(cop_Done, cop)
    cop <- file.copy(
      from = file.path(modelFrom, "starter.ss"),
      to = file.path(modelTo, "starter.ss"),
      overwrite = overwrite
    )
    if (file.exists(file.path(modelFrom, "run", "data_echo.ss_new", fsep = fsep))) {
      if (!dir.exists(file.path(modelTo, "run", fsep = fsep))) {
        dir.create(file.path(modelTo, "run"))
        cat("\n - Creating the following repertory:",
            file.path(modelTo, "run", fsep = fsep))
      }
      cop <- file.copy(
        from = file.path(modelFrom, "run", "data_echo.ss_new"),
        to = file.path(modelTo, "run", "data_echo.ss_new"),
        overwrite = overwrite
      )
      cop_Done <- c(cop_Done, cop)
    } else if (file.exists(file.path(modelFrom, "run", "data.ss_new"))) {
      if (!dir.exists(file.path(modelTo, "run", fsep = fsep))) {
        dir.create(file.path(modelTo, "run", fsep = fsep))
        cat("\n - Creating the following repertory:",
            file.path(modelTo, "run", fsep = fsep))
      }
      cop <- file.copy(
        from = file.path(modelFrom, "run", "data.ss_new"),
        to = file.path(modelTo, "run", "data.ss_new"),
        overwrite = overwrite
      )
      cop_Done <- c(cop_Done, cop)
    }
  } else {
    for (f in 1:length(SS_file)) {
      copFile <- SS_file[f]
      if (copFile == "control") {
        cop <- file.copy(
          from = file.path(modelFrom, starter[["ctlfile"]]),
          to = file.path(modelTo, starter[["ctlfile"]]),
          overwrite = overwrite
        )
        cop_Done <- c(cop_Done, cop)
      } else if (copFile == "data") {
        cop <- file.copy(
          from = file.path(modelFrom, starter[["datfile"]]),
          to = file.path(modelTo, starter[["datfile"]]),
          overwrite = overwrite
        )
        cop_Done <- c(cop_Done, cop)
      } else if (copFile == "forecast") {
        cop <- file.copy(
          from = file.path(modelFrom, "forecast.ss"),
          to = file.path(modelTo, "forecast.ss"),
          overwrite = overwrite
        )
        cop_Done <- c(cop_Done, cop)
      } else if (copFile == "starter") {
        cop <- file.copy(
          from = file.path(modelFrom, "starter.ss"),
          to = file.path(modelTo, "starter.ss"),
          overwrite = overwrite
        )
        cop_Done <- c(cop_Done, cop)
      } else if (copFile == "data_echo.ss_new") {
        if (!dir.exists(file.path(modelTo, "run"))) {
          dir.create(file.path(modelTo, "run"))
          cat(
            "\n - Creating the following repertory:",
            file.path(modelTo, "run", fsep = fsep)
          )
        }
        cop <- file.copy(
          from = file.path(modelFrom, "run", "data_echo.ss_new"),
          to = file.path(modelTo, "run", "data_echo.ss_new"),
          overwrite = overwrite
        )
        cop_Done <- c(cop_Done, cop)
      } else if (copFile == "data.ss_new") {
        if (!dir.exists(file.path(modelTo, "run", fsep = fsep))) {
          dir.create(file.path(modelTo, "run"))
          cat(
            "\n - Creating the following repertory:",
            file.path(modelTo, "run", fsep = fsep)
          )
        }
        cop <- file.copy(
          from = file.path(modelFrom, "run", "data.ss_new", fsep = fsep),
          to = file.path(modelTo, "run", "data.ss_new", fsep = fsep),
          overwrite = overwrite
        )
        cop_Done <- c(cop_Done, cop)
      }
    }
  }
  # check for successful copying
  if (unique(cop_Done) == TRUE) {
    cat("\n => Files have been copied.")
    # return(TRUE)
  } else {
    warning("At least 1 file failed to copy.")
    # return(FALSE)
  }
}
# ----------------------------------------------------------


#' 7. Function to add model(s) to a pre existing SA ----
#' ----------------------------------------------------------- #
#'
#' @param SA_ID (character string)- Name of the Sensitivity analysis to which 
#' you want to add one or more model(s) (e.g., "Item 0.1"). Please refer to the 
#' "Summery_sensitivity_analysis.pdf" file for the name.
#' @param new_model (character string)- name(s) of the model(s) you want to add. 
#' @param base_model (character string)- For each \code{'new_model'}, specify 
#' the name of the model used as base model.
#' @param object (character string)- Indicates a specific item for each new model. 
#' For example, "Length_Comp", "Age_comp", "Growth", "Fecundity",...
#' If multiple models are added, the length of \code{object} equals the numder of
#' models with a specific input for each model.
#' 
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
Add_Newmodel <- function(SA_ID = NULL,
                         new_model = NULL,
                         base_model = NULL,
                         object = NULL){
  
  # 1. Local declarations ----
  fsep <- .Platform$file.sep
  
  # Directories
  dir_model <- file.path(here::here(), "model", fsep = fsep)
  dir_script <- file.path(here::here(), "R", fsep = fsep)
  dir_SensAnal <-
    file.path(dir_model, "Sensitivity_Anal", fsep = fsep)
  dirScript_SensAnal  <-
    file.path(dir_script, "ss", "Sensitivity_Anal", fsep = fsep)
  # ========================================================
  
  # 2. load the SA_info dataframe ----
  load(file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
  SumUp <- SA_info$SumUp
  Models_SA <- SA_info$Models_SA
  # ========================================================
  
  # 3. Check the input ----
  # Detect wrong new model names
  if(any(new_model %in% Models_SA$`Model name`)){
    WrongNew <- new_model[which(new_model %in% Models_SA$`Model name`)]
    cat("The new model names (",paste("'", WrongNew, "'", sep="", collapse = ","),") already exist in the data base. 
Please provide other name(s) for the model you want to add.\n", sep="")
    stop()
  }
  # Detect wrong base models names
  WrongBase <- base_model[-c(which(base_model %in% c(Models_SA$`Model name`, new_model)))]
  if(length(WrongBase)>0){
    cat("The base model(s) you specified do(es) not exist in the data base (",
        paste("'", WrongBase, "'", sep="", collapse = ","),").
Please check the name(s) of you base model(s).\n", sep="")
    stop()
  }
  # Check for consistency in the number of base and new models
  if(length(base_model) > length(new_model)){
    cat("The number of 'base_model' does not match the number of 'new_model'.\n")
    stop()
  }
  # ========================================================
  
  # 4. Set up material to add the new model(s) ----
  # Affect the base model to each new model if needed
  if(length(base_model) < length(new_model)){
    base_model <- rep(base_model, length(new_model))
    cat("The model ",base_model[1]," is considered as the base model for each of the new model.", sep="")
  }
  # Store the models comparison details
  Modcomp <- data.frame(base_model = base_model,
                        new_model = new_model,
                        warning = 0)
  ModcompWARNING <- FALSE
  for (m in 1:dim(Modcomp)[1]) {
    if (!Modcomp$base_model[m] %in% Models_SA$`Model name`) {
      if (!ModcompWARNING) {
        cat("*************************************\n")
        cat("---           WARNINGS            ---\n")
        cat("*************************************\n")
      }
      ModcompWARNING <- TRUE
      Modcomp$warning[m] <- 1
      cat("\n")
      cat(
        "\n\t=> The base model specified for the new model:",
        Modcomp$new_model[m],
        " does not exist yet. This means you'll have to start by creating this base model (",
        Modcomp$base_model[m],
        ") before creating your new model !!!!\n"
        ,
        sep = ""
      )
      cat("\n")
      if (m == dim(Modcomp)[1]) {
        cat("*************************************\n")
        cat("*************************************\n")
      }
    }
  }
  # ========================================================
  
  # 5. Create the root folders for the analysis----
  # ======================================================== #
  # Get the infor from the SA_info tables
  tmpInfo <- SumUp %>%
    dplyr::filter(`SA number` %in% SA_ID)
  
  # Working directory for this SA
  folder_name <- unique(tmpInfo$Folder)
  WD <- file.path(dir_SensAnal, folder_name, fsep = fsep)
  FoldModel <-
    list.files(WD)[grepl(pattern = paste(tmpInfo$`New model`, collapse = "|"),x = list.files(WD))]
  FoldModel <- stringr::str_split(string = FoldModel, pattern = "_")
  numFolder <- an(max(unlist(lapply(FoldModel,FUN = function(x){return(x[1])}))))
  
  
  # Create the root folder for each model and copy and paste
  # the input files from the base model
  pathMod <- NULL
  
  for (m in 1:length(new_model)) {
    tmpNumFolder <- numFolder+m
    
    cat("\n")
    tmpWD <-
      file.path(WD, paste0(tmpNumFolder, "_", new_model[m]), fsep = fsep)
    # Create directory
    dir.create(tmpWD)
    # Save the directory
    pathMod <-
      c(pathMod,
        file.path(
          "model",
          "Sensitivity_Anal",
          folder_name,
          paste0(tmpNumFolder, "_", new_model[m])
        ))
    
    if (m == 1)
      cat("- Copying SS input files from :\n")
    
    # Copy SS input files from the base model
    if (Modcomp$warning[m] != 1) {
      modelFrom <-
        Models_SA[Models_SA$`Model name` == base_model[m], "path"]
      modelFrom <- file.path(here::here(), modelFrom, fsep = fsep)
      SS.files <-
        dir(modelFrom,
            "*.ss",
            ignore.case = TRUE,
            all.files = TRUE)
      data_echo <- file.path("run", "data_echo.ss_new", fsep = fsep)
      file.copy(
        from = file.path(modelFrom, SS.files, fsep = fsep),
        to = file.path(tmpWD, SS.files, fsep = fsep),
        overwrite = TRUE,
        copy.date = TRUE
      )
      cat("\t=>",
          modelFrom,
          "\n for the model :",
          paste0(tmpNumFolder, "_", new_model[m]),
          "\n")
      
      if (file.exists(file.path(modelFrom, data_echo, fsep = fsep))) {
        if (!dir.exists(dirname(file.path(tmpWD, data_echo, fsep = fsep))))
          dir.create(dirname(file.path(tmpWD, data_echo, fsep = fsep)))
        file.copy(
          from = file.path(modelFrom, data_echo, fsep = fsep),
          to = file.path(tmpWD, data_echo, fsep = fsep),
          overwrite = TRUE,
          copy.date = TRUE
        )
      } else {
        cat("WARNING\n")
        cat(
          "- The 'data_echo.ss_new' file does not exist in the directory of the following base model:\n"
        )
        cat(file.path(modelFrom, "run", fsep = fsep), "\n")
        cat(
          "\t=> If you are planning to modify the 'control file' of your new model, you will first need to run again your
 base model to get its 'data_echo.ss_new' file.\n"
        )
        cat("\n")
      }
      if (length(new_model) > 1 && m < length(new_model))
        cat("- Copying SS input files from :")
    } else {
      cat(
        "\n\n !!! The SS input files have not been copied in the repertory of the model: ",
        Modcomp$new_model[m],
        " since the based model considered here (",
        Modcomp$base_model[m],
        ") does not exist yet !!!",
        sep = ""
      )
    }
  }
  # ========================================================
  
#   # 6. Upodate the descriptive .txt file for this analysis ----
#   # ======================================================== #
#   # Ask the user for a description of the sensitivity analysis
#   if (length(new_model) > 0) {
#     Mod_Feat <- NULL
#   }
#   cat("\nYou are going to add ",length(new_model)," models to this sensitivity analysis.\n", sep="")
#   
#   # Get the global description of the sensitivity analysis
#   mess1 <-
#     paste("Do you want to update the general feature of the sensitivity analysis?
# The current feature is:\n", tmpInfo$Features[1], sep = "")
#   restart <- DialogBox(message = mess1, type = 'yesno')
#   Features <- NULL
#   if(restart == "yes"){
#     while (is.null(Features)) {
#       Impl <-
#         readline(prompt = "Please describe the general features of this sensistivity analysis:")
#       Features <- Impl
#       Sys.sleep(0.1)
#     }
#   }
#   # Get a description of each model
#   if (length(new_model) > 0) {
#     Nimpl <- length(new_model)
#     while (is.null(Mod_Feat)) {
#       for (i in 1:Nimpl) {
#         eval(parse(
#           text = paste0(
#             "Mod_",
#             i,
#             " <- readline(prompt = 'Please describe the ",
#             new_model[i],
#             " model: ')"
#           )
#         ))
#         
#         eval(parse(
#           text = paste0(
#             "Mod_",
#             i,
#             " <- paste0('\n# - Model ",
#             new_model[i],
#             ":\n# ', Mod_",
#             i,
#             "\n)"
#           )
#         ))
#       }
#       if (i == Nimpl)
#         eval(parse(text =
#                      paste0(
#                        'Mod_Feat <-paste(',
#                        paste(' Mod_', 1:Nimpl, sep = '', collapse = ','),
#                        ')'
#                      )))
#       Sys.sleep(0.1)
#     }
#   }
#   
#   timeSA <- ac(Sys.time())
#   out <-
#     file.path(WD, "Sensitivity_Analysis_Features.txt", fsep = fsep)
#   # Delete the old file
#   # base::unlink(out)
#   
#   # Set up material for the write_SA_files() function
#   file <- readLines(con = out)
#   
#   # 1. Add Object
#   Which1 <- grep(pattern = "# Author:", x = file)
#   fileOut <- file[1:(Which1-1)]
#   object1 <- paste("# \t-", object)
#   fileOut <- c(fileOut, object1)
#   
#   # 2. Update the date
#   timeSA <- ac(Sys.time())
#   fileOut <- c(fileOut, file[Which1])
#   fileOut <- c(fileOut, paste("# Date:", timeSA))
#   
#   # 3. Add the names of the new models
#   Which2 <- grep(pattern = "# This analysis has been developed based on the following ", x = file)
#   fileOut <- c(fileOut, file[(Which1+2):(Which2-3)])
#   NamMod <- paste("# \t-", new_model)
#   fileOut <- c(fileOut, NamMod)
#   
#   # 4. Add the correspondance between base and new models
#   # Which3 <- grep(pattern = "# Results are stored in the following foler: ", x = file)
#   # fileOut <- c(fileOut, file[(Which2-2):(Which3-2)])
#   # for(m in 1:dim(Modcomp)[1]){
#   #   Modcorr <- paste(Modcomp[m,1:2], sep = "", collapse = " \t\t\t\t ")
#   #   fileOut <- c(fileOut, paste("# ",Modcorr, sep=""))
#   # }
#   Which3 <- grep(pattern = "# Results are stored in the following foler: ", x = file)
#   tmpSumUp <- SumUp[SumUp$`SA number` %in% SA_ID,]
#   if(dim(tmpSumUp)[1] == 1){
#     fileOut <- c(fileOut, file[(Which2-2):(Which3-2-1)])
#     fileOut <- c(fileOut,"# New model \t\t\t\t\t Base model")
#     fileOut <- c(fileOut,paste0("# ", tmpSumUp$`New model`, "\t\t\t\t", tmpSumUp$`Base model`))
#   } else {
#     fileOut <- c(fileOut, file[(Which2-2):(Which3-2)])
#   }
#   for(m in 1:dim(Modcomp)[1]){
#     Modcorr <- paste(Modcomp[m,c(2,1)], sep = "", collapse = " \t\t\t\t ")
#     fileOut <- c(fileOut, paste("# ",Modcorr, sep=""))
#   }
#   
#   # Update the general feature of the SA
#   if(restart == "yes"){
#     Which4 <- grep(pattern = "# General features: ", x = file)
#     fileOut <- c(fileOut, file[(Which3-1):Which4])
#     fileOut <- c(fileOut, Features)
#     Which5 <- grep(pattern = "# Model features:", x = file)
#     fileOut <- c(fileOut, file[(Which5-1):(length(file)-2)])
#   } else {
#     fileOut <- c(fileOut, file[(Which3-1):(length(file)-2)])
#   }
#   
#   # Add the model features
#   Mod_Feat <- stringr::str_replace_all(string = Mod_Feat, pattern = "\n", replacement = "")
#   Mod_Feat <- unlist(stringr::str_split(string = Mod_Feat, pattern = "#"))
#   Mod_Feat <- Mod_Feat[-1]
#   fileOut <- c(fileOut,paste("#",Mod_Feat,sep=""))
#   fileOut <- c(fileOut,file[(length(file)-1):length(file)])
#   base::writeLines(text = fileOut, con = out)
#   
#   cat(
#     "=> The 'Sensitivity_Analysis_Features.txt' file has been updated.\n"
#   )
#   # ========================================================
  
  
  
  # 6. Upodate the descriptive .txt file for this analysis ----
  # ======================================================== #
  # Ask the user for a description of the sensitivity analysis
  if (length(new_model) > 0) {
    Mod_Feat <- NULL
  }
  cat("\nYou are going to add ",length(new_model)," models to this sensitivity analysis.\n", sep="")
  
  # Get the global description of the sensitivity analysis
  mess1 <-
    paste("Do you want to update the general feature of the sensitivity analysis?
The current feature is:\n", tmpInfo$Features[1], sep = "")
  restart <- DialogBox(message = mess1, type = 'yesno')
  Features <- NULL
  if(restart == "yes"){
    while (is.null(Features)) {
      Impl <-
        readline(prompt = "Please describe the general features of this sensistivity analysis:")
      Features <- Impl
      Sys.sleep(0.1)
    }
  }
  # Get a description of each model
  if (length(new_model) > 0) {
    Nimpl <- length(new_model)
    while (is.null(Mod_Feat)) {
      for (i in 1:Nimpl) {
        eval(parse(
          text = paste0(
            "Mod_",
            i,
            " <- readline(prompt = 'Please describe the ",
            new_model[i],
            " model: ')"
          )
        ))
        
        eval(parse(
          text = paste0(
            "Mod_",
            i,
            " <- paste0('\n# - Model ",
            new_model[i],
            ":\n# ', Mod_",
            i,
            "\n)"
          )
        ))
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
  
  timeSA <- ac(Sys.time())
  out <-
    file.path(WD, "Sensitivity_Analysis_Features.txt", fsep = fsep)
  # Delete the old file
  # base::unlink(out)
  
  # Set up material for the write_SA_files() function
  file <- readLines(con = out)
  
  # 1. Add Object
  Which1 <- grep(pattern = "# Author:", x = file)
  fileOut <- file[1:(Which1-1)]
  object1 <- paste("# \t-", object)
  fileOut <- c(fileOut, object1)
  
  # 2. Update the date
  timeSA <- ac(Sys.time())
  fileOut <- c(fileOut, file[Which1])
  fileOut <- c(fileOut, paste("# Date:", timeSA))
  
  # 3. Add the names of the new models
  # Which2 <- grep(pattern = "# This analysis has been developed based on the following", x = file)
  Which2 <- grep(pattern = "# This analysis has been develo", x = file)
  fileOut <- c(fileOut, file[(Which1+2):(Which2-3)])
  NamMod <- paste("# \t-", new_model)
  fileOut <- c(fileOut, NamMod)
  
  # 4. Add the correspondance between base and new models
  Which3 <- grep(pattern = "# Results are stored in the following foler: ", x = file)
  tmpSumUp <- SumUp[SumUp$`SA number` %in% SA_ID,]
  if(dim(tmpSumUp)[1] == 1){
    fileOut <- c(fileOut, file[(Which2-2):(Which3-2-1)])
    fileOut <- c(fileOut,"# New model \t\t\t\t\t Base model")
    fileOut <- c(fileOut,paste0("# ", tmpSumUp$`New model`, "\t\t\t\t", tmpSumUp$`Base model`))
    # fileOut <- c(fileOut,"")
  } else {
    fileOut <- c(fileOut, file[(Which2-2):(Which3-2)])
  }
  for(m in 1:dim(Modcomp)[1]){
    Modcorr <- paste(Modcomp[m,c(2,1)], sep = "", collapse = " \t\t\t\t ")
    fileOut <- c(fileOut, paste("# ",Modcorr, sep=""))
  }
  fileOut <- c(fileOut,"")
  
  # Update the general feature of the SA and model features
  if(dim(tmpSumUp)[1] == 1){
    Which4 <- grep(pattern = "# Features: ", x = file)
    file[Which4] <- "# General features: "
  }
  
  if(restart == "yes"){
    # if(dim(tmpSumUp)[1] == 1){
    #   
    #   Which4 <- grep(pattern = "# Features: ", x = file)
    #   fileOut <- c(fileOut, file[(Which3-1):(Which4-1)])
    #   fileOut <- c(fileOut, "# General features: ")
    #   fileOut <- c(fileOut, Features)
    # } else {
    Which4 <- grep(pattern = "# General features: ", x = file)
    fileOut <- c(fileOut, file[(Which3-1):Which4])
    fileOut <- c(fileOut, paste("# ",Features))
    # }
  } else {
    # fileOut <- c(fileOut, file[(Which3-1):(length(file)-2)])
    
    Which4 <- grep(pattern = "# Model features:", x = file)
    fileOut <- c(fileOut, file[(Which3-1):(Which4-1)])
  }
  
  # Add the model features
  if(dim(tmpSumUp)[1] == 1){
    # Model features for the pre-existing model
    fileOut <- c(fileOut, "", "# Model features:")
    OldMod_Feat <- NULL
    while (is.null(OldMod_Feat)) {
      eval(parse(
        text = paste0(
          "Mod_old <- readline(prompt = 'Please describe the ",
          tmpSumUp$`New model`,
          " model: ')"
        )
      ))
      
      eval(parse(
        text = paste0(
          "Mod_old <- paste0('\n# - Model ",
          tmpSumUp$`New model`,
          ":\n# ', Mod_old\n)"
        )
      ))
      eval(parse(text =
                   paste0(
                     'OldMod_Feat <-Mod_old'
                   )))
      Sys.sleep(0.1)
    }
    OldMod_Feat <- unlist(stringr::str_split(OldMod_Feat, pattern = "\n"))[2:3]
    fileOut <- c(fileOut, OldMod_Feat)
  } else {
    Which5 <- grep(pattern = "# Model features:", x = file)
    fileOut <- c(fileOut, file[(Which5-1):(length(file)-2)])
  }
  
  Mod_Feat <- stringr::str_replace_all(string = Mod_Feat, pattern = "\n", replacement = "")
  Mod_Feat <- unlist(stringr::str_split(string = Mod_Feat, pattern = "#"))
  Mod_Feat <- Mod_Feat[-1]
  fileOut <- c(fileOut,paste("#",Mod_Feat,sep=""))
  fileOut <- c(fileOut,file[(length(file)-1):length(file)])
  fileOut <- fileOut[!fileOut==""]
  base::writeLines(text = fileOut, con = out)
  
  cat(
    "=> The 'Sensitivity_Analysis_Features.txt' file has been updated.\n"
  )
  # ========================================================
  
  
  
  # 7. Update the "Summary_Sensitivity_analysis.pdf" ----
  # ======================================================== #
  cat("=> Now updating the 'Summary_Sensitivity_analysis.pdf' file.\n")
  
  topic <- unique(tmpInfo$Topic)
  author <- unique(tmpInfo$Author)
  script_model <- unique(tmpInfo$`Script model`)
  script_results <- unique(tmpInfo$`Script results`)
  if(is.null(Features)){
    Features <- unique(tmpInfo$Features)
  }
  SumUp <- SumUp %>%
    tibble::add_row(
      'SA number' = SA_ID,
      Topic = topic,
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
  SumUp <- SumUp[order(SumUp$`SA number`),]
  suppressMessages(SumUp <-
                     update_SA_table(SumUp = SumUp, dir_SensAnal = dir_SensAnal))
  # ========================================================
  
  # 8. Update the "Models_Sensitivity_analysis.pdf" ----
  # ======================================================== #
  cat("=> Now updating the 'Models_Sensitivity_analysis.pdf' file.\n")
  cat(
    "Please provide a short description for each model new model.
\t => Refer to the 'Models_Sensitivity_analysis.pdf' for example."
  )
  
  # Get a description of each model
  Nimpl <- length(new_model)
  Mod_dsc <- NULL
  while (is.null(Mod_dsc)) {
    for (i in 1:Nimpl) {
      eval(parse(
        text = paste0(
          "dsc_",
          i,
          " <- readline(prompt = 'Short description for the ",
          new_model[i],
          " model: ')"
        )
      ))
    }
    if (i == Nimpl)
      Mod_dsc <- "ok"
    Sys.sleep(0.1)
  }
  
  Desc <- NULL
  for (m in 1:Nimpl) {
    eval(parse(text = paste0("Desc <- c(Desc, dsc_", m, ")")))
  }
  
  Models_SA <- Models_SA %>%
    tibble::add_row(
      'SA number' = SA_ID,
      Topic = topic,
      Object = object,
      'Model name' = new_model,
      Description = Desc,
      path = pathMod
    )
  Models_SA <- Models_SA[order(Models_SA$`SA number`),]
  suppressMessages(
    Models_SA <-
      update_Models_SA_table(Models_SA = Models_SA, dir_SensAnal = dir_SensAnal)
  )
  # ========================================================
  
  
  # 7. Update the scripts for this sensitivity analysis ----
  # ======================================================== #
  out <- file.path(dirScript_SensAnal, script_model, fsep = fsep)
  file <- readLines(out)
  
  # Set up the header 
  outBeg <-
    file.path(WD, "Sensitivity_Analysis_Features.txt", fsep = fsep)
  Beg <- readLines(outBeg)
  
  Which1 <-  grep(pattern = "# Sensitivity Analysis ID:", x = Beg)
  Beg <- Beg[-c(Which1)]
  Which2 <-  grep(pattern = "# Name of the script used to build the new model", x = Beg)
  Beg <- Beg[-c(Which2:(Which2+3))]
  
  WhichFirst <-  grep(pattern = "# Topic of the sensitivity analysis", x = Beg)
  Beg <- Beg[(WhichFirst-1):length(Beg)]
  Beg <- c("# ============================================================ #",
           "# Script used to develop the model(s) considered in the",
           paste("# sensitivity analysis:",SA_ID),
           "# ============================================================ #",
           "#", "# Sensitivity analysis summary", "#", Beg, "",
           "# ----------------------------------------------------------- #",
           "# ----------------------------------------------------------- #", "")
  
  
  # Get the warnings and update them
  WhichFirst <- grep(pattern = "# This script holds the code used to develop the models considered in this sensitivity analysis.", x = file)
  WhichLast <- grep(pattern = "WARNINGS", x = file, perl = FALSE)
  if (length(WhichLast) > 0){
    warnMod_New <-
      Modcomp[which(Modcomp$warning == 1), "new_model"]
    warnMod_Base <-
      Modcomp[which(Modcomp$warning == 1), "base_model"]
    
    Beg <- c(Beg, file[WhichFirst:(WhichLast + 3)],
             paste(file[(WhichLast + 4)], paste(warnMod_New, collapse = ", "),sep = ","),
             "# do(es) not exist yet. This means you'll have to start by developping its/their own base model before creating your new model !!!!",
             "# Specifically, you must first develop the following model(s):",
             paste(file[(WhichLast + 7)], paste(warnMod_Base, collapse = ", "),sep = ","),
             "", 
             "# *************************************", 
             "# *************************************", 
             ""
    )
  }
  
  WhichLast <- grep(pattern = "(all.names = TRUE)", x = file)[1]
  file <- c(Beg,
            "# ----------------------------------------------------------- #",
            "# ----------------------------------------------------------- #", 
            "",
            file[WhichLast:length(file)])
  
  # Modify the Hessian stuff
  WhichLast <- grep(pattern = "noHess <-", x = file)[1]
  # Detect the TRUE
  SetNewHess <- unlist(strsplit(file[WhichLast], '[()]'))[2]
  SetNewHess <- unlist(stringr::str_split(string = SetNewHess,pattern = ","))
  SetNewHess <- c(SetNewHess, rep("FALSE", length(new_model)))
  SetNewHess <- paste0("noHess <- c(",paste(SetNewHess, sep = "", collapse = ","),")")
  file[WhichLast] <- SetNewHess
  
  # Find the last model 
  WhichLast <- grep(pattern = "## End section ##", x = file)
  file <- file[1:(WhichLast-4)]
  
  if(unique(file[(length(file)-1):length(file)]) %in% ""){
    file <- file[-c((length(file)-1):length(file))]
    file <- c(file, "")
  }
  if(file[length(file)]!=""){
    file <- c(file, "")
  }
  base::writeLines(text = file, con = out)
  
  tmpSumUp <- SumUp[SumUp$`SA number` == SA_ID,]
  length_old <- length(tmpSumUp$`New model`)-dim(Modcomp)[1]
  stp <- length_old + 3
  
  # Append the new script to the old one
  environment(Append_SA_analyses_Script) <- environment()
  Append_SA_analyses_Script(out = out, stp = stp, length_old = length_old)
  
  cat(
    "- The",
    paste0("'", script_model, "'"),
    " file has been updated in the",
    paste0("'", dirScript_SensAnal, "'"),
    "folder.\n"
  )
  
  
  # Update Modcomp to get the past models
  Modcomp <- data.frame(base_model = tmpSumUp$`Base model`,
                        new_model = tmpSumUp$`New model`, warning = 0)  
  
  # Model features
  OldModFeat <-
    file.path(WD, "Sensitivity_Analysis_Features.txt", fsep = fsep)
  OldModFeat <- readLines(OldModFeat)
  WhichLast <- grep(pattern = "# Model features:", x = OldModFeat)
  OldModFeat <- OldModFeat[WhichLast:(length(OldModFeat)-2)]
  
  out <- file.path(dirScript_SensAnal, script_results, fsep = fsep)
  object <- tmpSumUp$Object
  new_model <- tmpSumUp$`New model`
  base_model <- tmpSumUp$`Base model`
  
  environment(write_SA_files) <- environment()
  write_SA_files(out = out, do_results = TRUE)
  
  # Update model features
  file <- readLines(out)
  WhichLast <- grep(pattern = "# Model features:", x = file)
  file <- c(file[1:(WhichLast-1)],OldModFeat,file[(WhichLast+1):length(file)])
  base::writeLines(text = file, con = out)
  
  cat(
    "- The",
    paste0("'", script_results, "'"),
    " file has been updated in the",
    paste0("'", dirScript_SensAnal, "'"),
    "folder.\n"
  )
  # ========================================================
  
  # 8. Update SA_info ----
  # ======================================================== #
  SA_info <- NULL
  SA_info <- list(SumUp = SumUp, Models_SA = Models_SA)
  save(SA_info,
       file = file.path(dirScript_SensAnal, "SA_info.RData", fsep = fsep))
  # ========================================================
  
}



#' 8. Function to append the developemnt script to the SA analyze scritp ----
#' ----------------------------------------------------------- #
#'
#' @param out (character string)- Name of the script file where new stuff has to
#' be appended.
#' @param stp (integer)- Count the number of models already developed.
#' @param length_old (integer) - Number of pre-existant models. Needed for the 
#' Hessian stuff
#' 
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
Append_SA_analyses_Script <- function(out = NULL, 
                                      stp = NULL, 
                                      length_old = NULL) {
  for (m in 1:dim(Modcomp)[1]) {
    Dirmod <- NULL
    ModelName <- Modcomp[m, "new_model"]
    
    cat(
      "# ",
      paste0(stp, "."),
      "Developing model",
      Modcomp[m, "new_model"],
      " ----\n",
      file = out,
      append = TRUE
    )
    cat(
      "# ----------------------------------------------------------- #\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# Path to the",
        Modcomp[m, "new_model"],
        "repertory\n",
        file = out,
        append = TRUE)
    tmp <-
      gsub(
        pattern = file.path("model", "Sensitivity_Anal", fsep = fsep),
        replacement = "",
        x = Models_SA[Models_SA$`Model name` == Modcomp[m, "new_model"], "path"]
      )
    tmp <-
      stringr::str_split_fixed(string = tmp,
                               pattern = fsep,
                               n = 3)
    cat(
      paste0("Dir_", gsub('\\.', '_', Modcomp[m, "new_model"])),
      "<- file.path(dir_SensAnal,",
      paste0("'", paste(tmp[2], tmp[3], sep = "','"), "'"),
      ",fsep = fsep)\n",
      file = out,
      append = TRUE
    )
    Dirmod <-
      paste0("Dir_", gsub('\\.', '_', Modcomp[m, "new_model"]))
    cat("\n", file = out, append = TRUE)
    cat(
      "# Add the model directory to the saved variables\n",
      file = out,
      append = TRUE
    )
    cat(
      "var.to.save <- c(var.to.save,",
      paste0("'", Dirmod, "')"),
      "\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    ext <- gsub(pattern = "\\.",
                replacement = "_",
                x = ModelName)
    ext <- paste0(c("Start", "Dat", "Ctl", "Fore"), ext)
    namFiles <-
      c("Starter file",
        "Data file",
        "Control file",
        "Forecast file")
    cat(
      "# For each SS input file, the following variable names will be used:\n",
      file = out,
      append = TRUE
    )
    for (d in 1:4)
      cat(
        "#",
        namFiles[d],
        ifelse(m == 2, yes = ":\t\t\t\t\t", no = ":\t\t\t"),
        ext[d],
        "\n",
        file = out,
        append = TRUE
      )
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat(
      "# Do you want to copy the SS input files from the base model?\n",
      file = out,
      append = TRUE
    )
    cat(
      "# This is useful if you are developing a model based on a base model that
# that did not exist when you set up the sensitivity analysis or if you already
# wrote a new SS input file for your new model and need to modify it (It ensure
# to start again from scratch and get the same\n",
      file = out,
      append = TRUE
    )
    cat("# basis of comparison.\n",
        file = out,
        append = TRUE)
    cat("Restart_SA_modeldvpt()\n",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    
    # Starter file
    cat(
      "#",
      paste0(stp, ".1"),
      " Work on the Starter file ----\n",
      file = out,
      append = TRUE
    )
    cat("# ======================= #",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("# Read in the file\n", file = out, append = TRUE)
    cat(
      "StarterFile <-",
      paste0("file.path(", Dirmod, ","),
      "'starter.ss', fsep = fsep)\n",
      file = out,
      append = TRUE
    )
    cat(
      ext[1],
      "<- SS_readstarter(
      file = StarterFile,
      verbose = TRUE
      )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# Make your modification if applicable\n",
        file = out,
        append = TRUE)
    cat("# Code modifying the starter file\n",
        file = out,
        append = TRUE)
    cat("# ..... \n", file = out, append = TRUE)
    cat("# ..... \n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("# Save the starter file for the model\n",
        file = out,
        append = TRUE)
    cat(
      "SS_writestarter(
      mylist = ",
      ext[1],
      ",
      dir = ",
      paste0(Dirmod, ","),
      "
      overwrite = TRUE,
      verbose = TRUE
      )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# Check file structure\n",
        file = out,
        append = TRUE)
    cat(
      "# StarterFile <-",
      paste0("file.path(", Dirmod, ","),
      "'starter.ss')\n",
      file = out,
      append = TRUE
    )
    cat(
      "# ",
      ext[1],
      "<- SS_readstarter(
      # file = StarterFile,
      # verbose = TRUE
      # )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# clean environment\n",
        file = out,
        append = TRUE)
    cat(
      "var.to.save <- c(var.to.save, '",
      ext[1],
      "')\n",
      sep = "",
      file = out,
      append = TRUE
    )
    cat("rm(list = setdiff(ls(), var.to.save))\n",
        file = out,
        append = TRUE)
    cat("var.to.save <- ls()\n",
        file = out,
        append = TRUE)
    cat("# =======================",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    
    # Data file
    cat(
      "#",
      paste0(stp, ".2"),
      " Work on the data file ----\n",
      file = out,
      append = TRUE
    )
    cat("# ======================= #",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("# Read in the file\n", file = out, append = TRUE)
    cat(
      "DatFile <-",
      paste0("file.path(", Dirmod, ","),
      ext[1],
      "$datfile, fsep = fsep)\n",
      sep = "",
      file = out,
      append = TRUE
    )
    cat(
      ext[2],
      "<- SS_readdat_3.30(
      file = DatFile,
      verbose = TRUE,
      section = TRUE
      )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# Make your modification if applicable\n",
        file = out,
        append = TRUE)
    cat("# Code modifying the data file \n",
        file = out,
        append = TRUE)
    cat("# ..... \n", file = out, append = TRUE)
    cat("# ..... \n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("# Save the data file for the model\n",
        file = out,
        append = TRUE)
    cat(
      "SS_writedat(
      datlist = ",
      ext[2],
      ",
      outfile =",
      paste0("file.path(", Dirmod, ","),
      "'SST_data.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# Check file structure\n",
        file = out,
        append = TRUE)
    cat(
      "# DatFile <-",
      paste0("file.path(", Dirmod, ","),
      "'SST_data.ss', fsep = fsep)\n",
      file = out,
      append = TRUE
    )
    cat(
      "# ",
      ext[2],
      "<-
      # SS_readdat_3.30(
      # file = DatFile,
      # verbose = TRUE,
      # section = TRUE
      # )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# clean environment\n",
        file = out,
        append = TRUE)
    cat(
      "var.to.save <- c(var.to.save, '",
      ext[2],
      "')\n",
      sep = "",
      file = out,
      append = TRUE
    )
    cat("rm(list = setdiff(ls(), var.to.save))\n",
        file = out,
        append = TRUE)
    cat("var.to.save <- ls()\n",
        file = out,
        append = TRUE)
    cat("# =======================",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    
    # Control file
    cat(
      "#",
      paste0(stp, ".3"),
      " Work on the control file ----\n",
      file = out,
      append = TRUE
    )
    cat("# ======================= #",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat(
      "# The SS_readctl_3.30() function needs the 'data_echo.ss_new' file to read the control file
# This file is created while running SS. You may have had a warning when building
# this script. Please check that the existence of the 'data_echo.ss_new' file
# in the 'run' folder of your new model.
# If the file does not exist, please use the RunSS_CtlFile() function that run SS
# in a designated file.\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# Read in the file\n", file = out, append = TRUE)
    cat(
      "Ctlfile <-",
      paste0("file.path(", Dirmod, ","),
      ext[1],
      "$ctlfile, fsep = fsep)\n",
      sep = "",
      file = out,
      append = TRUE
    )
    
    cat(
      ext[3],
      "<- SS_readctl_3.30(
      file = Ctlfile,
      use_datlist = TRUE,
      datlist =",
      paste0("file.path(", Dirmod, ","),
      "'run','data_echo.ss_new', fsep = fsep),
      verbose = TRUE
      )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# Make your modification if applicable\n",
        file = out,
        append = TRUE)
    cat("# Code modifying the control file \n",
        file = out,
        append = TRUE)
    cat("# ..... \n", file = out, append = TRUE)
    cat("# ..... \n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("# Save the control file for the model\n",
        file = out,
        append = TRUE)
    cat(
      "SS_writectl(
      ctllist = ",
      ext[3],
      ",
      outfile =",
      paste0("file.path(", Dirmod, ","),
      "'SST_control.ss', fsep = fsep),
      version = '3.30',
      overwrite = TRUE
      )\n",
      file = out,
      append = TRUE
    )
    cat("# Check file structure\n",
        file = out,
        append = TRUE)
    cat(
      "# We actually need to run the model to check the file structure\n",
      file = out,
      append = TRUE
    )
    
    cat("\n", file = out, append = TRUE)
    cat("# clean environment\n",
        file = out,
        append = TRUE)
    cat(
      "var.to.save <- c(var.to.save, '",
      ext[3],
      "')\n",
      sep = "",
      file = out,
      append = TRUE
    )
    cat("rm(list = setdiff(ls(), var.to.save))\n",
        file = out,
        append = TRUE)
    cat("var.to.save <- ls()\n",
        file = out,
        append = TRUE)
    cat("# =======================",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    
    
    # Forecast file
    cat(
      "#",
      paste0(stp, ".4"),
      " Work on the forecast file ----\n",
      file = out,
      append = TRUE
    )
    cat("# ======================= #\n",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("# Read in the file\n", file = out, append = TRUE)
    cat(
      "ForeFile <-",
      paste0("file.path(", Dirmod, ","),
      "'forecast.ss', fsep = fsep)\n",
      file = out,
      append = TRUE
    )
    cat(
      ext[4],
      "<-SS_readforecast(
      file = ForeFile,
      version = '3.30',
      verbose = T,
      readAll = T
      )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# Make your modification if applicable\n",
        file = out,
        append = TRUE)
    cat("# Code modifying the forecast file \n",
        file = out,
        append = TRUE)
    cat("# ..... \n", file = out, append = TRUE)
    cat("# ..... \n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("# Save the forecast file for the model\n",
        file = out,
        append = TRUE)
    cat(
      "SS_writeforecast(
      mylist = ",
      ext[4],
      ",
      dir =",
      paste0(Dirmod, ","),
      "
      file = 'forecast.ss',
      writeAll = TRUE,
      verbose = TRUE,
      overwrite = TRUE
      )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# Check file structure\n",
        file = out,
        append = TRUE)
    cat(
      "# ForeFile <-",
      paste0("file.path(", Dirmod, ","),
      "'forecast.ss', fsep = fsep)\n",
      file = out,
      append = TRUE
    )
    cat(
      "# ",
      ext[4],
      "<- SS_readforecast(
      # file = ForeFile,
      # version = '3.30',
      # verbose = T,
      # readAll = T
      # )\n",
      file = out,
      append = TRUE
    )
    
    cat("\n", file = out, append = TRUE)
    cat("# clean environment\n",
        file = out,
        append = TRUE)
    cat(
      "var.to.save <- c(var.to.save, '",
      ext[4],
      "')\n",
      sep = "",
      file = out,
      append = TRUE
    )
    cat("rm(list = setdiff(ls(), var.to.save))\n",
        file = out,
        append = TRUE)
    cat("var.to.save <- ls()\n",
        file = out,
        append = TRUE)
    cat("# =======================\n",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat(
      "# If you are done with your implementations, you can now run this new model\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat(
      "# *********************************************************** #\n",
      file = out,
      append = TRUE
    )
    cat(
      "#",
      paste0(stp, ".5"),
      " Run the new model using the new input files ----\n",
      file = out,
      append = TRUE
    )
    cat("# ======================= #",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat(
      "run_SS(SS_version = '3.30.21',
      # version of SS
      base_path =",
      paste0(Dirmod, ","),
      "
      # root directory where the input file are housed
      pathRun = NULL,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = TRUE,
      # copy the input files from the",
      ModelName ,
      "folder
      cleanRun = TRUE,
      # clean the folder after the run
      extra = ifelse(noHess[",
      m+length_old,
      "], yes = '-nohess', no = '')
      # this is if we want to use '-nohess'
      )\n",
      sep = "",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat(
      "#",
      paste0(stp, ".6"),
      " Let's plot the outputs from this model ----\n",
      file = out,
      append = TRUE
    )
    cat("# ======================= #\n",
        file = out,
        append = TRUE)
    cat(
      "# read the model output and print diagnostic messages\n",
      file = out,
      append = TRUE
    )
    cat(
      "Dirplot <-",
      paste0("file.path(", Dirmod, ","),
      "'run', fsep = fsep)\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat(
      "replist <- SS_output(
      dir = Dirplot,
      verbose = TRUE,
      printstats = TRUE
      )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat(
      "# plots the results (store in the 'plots' sub-directory)\n",
      file = out,
      append = TRUE
    )
    cat(
      "SS_plots(replist,
      dir = Dirplot,
      printfolder = 'plots'
      )\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("# =======================\n",
        file = out,
        append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
    cat(
      "# -----------------------------------------------------------\n",
      file = out,
      append = TRUE
    )
    cat(
      "# -----------------------------------------------------------\n",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    if (m == dim(Modcomp)[1]) {
      cat("## End section ##\n", file = out, append = TRUE)
      cat("\n", file = out, append = TRUE)
      cat(
        "# You are ready to analyze the differences between the models
# considered in this sensitivity analysis.\n",
        file = out,
        append = TRUE
      )
      cat(
        "# This can be done using the",
        script_results,
        "script.\n",
        file = out,
        append = TRUE
      )
      cat("\n", file = out, append = TRUE)
      cat("# !!!!! WARNING !!!!!\n",
          file = out,
          append = TRUE)
      cat("# ------------------- #\n",
          file = out,
          append = TRUE)
      cat(
        "# Please do not develop any script that you want to keep after this
# warning section - It might be overwritten in the case you add a new
# model to this SA.\n",
        file = out,
        append = TRUE
      )
      # cat("# !!! END WARNING !!!\n",
      #     file = out,
      #     append = TRUE)
      cat("# ------------------- #\n",
          file = out,
          append = TRUE)
      cat("\n", file = out, append = TRUE)
      cat("## End script to develop SA models ##\n",
          file = out,
          append = TRUE)
    } else {
      cat(
        "# End development for model",
        ModelName,
        "\n",
        file = out,
        append = TRUE
      )
      cat(
        "# You can now develop the next 'new model'.\n",
        file = out,
        append = TRUE
      )
      cat(
        "# Let's remove the input files for this from the 'var.to.save' variable\n",
        file = out,
        append = TRUE
      )
      cat(
        "var.to.save <- var.to.save[!var.to.save %in% c('",
        ext[1],
        "','",
        ext[2],
        "','",
        ext[3],
        "','",
        ext[4],
        "')]\n",
        sep = "",
        file = out,
        append = TRUE
      )
      cat("rm(list = setdiff(ls(), var.to.save))\n",
          file = out,
          append = TRUE)
      cat("var.to.save <- ls()\n",
          file = out,
          append = TRUE)
      stp <- stp + 1
    }
    cat("\n", file = out, append = TRUE)
    cat(
      "# -----------------------------------------------------------\n",
      file = out,
      append = TRUE
    )
    cat(
      "# -----------------------------------------------------------\n",
      sep = "",
      file = out,
      append = TRUE
    )
    cat("\n", file = out, append = TRUE)
    cat("\n", file = out, append = TRUE)
  } # end loop on m
}
