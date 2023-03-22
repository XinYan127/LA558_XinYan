# installPackage ----------------------------------------------------------
install.packages("leaflet", "leaflet.providers", "tidyverse", "sf", "htmlwidgets")
library(leaflet)
library(leaflet.providers)
library(tidyverse)
library(readxl)
library(sf)
library(htmlwidgets)

# Create a Leaflet page in R that includes at least 20 markers. 
data(quakes)
leaflet(data = sample_n(quakes,50)) %>% addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
  addMarkers(~long, ~lat, popup = ~as.character(mag), label = ~as.character(mag), clusterOptions = markerClusterOptions()) 

#Create a Leaflet page in R that includes a chloropleth. 
studentCount <- st_read("studentConferenceCounty.shp")
studentCount <- st_transform(studentCount, crs = 4326)
studentCount <- studentCount %>% rename(count = last_name_)

bins <- c(0, 2, 4, 6, 8, 10, 12, 14, Inf)
pal <- colorBin("Pastel2", domain = studentCount$count, bins = bins)

labels <- sprintf(
  "<strong>%s</strong><br/>%g students",
  studentCount$COUNTY, studentCount$count
) %>% lapply(htmltools::HTML)

m <- leaflet() %>%
  setView(-93.5, 42.2, 7)  %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = studentCount,
              fillColor = ~pal(count),
              weight = 0.5,
              opacity = 1,
              color = "purple",
              dashArray = "1",
              fillOpacity = 0.8,  #be careful, you need to switch the ) to a comma
              highlightOptions = highlightOptions(
                weight = 2,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "10px",
                direction = "auto")) %>% addLegend(pal = pal, values = count, opacity = 0.7, title = "Students", position = "bottomright")
m

#This does the same as export and creates a single 1.7 MB file
saveWidget(m, file="m.html")

# however if you want to export multiple maps for a page, then you can put 
# the shared resources into a dir named lib. The m.html file then is 1.
saveWidget(m, "m.html", selfcontained = F, libdir = "lib")
