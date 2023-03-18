# Shortened functions
.an <- function(x) {
  return(as.numeric(x))
}
.ac <- function(x) {
  return(as.character(x))
}
.af <- function(x) {
  return(as.factor(x))
}

#' @title Get file names without extension
#'
#' @description This function returns a file name without its extension
#'
#' @param filenames Name of file
#'
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
#' @return character string: the file name
#'
get_nam <- function(filenames) {
  tmp <- c()
  for (i in 1:length(filenames))
    tmp <- c(tmp, unlist(strsplit(filenames, "\\.")[[i]][1]))
  return(tmp)
}

#' Clean files in a folder
#'
#' @param path (character string) file path representing the root folder to be cleaned
#' @param names (vector of character strings) - Indicate the files in the root 
#' folder to be removed
#' @param verbose (logical) -  flag to print filenames being deleted
#
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
clean_files <- function(path = ".",
                        names = c("no_file"),
                        verbose = FALSE) {
  for (name in names) {
    fns = list.files(path = path,
                     pattern = glob2rx(name),
                     full.names = TRUE)
    
    if (length(fns) > 0) {
      if (verbose)
        cat("--Removing files:\n", paste0("\t", fns, "\n"))
      
      file.remove(fns)
      
    }
  }
}

#' Clean files SS output files
#' @param path (character string) - file path to the folder that has to be cleaned
#' @param verbose (logical) -  flag to print filenames being deleted
#
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
clean_bat <- function(path = ".", verbose = TRUE) {
  # Remove the basic files that we don't want
  names = c("*.bar","*.eva","*.log","*.std","gradient.*",
            "*.r0*","*.p0*","*.b0*", "starter.ss_new", "forecast.ss_new","control.ss_new")
  clean_files(path=path,names=names,verbose=verbose)
  # Files we want to save
  filesSave <- c(
    "starter",
    "forecast",
    "Report",
    "Forecast-report",
    "echoinput",
    "ss_summary",
    "CompReport",
    "ss_win~4",
    "ss_win~4",
    "warning",
    "console.output",
    "data_echo.ss_new",
    "data.ss_new"
  )
  filesSave <- list.files(path)[get_nam(list.files(path)) %in% get_nam(filesSave)]
  
  # Get the names of the data and control files
  starternam <- filesSave[grepl(pattern = "starter.", x = filesSave)]
  starter <-
    r4ss::SS_readstarter(
      file = file.path(path, starternam,
                       fsep = .Platform$file.sep),
      verbose = verbose
    )
  
  TrueNam <- c(starter$datfile, starter$ctlfile)
  inputFiles <- list.files(path)[get_nam(list.files(path)) %in% get_nam(TrueNam)]
  for(i in 1:2){
    inputFiles[i] <- paste0(get_nam(inputFiles[i]), ".", unlist(strsplit(TrueNam[i], "\\."))[2])
  }
  
  filesSave <- c(filesSave, inputFiles)
  names <- list.files(path)[!get_nam(list.files(path)) %in% get_nam(filesSave)]
  # Remove files we don't want
  clean_files(path = path,
              names = names,
              verbose = verbose)
}
