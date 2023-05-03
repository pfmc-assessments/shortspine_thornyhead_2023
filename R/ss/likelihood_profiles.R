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

