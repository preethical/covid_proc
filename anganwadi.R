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
set.seed(8000)

options(scipen =999)
## Read csvs for the vaccinated and to be vaccinated

#coldstorage
coldstorage <- read.csv("storage_tenders_copy.csv",row.names = NULL,
                        stringsAsFactors = FALSE)

## read the shp file
states_shape <- readOGR("Admin2.shp")
states_shape = st_sf(geom=states_shape)

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

#healthcenters

healthcentre1 <- read.csv("subcentre21.csv",row.names = NULL,
                          stringsAsFactors = FALSE)
healthcentre2 <- read.csv("health_centre_21.csv",row.names = NULL,
                          stringsAsFactors = FALSE)

healthcentre3 <- read.csv("subcentre.csv",row.names = NULL,
                          stringsAsFactors = FALSE)
healthcentre4 <- read.csv("health_centre.csv",row.names = NULL,
                          stringsAsFactors = FALSE)

healthcentre_merge <- rbind(healthcentre1, healthcentre2, healthcentre3, healthcentre4)

healthcentre_merge_rem_dup<- 
 healthcentre_merge[!duplicated(healthcentre_merge[c(4,3,2)]),]
names(healthcentre_merge_rem_dup)[5] <- paste("id")

healthcentre_merge_rem_dup$id <- replace(healthcentre_merge_rem_dup$id, healthcentre_merge_rem_dup$id =="Dadra and Nagar Haveli (UT)", "Dadra and Nagar Haveli and Daman and Diu")
healthcentre_merge_rem_dup$id <- replace(healthcentre_merge_rem_dup$id, healthcentre_merge_rem_dup$id =="Puducherry UT", "Puducherry")
healthcentre_merge_rem_dup$id <- replace(healthcentre_merge_rem_dup$id, healthcentre_merge_rem_dup$id =="Uttar Pradesh", "Uttar Pradesh")

newtable<- as.data.frame(count(healthcentre_merge_rem_dup$id))

names(newtable)[1] <- paste("id")
fortify_shape = fortify(states_shape, region = "ST_NM")
health_centres <- fortify_shape %>% 
  left_join(newtable)

final.plot<-health_centres[(health_centres$order), ]

ggplot() + 
  geom_polygon(data = final.plot, aes(x = long, y = lat, group = group, fill = freq),color="#7f7f7f", size=0.15) +
  coord_map() + scale_fill_continuous(labels = comma) + expand_limits(fill = seq(from = 0, to = 5))

write.csv(healthcentre_merge_rem_dup, "healthcentres.csv")


#vaccine
vaccines <- read.csv("tables_vaccine.csv",row.names = NULL,
                     stringsAsFactors = FALSE, na.strings = "-")
total_cases <- read.csv("total_cases.csv",row.names = NULL,
                        stringsAsFactors = FALSE, skip = 1, header = TRUE)

names(vaccines)[2] <- paste("id")
names(total_cases)[1] <- paste("id")

vaccines <- merge(vaccines,total_cases)

vaccines$Total.doses.in.pipeline.supply[is.na(vaccines$Total.doses.in.pipeline.supply)] <- 0

vaccines$perthouvaccinated <- ((vaccines$Total.consumption.including.waste - (vaccines$Percentage.wastage/vaccines$Doses.received.by.state)*100)/vaccines$Population.projection)*1000
vaccines$percapitavaccineavail <- ((vaccines$Doses.received.by.state + vaccines$Total.doses.in.pipeline.supply)/vaccines$Population.projection)*1000

vaccines$id <- replace(vaccines$id, vaccines$id =="Jammu and Kashmir", "Jammu & Kashmir")

vaccines$ratio <-vaccines$Per.100.000.1/vaccines$percapitavaccineavail


fortify_shape = fortify(states_shape, region = "ST_NM")


vaccines_maps <- fortify_shape %>% 
  left_join(vaccines)

final.plot<- (vaccines_maps[(vaccines_maps$order), ])

ggplot+ geom_polygon(data = final.plot, aes(x = long, y = lat, group = group, fill = perthouvaccinated),color="#FF0000", size=0.15) +
  coord_map() + scale_fill_continuous(labels = comma) + expand_limits(fill = seq(from = 0, to = 200))

ggplot() + 
  geom_polygon(data = final.plot, aes(x = long, y = lat, group = group, fill = percapitavaccineavail),color="#7f7f7f", size=0.15) +
  coord_map() + scale_fill_continuous(labels = comma) + expand_limits(fill = seq(from = 0, to = 300))

ggplot() + 
  geom_polygon(data = final.plot, aes(x = long, y = lat, group = group, fill = Per.100.000.1),color="#7f7f7f", size=0.15) +
  coord_map() + scale_fill_continuous(labels = comma) + expand_limits(fill = seq(from = 0, to = 100)) + layer()

ggplot() + 
  geom_polygon(data = final.plot, aes(x = long, y = lat, group = group, fill = ratio),color="#7f7f7f", size=0.15) +
  coord_map() + scale_fill_continuous(labels = comma) + expand_limits(fill = seq(from = 0, to = 1)) 

#data <- bi_class(vaccines_maps, x = percapitavaccineavail, y = Per.100.000.1, style = "quantile", dim = 3)


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
  gather("group", "fill")

vaccines_maps <- fortify_shape %>% 
  left_join(vaccines)

vaccines_maps <- fortify_shape %>% 
  left_join(total_cases)


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
    group = paste(
      as.numeric(quantiles_vaccineavial), "-",
      as.numeric(quantiles_cases)
    )
  ) %>%
  # we now join the actual hex values per "group"
  # so each municipality knows its hex value based on the vaccine availability and vaccinations
  left_join(bivariate_color_scale, by = "group")


final.plot<-(vaccines_maps[(vaccines_maps$order), ])

ggplot() + geom_sf(data = final.plot, aes(fill = fill, color = "white", size = 0.1)) +
  scale_alpha(name = "",range = c(0.6, 0), guide = F) + scale_fill_identity()


ggplot() + 
  geom_polygon(data = final.plot,aes(x = long, y = lat, group = group, fill = fill),color="white", size=0.15) +
  coord_map() +  scale_fill_identity() + expand_limits(fill = seq(from = 0, to = 1)) 





#Anganwadi
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
  coord_map() + scale_fill_continuous(labels = comma) + expand_limits(fill = seq(from = 0, to = 20))
