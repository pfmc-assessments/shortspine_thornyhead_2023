library(ggplot2)
library(nwfscSurvey)

strata = CreateStrataDF.fn(
  names          = c("shallow_south", "deep_south", "shallow_cen", "deep_cen", "shallow_north", "mid_north", "deep_north"), 
  depths.shallow = c(183, 549, 183, 549, 100, 183, 549), 
  depths.deep = c(549, 1280, 549, 1280, 183, 549, 1280),
  lats.south = c(32, 32, 34.5, 34.5, 40.5, 40.5, 40.5),
  lats.north = c(34.5, 34.5, 40.5, 40.5, 49, 49, 49) 
)

PlotStrata.fn <- function(strata, strata.groups=1:nrow(strata)){
  latitudes <- seq(30, 51, length.out = 100)
  depths <- seq(0, 1500, length.out = 100)
  
  lat.depth <- data.frame(expand.grid(latitudes, depths))
  colnames(lat.depth) <- c("latitude", "depth")
  
  strata$group <- factor(strata.groups, levels=unique(strata.groups))
  strata$Latitude_dd.2 <- strata$Latitude_dd.2-0.09
  
  p <- ggplot(lat.depth)+
          geom_tile(aes(x=latitude, y=depth, fill=depth), alpha=0.9)+
          geom_rect(data=strata, aes(xmin=Latitude_dd.1, xmax=Latitude_dd.2, ymin=Depth_m.1, ymax=Depth_m.2, color=group), alpha=0.0, size=1)+
          geom_vline(aes(xintercept=42), linetype="dashed", color="white")+
          geom_vline(aes(xintercept=46.1878), linetype="dashed", color="white")+
          geom_vline(aes(xintercept=32), linetype="dashed", color="white")+
          geom_vline(aes(xintercept=49), linetype="dashed", color="white")+
          scale_color_manual(values=c("#E11845", "#87E911", "#F2CA19"))+
          scale_fill_gradient(low="#56B1F7", high="#132B43")+
          scale_x_continuous(
            breaks=c(32, 35, 40, 42, 45, 49), 
            limits = c(31.5, 49.5), 
            name="Latitude (˚N)")+
          scale_y_reverse(breaks=rev(c(0, 55, 150, 300, 500, 1000, 1250, 1500)), name="Depth (m)")+
          annotate("text", label="California", x=37,   y=1450, color="white")+
          annotate("text", label="Oregon",     x=44,   y=1450, color="white")+
          annotate("text", label="Washington", x=47.6, y=1450, color="white")+
          coord_cartesian(expand=0, clip="off")+
          ggtitle("NWFSC Combo Survey Strata")+
          theme(
            panel.background = element_blank()
          )+
          guides(fill="none") 
  return(p)
}

PlotStrata.fn(strata, strata.groups = c("South", "South", "Central", "Central", "North", "North", "North"))
