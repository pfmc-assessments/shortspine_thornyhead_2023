library(tidyverse)
library(r4ss)
library(kableExtra)

model.names <- c("Base", "Low Growth", "High Growth", "2013 Maturity", "Intermediate Maturity", "Imputed Landings", "2013 Landings")
model.ids <- c("5.8_Francis_Reweighting_2/1_23.model.francis_2", 
               "4.1_Growth_Sensitivity/2_23.growth.low", 
               "4.1_Growth_Sensitivity/1_23.growth.high", 
               "4.2_Maturity_Sensitivity/1_23.maturity.pgcurve", 
               "4.2_Maturity_Sensitivity/2_23.maturity.mix_curve", 
               "1.1_Landings_Sensitivity/1_23.land.hist_impute", 
               "1.1_Landings_Sensitivity/2_23.land.2013")

sensi.dir <- file.path(here::here(), "model", "Sensitivity_Anal")

model.dirs <- apply(as.matrix(model.ids), 1, function(x) file.path(sensi.dir, x, "run"))

summary <- matrix(NA, nrow=11, ncol=length(model.names))

for(i in 1:length(model.dirs)){
  m <- model.dirs[i]
  replist <- SS_output(m)
  likes <- replist$likelihoods_used
  derived <- replist$derived_quants
  
  summary[1,i] <- likes["TOTAL",]$values
  summary[2,i] <- likes["Survey",]$values
  summary[3,i] <- likes["Length_comp",]$values
  summary[4,i] <- likes["Discard",]$values
  summary[5,i] <- likes["Mean_body_wt",]$values
  summary[6,i] <- likes["Recruitment",]$values
  summary[7,i] <- likes["Parm_priors",]$values
  summary[8,i] <- derived["Recr_Virgin",]$Value
  summary[9,i] <- derived["SSB_2023",]$Value
  summary[10,i] <- derived["Bratio_2023",]$Value
  summary[11,i] <- derived["SPRratio_2023",]$Value
}

summary(c)

#replist$likelihoods_used
#replist$derived_quants

colnames(summary) <- model.names
rownames(summary) <- c("Total L", "Survey L", "Length Comp L", "Discards L", "Mean Body Wt L", "Recruitment L", "Prior L", "R0", "B0", "Depletion", "Relative SPR")

write.csv(summary, file = file.path(here::here(), "doc", "FinalTables", "Sensitivities", "summary.csv"))



### summary table w/ all sensitivity

model.names <- c("Base", "Low Growth", "High Growth", "2013 Maturity", "Intermediate Maturity", "Updated W-L",
                 "Imputed Landings", "2013 Landings", "ASGOP Landings", "LogNorm Error MBI", "DBI", 
                 "MBI Depth-cov.", "+ Slope Survey", "WCGBTS extra SD", "all retention blocks",
                 "all selectivity blocks", "ret + sel blocks")
model.ids <- c("5.8_Francis_Reweighting_2/1_23.model.francis_2", 
               "4.1_Growth_Sensitivity/2_23.growth.low", 
               "4.1_Growth_Sensitivity/1_23.growth.high", 
               "4.2_Maturity_Sensitivity/1_23.maturity.pgcurve", 
               "4.2_Maturity_Sensitivity/2_23.maturity.mix_curve",
               "STAR_Panel/4.4_WL_Sensitivity/1_23.WL.sensitivity", 
               "1.1_Landings_Sensitivity/1_23.land.hist_impute", 
               "1.1_Landings_Sensitivity/2_23.land.2013",
               "1.2_Landings_ashop/1_23.landings.ashop",
               "3.1_surveys_Sensitivity/1_23.surveys.gamvln",
               "3.2_surveys2_Sensitivity/1_23.surveys.db",
               "3.2_surveys2_Sensitivity/2_23.surveys.wcgbts_depth",
               "3.3_surveys3_Sensitivity/1_23.surveys.useslope",
               "3.3_surveys3_Sensitivity/2_23.surveys.extaSDwcgbts",
               "5.9_Retention_Selectivity_Sensitivity/4_23.blkret.T4",
               "5.11_Selectivity_Sensitivity/3_23.blksel.T3",
               "5.11_Selectivity_Sensitivity/7_23.blkret.T3.blksel.T3")




sensi.dir <- file.path(here::here(), "model", "Sensitivity_Anal")

model.dirs <- apply(as.matrix(model.ids), 1, function(x) file.path(sensi.dir, x, "run"))

tmp = SSgetoutput(
  dirvec = model.dirs,
)


tmp_summary  = SSsummarize(
  tmp
)
summary_table = SStableComparisons(
  tmp_summary,
  modelnames = model.names,
  csv = TRUE,
  csvdir = file.path(here::here(), "doc", "FinalTables", "Sensitivities")
)

summary_table <- summary_table %>%                   # Using dplyr functions
  mutate_if(is.numeric,
            round,
            digits = 3)




summary_table %>%
  kbl() %>%
  kable_classic(full_width = F, html_font = "Times New Roman") %>%
  add_header_above(c(" " = 1, " " = 1, "Biology" = 5, "Landings" = 3, 
                     "Surveys" = 5, "Retention + Selectivity" = 3)) %>% 
  save_kable(file = file.path(here::here(), "outputs", "summary_table.jpeg"),
             zoom = 2)







