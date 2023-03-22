# Find the Percent language spoken in each of the counties in the H2 regions.
# 
# February 15, 2023
# Chris Seeger



install.packages(c("tidycensus", "tidyverse"))
library(tidycensus)
library(tidyverse)


#working with American Community Survey (ACS) Data
# create a table of the ACS Variables
vars <- load_variables(2021, "acs5")
View(vars)

variables = c("B19013_001", "B19013I_001")


iowa_income <- get_acs(
  geography = "tract",
  variables = variables,
  state = "Iowa",
  year = 2021,
  geometry = TRUE
)
#plot(iowa_income["estimate"])


iowa_income %>% 
  ggplot(aes(fill = estimate, color = estimate)) +
  geom_sf() +
  coord_sf(crs = 5070, datum = NA) +
  scale_fill_viridis_c() + 
  scale_color_viridis_c() +
  facet_wrap(~ variable, 
             nrow = 3, ncol = 2)

