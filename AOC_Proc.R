library(dplyr)
library(ggplot2)
library(tidyverse)
library(stringr)

aoc_all <- as.tibble(read.csv("aoc_all_records.csv", 
                              stringsAsFactors = FALSE))
aoc_all_1 <- as.tibble(read.csv("aoc_all_records_1.csv", 
                                stringsAsFactors = FALSE))
aoc_all_2 <- as.tibble(read.csv("aoc_all_records_2.csv", 
                                stringsAsFactors = FALSE))
aoc_all_3 <- as.tibble(read.csv("aoc_all_records_3.csv", 
                                stringsAsFactors = FALSE))

aoc_merge <- rbind(aoc_all_3,aoc_all_2,aoc_all_1,aoc_all)
aoc_merge_rem_dup<- 
 aoc_merge[!duplicated(aoc_merge[c(4,6)]),]

aoc_merge_rem_dup$AOC.Date <- as.Date(aoc_merge_rem_dup$AOC.Date, 
                                      format="%d-%b-%Y")
aoc_merge_rem_dup$e.Published.Date <- as.Date(aoc_merge_rem_dup$e.Published.Date, 
                                              format="%d-%b-%Y")
aoc_merge_rem_dup$Contract.Date <- as.Date(aoc_merge_rem_dup$Contract.Date, 
                                           format="%d-%b-%Y")

aoc_merge_state2 <- aoc_merge_rem_dup %>% group_by(State.Name, Tender.Type) %>% 
  summarise(total=sum(Contract.Value, na.rm = TRUE))

aoc_merge_state1 <- aoc_merge_rem_dup %>% group_by(State.Name, Tender.Type) %>% 
  tally()

award_box<- ggplot(aoc_merge_rem_dup, 
                   aes(x=State.Name, y=Number.of.bids.received)) + 
  geom_boxplot() + theme(axis.text.x = element_text(size = 6, angle = 90))

aoc_merge_rem_dup <- aoc_merge_rem_dup[with(aoc_merge_rem_dup,
                                            order(-Contract.Value)),]

Top_10_contracts<- aoc_merge_rem_dup[1:10,]

Top_10_contracts %>% ggplot(aes(x = Tender.ID, y = Contract.Value)) + 
  geom_col() +
  theme(axis.text.x = element_text(size = 6, angle = 90))
                            



