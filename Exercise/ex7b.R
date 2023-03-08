## ----install-packages---------------------------------------------------
install.packages(c("tidycensus", "tidyverse", "leaflet", "plotly"))
## # For brand-new features:
## install.packages("remotes")
## remotes::install_github("walkerke/tidycensus")


## ----api-key------------------------------------------------------------
library(tidycensus)
library(tidyverse)
library(leaflet)


mymap = leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng=-87.6298, lat=41.8781, popup = "Chicago") %>%
  setView(lng=-87.6298, lat=41.8781, zoom = 12)
mymap
