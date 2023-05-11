# plot retention curves 

Dirplot <- file.path("model/Sensitivity_Anal/5.8_Francis_Reweighting_2/1_23.model.francis_2/run")

replist <- SS_output(
  dir = Dirplot,
  verbose = TRUE,
  printstats = TRUE
)

# get retention values
# fleet 1
tmp <- SSplotSelex(replist, fleets=1, sizefactors="Ret", years=1901:2022,
                   subplot=1)

tmp$infotable$col <- c("#009E73","#56B4E9", "#E69F00")#rich.colors.short(3, alpha=0.7)
tmp$infotable$pch <- NA
tmp$infotable$lty <- 1
tmp$infotable$longname <- tmp$infotable$Yr_range
tmp$infotable$longname[1] <- gsub(1916, 1995, tmp$infotable$longname[1])

# fleet 2
tmp2 <- SSplotSelex(replist, fleets=2, sizefactors="Ret", years=1901:2022,
                   subplot=1)

tmp2$infotable$col <- c("#009E73","#56B4E9", "#E69F00")#rich.colors.short(3, alpha=0.7)
tmp2$infotable$pch <- NA
tmp2$infotable$lty <- 1
tmp2$infotable$longname <- tmp2$infotable$Yr_range
tmp2$infotable$longname[1] <- gsub(1916, 1995, tmp2$infotable$longname[1])

# fleet 3
tmp3 <- SSplotSelex(replist, fleets=3, sizefactors="Ret", years=1901:2022,
                    subplot=1)

tmp3$infotable$col <- "#E69F00"
tmp3$infotable$pch <- NA
tmp3$infotable$lty <- 1
tmp3$infotable$longname <- tmp3$infotable$Yr_range
tmp3$infotable$longname[1] <- gsub(1916, 1995, tmp3$infotable$longname[1])

# save plot of time-varying retention
dev.off()
png('Outputs/discard_data/retention.png', width=7, height=4, units='in',
    res=300, pointsize=9)
par(mfrow=c(1,3))

SSplotSelex(replist, fleets=1, sizefactors="Ret",
            labels = c("Length (cm)", 
                       "Age (yr)", "Year", "Retention", "Retention", "Discard mortality"),
            years=2002:2018, subplot=1, infotable=tmp$infotable)

SSplotSelex(replist, fleets=2, sizefactors="Ret",
            labels = c("Length (cm)", 
                       "Age (yr)", "Year", "Retention", "Retention", "Discard mortality"),
            years=2002:2018, subplot=1, infotable=tmp2$infotable)

SSplotSelex(replist, fleets=3, sizefactors="Ret",
            labels = c("Length (cm)", 
                       "Age (yr)", "Year", "Retention", "Retention", "Discard mortality"),
            years=2002:2018, subplot=1, infotable=tmp3$infotable)
         
