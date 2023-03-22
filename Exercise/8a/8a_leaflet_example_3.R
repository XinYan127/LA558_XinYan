# Leaflet mapping: Make a Chloropleth map.
# 
# March 7, 2023
# Chris Seeger

# installPackage ----------------------------------------------------------

install.packages("leaflet", "leaflet.providers", "tidyverse", "sf")
library(leaflet)
library(leaflet.providers)
library(tidyverse)
library(readxl)
library(sf)

# Set working directory to the same as this R file.
# Read in the shapefile
studentCount <- st_read("studentConferenceCounty.shp")

# Set the projection to use lat and longs
studentCount <- st_transform(studentCount, crs = 4326)

# I should have corrected the name of the count field. It is currently 
# last_name_, but I can use dplyr to rename the column!
studentCount <- studentCount %>% rename(count = last_name_)

m <- leaflet() %>%
  setView(-94.5, 42.2, 6)  %>%
  addTiles() %>%
  addPolygons(data = studentCount,  # borders of all counties
    color = "blue", fill = NA, weight = 1)
m

# Display only a few counties, Boone and Green for example.
studentCount_selection1 <- studentCount %>% 
  filter(COUNTY %in% c("Boone", "Greene"))

m <- leaflet() %>%
  setView(-94.5, 42.2, 6)  %>%
  addTiles() %>%
  addPolygons(data = studentCount_selection1,  # borders of all counties
              color = "#ffff00", fillColor = "blue", weight = 5, opacity = 0.75)
m
# Yes, that was a poor color selection ...
# Note using help to see the other properties of the addPolygons - notice to
# Change the opacity of the fill you need to use fillOpacity = a value of 0-1
?leaflet::addPolygons

# Or maybe only the counties with no participants? Look for not > than 0 or NA
studentCount_selection2 <- studentCount %>% 
  filter(is.na(count) | !count > 0)

m <- leaflet() %>%
  setView(-94.5, 42.2, 6)  %>%
  addTiles() %>%
  addPolygons(data = studentCount_selection2,  # borders of all counties
    color = "#000", fillColor = "red", weight = 1, 
    opacity = 0.75, fillOpacity = 0.8)
m


# What if I wanted to show both of the special county selections?
m <- leaflet() %>%
  setView(-94.5, 42.2, 6)  %>%
  addTiles() %>%
  addPolygons(data = studentCount_selection2,  # borders of all counties
              color = "#000", fillColor = "red", weight = 1, 
              opacity = 0.75, fillOpacity = 0.8) %>%
# Add the additional polygon! This woudl work for markers as well!!!
  addPolygons(data = studentCount_selection1,  # borders of all counties
              color = "blue", fillColor = "white", weight = 5, 
              opacity = 0.75, fillOpacity = 0.8)
m


# OK, but what I really want is a chloropleth map of the counts
# First I better replace the NA in the entire dataframe with a 0.
studentCount <- studentCount %>%
  replace(is.na(.), 0)

# Select the color scheme from Color Brewer
library("RColorBrewer") #I think either Leaflet or tidyverse loads this for you
display.brewer.all()


bins <- c(0, 2, 4, 6, 8, 10, 12, 14, Inf)
pal <- colorBin("PuBu", domain = studentCount$count, bins = bins)

m <- leaflet() %>%
  setView(-94.5, 42.2, 6)  %>%
  addTiles() %>%
  addPolygons(data = studentCount,
    fillColor = ~pal(count),
    weight = 0.5,
    opacity = 1,
    color = "grey",
    dashArray = "1",
    fillOpacity = 0.8)
m


# Add interaction
m <- leaflet() %>%
  setView(-94.5, 42.2, 6)  %>%
  addTiles() %>%
  addPolygons(data = studentCount,
      fillColor = ~pal(count),
      weight = 0.5,
      opacity = 1,
      color = "grey",
      dashArray = "1",
      fillOpacity = 0.8,  #be careful, you need to switch the ) to a comma
      highlightOptions = highlightOptions(
        weight = 2,
        color = "#666",
        dashArray = "",
        fillOpacity = 0.7,
        bringToFront = TRUE)
  )
m

# With that working we now need to display the county and the count in a popup
# Start with the description of the labels , must do this before 
# loading the map reference for sprintf 
# is https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/sprintf
labels <- sprintf(
  "<strong>%s</strong><br/>%g students",
  studentCount$COUNTY, studentCount$count
) %>% lapply(htmltools::HTML)

m <- leaflet() %>%
  setView(-94.5, 42.2, 6)  %>%
  addTiles() %>%
  addPolygons(data = studentCount,
    fillColor = ~pal(count),
    weight = 0.5,
    opacity = 1,
    color = "grey",
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
      direction = "auto"))
m


#finally we can add a legend! I will append this to m
m %>% addLegend(pal = pal, values = count, opacity = 0.7, title = "Students",
                position = "bottomright")


# ----------------Complete Code!!  But with a different color scheme! ------


studentCount <- st_read("studentConferenceCounty.shp")
studentCount <- st_transform(studentCount, crs = 4326)
studentCount <- studentCount %>% rename(count = last_name_)
studentCount <- studentCount %>% replace(is.na(.), 0)

display.brewer.all() # I am selecting the Reds
bins <- c(0, 2, 4, 6, 8, 10, 12, 14, Inf)
pal <- colorBin("Reds", domain = studentCount$count, bins = bins)

labels <- sprintf(
  "<strong>%s</strong><br/>%g students",
  studentCount$COUNTY, studentCount$count
) %>% lapply(htmltools::HTML)

m <- leaflet() %>%
  setView(-94.5, 42.2, 6)  %>%
  addTiles() %>%
  addPolygons(data = studentCount,
    fillColor = ~pal(count),
    weight = 0.5,
    opacity = 1,
    color = "grey",
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
      direction = "auto")) %>% 
addLegend(pal = pal, values = count, opacity = 0.7, title = "Students",
    position = "bottomright")
m

#now export this as a web page!!!