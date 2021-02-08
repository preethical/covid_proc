library(tidyverse)
library(ggplot2)
library(maptools)
library(rgeos)
library(ggmap)
library(scales)
library(RColorBrewer)
library(rgdal)
library(ggthemes)
set.seed(8000)
## Read csvs for the vaccinated and to be vaccinated
results_1 <- read.csv("states_vaccine - Sheet1(1).csv", row.names = NULL,
                                stringsAsFactors = FALSE)
results_2 <- read.csv("states_vaccine.csv", row.names = NULL,
                                stringsAsFactors = FALSE)
#states_shape <-  readShapeSpatial("IND_adm1.shp")

## read the shp file
states_shape <- readOGR("Admin2.shp")

##Clean the data
names(results_1)[2] <- paste("id")
names(results_1)[3] <- paste("vaccinated")
results_1$vaccinated <- as.numeric(gsub(",","",results_1$vaccinated))

names(results_2)[2] <- paste("id")
names(results_2)[3] <- paste("vaccine")
results_2$vaccine <- as.numeric(gsub(",","",results_2$vaccine))

results_3 <- merge(results_1, results_2)
results_3$tbv <- results_3$vaccinated - results_3$vaccine
results_3 = subset(results_3, select = -c(X,X.1,X.2,X.3))

#make a dataframe of the map data
fortify_shape = fortify(states_shape, region = "ST_NM")

##Merge map and csb
states_vaccinated <- fortify_shape %>% 
  left_join(results_1)

states_vaccine<- fortify_shape %>% 
  left_join(results_2)

states_vaccine_tbd <- fortify_shape %>% 
  left_join(results_3)

## Plot data

final.plot<-states_vaccinated[(states_vaccinated$order), ]

final.plot_1 <- states_vaccine[(states_vaccine$order), ]

final.plot_2 <- states_vaccine_tbd[(states_vaccine_tbd$order), ]

ggplot() + 
  geom_polygon(data = final.plot, aes(x = long, y = lat, group = group, fill = vaccinated),color = "black") +
  coord_map()

ggplot() + 
  geom_polygon(data = final.plot_1, aes(x = long, y = lat, group = group, fill = vaccine),color = "black") +
  coord_map()

ggplot() + 
  geom_polygon(data = final.plot_2, aes(x = long, y = lat, group = group, fill = tbv),color = "black") +
  coord_map()

##ggsave("India_IMR_2013_BLUE.png",dpi = 300, width = 20, height = 20, units = "cm")

#merge.shp.coef<-merge(states_shape,results_2, by="id", all.x=TRUE)

#ggplot() + geom_map(data = states_vaccinated, aes(map_id = id, fill = mean(vaccinated), 
#map = fortify_shape) + expand_limits(x = states_shape$long, y = states_shape$lat) + 
#scale_fill_gradient2(low = muted("red"),mid = "white", midpoint = 10000, high = muted("blue"), limits = c(1000, 1000000))

#ggplot(states_vaccinated, aes(fill = vaccinated)) +
 # geom_sf() +
#  scale_fill_viridis_c() +
#  ggthemes::theme_map()