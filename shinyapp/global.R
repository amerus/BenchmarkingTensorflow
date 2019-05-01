library(shinydashboard)
library(tidyverse)
library(ggplot2)
library(DT)
library(naturalsort)
library(codeModules)

# load saved metrics from RDS files
ALL <- readRDS('./data/ALL.RDS')

# slider controls for seconds 
sliderSeconds <- as.data.frame(ALL) %>%
  select(seconds) %>%
  unique() %>%
  unlist() %>%
  as.numeric()

# dropdown controls for execution (Processor/Graphics Card) selection 
dropDownTags <- ALL %>%
  group_by(execution) %>%
  select(execution) %>%
  unique()

colnames(dropDownTags) <- "Trained on:"

# dropdown controls for hardware selection
selHard <- ALL %>%
  group_by(Hardware) %>%
  select(Hardware) %>%
  unique()

colnames(selHard) <- "Affected Hardware:"

# dropdown controls for Waldo image selection
selWaldo <- list.files(path = './waldo/images', pattern = '.jpg') %>% naturalsort()