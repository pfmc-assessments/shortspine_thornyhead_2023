library(here)
library(r4ss)
source(file=file.path(here::here(), "R", "utils", "ss_utils.R"))

retro.dir <- file.path(here::here(), "model", "Sensitivity_Anal", "5.8_Francis_Reweighting_2", "1_23.model.francis_2_retro")
if(dir.exists(retro.dir)){
  unlink(retro.dir, recursive=TRUE)
}

model_settings <- get_settings(settings = list(base_name = '1_23.model.francis_2',
                                               run = "retro",
                                               init_values_src = 1,
                                               usepar=TRUE,
                                               globalpar=TRUE,
                                               skipfinished=FALSE
                                              )
                                )


model_settings$exe <- 'ss_osx'
file.copy(here::here("model/ss_executables/SS_V3_30_21/ss_osx"), here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2"))
run_diagnostics_MacOS(mydir = here::here("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/"), 
                      model_settings = model_settings)


#### For plotting the base model with uncertainty on
retro.output <- SSgetoutput(dirvec = c(file.path(here::here(), "model", "Sensitivity_Anal", "5.8_Francis_Reweighting_2", "1_23.model.francis_2", "run"), 
                                       file.path(base.dir, "retro", "retro-1"),
                                       file.path(base.dir, "retro", "retro-2"), 
                                       file.path(base.dir, "retro", "retro-3"), 
                                       file.path(base.dir, "retro", "retro-4"), 
                                       file.path(base.dir, "retro", "retro-5")))
retroSummary <- SSsummarize(retro.output)
endyrvec <- c(retroSummary$endyrs[1], retroSummary$endyrs[1] + model_settings$retro_yrs)

rhosall <- mapply(
  r4ss::SSmohnsrho,
  summaryoutput = lapply(
    seq_along(retro.output)[-1],
    function(x) r4ss::SSsummarize(retro.output[1:x], verbose = FALSE)
  ),
  endyrvec = mapply(seq,from=endyrvec[1], to= endyrvec[-1])
)

r4ss::SSplotComparisons(
  summaryoutput = retroSummary,
  endyrvec = endyrvec,
  legendlabels = c(
    "Base Model",
    sprintf("Data %.0f year%s",
            model_settings$retro_yrs,
            ifelse(abs(model_settings$retro_yrs) == 1, "", "s")
    )
  ),
  subplots=c(2, 4),
  plotdir = base.dir,
  legendloc = "topright",
  print = TRUE,
  plot = TRUE,
  pdf = FALSE
)

mapply(
  FUN = r4ss::SSplotComparisons,
  MoreArgs = list(
    summaryoutput = retroSummary,
    endyrvec = endyrvec,
    legendloc = "topleft",
    plotdir = base.dir,
    print = TRUE, plot = FALSE, pdf = FALSE
  ),
  subplot = c(2, 4),
  legendlabels = lapply(
    c("SSB", "Bratio"),
    function(x) {
      c(
        "Base Model",
        sprintf("Data %.0f year%s (Mohn's rho %.2f)",
                model_settings$retro_yrs,
                ifelse(abs(model_settings$retro_yrs) == 1, "", "s"),
                rhosall[rownames(rhosall) == x, ]
        )
      )
    })
)
