library(ggplot2)
library(dplyr)


# ------------ 1. Plot using variables of choice from TidyCensus ------------  
iowa_income <- get_acs(
  geography = "county",
  variables = "B19013_001",
  state = "IA",
  year = 2020,
  geometry = TRUE
)

basemap <- osm.raster(
  st_bbox(iowa_income), 
  zoom = 8,
  type = "cartolight",
  crop = TRUE
)

tm_shape(basemap) + 
  tm_rgb() + 
  tm_shape(iowa_income) + 
  tm_polygons(col = "estimate",
              style = "quantile",
              n = 7,
              palette = "Blues",
              title = "Income") + 
  tm_layout(title = "Income2020 IOWA Income Cencus",
            frame = FALSE,
            legend.outside = TRUE) +
  tm_scale_bar(position = c("left", "BOTTOM")) + 
  tm_compass(position = c("right", "top")) + 
  tm_credits("Basemap (c) CARTO, OSM", 
             bg.color = "white",
             position = c("RIGHT", "BOTTOM"), 
             bg.alpha = 0,
             align = "right")

# ------------ 2. Plot from tidyCensus or a plot using the world data and  the idbr package ------------ 

## ----nj-income------------------------------------------------------------------------
ia_income <- get_acs(
  geography = "county",
  variables = "B19013_001",
  state = "IA",
  year = 2020,
  moe_level = 99
) %>%
  mutate(NAME = str_remove(NAME, 
                           " County, Iowa"))

ia_income1 = ia_income %>%
  arrange(desc(estimate)) %>%
  head(10)

ggplot(ia_income1, 
       aes(x = estimate, 
           y = reorder(NAME, estimate))) + 
  geom_errorbar(aes(xmin = estimate - moe, xmax = estimate + moe), #<<
                width = 0.5, size = 0.5) + #<<
  geom_point(color = "navy", size = 3) + #<<
  labs(title = "TOP 10 counties in IOWA by Median household income, 2016-2020 ACS", 
       subtitle = "Counties in Iowa", 
       x = "ACS estimate", 
       y = "",
       caption = "Error bars reflect the margin of error around the ACS estimate") + #<< 
  theme_minimal(base_size = 14) + 
  scale_x_continuous(labels = dollar_format(scale = 0.001, 
                                            suffix = "K"))

# ------------ 3. Plot using external data from a csv, xlsx, google sheet or even a Github repository ------------ 
# Dataset 1: one value per group
data <- read.csv("https://raw.githubusercontent.com/mwaskom/seaborn-data/master/iris.csv")

data %>%
  ggplot( aes(x=species, y=sepal_length, fill=species) ) + 
  scale_fill_manual(values=c("#0000FF", "#00FF00", "#FF0000")) +
  geom_violin(alpha = 0.3) + 
  labs(title = "Violin plot", 
       x = "species") 
