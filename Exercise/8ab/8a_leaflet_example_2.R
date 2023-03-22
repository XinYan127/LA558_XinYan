# Leaflet mapping: adding multiple markers to slippy map
# 
# March 7, 2023
# Chris Seeger

install.packages("leaflet", "leaflet.providers", "tidyverse")
library(leaflet)
library(leaflet.providers)
library(tidyverse)

#resource for this is https://rstudio.github.io/leaflet/map_widget.html
#resource https://bookdown.org/nicohahn/making_maps_with_r5/docs/leaflet.html

# For the demo I used Mockaroo to make some fake data for a fictional youth
# coding conference, the data set includes latitude, longitude, gender, shirt 
# size and favorite color. I forgot the age! see https://www.mockaroo.com/16ccd380
# Set your sessions working directory to match this files source
youthConf100 <- read.csv("IowaShirtSizes100.csv", header = TRUE)
youthConf1000 <- read.csv("IowaShirtSizes1000.csv", header = TRUE)
myData <- youthConf100

# Add markers from the CSV to this map
map <- leaflet(myData) %>% 
  addTiles() %>%
  addMarkers(~longitude, ~latitude)
map

# Circles might be better for this map, while at it maybe also include labels
# a typical syntax for this is label = ~htmlEscape(Name) however we won't escape
# instead I use the name of the data set, myData followed by a $ and var name
map <- leaflet(myData) %>% 
  addTiles() %>%
  addCircles(~longitude, ~latitude, label = myData$shirt_color)
map

# Might be nice to have a popup of the participant's shirt size
# while not used here, some guides use the htmlEscape() package to make sure 
# there are no characters within the popup text that could mess up the code
map <- leaflet(myData) %>% 
  addTiles() %>%
  addCircles(~longitude, ~latitude, popup = paste("<strong>", 
    myData$last_name, "</strong><br>", "Shirt Size: ", 
    myData$shirt_size))
map

# Maybe change the size and color of the circles
# Note for the color you can also use the hex color value
map <- leaflet(myData) %>% 
  addTiles() %>%
  addCircles(~longitude, ~latitude, popup= paste("<strong>", 
    myData$last_name, "</strong><br>", "Shirt Size: ", 
    myData$shirt_size), weight = 4, radius=1000, 
    color="red", stroke = TRUE, fillOpacity = 0.8)
map

# Time to add some options for the base map
# See the complete set of Leaflet providers 
# http://leaflet-extras.github.io/leaflet-providers/preview/index.html
# Running the following should display the map layers in the console.
names(providers)

# We now have an button containing a group of background layers
map <- leaflet(myData) %>% 
  addTiles(group = "OSM", options = providerTileOptions(minZoom = 4, maxZoom = 10)) %>%
  addProviderTiles("Stamen.TonerLite", group = "Toner", 
    options = providerTileOptions(minZoom = 8, maxZoom = 10)) %>%
  addProviderTiles("Stamen.Watercolor", group = "Water Color") %>%
  addProviderTiles("Esri.WorldTopoMap", group = "Topo") %>%
  addProviderTiles("OpenStreetMap.Mapnik", group = "Mapnik") %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB") %>%
  addLayersControl(baseGroups = c("OSM", "Toner", "Water Color", "Topo", "Mapnik", "CartoDB"),
    options = layersControlOptions(collapsed = TRUE)) %>%
  addCircles(~longitude, ~latitude, popup= paste("<strong>", 
    myData$last_name, "</strong><br>", "Shirt Size: ", 
    myData$shirt_size), weight = 4, radius=40, 
    color="red", stroke = TRUE, fillOpacity = 0.8)
map

# Time to go back to something a bit simpler. Add markers from the CSV with 
# 1000 to this map. Only use the toner lite base map for this.
myData <-youthConf1000
map <- leaflet(myData) %>% 
  addProviderTiles("Stamen.TonerLite", 
    options = providerTileOptions(minZoom = 4, maxZoom = 10)) %>%
  addMarkers(~longitude, ~latitude)
map

# Wow, that was a lot of points! How about only the first 200 observations?
map <- leaflet(myData[1:200,]) %>% 
  addProviderTiles("Stamen.TonerLite", 
    options = providerTileOptions(minZoom = 4, maxZoom = 10))%>%
  addMarkers(~longitude, ~latitude)
map

# Make clusters, note this only appears to work with addMarkers
map <- leaflet(myData[1:200,]) %>% 
  addProviderTiles("Stamen.TonerLite", 
    options = providerTileOptions(minZoom = 4, maxZoom = 10))%>%
  addMarkers(~longitude, ~latitude, clusterOptions = markerClusterOptions())
map

# One more try on all 1,000 locations
map <- leaflet(myData) %>% 
  addProviderTiles("Stamen.TonerLite", 
    options = providerTileOptions(minZoom = 4, maxZoom = 10))%>%
  addMarkers(~longitude, ~latitude, clusterOptions = markerClusterOptions())
map