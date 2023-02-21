library(ggplot2)
library(tidyverse)
library(sf)

# strata = CreateStrataDF.fn(
#   names          = c("shallow_south", "deep_south", "shallow_cen", "deep_cen", "shallow_north", "mid_north", "deep_north"), 
#   depths.shallow = c(183, 549, 183, 549, 100, 183, 549), 
#   depths.deep = c(549, 1280, 549, 1280, 183, 549, 1280),
#   lats.south = c(32, 32, 42, 42, 46.5, 46.5, 46.5),
#   lats.north = c(42, 42, 46.5, 46.5, 49, 49, 49) 
# )

generate.lat.box <- function(strata){
  lats <- sort(unique(c(strata$Latitude_dd.1, strata$Latitude_dd.2)))
  n.strata <- length(lats)-1
  box <- c()
  
  for(s in 1:n.strata){
      i=1
      box.small <- rep(NA, 4)
      box.small[i+0] <- lats[s]
      box.small[i+1] <- lats[s+1]
      box.small[i+2] <- lats[s+1]
      box.small[i+3] <- lats[s]
      box <- c(box, box.small)
  }
  return(box)
}

PlotStratMap.fn <- function(strata, strata.names, plot.crs=4326){
  
  left.lon    <- -134
  right.lon   <- -114
  min.lat     <- 32
  max.lat     <- 49
  
  lat.adj     <- -0.38 # needed to align spherical and rectangular latitudinal coords
  max.lat.adj <- 0.025 # needed to align upper latitudinal bound
  
  buffer.size.mls <- 100
  
  lat.boxes <- generate.lat.box(strata)
  lat.boxes[which(lat.boxes == max.lat)] <- max.lat+max.lat.adj
  
  # Get state data for west coast states
  info_state <- ggplot2::map_data(
    map = "state",
    region = c("california", "oregon", "washington", "nevada", "idaho")
  )
  
  info_world <- ggplot2::map_data(
    map = "world",
    region = c("USA", "Canada", "Mexico")
  )
  
  world.polys <- info_world %>%
    st_as_sf(coords=c("long", "lat"), crs=4326) %>%
    st_transform(crs=st_crs(2227)) %>%
    group_by(group) %>%
    summarise(
      geometry = st_combine(geometry)
    ) %>%
    st_cast("POLYGON")
  
  # Convert raw state data into SF objects
  state.polys <- info_state %>%
    st_as_sf(coords=c("long", "lat"), crs=4326) %>%
    st_transform(crs=st_crs(2227)) %>%
    group_by(group) %>%
    summarise(
      geometry = st_combine(geometry)
    ) %>%
    st_cast("POLYGON")
  
  # Create a 100 mile buffer around the states
  region.poly.buffer <- state.polys %>%
    st_combine() %>%
    st_buffer(5280*buffer.size.mls) %>%
    st_transform(crs=st_crs(4326)) %>%
    st_crop(xmin = -130, xmax = -117, ymin = 32.53827, ymax = 49) %>% # Force clip to min/max latitude of US west coast
    st_transform(crs=2227)
  
  # Create strata boxes
  strata.polys.df <- data.frame(
    lat = lat.boxes,
    long = rep(c(left.lon, left.lon, right.lon, right.lon), 3),
    strata.num = c(1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3)
  )
  
  strata.polys.df$lat <- strata.polys.df$lat+lat.adj
  strata.polys.df$strata.num <- factor(strata.polys.df$strata.num, labels=strata.names)
  
  # Convert strata boxes into SF polygon objects
  strata.polys <- strata.polys.df %>%
    st_as_sf(coords=c("long", "lat"), crs=4326) %>%
    st_transform(crs=st_crs(2227)) %>%
    group_by(strata.num) %>%
    summarise(
      geometry = st_combine(geometry)
    ) %>%
    st_cast("POLYGON")
  
  # Combine state polygons into single region polygon
  region.poly <- state.polys %>%
    st_combine()
  
  
  strata.polys.new <- st_intersection(
    st_difference(
      strata.polys, 
      st_buffer(region.poly, 0)
    ), 
    region.poly.buffer
  )
  
  p <- ggplot() +
    geom_sf(data=strata.polys.new, aes(fill=strata.num), alpha=0.85)+
    geom_sf(data=state.polys)+
    scale_fill_discrete(name="Strata")+
    coord_sf(crs=plot.crs, default_crs=4326, xlim=c(-129.15, -116.50), ylim=c(32, 49))+
    theme_minimal()+
    theme(
      panel.grid = element_blank(),
      axis.line = element_line(),
      axis.ticks = element_line()
    )
  
  return(p)
}

#PlotStratMap.fn(strata, c("Southern", "Central", "Northern"), plot.crs=4326)
