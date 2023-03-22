# Find the Percent language spoken in each of the counties in the H2 regions.
# 
# March 3, 2023
# Chris Seeger



install.packages(c("usmap", "tidyverse", "usmapdata", "tigris"))
#"readxls"
library(tidyverse)
library(readxl)
library(usmap)
library(tigris)


freeReduced <- read_excel("2021-2022freeReduced.xlsx")
dailyAttendance <- read_excel("2021-2022dailyAttendance.xlsx")

# need to get a lookup file that contains the FIPS code and CountyID
# read.csv will import 01 and 1 so have to set it to be a character
countyLookup <- read.csv("lookup_county_regions_includesCountyID.csv", 
                         colClasses = c(CountyID = "character"))

#free and reduced summarize by county
freeReducedCounty <- freeReduced %>%
  group_by(County_ID) %>%
  summarise(
    County_Name = County_Name,
    k12_enrollment = sum(K12_Enrollment),
    fl = sum(Number_Eligible_Free_Lunch),
    rpl = sum(Number_Eligible_Reduced_Price_Lunch),
    total_fl_rpl = sum(total_fl_rpl),
    percent_fl = sum((fl/k12_enrollment)*100),
    percent_rpl = sum((rpl/k12_enrollment)*100),
    state = "Iowa" #not file, usmap requires, add it here since all Iowa data
    ) 
head(freeReducedCounty) 

# a field named fips is required by usmap, this info has to be joined
freeReducedCounty <- left_join(freeReducedCounty, countyLookup, 
  by = join_by("County_ID" == "CountyID"))
#I would like to have used %>% select(countyFIPS5) to bring just that field over
#but for some reason it fails
#so instead will remove the fields I do not need
#I will also rename the countyFIPS5 to be just fips
#remember the syntax here is rename(new_column_name = old_column_name)
freeReducedCounty <- select(freeReducedCounty,-state.y, -state.x, -County) %>%
  rename(fips = countyFIPS5)
head(freeReducedCounty) 



 
#Add some data to the usmap package
plot_usmap(regions = "counties", include = "IA", data = freeReducedCounty, 
    values = "percent_fl", color = "grey") + 
  labs(title = "Iowa Free and Reduced Lunch", 
       subtitle = "2021 - 2022 K12 summarized by County") +
  scale_fill_continuous(name = "Percent", label = scales::comma) + 
  theme(legend.position = "right")
# the projection used in usmap is (Albers Equal Area projection).



#so maybe  instead I should instead use tiger data and ggPlot2 to make this map?
#will start by getting the geometry for Iowa counties from Tiger
iowa_counties<- counties("IA") %>% 
  mutate_at(("GEOID"), as.numeric)
ggplot(iowa_counties) + 
  geom_sf() + 
  theme_void()

#Next join the geometry from iowa_counties to freeReducedCounty
#Note the left side of the join must contain the geometry
freeReducedCounty_sf <- left_join(iowa_counties %>% 
  select(geometry, GEOID), freeReducedCounty,  
  by = join_by(GEOID == fips))

#test to see if the geometry draws
ggplot(freeReducedCounty_sf) + 
  geom_sf() + 
  theme_void()

freeReducedCounty_sf %>% 
  ggplot(aes(fill = percent_fl)) +
  labs(title = "Percent Free Lunch", fill = "Percent", caption = "Data source: Iowa Department of Education") +
  geom_sf() +
  theme_void() +
  scale_fill_viridis_c() 

#the outlines get the same color as the fill
+ scale_color_viridis_c()

#need to convert to long format

aa <- gather(freeReducedCounty_sf, tVar, percent, percent_fl, percent_rpl)


# New facet label names for supp variable
supp.labs <- c("Orange Juice", "Vitamin C")
#names(supp.labs) <- c("OJ", "VC")
aa %>% 
  ggplot(aes(fill = percent)) +
  labs(title = "Percent Free Lunch", fill = "Percent", caption = "Data source: Iowa Department of Education") +
  geom_sf() +
  theme_void() +
  scale_fill_viridis_c() +
  facet_grid (~ tVar, labeller = labeller(tVar = supp.labs)
  )
  
  
  #facet_wrap(~ ext_region_new, nrow = 10, ncol = 3)


  

  
  # Create the plot
  p + facet_grid(
    dose ~ supp, 
    labeller = labeller(dose = dose.labs, tVar = supp.labs)
  )