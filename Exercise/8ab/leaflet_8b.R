# Leaflet mapping: Taking the Chloroplet map and adding it to a web page.
# 
# March 7, 2023
# Chris Seeger

install.packages("leaflet", "leaflet.providers", "tidyverse", "sf")
library(leaflet)
library(leaflet.providers)
library(tidyverse)
library(readxl)
library(sf)
library("RColorBrewer")

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



#make a short list of markers and convert to a data frame
longitude<- c(-92.3, -91.4, -92.7)
latitude <- c(42.1, 42.7, 42.0)
df <- data.frame(longitude, latitude)
# convert to spatial data frame
df_sf = st_as_sf(df, coords = c("longitude", "latitude"), crs = 4326)

#But we would prefer to have
bounds <- df_sf %>% 
  st_bbox() %>% 
  as.character()
#fitBounds(m, bounds[1], bounds[2], bounds[3], bounds[4])


m <- leaflet() %>%
  setView(-94.5, 42.2, 6)  %>%
  addTiles() %>%
  addMarkers(data = df_sf) %>%
  fitBounds(bounds[1], bounds[2], bounds[3], bounds[4])  %>%
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
                direction = "auto")) %>% addLegend(pal = pal, values = count, opacity = 0.7, title = "Students", position = "bottomright")
m


#Add the legend as an option - you will see an issue is that it could overlap
#the map when exported and displayed in your html.
m %>% addLegend(pal = pal, values = count, opacity = 0.7, title = "Students",
            position = "bottomright")




#this will reset the map bounds to center the content
#fitBounds(map, lng1, lat1, lng2, lat2, options = list())
#however, I had to look up the bounds for Iowa
fitBounds(m, -96.63306039630396,40.37830479583795,
          -90.14002756307562,43.50012771146711)
m

# A better way is to us sf package to find the bounds of your data layer of 
# interest. For example, those two points we access the data fdf_sf frame

bounds <- df_sf %>% 
  st_bbox() %>% 
  as.character()
fitBounds(m, bounds[1], bounds[2], bounds[3], bounds[4])

#But we would prefer to have
bounds <- studentCount %>% 
  st_bbox() %>% 
  as.character()
fitBounds(m, bounds[1], bounds[2], bounds[3], bounds[4])




library(htmlwidgets)
#This does the same as export and creates a single 1.7 MB file
saveWidget(m, file="m.html")

# however if you want to export multiple maps for a page, then you can put 
# the shared resources into a dir named lib. The m.html file then is 1.
saveWidget(m, "m.html", selfcontained = F, libdir = "lib")