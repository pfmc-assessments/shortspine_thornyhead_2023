# library(stringr)
library(doParallel)
library(nwfscDiag)

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

#  =========================================================================== #

#' @title Set the path where the SS exe is stored
#' 
#' @param os the OS of your machine
#' @param ss_version (character string) - The SS version currently supported are
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

#  =========================================================================== #

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
#' @param show_in_console (logical) - Display SS output in R console whiel running.
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
                   show_in_console = TRUE,
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
          pattern = "*.ss|*.par",
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
          "*.ss|*.par",
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
      skipfinished = FALSE,
      show_in_console = show_in_console
    )
  )
  # run clean functions to delete files
  if (cleanRun)
    clean_bat(path = pathRun, verbose = FALSE)
}

#  =========================================================================== #

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
      extras = extras,
      # Additional ADMB command line arguments
      cleanRun = cleanRun
      # clean the folder after the run
    )
  } else {
    cat("The ",
        fileneeded,
        " file is already available in the run directory (",
        pathRuntmp,
        ")", sep="")
  }
}


#' Run [r4ss::profile] based on `model_settings`
#'
#' Generate likelihood profiles compatible with macOS
#' To be called from the run_diagnostics function after creating
#' the model settings using the get_settings function.
#'
#'
#' @seealso The following functions interact with `profile_wrapper`:
#' * [run_diagnostics]: calls `profile_wrapper`
#' * [r4ss::profile]: the workhorse of `profile_wrapper` that does the parameter profiles
#'
#'
#' @template mydir
#' @template model_settings
#'
#' @author Chantel Wetzel, Emily Sellinger, Sophia Wassermann.
#' @return
#' Nothing is explicitly returned from `profile_wrapper`.
#' The following objects are saved to the disk.
profile_wrapper_MacOS <- function(mydir, model_settings) {
  
  # Add the round_any function from the plyr package to avoid conflicts between
  # plyr and dplyr.
  round_any <- function(x, accuracy, f = round) {
    f(x / accuracy) * accuracy
  }
  
  check_exe <- paste0(model_settings$exe)
  # check whether exe is in directory
  if (!check_exe %in% list.files(file.path(mydir, model_settings$base_name))) {
    stop("Executable not found in ", file.path(mydir, model_settings$base_name))
  }
  
  N <- nrow(model_settings$profile_details)
  
  for (aa in 1:N) {
    para <- model_settings$profile_details$parameters[aa]
    prior_used <- model_settings$profile_details$use_prior_like[aa]
    # Create a profile folder with the same naming structure as the base model
    # Add a label to show if prior was used or not
    profile_dir <- file.path(mydir, paste0(model_settings$base_name, "_profile_", para, "_prior_like_", prior_used))
    dir.create(profile_dir, showWarnings = FALSE)
    
    # Check for existing files and delete
    if (model_settings$remove_files & length(list.files(profile_dir)) != 0) {
      remove <- list.files(profile_dir)
      file.remove(file.path(profile_dir, remove))
    }
    
    all_files <- list.files(file.path(mydir, model_settings$base_name))
    capture.output(file.copy(
      from = file.path(mydir, model_settings$base_name, all_files),
      to = profile_dir, overwrite = TRUE
    ), file = "run_diag_warning.txt")
    message(paste0("Running profile for ", para, "."))
    
    # Copy the control file to run from the copy
    if (!file.exists(file.path(profile_dir, "control.ss_new"))) {
      orig_dir <- getwd()
      setwd(profile_dir)
      r4ss::run(
        dir = profile_dir,
        exe = model_settings$exe,
        extras = model_settings$extras
      )
      setwd(orig_dir)
    }
    
    # Use the SS_parlines funtion to ensure that the input parameter can be found
    check_para <- r4ss::SS_parlines(
      ctlfile = "control.ss_new",
      dir = profile_dir,
      verbose = FALSE,
      # version = model_settings$version,
      version = model_settings$version, # MM change - the argument is called "SSversion", not "version"
      active = FALSE
    )$Label == para
    
    if (sum(check_para) == 0) {
      print(para)
      stop(paste0("The input profile_custom does not match a parameter in the control.ss_new file."))
    }
    
    file.copy(file.path(profile_dir, "control.ss_new"), file.path(profile_dir, model_settings$newctlfile))
    # Change the control file name in the starter file
    starter <- r4ss::SS_readstarter(file = file.path(profile_dir, "starter.ss"))
    starter$ctlfile <- "control_modified.ss"
    starter$init_values_src <- model_settings$init_values_src
    # make sure the prior likelihood is calculated for non-estimated quantities
    starter$prior_like <- prior_used
    r4ss::SS_writestarter(mylist = starter, dir = profile_dir, overwrite = TRUE)
    
    # Read in the base model
    rep <- r4ss::SS_output(file.path(mydir, model_settings$base_name),
                           covar = FALSE,
                           printstats = FALSE, verbose = FALSE
    )
    est <- rep$parameters[rep$parameters$Label == para, "Value"]
    
    # Determine the parameter range
    if (model_settings$profile_details$param_space[aa] == "relative") {
      range <- c(
        est + model_settings$profile_details$low[aa],
        est + model_settings$profile_details$high[aa]
      )
    }
    if (model_settings$profile_details$param_space[aa] == "multiplier") {
      range <- c(
        est - est * model_settings$profile_details$low[aa],
        est + est * model_settings$profile_details$high[aa]
      )
    }
    if (model_settings$profile_details$param_space[aa] == "real") {
      range <- c(
        model_settings$profile_details$low[aa],
        model_settings$profile_details$high[aa]
      )
    }
    step_size <- model_settings$profile_details$step_size[aa]
    
    # Create parameter vect from base down and the base up
    if (est != round_any(est, step_size, f = floor)) {
      low <- rev(seq(
        round_any(range[1], step_size, f = ceiling),
        round_any(est, step_size, f = floor), step_size
      ))
    } else {
      low <- rev(seq(
        round_any(range[1], step_size, f = ceiling),
        round_any(est, step_size, f = floor) - step_size, step_size
      ))
    }
    
    if (est != round_any(est, step_size, f = ceiling)) {
      high <- c(est, seq(round_any(est, step_size, f = ceiling), range[2], step_size))
    } else {
      high <- c(seq(round_any(est, step_size, f = ceiling), range[2], step_size))
    }
    
    vec <- c(low, high)
    num <- sort(vec, index.return = TRUE)$ix
    
    profile <- r4ss::profile(
      dir = profile_dir,
      oldctlfile = "control.ss_new",
      newctlfile = model_settings$newctlfile,
      linenum = model_settings$linenum,
      string = para,
      profilevec = vec,
      usepar = model_settings$usepar,
      globalpar = model_settings$globalpar,
      parlinenum = model_settings$parlinenum,
      parstring = model_settings$parstring,
      saveoutput = model_settings$saveoutput,
      overwrite = model_settings$overwrite,
      whichruns = model_settings$whichruns,
      prior_check = model_settings$prior_check,
      read_like = model_settings$read_like,
      exe = model_settings$exe,
      verbose = model_settings$verbose,
      extras = model_settings$extras
    )
    
    # Save the output and the summary
    name <- paste0("profile_", para)
    vec_unordered <- vec
    vec <- vec[num]
    
    profilemodels <- r4ss::SSgetoutput(dirvec = profile_dir, keyvec = num)
    profilesummary <- r4ss::SSsummarize(biglist = profilemodels)
    
    profile_output <- list()
    profile_output$mydir <- profile_dir
    profile_output$para <- para
    profile_output$name <- paste0("profile_", para)
    profile_output$vec <- vec[num]
    profile_output$model_settings <- model_settings
    profile_output$profilemodels <- profilemodels
    profile_output$profilesummary <- profilesummary
    profile_output$rep <- rep
    profile_output$vec_unordered <- vec
    profile_output$num <- num
    
    save(
      profile_dir,
      para,
      name,
      vec,
      vec_unordered,
      model_settings,
      profilemodels,
      profilesummary,
      rep,
      num,
      file = file.path(profile_dir, paste0(para, "_profile_output.Rdata"))
    )
    
    nwfscDiag::get_summary(
      mydir = profile_dir,
      name = paste0("profile_", para),
      para = para,
      # vec = vec[num],
      vec = profilesummary$pars %>%
        dplyr::filter(Label == para) %>%
        dplyr::select(dplyr::starts_with("rep")) %>%
        as.vector(),
      profilemodels = profilemodels,
      profilesummary = profilesummary
    )
    
    nwfscDiag::profile_plot(
      mydir = profile_dir,
      para = para,
      rep = rep,
      profilesummary = profilesummary
    )
    
    message("Finished profile of ", para, ".")
  } # end parameter loop
}

#' macOS Wrapper to run each of the 3 standard diagnostic items:
#' 1) Jitter
#' 2) Profiles across female m, steepness, and R0
#' 3) Retrospectives
#'
#'
#' @template mydir
#' @template model_settings
#'
#' @author Chantel Wetzel
#' @return A vector of likelihoods for each jitter iteration.
run_diagnostics_MacOS <- function(mydir, model_settings) {
  
  library(dplyr)
  # Check for Report file
  model_dir <- file.path(mydir, paste0(model_settings$base_name))
  
  if (!file.exists(file.path(model_dir, "Report.sso"))) {
    orig_dir <- getwd()
    setwd(model_dir)
    cat("Running model in directory:", getwd(), "\n")
    run(
      dir = model_dir,
      exe = model_settings$exe,
      extras = model_settings$extras
    )
    setwd(orig_dir)
  }
  
  if ("retro" %in% model_settings$run) {
    retro_wrapper(mydir = mydir, model_settings = model_settings)
  }
  
  if ("profile" %in% model_settings$run) {
    profile_wrapper_MacOS(mydir = mydir, model_settings = model_settings)
  }
  
  if ("jitter" %in% model_settings$run) {
    jitter_wrapper(mydir = mydir, model_settings = model_settings)
  }
}
