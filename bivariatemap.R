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
library(biscale)
library(sf)
library(plotly)
library(cowplot)
set.seed(8000)

options(scipen =999)

states_shape <- readOGR("Admin2.shp")

##read vaccine data
vaccines <- read.csv("tables_vaccine.csv",row.names = NULL,
                     stringsAsFactors = FALSE, na.strings = "-")
total_cases <- read.csv("total_cases.csv",row.names = NULL,
                        stringsAsFactors = FALSE, skip = 1, header = TRUE)

#make column names same
names(vaccines)[2] <- paste("id")
names(total_cases)[1] <- paste("id")

#merge vaccine and case information
vaccines <- merge(vaccines,total_cases)

#make the na's into 0's
vaccines$Total.doses.in.pipeline.supply[is.na(vaccines$Total.doses.in.pipeline.supply)] <- 0

#calculate per capita vaccines available and vaccinated individuals/
vaccines$perthouvaccinated <- ((vaccines$Total.consumption.including.waste - (vaccines$Percentage.wastage/vaccines$Doses.received.by.state)*100)/vaccines$Population.projection)*1000
vaccines$percapitavaccineavail <- ((vaccines$Doses.received.by.state + vaccines$Total.doses.in.pipeline.supply)/vaccines$Population.projection)*1000

#standardise the state names
vaccines$id <- replace(vaccines$id, vaccines$id =="Jammu and Kashmir", "Jammu & Kashmir")

#vaccines$ratio <-vaccines$Per.100.000.1/vaccines$percapitavaccineavail

#make into a dataframe
fortify_shape = fortify(states_shape, region = "ST_NM")
#join the geo data with vaccine data
vaccines_maps <- fortify_shape %>% 
  left_join(vaccines)


#attempt 1
#make a bi_class column which has the quanitles across the two factors we are looking at. 
final.plot<- (vaccines_maps[(vaccines_maps$order), ])

data = st_as_sf(final.plot, coords = c("long", "lat"), 
                crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

data <- bi_class(data, x = percapitavaccineavail, y = Per.100.000.1, style = "quantile", dim = 3)

ggplot() +
  geom_sf(data = data, mapping = aes(fill = bi_class), color = "white", size = 0.1, show.legend = FALSE) +
  bi_scale_fill(pal = "DkBlue", dim = 3) +
  bi_theme()


## attempt 2

quantiles_vaccineavial<- vaccines %>%
  pull(percapitavaccineavail) %>%
  quantile(probs = seq(0, 1, length.out = 4))

quantiles_cases<- vaccines %>%
  pull(Per.100.000.1) %>%
  quantile(probs = seq(0, 1, length.out = 4))

bivariate_color_scale <- tibble(
  "3 - 3" = "#3F2949", # high vaccine avail, high caseload
  "2 - 3" = "#435786",
  "1 - 3" = "#4885C1", # low vaccineavail, high caseload
  "3 - 2" = "#77324C",
  "2 - 2" = "#806A8A", # medium vacc, medium caseload
  "1 - 2" = "#89A1C8",
  "3 - 1" = "#AE3A4E", # high vaccineavail, low caseload
  "2 - 1" = "#BC7C8F",
  "1 - 1" = "#CABED0" # low vaccavail, low caseload
) %>%
  gather("numbers", "fill")

#vaccines_maps <- fortify_shape %>% 
  #left_join(vaccines)

#vaccines_maps <- fortify_shape %>% 
 # left_join(total_cases)

vaccines_maps %<>%
  mutate(
    quantiles_vaccineavial = cut(
      percapitavaccineavail,
      breaks = quantiles_vaccineavial,
      include.lowest = TRUE
    ),
    quantiles_cases = cut(
      Per.100.000.1,
      breaks = quantiles_cases,
      include.lowest = TRUE
    ),
    # by pasting the factors together as numbers we match the groups defined
    # in the tibble bivariate_color_scale
    numbers = paste(
      as.numeric(quantiles_vaccineavial), "-",
      as.numeric(quantiles_cases)
    )
  ) %>%
  # we now join the actual hex values per "group"
  # so each municipality knows its hex value based on the vaccine availability and vaccinations
  left_join(bivariate_color_scale, by = "numbers")

final.plot<- (vaccines_maps[(vaccines_maps$order), ])

data = st_as_sf(final.plot, coords = c("long", "lat"), 
                crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

#attempt 1
ggplot() + geom_sf(data = data, aes(fill = fill, group = group),color="white", size=0.15) +
  scale_fill_identity() + expand_limits(fill = seq(from = 0, to = 1)) 

#attempt 2
map <- ggplot() +
  geom_sf(data = data, mapping = aes(fill = bi_class), color = "white", show.legend = FALSE) +
  bi_scale_fill(pal = "DkBlue", dim = 3) +
  bi_theme()

#attempt 3
map <- ggplot() + 
  geom_polygon(data = final.plot, aes(x = long, y = lat, group = group, fill = fill), color = "black", size=0.15) +
   coord_map()+scale_fill_identity()

map <- ggplotly(map)

# separate the groups
bivariate_color_scale %<>%
  separate(numbers, into = c("vaccineavail", "caseload"), sep = " - ") %>%
  mutate(vaccineavail = as.integer(vaccineavail),
         caseload = as.integer(caseload))

legend <- ggplot() +
  geom_tile(
    data = bivariate_color_scale,
    mapping = aes(
      x = vaccineavail,
      y = caseload,
      fill = fill)
  ) +
  scale_fill_identity() +
  labs(x = "Increased vaccine availability per capita⟶️",
       y = "Increased number of cases/100 pop ⟶️") +
  theme_map() +
  # make font small enough
  theme(
    axis.title = element_text(size = 6)
  ) +
  # quadratic tiles
  coord_fixed()


ggdraw() +
  draw_plot(map, 0, 0, 1, 1) +
  draw_plot(legend, 0.05, 0.075, 0.2, 0.2)


