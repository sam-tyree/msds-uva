#Spring 2020 Cohort Bootcamp
#UK election results mapping in R exercise
#Breakout Group 3: Michael, Mike, Travis, Sam 
#Jan 4, 2020


#install.packages("leaflet")
#install.packages("sf")
#install.packages("htmlwidgets")
#install.packages("dplyr")
#install.packages("parlitools")
#install.packages("cartogram")

library(leaflet)
library(sf)
library(htmlwidgets)
library(dplyr)
library(parlitools)
library(cartogram)

west_hex_map <- parlitools::west_hex_map

party_colour <- parlitools::party_colour

elect2015 <- parlitools::bes_2015

elect2015_win_colours <- left_join(elect2015, party_colour, by = c("winner_15" ="party_name")) #Join to current MP data

gb_hex_map <- right_join(west_hex_map, elect2015_win_colours, by = c("gss_code"="ons_const_id")) #Join colours to hexagon map

gb_hex_map <- as(gb_hex_map, "Spatial")

gb_hex_map <- as(gb_hex_map, "SpatialPolygonsDataFrame")

gb_hex_map$majority_15 <- round(gb_hex_map$majority_15, 2)

gb_hex_map$turnout_15 <- round(gb_hex_map$turnout_15, 2)

gb_hex_map$marginality <- (100-gb_hex_map$majority_15)^3

#gp_hex_scaled <- cartogram_cont(gb_hex_map, 'marginality', itermax = 5)
gp_hex_scaled <- gb_hex_map

winners <- as.data.frame(party_name = unique(gp_hex_scaled$winner_15))
winners <- winners %>% rename(party_name = "unique(gp_hex_scaled$winner_15)")
winner_colour <- left_join(winners, party_colour, by = "party_name")


# Creating map labels
labels <- paste0(
  "Constituency: ", gp_hex_scaled$constituency_name.y, "</br>",
  "Most Recent Winner: ", gp_hex_scaled$winner_15, "</br>",
  "Most Recent Majority: ", gp_hex_scaled$majority_15, "%","</br>",
  "Turnout: ", gp_hex_scaled$turnout_15, "%"
) %>% lapply(htmltools::HTML)

# Creating the map itself
leaflet(options=leafletOptions(
  dragging = FALSE, zoomControl = FALSE, tap = FALSE,
  minZoom = 6, maxZoom = 6, maxBounds = list(list(2.5,-7.75),list(58.25,50.0)),
  attributionControl = FALSE),
  gp_hex_scaled) %>%
  addPolygons(
    color = "grey",
    weight=0.75,
    opacity = 0.5,
    fillOpacity = 1,
    fillColor = ~party_colour,
    label=labels) %>%
  addLegend("topright", colors = winner_colour$party_colour, labels = winner_colour$party_name, opacity = 1) %>%
  htmlwidgets::onRender(
    "function(x, y) {
        var myMap = this;
        myMap._container.style['background'] = '#fff';
    }")%>% 
  mapOptions(zoomToLimits = "first")
