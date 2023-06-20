library(here)
library(r4ss)
source(file=file.path(here::here(), "R", "utils", "ss_utils.R"))

model_settings <- get_settings(settings = list(base_name = '1_23.base.official',
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
file.copy(here::here("model/ss_executables/SS_V3_30_21/ss_osx"), here::here("model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official/"))
run_diagnostics_MacOS(mydir = here::here("model/Sensitivity_Anal/Base_Model/5.23_Official_Base/"), 
                      model_settings = model_settings)

#### Get starting values
i=3 # Check CSV to find a model with optimal likelihood
file = file.path(here::here("model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official_jitter_0.1/"), paste0("ParmTrace",i,".sso"))
pars.i <- read.table(file, header = TRUE, nrows = 1, check.names = FALSE, sep="\t")

jitter.dir <- file.path(here::here(), "model/Sensitivity_Anal/Base_Model/jitter/")
if(file.exists(jitter.dir)){
  unlink(jitter.dir, recursive = TRUE)
}

file.rename(
  from=file.path(here::here(), "model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official_jitter_0.1/"),
  to=jitter.dir
)