library(here)
library(r4ss)
source(file=file.path(here::here(), "R", "utils", "ss_utils.R"))


##### Run profile for R0 #####

profile.settings <- get_settings_profile(parameters = 'SR_LN(R0)',
                                         low = 10, high = 10.7,
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


##### Retrospectives

# Run profile for Natural Mortality -----------
#Using r4ss::profile, I believe it *is* possible, you can set linenum or string to be a vector, and it will profile over the two parameters simultaneously. And then profilevec would be a matrix along the lines of cbind(seq(m.low, m.high, length.out = n), nrow = n, ncol = 2)

#if (FALSE) {
  # note: don't run this in your main directory
  # make a copy in case something goes wrong
  mydir <- "model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2_profile_mortality"

#file.copy("model/ss_executables/SS_V3_30_21/ss_osx", mydir)
  
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
  m.vec <- cbind(seq(0.03, 0.07, length.out = 5), seq(0.03, 0.07, length.out = 5), seq(0.03, 0.07, length.out = 5), seq(0.03, 0.07, length.out = 5))
  Nprofile <- length(m.vec)
  
  # make a vector for string 
  string <- c("NatM_p_1_Fem_GP_1","NatM_p_2_Fem_GP_1","NatM_p_1_Mal_GP_1","NatM_p_2_Mal_GP_1")
  
  # run profile command
  profile <- profile(
    #exe = "ss",
    dir = mydir,
    oldctlfile = "SST_control.ss",
    newctlfile = "control_modified.ss",
    string = string, # subset of parameter label
    profilevec = m.vec
  )
  
# below copied from r4ss vignette 
  
  # read the output files (with names like Report1.sso, Report2.sso, etc.)
  profilemodels <- SSgetoutput(dirvec = mydir, keyvec = 1:Nprofile)
  # summarize output
  profilesummary <- SSsummarize(profilemodels)
  
  # OPTIONAL COMMANDS TO ADD MODEL WITH PROFILE PARAMETER ESTIMATED
  MLEmodel <- SS_output("C:/ss/SSv3.24l_Dec5/Simple")
  profilemodels[["MLE"]] <- MLEmodel
  profilesummary <- SSsummarize(profilemodels)
  # END OPTIONAL COMMANDS
  
  # plot profile using summary created above
  SSplotProfile(profilesummary, # summary object
                profile.string = "steep", # substring of profile parameter
                profile.label = "Stock-recruit steepness (h)"
  ) # axis label
  
  # make timeseries plots comparing models in profile
  SSplotComparisons(profilesummary, legendlabels = paste("h =", h.vec))
  
  
  ###########################################################################
  
  # example two-dimensional profile
  # (e.g. over 2 of the parameters in the low-fecundity stock-recruit function)
  base_dir <- "c:/mymodel"
  
  dir_profile_SR <- file.path(base_dir, "Profiles/Zfrac_and_Beta")
  
  # make a grid of values in both dimensions Zfrac and Beta
  # vector of values to profile over
  Zfrac_vec <- seq(from = 0.2, to = 0.6, by = 0.1)
  Beta_vec <- c(0.5, 0.75, 1.0, 1.5, 2.0)
  par_table <- expand.grid(Zfrac = Zfrac_vec, Beta = Beta_vec)
  nrow(par_table)
  ## [1] 25
  head(par_table)
  ##   Zfrac Beta
  ## 1   0.2 0.50
  ## 2   0.3 0.50
  ## 3   0.4 0.50
  ## 4   0.5 0.50
  ## 5   0.6 0.50
  ## 6   0.2 0.75
  
  # run profile command
  profile <- profile(
    dir = dir_profile_SR, # directory
    oldctlfile = "control.ss_new",
    newctlfile = "control_modified.ss",
    string = c("Zfrac", "Beta"),
    profilevec = par_table,
    extras = "-nohess" # argument passed to run()
  )
  
  # get model output
  profilemodels <- SSgetoutput(
    dirvec = dir_profile_SR,
    keyvec = 1:nrow(par_table), getcovar = FALSE
  )
  n <- length(profilemodels)
  profilesummary <- SSsummarize(profilemodels)
  
  # add total likelihood (row 1) to table created above
  par_table[["like"]] <- as.numeric(profilesummary[["likelihoods"]][1, 1:n])
  
  # reshape data frame into a matrix for use with contour
  like_matrix <- reshape2::acast(par_table, Zfrac ~ Beta, value.var = "like")
  
  # make contour plot
  contour(
    x = as.numeric(rownames(like_matrix)),
    y = as.numeric(colnames(like_matrix)),
    z = like_matrix
  )
#}


