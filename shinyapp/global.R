library(shinydashboard)
library(tidyverse)
library(ggplot2)
library(plotly)
library(RColorBrewer)
library(reticulate)

use_virtualenv('bench')

# load saved metrics from RDS files
CPU <- readRDS('./data/cpu.RDS')
DISK <- readRDS('./data/disk.RDS')
MEM <- readRDS('./data/mem.RDS')
CPU_TEMP <- readRDS('./data/cpuTemp.RDS')
GPU_TEMP <- readRDS('./data/gpuTemp.RDS')

# slider controls populated from one of the RDS files. It can be any, since runtime is identical.
sliderSeconds <- as.data.frame(CPU) %>%
  select(seconds) %>%
  unique() %>%
  unlist() %>%
  as.numeric()

# dropdown controls of execution - CPU versus CUDA. Loadning from CPU RDS but can be any.
dropDownTags <- CPU %>%
  group_by(execution) %>%
  select(execution) %>%
  unique()

# finding unique tags for each of the communities
# englishOnly <- anti_join(englishData, russianData, by = "Tag")
# russianOnly <- anti_join(russianData, englishData, by = "Tag")

#engSpecTags <- as.data.frame(englishOnly) %>%
#  group_by(Tag) %>%
#  arrange(desc(TagProp)) %>%
#  select(Tag) %>%
#  unique()

#rusSpecTags <- as.data.frame(russianOnly) %>%
#  group_by(Tag) %>%
#  arrange(desc(TagProp)) %>%
#  select(Tag) %>%
#  unique()