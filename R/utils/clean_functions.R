# Clean files in a folder
#
# path = character string or file path representing the root folder to be cleaned
# names = vector of character strings representing files in the root folder to be removed
# verbose = (TRUE/FALSE) flag to print filenames being deleted
#
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

# Clean files SS output files
# path = character string or file path representing the root folder to be cleaned
clean_bat <- function(path = ".", verbose = TRUE) {
  filesSave <- c(
    "starter.ss",
    "forecast.ss",
    "Report.sso",
    "Forecast-report.sso",
    "ss.par",
    "ss.rep",
    "echoinput.sso",
    "ss_summary.sso",
    "CompReport.sso"
  )
  
  starter <-
    r4ss::SS_readstarter(
      file = file.path(path, "starter.ss",
                       fsep = .Platform$file.sep),
      verbose = FALSE
    )
  
  if(file_ext(starter$datfile) == "SS"){
    starter$datfile <- str_replace(starter$datfile, ".SS", ".ss")
  }
  
  if(file_ext(starter$ctlfile) == "SS"){
    starter$ctlfile <- str_replace(starter$ctlfile, ".SS", ".ss")
  }
  
  filesSave <- c(filesSave, starter$datfile, starter$ctlfile)
  
  names <- list.files(path)[!list.files(path) %in% filesSave]
  
  
  clean_files(path = path,
              names = names,
              verbose = verbose)
  
}














