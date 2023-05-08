library(here)
library(r4ss)
source(file=file.path(here::here(), "R", "utils", "ss_utils.R"))

model_settings <- get_settings(settings = list(base_name = '1_23.model.francis_2',
                                               run = "jitter",
                                               init_values_src = 0,
                                               usepar=FALSE,
                                               globalpar=FALSE,
                                               skipfinished=FALSE,
                                               Njitter=100,
                                               jitter_fraction=0.10
                                          )
                                )


model_settings$exe <- 'ss_osx'
file.copy(here::here("model/ss_executables/SS_V3_30_21/ss_osx"), here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2"))
run_diagnostics_MacOS(mydir = here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/"), 
                      model_settings = model_settings)

#### Get starting values
i=1 # Check CSV to find a model with optimal likelihood
file = file.path(here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2_jitter_0.1"), paste0("ParmTrace",i,".sso"))
pars.i <- read.table(file, header = TRUE, nrows = 1, check.names = FALSE, sep="\t")


