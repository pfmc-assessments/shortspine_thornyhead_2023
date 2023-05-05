library(here)
library(r4ss)
source(file=file.path(here::here(), "R", "utils", "ss_utils.R"))


##### Run profile for R0 #####

profile.settings <- get_settings_profile(parameters = 'SR_LN(R0)',
                                         low = 9, high = 10,
                                         step_size = 0.05,
                                         param_space = 'real',
                                         use_prior_like = 0)


model_settings <- get_settings(settings = list(base_name = '1_23.model.francis_2',
                                               run = "profile",
                                               profile_details = profile.settings,
                                               init_values_src = 1,
                                               usepar=TRUE,
                                               globalpar=TRUE,
                                               parstring="SR_parm[1]"
                                               )
                               )


model_settings$exe <- 'ss_osx'
file.copy(here::here("model/ss_executables/SS_V3_30_21/ss_osx"), here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2"))
run_diagnostics_MacOS(mydir = here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/"), 
                      model_settings = model_settings)


##### Run profile for Steepness #####

profile.settings <- get_settings_profile(parameters = 'SR_BH_steep',
                                         low =0.5, high = 1.0,
                                         step_size = 0.05,
                                         param_space = 'real',
                                         use_prior_like = 0)


model_settings <- get_settings(settings = list(base_name = '1_23.model.francis_2',
                                               run = "profile",
                                               profile_details = profile.settings,
                                               init_values_src = 1,
                                               usepar=TRUE,
                                               globalpar=TRUE,
                                               parstring="SR_parm[2]"
                                               )
                               )


model_settings$exe <- 'ss_osx'
file.copy(here::here("model/ss_executables/SS_V3_30_21/ss_osx"), here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2"))
run_diagnostics_MacOS(mydir = here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/"), 
                      model_settings = model_settings)

##### Run profile for Natural Mortality #####

profile.settings <- get_settings_profile(parameters = 'NatM_break_1_Fem_GP_1',
                                         low = 0.04, high = 0.08,
                                         step_size = 0.005,
                                         param_space = 'real',
                                         use_prior_like = 0)


model_settings <- get_settings(settings = list(base_name = '1_23.model.francis_2',
                                               run = "profile",
                                               profile_details = profile.settings,
                                               init_values_src = 1,
                                               usepar=TRUE,
                                               globalpar=TRUE,
                                               parstring="MGparm[1]"
                                               )
                               )


model_settings$exe <- 'ss_osx'
file.copy(here::here("model/ss_executables/SS_V3_30_21/ss_osx"), here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2"))
run_diagnostics_MacOS(mydir = here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/"), 
                      model_settings = model_settings)


# Run profile for Natural Mortality -----------
#Using r4ss::profile, I believe it *is* possible, you can set linenum or string to be a vector, and it will profile over the two parameters simultaneously. And then profilevec would be a matrix along the lines of cbind(seq(m.low, m.high, length.out = n), nrow = n, ncol = 2)

custom.profile <- function(dir,
                          oldctlfile = "control.ss_new",
                          masterctlfile = lifecycle::deprecated(),
                          newctlfile = "control_modified.ss",
                          linenum = NULL,
                          string = NULL,
                          profilevec = NULL,
                          usepar = FALSE,
                          globalpar = FALSE,
                          parlinenum = NULL,
                          parstring = NULL,
                          saveoutput = TRUE,
                          overwrite = TRUE,
                          whichruns = NULL,
                          prior_check = TRUE,
                          read_like = TRUE,
                          exe = "ss",
                          verbose = TRUE,
                          ...) {
  # Ensure wd is not changed by the function
  orig_wd <- getwd()
  on.exit(setwd(orig_wd))
  
  # deprecated variable warnings
  # soft deprecated for now, but fully deprecate in the future.
  if (lifecycle::is_present(masterctlfile)) {
    lifecycle::deprecate_warn(
      when = "1.46.0",
      what = "profile(masterctlfile)",
      with = "profile(oldctlfile)"
    )
    oldctlfile <- masterctlfile
  }
  
  # check for executable
  check_exe(exe = exe, dir = dir, verbose = verbose)
  
  # figure out which line to change in control file
  # if not using par file, info still needed to set phase negative in control file
  if (is.null(linenum) & is.null(string)) {
    stop("You should input either 'linenum' or 'string' (but not both)")
  }
  if (!is.null(linenum) & !is.null(string)) {
    stop("You should input either 'linenum' or 'string' (but not both)")
  }
  if (usepar) { # if using par file
    if (is.null(parlinenum) & is.null(parstring)) {
      stop(
        "Using par file. You should input either 'parlinenum' or ",
        "'parstring' (but not both)"
      )
    }
    if (!is.null(parlinenum) & !is.null(parstring)) {
      stop(
        "Using par file. You should input either 'parlinenum' or ",
        "'parstring' (but not both)"
      )
    }
  }
  
  # count parameters to profile over (typically just 1)
  if (!is.null(linenum)) {
    npars <- length(linenum)
  }
  if (!is.null(string)) {
    npars <- length(string)
  }
  if (usepar) {
    if (!is.null(parlinenum)) {
      npars <- length(parlinenum)
    }
    if (!is.null(parstring)) {
      npars <- length(parstring)
    }
  }
  # not sure what would cause a bad value, but checking for it anyway
  if (is.na(npars) || npars < 1) {
    stop("Problem with the number of parameters to profile over. npars = ", npars)
  }
  
  print(paste0("npars=", npars))
  # figure out length of profile vec and sort out which runs to do
  if (is.null(profilevec)) {
    stop("Missing input 'profilevec'")
  }
  if (npars == 1) {
    n <- length(profilevec)
  } else {
    if ((!is.data.frame(profilevec) & !is.matrix(profilevec)) ||
        ncol(profilevec) != npars) {
      stop(
        "'profilevec' should be a data.frame or a matrix with ",
        npars, " columns"
      )
    }
    print(profilevec)
    n <- length(profilevec[,1])
    if (any(apply(profilevec, 2, FUN = length) != n)) {
      stop("Each element in the 'profilevec' list should have length ", n)
    }
    
    if (verbose) {
      if (!is.null(string)) {
        profilevec_df <- data.frame(profilevec)
        names(profilevec_df) <- string
        message(
          "Profiling over ", npars, " parameters\n",
          paste0(profilevec_df, collapse = "\n")
        )
      }
    }
  }
  print(paste0("n=", n))
  # subset runs if requested
  if (is.null(whichruns)) {
    whichruns <- 1:n
  } else {
    if (!all(whichruns %in% 1:n)) {
      stop("input whichruns should be NULL or a subset of 1:", n, "\n", sep = "")
    }
  }
  if (verbose) {
    message(
      "Doing runs: ", paste(whichruns, collapse = ", "),
      ",\n  out of n = ", n
    )
  }
  
  # places to store convergence and likelihood info
  converged <- rep(NA, n)
  totallike <- rep(NA, n)
  liketable <- NULL
  
  # change working directory
  if (verbose) {
    message(
      "Changing working directory to ", dir, ",\n",
      " but will be changed back on exit from function."
    )
  }
  setwd(dir)
  
  # note: std file name is independent of executable name
  stdfile <- file.path(dir, "ss.std")
  
  # read starter file to get input file names and check various things
  starter.file <- dir()[tolower(dir()) == "starter.ss"]
  if (length(starter.file) == 0) {
    stop("starter.ss not found in", dir)
  }
  starter <- SS_readstarter(starter.file, verbose = FALSE)
  # check for new control file
  if (starter[["ctlfile"]] != newctlfile) {
    stop(
      "starter file should be changed to change\n",
      "'", starter[["ctlfile"]], "' to '", newctlfile, "'"
    )
  }
  # check for prior in likelihood
  if (prior_check & starter[["prior_like"]] == 0) {
    stop(
      "for likelihood profile, you should change the starter file value of\n",
      " 'Include prior likelihood for non-estimated parameters'\n",
      " from 0 to 1 and re-run the estimation.\n"
    )
  }
  # check for consistency in use of par file (part 1)
  if (usepar & starter[["init_values_src"]] == 0) {
    stop(
      "With setting 'usepar=TRUE', change the starter file value",
      " for initial value source from 0 (ctl file) to 1 (par file).\n"
    )
  }
  # check for consistency in use of par file (part 2)
  if (!usepar & starter[["init_values_src"]] == 1) {
    stop(
      "Change the starter file value for initial value source",
      " from 1 (par file) to 0 (par file) or change to",
      " profile(..., usepar = TRUE)."
    )
  }
  
  # back up par file
  if (usepar) {
    file.copy("ss.par", "parfile_original_backup.sso")
  }
  
  # run loop over profile values
  for (i in whichruns) {
    # check for presence of ReportN.sso files. If present and overwrite=FALSE,
    # then don't bother running anything
    newrepfile <- paste("Report", i, ".sso", sep = "")
    if (!overwrite & file.exists(newrepfile)) {
      message(
        "skipping profile i=", i, "/", n, " because overwrite=FALSE\n",
        "  and file exists: ", newrepfile
      )
    } else {
      message("running profile i=", i, "/", n)
      
      # change initial values in the control file
      # this also sets phase negative which is needed even when par file is used
      # dir set as NULL because the wd was already changed to dir earlier in the
      # script.
      if (npars == 1) {
        # get new parameter value
        newvals <- profilevec[i]
      } else {
        # get row as a vector (passing a data.frame to SS_changepars caused error)
        newvals <- as.numeric(profilevec[i, ])
      }
      SS_changepars(
        dir = NULL, ctlfile = oldctlfile, newctlfile = newctlfile,
        linenums = linenum, strings = string,
        newvals = newvals, estimate = FALSE,
        verbose = TRUE, repeat.vals = TRUE
      )
      
      # read parameter lines of control file
      ctltable_new <- SS_parlines(ctlfile = newctlfile)
      # which parameters are estimated in phase 1
      if (!any(ctltable_new[["PHASE"]] == 1)) {
        warning(
          "At least one parameter needs to be estimated in phase 1.\n",
          "Edit control file to add a parameter\n",
          "which isn't being profiled over to phase 1."
        )
      }
      
      if (usepar) {
        # alternatively change initial values in the par file
        # read file
        if (globalpar) {
          par <- readLines("parfile_original_backup.sso")
        } else {
          par <- readLines("ss.par")
        }
        # loop over the number of parameters (typically just 1)
        for (ipar in 1:npars) {
          # find value
          if (!is.null(parstring)) {
            parlinenum <- grep(parstring[ipar], par, fixed = TRUE) + 1
          }
          if (length(parlinenum) == 0) {
            stop("Problem with input parstring = '", parstring[ipar], "'")
          }
          parline <- par[parlinenum[ipar]]
          parval <- as.numeric(parline)
          if (is.na(parval)) {
            stop(
              "Problem with parlinenum or parstring for par file.\n",
              "line as read: ", parline
            )
          }
          # replace value
          par[parlinenum[ipar]] <- ifelse(npars > 1,
                                          profilevec[i, ipar],
                                          profilevec[i]
          )
        }
        # add new header
        note <- c(
          paste("# New par file created by profile() with the value on line number", linenum),
          paste("# changed from", parval, "to", profilevec[i])
        )
        par <- c(par, "#", note)
        message(paste0(note, collapse = "\n"))
        # write new par file
        writeLines(par, paste0("ss_input_par", i, ".ss"))
        writeLines(par, "ss.par")
      }
      if (file.exists(stdfile)) {
        file.remove(stdfile)
      }
      if (file.exists("Report.sso")) {
        file.remove("Report.sso")
      }
      
      #stop()
      # run model
      run(dir = dir, verbose = verbose, exe = exe, ...)
      
      # check for convergence
      converged[i] <- file.exists(stdfile)
      # onegood tracks whether there is at least one non-empty Report file
      onegood <- FALSE
      # look for non-zero report file and read LIKELIHOOD table
      if (read_like && file.exists("Report.sso") &
          file.info("Report.sso")$size > 0) {
        onegood <- TRUE
        # read first 400 lines of Report.sso
        Rep <- readLines("Report.sso", n = 400)
        # calculate range of rows with LIKELIHOOD table
        skip <- grep("LIKELIHOOD", Rep)[2]
        nrows <- grep("Crash_Pen", Rep) - skip - 1
        # read Report again to just get LIKELIHOOD table
        like <- read.table("Report.sso",
                           skip = skip,
                           nrows = nrows, header = TRUE, fill = TRUE
        )
        liketable <- rbind(liketable, as.numeric(like[["logL.Lambda"]]))
      } else {
        # add a placeholder row of NA values if no good report file
        liketable <- rbind(liketable, rep(NA, 10))
      }
      
      # rename output files
      if (saveoutput) {
        file.copy("Report.sso", paste("Report", i, ".sso", sep = ""),
                  overwrite = overwrite
        )
        file.copy("CompReport.sso", paste("CompReport", i, ".sso", sep = ""),
                  overwrite = overwrite
        )
        file.copy("covar.sso", paste("covar", i, ".sso", sep = ""),
                  overwrite = overwrite
        )
        file.copy("warning.sso", paste("warning", i, ".sso", sep = ""),
                  overwrite = overwrite
        )
        file.copy("admodel.hes", paste("admodel", i, ".hes", sep = ""),
                  overwrite = overwrite
        )
        file.copy("ss.par", paste("ss.par_", i, ".sso", sep = ""),
                  overwrite = overwrite
        )
      }
    } # end running stuff
  } # end loop of whichruns
  if (onegood) {
    liketable <- as.data.frame(liketable)
    names(liketable) <- like[["Component"]]
    bigtable <- cbind(profilevec, converged, liketable)
    names(bigtable)[1] <- "Value"
    return(bigtable)
  } else {
    stop("Error: no good Report.sso files created in profile")
  }
} # end function



#if (FALSE) {
  # note: don't run this in your main directory
  # make a copy in case something goes wrong
  mydir <- file.path(here::here(), "model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2_profile_mortality")

  file.copy("model/ss_executables/SS_V3_30_21/ss_osx", mydir)
  
  # the following commands related to starter.ss could be done by hand
  # read starter file
  starter <- SS_readstarter("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2_profile_mortality/starter.ss")
  # change control file name in the starter file
  starter[["ctlfile"]] <- "control_modified.ss"
  # make sure the prior likelihood is calculated
  # for non-estimated quantities
  starter[["prior_like"]] <- 1
  # write modified starter file
  SS_writestarter(starter, dir = mydir, overwrite = TRUE)
  
  # vector of values to profile over
  m.vec <- cbind(seq(0.03, 0.055, by=0.005), seq(0.03, 0.055, by=0.005), seq(0.03, 0.055, by=0.005), seq(0.03, 0.055, by=0.005))
  Nprofile <- length(m.vec)
  
  # make a vector for string 
  string <- c("NatM_p_1_Fem_GP_1","NatM_p_2_Fem_GP_1","NatM_p_1_Mal_GP_1","NatM_p_2_Mal_GP_1")
  
  
  colnames(m.vec) <- string
  
  # run profile command
  profilemodels <- custom.profile(
    exe = "ss_osx",
    dir = mydir,
    oldctlfile = "SST_control.ss",
    newctlfile = "control_modified.ss",
    string = string, # subset of parameter label
    profilevec = m.vec,
    extras = "-nohess"
  )
  
# below copied from r4ss vignette 
  
  # read the output files (with names like Report1.sso, Report2.sso, etc.)
  profilemodels <- SSgetoutput(dirvec = mydir, keyvec = 1:nrow(m.vec))
  # summarize output
  profilesummary <- SSsummarize(profilemodels)
  
  # OPTIONAL COMMANDS TO ADD MODEL WITH PROFILE PARAMETER ESTIMATED
  rep <- r4ss::SS_output(file.path(here::here(), "model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2/run"),
                         covar = FALSE,
                         printstats = FALSE, verbose = FALSE
  )
  
  
  nwfscDiag::profile_plot(
    mydir = mydir,
    para = "NatM_break_1_Fem_GP_1",
    rep = rep,
    profilesummary = profilesummary
  )

  


