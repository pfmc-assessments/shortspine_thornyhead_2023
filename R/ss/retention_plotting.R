Dirplot <- file.path(here::here(), "model/Sensitivity_Anal/Base_Model/5.23_Official_Base/1_23.base.official/run")

replist <- SS_output(
  dir = Dirplot,
  verbose = TRUE,
  printstats = TRUE
)

# get retention values
# fleet 1
tmp <- SSplotSelex(replist, fleets=1, sizefactors="Ret", years=1901:2022,
                   subplot=1)

nlines <- nrow(tmp$infotable)
tmp$infotable$col <- r4ss::rich.colors.short(max(6,nlines), alpha = 0.7) %>%
  rev() %>% tail(nlines)
#tmp$infotable$col <- c("#009E73","#56B4E9", "#E69F00","#009E73","#56B4E9",
#                       "#E69F00","#009E73","#56B4E9", "#E69F00")[seq(1,nlines)]#rich.colors.short(3, alpha=0.7)
tmp$infotable$pch <- NA
tmp$infotable$lty <- 1
tmp$infotable$longname <- tmp$infotable$Yr_range
tmp$infotable$longname[1] <- gsub(1916, 1995, tmp$infotable$longname[1])

# fleet 2
tmp2 <- SSplotSelex(replist, fleets=2, sizefactors="Ret", years=1901:2022,
                    subplot=1)
nlines2 <- nrow(tmp2$infotable)
tmp2$infotable$col <- r4ss::rich.colors.short(max(6,nlines2), alpha = 0.7) %>%
  rev() %>% tail(nlines2)
#tmp2$infotable$col <- c("#009E73","#56B4E9", "#E69F00")#rich.colors.short(3, alpha=0.7)
tmp2$infotable$pch <- NA
tmp2$infotable$lty <- 1
tmp2$infotable$longname <- tmp2$infotable$Yr_range
tmp2$infotable$longname[1] <- gsub(1916, 1995, tmp2$infotable$longname[1])

# fleet 3
tmp3 <- SSplotSelex(replist, fleets=3, sizefactors="Ret", years=1901:2022,
                    subplot=1)
nlines3 <- nrow(tmp3$infotable)
tmp3$infotable$col <- r4ss::rich.colors.short(max(6,nlines3), alpha = 0.7) %>%
  rev() %>% tail(nlines3)
#tmp3$infotable$col <- "#E69F00"
tmp3$infotable$pch <- NA
tmp3$infotable$lty <- 1
tmp3$infotable$longname <- tmp3$infotable$Yr_range
tmp3$infotable$longname[1] <- gsub(1916, 1995, tmp3$infotable$longname[1])

# save plot of time-varying retention
#dev.off()
png(file.path(here::here(), 'outputs/discard_data/retention.png'), width=7, height=4, units='in',
   res=300, pointsize=9)
par(mfrow=c(1,3))

SSplotSelex(replist, fleets=1, sizefactors="Ret",
            labels = c("Length (cm)", 
                       "Age (yr)", "Year", "Retention", "Retention", "Discard mortality"),
            years=1901:2022,
            subplot=1, infotable=tmp$infotable)

SSplotSelex(replist, fleets=2, sizefactors="Ret",
            labels = c("Length (cm)", 
                       "Age (yr)", "Year", "Retention", "Retention", "Discard mortality"),
            years=1901:2022,
            subplot=1, infotable=tmp2$infotable)

SSplotSelex(replist, fleets=3, sizefactors="Ret",
            labels = c("Length (cm)", 
                       "Age (yr)", "Year", "Retention", "Retention", "Discard mortality"),
            years=1901:2022,
            subplot=1, infotable=tmp3$infotable)
dev.off()
file.copy(
  from=file.path(here::here(), 'outputs/discard_data/retention.png'),
  to=file.path(here::here(), "doc", "FinalFigs", "Base", "retention_curves.png")
)
