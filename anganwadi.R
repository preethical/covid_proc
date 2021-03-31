library(tidyverse)
library(ggplot2)
library(maptools)
library(rgeos)
library(ggmap)
library(scales)
library(RColorBrewer)
library(rgdal)
library(ggthemes)
library(plyr)
set.seed(8000)

options(scipen =999)
## Read csvs for the vaccinated and to be vaccinated


coldstorage <- read.csv("Sheet 1-Table 1.csv",row.names = NULL,
                        stringsAsFactors = FALSE)

## read the shp file
states_shape <- readOGR("Admin2.shp")

##Clean the data
names(coldstorage)[7] <- paste("id")

newtable <- as.data.frame(count(coldstorage$id))
names(newtable)[1] <- paste("id")
fortify_shape = fortify(states_shape, region = "ST_NM")
coldstorage_tenders <- fortify_shape %>% 
  left_join(newtable)

final.plot<-coldstorage_tenders[(coldstorage_tenders$order), ]

ggplot() + 
  geom_polygon(data = final.plot, aes(x = long, y = lat, group = group, fill = freq),color="#7f7f7f", size=0.15) +
  coord_map() + scale_fill_continuous(labels = comma) + expand_limits(fill = seq(from = 0, to = 5))


anganwadi <- read.csv("anganwadi.csv",row.names = NULL,
                      stringsAsFactors = FALSE)

names(anganwadi)[6] <- paste("id")
newtable <- as.data.frame(count(anganwadi$id))
names(newtable)[1] <- paste("id")
anganwadi_tenders <- fortify_shape %>% 
  left_join(newtable)

final.plot<-anganwadi_tenders[(anganwadi_tenders$order), ]

ggplot() + 
  geom_polygon(data = final.plot, aes(x = long, y = lat, group = group, fill = freq),color="#7f7f7f", size=0.15) +
  coord_map() + scale_fill_continuous(labels = comma) + expand_limits(fill = seq(from = 0, to = 30))
