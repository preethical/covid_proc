library(dplyr)
library(ggplot2)
library(tidyverse)
library(stringr)

aoc_all <- read.csv("aoc_all_records.csv", stringsAsFactors = FALSE)
aoc_all_1 <- read.csv("aoc_all_records_1.csv", stringsAsFactors = FALSE)
aoc_all_2 <- read.csv("aoc_all_records_2.csv", stringsAsFactors = FALSE)
aoc_all_3 <- read.csv("aoc_all_records_3.csv", stringsAsFactors = FALSE)

aoc_merge <- rbind(aoc_all_3,aoc_all_2,aoc_all_1,aoc_all)
aoc_merge[!duplicated(aoc_merge$Tender.ID),]

aoc_merge$AOC.Date <- as.Date(aoc_merge$AOC.Date, format="%d-%b-%Y")
aoc_merge$e.Published.Date <- as.Date(aoc_merge$e.Published.Date, format="%d-%b-%Y")
aoc_merge$Contract.Date <- as.Date(aoc_merge$Contract.Date, format="%d-%b-%Y")

aoc_merge_state2 <- aoc_merge %>% group_by(State.Name, Tender.Type) %>% 
  summarise(total=sum(Contract.Value, na.rm = TRUE))

aoc_merge_state1 <- aoc_merge %>% group_by(State.Name, Tender.Type) %>% tally()

award_box<- ggplot(aoc_merge, aes(x=State.Name, y=Number.of.bids.received)) + 
  geom_boxplot() + theme(axis.text.x = element_text(size = 6, angle = 90))

award_box <- ggplot(aoc_merge, aes())




