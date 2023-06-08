############################
#

library(r4ss)

new_base_loc <- file.path("C:/Users/pyher/Documents/shortspine_thornyhead_2023/model/Sensitivity_Anal/STAR_Panel/****/****/run")

new_base = SS_output(new_base_loc)

new_base_sb = new_base$derived_quants[new_base$derived_quants$Label == "SSB_2023", ]

sigma <- ""
ofl_sigma <- ""

new_base_sb[,"Value"]/(exp(-1.15*ofl_sigma)); new_base_sb[,"Value"]/(exp(1.15*ofl_sigma))
# SB low = 182.5278, SB = 333.8

find_para(dir = file.path(wd, "nca", "_decision_table", base_north), 
          base = north, 
          yr = 2023, 
          parm = c("SR_parm[2]"), 
          quant = c(0.875), 
          est = FALSE, 
          sigma = round(ofl_sigma, 3), 
          tol = 0.005, use_115 = TRUE)

low <- SS_output(file.path(wd, "nca", "_decision_table", "9.11_revised_pre-star_base_SR_parm[2]_decision_table_1.15_0.262_0.125"))
hi <- SS_output(file.path(wd, "nca", "_decision_table", "9.11_revised_pre-star_base_SR_parm[2]_decision_table_1.15_0.262_0.875"))








