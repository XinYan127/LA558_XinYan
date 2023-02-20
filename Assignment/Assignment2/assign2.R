#----------------------------------------------shortcuts-------------------------------------------
# %>% is Ctrl+Shift+M (Windows) or Cmd+Shift+M (Mac)
# <- is Alt + - (Windows) or Option + - (Mac).

setwd("/Users/user/Desktop/r")

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

packages <- c("googlesheets4","tidyverse","readxl","ggmap","ggplot2", "ggpointdensity","gridExtra")

ipak(packages)

#--------------------------------------------------------------------------------------------------
# plot 1 --- read data from google
#Read google sheets data into R
df <- read_sheet('https://docs.google.com/spreadsheets/d/1J9-ZpmQT_oxLZ4kfe5gRvBs7vZhEGhSCIpNS78XOQUE/edit?usp=sharing')
#Prints the data
df
head(df)
glimpse(df)

df_plot <- df %>%
  select(mpg, hp, cyl) %>%
  mutate(rank = min_rank(desc(hp)))

ggplot(df_plot, aes(x = rank, y = mpg)) + 
  geom_point()+
  geom_smooth(method=lm) +
  ggtitle("More mpg, stronger hp?")

#plot 2 --- read data locally
my_data <- read_excel("/Users/user/Documents/github/LA558_XinYan/Assignment/Assignment2/sampledatafoodsales.xlsx") 

plot_data <- my_data %>% group_by(City, Category) %>% summarise(Quantity = sum(Quantity))

ggplot(plot_data, aes(x = City, y = Quantity, fill = Category)) + 
  geom_bar(position="dodge", stat="identity") +
  ggtitle("The food sales in different cities")





