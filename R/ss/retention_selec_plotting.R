###########################3#####
##### 
#modloc <- file.path("C:/Users/pyher/Documents/shortspine_thornyhead_2023/model/Sensitivity_Anal/STAR_Panel/5.14_Day2_Base_Update/1_23.base.day2.update/run")

modloc <- file.path(here::here(), "model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official/run")


#modloc <- "C:/Users/pyher/Documents/shortspine_thornyhead_2023/model/Sensitivity_Anal/STAR_Panel/5.14_Request_4/1_23.est.max.ret/run"
mod <- SS_output(dir = modloc)

plot_sel_ret <- function(mod,
                         fleet = 1,
                         Factor = "Lsel",
                         sex = 1) {
  
  input = r4ss::SS_read(mod$inputs$dir)
  
  years <- mod$startyr:mod$endyr
  # run selectivity function to get table of info on time blocks etc.
  # NOTE: this writes a png file to unfit/sel01_multiple_fleets_length1.png
  infotable <- r4ss::SSplotSelex(mod,
                                 fleets = fleet,
                                 sexes = 1,
                                 sizefactors = Factor,
                                 years = years,
                                 subplot = 1,
                                 plot = FALSE,
                                 print = TRUE,
                                 plotdir = mod$inputs$dir
  )$infotable
  # remove extra file (would need to sort out the relative path stuff)
  file.remove(file.path(mod$inputs$dir, "sel01_multiple_fleets_length1.png"))
  nlines <- nrow(infotable)
  infotable$col <- r4ss::rich.colors.short(max(6,nlines), alpha = 0.7) %>%
    rev() %>% tail(nlines)
  infotable$pch <- NA
  infotable$lty <- nrow(infotable):1
  infotable$lwd <- 3
  infotable$longname <- infotable$Yr_range
  # run plot function again, passing in the modified infotable
  r4ss::SSplotSelex(mod,
                    fleets = fleet,
                    sexes = 1,
                    sizefactors = Factor,
                    labels = c(
                      "Length (cm)",
                      "Age (yr)",
                      "Year",
                      ifelse(Factor == "Lsel", "Selectivity", "Retention"),
                      "Retention",
                      "Discard mortality"
                    ),
                    legendloc = "topright",
                    years = years,
                    subplot = 1,
                    plot = TRUE,
                    print = FALSE,
                    infotable = infotable,
                    mainTitle = TRUE,
                    mar = c(2,2,2,1),
                    plotdir = mod$inputs$dir,
                    #subplots=2
  )
  #dev.off()
}


## EDIT MADI 6/23/23

png(file.path(here::here(), 'doc/FinalFigs/Base/selec_block.png'), width=7, height=4, units='in',
    res=300, pointsize=9)
par(mfrow=c(1,3))

plot_sel_ret(mod, Factor = "Lsel", fleet = 1, sex = 1)
plot_sel_ret(mod, Factor = "Lsel", fleet = 2, sex = 1)
plot_sel_ret(mod, Factor = "Lsel", fleet = 3, sex = 1)

dev.off()



    #REC
plot_sel_ret(mod, Factor = "Lsel", fleet = 1, sex = 1)
plot_sel_ret(mod, Factor = "Lsel", fleet = 2, sex = 1)
plot_sel_ret(mod, Factor = "Lsel", fleet = 3, sex = 1)
plot_sel_ret(mod, Factor = "Selectivity", fleet = 1, sex = 1)
plot_sel_ret(mod, Factor = "Selectivity", fleet = 2, sex = 1)
plot_sel_ret(mod, Factor = "Selectivity", fleet = 3, sex = 1)
plot_sel_ret(mod, Factor = "Retention", fleet = 1, sex = 1)
plot_sel_ret(mod, Factor = "Retention", fleet = 2, sex = 1)
plot_sel_ret(mod, Factor = "Retention", fleet = 3, sex = 1)

plot_sel_ret(mod, Factor = "Lsel", fleet = 1, sex = 1)
plot_sel_ret(mod, Factor = "Lsel", fleet = 2, sex = 2)
plot_sel_ret(mod, Factor = "Lsel", fleet = 3, sex = 2)
plot_sel_ret(mod, Factor = "Selectivity", fleet = 1, sex = 2)
plot_sel_ret(mod, Factor = "Selectivity", fleet = 2, sex = 2)
plot_sel_ret(mod, Factor = "Selectivity", fleet = 3, sex = 2)
plot_sel_ret(mod, Factor = "Retention", fleet = 1, sex = 2)
plot_sel_ret(mod, Factor = "Retention", fleet = 2, sex = 2)
plot_sel_ret(mod, Factor = "Retention", fleet = 3, sex = 2)


