# library(stringr)
library(doParallel)

#' Define the current OS
#'
#' @author Joshua A Zahner & Matthieu Veron
# Contacts: jzahner@uw.edu | mveron@uw.edu
#
get_os <- function() {
  sysinf <- Sys.info()
  if (!is.null(sysinf)) {
    os <- sysinf['sysname']
    if (os == 'Darwin') {
      os <- "osx"
    } else if (os == "Windows") {
      if (grepl("64", sysinf["release"])) {
        os <- "win64"
      } else{
        os <- "win32"
      }
    }
  } else {
    ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  return(tolower(os))
}

#' @title Set the path where the SS exe is stored
#' 
#' @param os the OS of your machine
#' @param (character string) - The SS version currently supported are
#' either "3.30.21" or "3.24.U".
#' @param fname.extra (character string) - Define the "extra" name of the executable.
#' The possible name extensions are: "fast", "safe", "opt" for the "3.24.U" SS version
#' and "opt" for the "3.30.21" version.
#' 
#' @author Joshua A Zahner & Matthieu Veron
# Contact: jzahner@uw.edu | mveron@uw.edu
#
get.ss.exe.path <-
  function(os = NULL,
           ss_version = "3.30.21",
           fname.extra = "") {
    
    if (is.null(os)) {
      os <- get_os()
    }
    
    if (!(os %in% c("win32", "win64", "win", "osx", "linux"))) {
      stop(
        "Unknown OS provided. Must be one of: 'win', 'win32', 'win64', 'osx', 'linux'.
       Note that newer version of SS do not support win32.
      "
      )
    }
    
    if (!(ss_version %in% c("3.24.U", "3.30.21"))) {
      stop("Unsupported SS version. Please used either 3.24.U or 3.30.21.")
    }
    
    file.extension = ""
    if (os %in% c("win32", "win64", "win")) {
      file.extension <- ".exe"
    }
    
    version.components <- stringr::str_split(ss_version, "[.]")[[1]]
    major.version <- version.components[1]
    minor.version <- version.components[2]
    patch.number  <- version.components[3]
    
    if (as.numeric(minor.version) >= 30 &
        os %in% c("win32", "win64", "win")) {
      os <- "win"
    }
    
    exe.dir <- file.path(here::here(), "model", "ss_executables")
    
    version.dir <-
      paste0("SS_V", major.version, "_", minor.version, "_", patch.number)
    
    if (nchar(fname.extra) > 0) {
      fname.extra <- paste0("_", fname.extra)
    }
    
    if (minor.version >= 30) {
      ss.file <- paste0("ss", fname.extra, "_", os,  file.extension)
    } else {
      ss.file <- paste0("ss_", os, fname.extra, file.extension)
    }
    
    exe.path <- file.path(exe.dir, version.dir, ss.file)
    if (!file.exists(exe.path)) {
      warning("Note that this executable does not exist.")
    }
    return(exe.path)
  }


#' Run SS
#'
#' @param SS_version (character string) - The SS version currently supported are
#' either "3.30.21" or "3.24.U".
#' @param Exe_extra (character string) - Define the "extra" name of the executable.
#' The possible name extensions are: "fast", "safe", "opt" for the "3.24.U" SS version
#' and "opt" for the "3.30.21" version.
#' @param base_path (character string) - root directory where the input file are
#' housed.
#' @param pathRun (character string) - path where the run has to be done. If
#' \code{NULL} (default), then the run will be done in the `run` folder housed
#' in the `base_path`. This `run` folder is created if it doesn't already exist.
#' @param copy_files (logical) - Do the iinput files have to be copied from the
#' `base_path` to the `pathRun` ?
#' @param extras (character string) - Additional ADMB command line arguments
#' passed to the executable, such as "-nohess".
#' @param cleanRun (logical) - Specify if the `pathRun` has to be cleaned after
#' the run. See the `clean_bat()` function.
#' 
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#'
#' @Details
#' By default, the function will save the output of the console in the
#' `console.output.txt` file and won't skip the run if the `pathRun` folder
#' already contain a `Report.sso` file.

run_SS <- function(SS_version = "3.30.21",
                   Exe_extra = "",
                   base_path = "",
                   pathRun = NULL,
                   copy_files = TRUE,
                   extras = NULL,
                   cleanRun = TRUE) {
  .fsep <- .Platform$file.sep #easy for file.path() function
  
  # Directory where the executable is stored
  pathExe <-
    get.ss.exe.path(ss_version = SS_version, fname.extra = Exe_extra)
  
  # Check the existence of pathRun and copy SS input files if needed
  if (!is.null(pathRun)) {
    if (!dir.exists(pathRun)) {
      stop("The 'pathRun' specified does not exist. Please check the directory you entered.")
    }
    # Copy SS input files
    if (copy_files) {
      SS.files <-
        dir(
          base_path,
          pattern = "*.ss",
          ignore.case = TRUE,
          all.files = TRUE
        )
      file.copy(
        from = file.path(base_path, SS.files, fsep = .fsep),
        to = file.path(pathRun, SS.files, fsep = .fsep),
        overwrite = TRUE,
        copy.date = TRUE
      )
    }
  } else {
    pathRun <- file.path(base_path, "run", fsep = .fsep)
    if (!dir.exists(pathRun)) {
      dir.create(pathRun)
    }
    # Copy SS input files
    SS.files <-
      dir(base_path,
          "*.ss",
          ignore.case = TRUE,
          all.files = TRUE)
    file.copy(
      from = file.path(base_path, SS.files, fsep = .fsep),
      to = file.path(pathRun, SS.files, fsep = .fsep),
      overwrite = TRUE,
      copy.date = TRUE
    )
  }
  # run SS
  print(
    r4ss::run(
      dir = pathRun,
      extras = extras,
      exe = pathExe,
      verbose = TRUE,
      skipfinished = FALSE
    )
  )
  # run clean functions to delete files
  if (cleanRun)
    clean_bat(path = pathRun, verbose = FALSE)
}



#' @title Run SS if data.ss_new/data_echo.ss_new is missing when reading .ctl file
#'
#' @description Function that runs SS to get the file needed to read in the control
#' file. This depends on the version of SS considered (see below - data.ss_new /
#' data_echo.ss_new)
#'
#'@param SS_version (character string) - The SS version currently supported are
#' either "3.30.21" or "3.24.U".
#' @param Exe_extra (character string) - Define the "extra" name of the executable.
#' The possible name extensions are: "fast", "safe", "opt" for the "3.24.U" SS version
#' and "opt" for the "3.30.21" version.
#' @param base_path (character string) - root directory where the input file are
#' housed.
#' @param pathRun (character string) - path where the run has to be done. If
#' \code{NULL} (default), then the run will be done in the `run` folder housed
#' in the `base_path`. This `run` folder is created if it doesn't already exist.
#' @param copy_files (logical) - Do the iinput files have to be copied from the
#' `base_path` to the `pathRun` ?
#' @param extras (character string) - Additional ADMB command line arguments
#' passed to the executable, such as "-nohess".
#' @param cleanRun (logical) - Specify if the `pathRun` has to be cleaned after
#' the run. See the `clean_bat()` function.
#'
#' @author Matthieu Veron
#  Contact: mveron@uw.edu
#' @Details
#' By default, the function will save the output of the console in the
#' `console.output.txt` file and won't skip the run if the `pathRun` folder
#' already contain a `Report.sso` file.
#'
RunSS_CtlFile <- function(SS_version = "3.30.21",
                          Exe_extra = "",
                          base_path = "",
                          pathRun = NULL,
                          copy_files = TRUE,
                          extras = NULL,
                          cleanRun = TRUE) {
  pathRuntmp <- file.path(base_path, 'run', fsep = .Platform$file.sep)
  fileneeded <- ifelse(test = SS_version == "3.24.U",
                       yes = "data.ss_new",
                       no = "data_echo.ss_new")
  if (!file.exists(file.path(pathRuntmp, fileneeded, fsep = .Platform$file.sep))) {
    run_SS(
      SS_version = SS_version,
      # version of SS
      Exe_extra = Exe_extra,
      # "extra" name of the executable
      base_path = base_path,
      # root directory where the input file are housed
      pathRun = pathRun,
      # A 'run' folder is created if needed (where output files will be stored)
      copy_files = copy_files,
      # copy the input files from the 23.sq.fix folder
      extras - extras,
      # Additional ADMB command line arguments
      cleanRun = cleanRun
      # clean the folder after the run
    )
  } else {
    cat("The ",
        fileneeded,
        " file is already available in the run directory (",
        pathRun,
        ")")
  }
}
