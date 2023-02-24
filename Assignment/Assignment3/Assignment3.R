library(ggplot2)
library(dplyr)


# ------------ 1. Plot using variables of choice from TidyCensus ------------  

ia_vacancies <- get_decennial(
  geography = "county",
  variables = c(total_households = "H1_001N",
                vacant_households = "H1_003N"),
  state = "IA",
  year = 2020,
  output = "wide"
) %>%
  mutate(percent_vacant = 100 * (vacant_households / total_households)) %>% subset(percent_vacant > 15)

ggplot(ia_vacancies, aes(x = percent_vacant, y = reorder(NAME, percent_vacant)), fill = NAME) + 
  geom_bar(stat="identity", fill="#f68060", alpha=.6, width=.4) +
  scale_x_continuous(labels = label_percent(scale = 1)) + 
  scale_y_discrete(labels = function(y) stringr::str_remove	(y, " County, Iowa")) + 
  labs(x = "Percent vacant households", 
       y = "", 
       title = "Household vacancies (15%) by county in Iowa", 
       subtitle = "2020 decennial US Census") +
  theme_bw()

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
