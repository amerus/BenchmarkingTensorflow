library(tidyr)
library(ggplot2)
library(jsonlite)
library(tibble)
library(dplyr)

setwd('~/Documents/datascience/finalproject/gpulog')

### GPU run ###
# Memory stats
# free -w -m -s 1 -c 1 | egrep -v 'Swap|total' >> $LOGDIR/memory.out &
memCols = c("measurement", "total", "used", "free", "shared", "buffers", "cache", "available")
memory <- read.table('memory.out', col.names = memCols)
memory <- memory %>% select(-measurement)

# Disk stats
# iostat -xyh -d /dev/nvme0n1p2 1 1 | egrep -v 'Linux|Device|nvme' >> $LOGDIR/disk.out &
diskCols = c("rs", "ws", "rkBs", "wkBs", "rrqms", "wrqms", "rrqm",  "wrqm", "rawait", "wawait", "aqusz", "rareqsz", "wareqsz",  "svctm",  "util")
disk <- read.table('disk.out', col.names = diskCols)
disk <- disk %>% select(util)
disk$util <- round(as.numeric(gsub("%","",disk$util)),0)
disk$seconds <- rownames(disk)
disk$execution <- "Graphics Card"

# CPU stats
# mpstat -P all 1 1 | grep -v Average | awk -F'all' '{print $2}' >> $LOGDIR/cpu.out &
cpuCols = c("usr", "nice", "sys", "iowait", "irq", "soft", "steal", "guest", "gnice", "idle")
cpu <- read.table('cpu.out', col.names = cpuCols)
cpu <- cpu %>% select(idle)
# Swapping values to represent utilization instead of idle time
cpu$idle <- round((100 - cpu$idle),0)
# Changing column name from idle to utilization
colnames(cpu)[colnames(cpu) == "idle" ] <- "utilization"
cpu$execution <- "Graphics Card"
cpu$seconds <- rownames(cpu)

# CPU Temp
# sensors | grep Package | awk -F"+" '{print $2}' | awk -F"°" '{print $1}' >> $LOGDIR/cputemp.out &
cpuTemp <- read.table('cputemp.out', col.names = "Temperature")
# cpuTemp$execution <- "Processor"
cpuTemp$execution <- "Graphics Card"
# Adding seconds for CUDA run
cpuTemp$seconds <- rownames(cpuTemp)

# GPU Temp
# nvidia-smi -q -d temperature | grep 'GPU Current' | awk -F":" '{print $2}' | cut -c2-3 >> $LOGDIR/gputemp.out &
gpuTemp <- read.table('gputemp.out', col.names = "Temperature")
gpuTemp$execution <- "Graphics Card"
# Adding seconds for CUDA run
gpuTemp$seconds <- rownames(gpuTemp)

### CPU run ###
setwd('~/Documents/datascience/finalproject/cpulog')
# Memory stats
memCols = c("measurement", "total", "used", "free", "shared", "buffers", "cache", "available")
c_memory <- read.table('memory.out', col.names = memCols)
c_memory <- c_memory %>% select(-measurement)

# Disk stats
diskCols = c("rs", "ws", "rkBs", "wkBs", "rrqms", "wrqms", "rrqm",  "wrqm", "rawait", "wawait", "aqusz", "rareqsz", "wareqsz",  "svctm",  "util")
c_disk <- read.table('disk.out', col.names = diskCols)
c_disk <- c_disk %>% select(util)
c_disk$util <- round(as.numeric(gsub("%","",c_disk$util)),0)
c_disk$seconds <- rownames(c_disk)
c_disk$execution <- "Processor"

# CPU stats
cpuCols = c("usr", "nice", "sys", "iowait", "irq", "soft", "steal", "guest", "gnice", "idle")
c_cpu <- read.table('cpu.out', col.names = cpuCols)
c_cpu <- c_cpu %>% select(idle)
c_cpu$execution <- "Processor"
c_cpu$seconds <- rownames(c_cpu)
c_cpu$idle <- round((100 - c_cpu$idle),0)
colnames(c_cpu)[colnames(c_cpu) == "idle"] <- "utilization"

# CPU Temp
c_cpuTemp <- read.table('cputemp.out', col.names = "Temperature")
c_cpuTemp$execution <- "Processor"
# Adding  seconds as a column
c_cpuTemp$seconds <- rownames(c_cpuTemp)

# GPU Temp
c_gpuTemp <- read.table('gputemp.out', col.names = "Temperature")
# c_gpuTemp$execution <- "Graphics Card"
c_gpuTemp$execution <- "Processor"
# Adding seconds as a clolumn
c_gpuTemp$seconds <- rownames(c_gpuTemp)

# Joining GPU temperatures from the two runs into one data frame
GPU_TEMP <- bind_rows(gpuTemp, c_gpuTemp)

# Joining CPU temperatures from the two runs into one data frame
CPU_TEMP <- bind_rows(cpuTemp, c_cpuTemp)

# Joining disk utilization from the two runs into one data frame
DISK <- bind_rows(disk, c_disk)

# Joining CPU utilization from the two runs into one data frame
CPU <- bind_rows(cpu, c_cpu)

# Keeping only used memory column from both CPU and CUDA runs
memory <- memory %>% select(used,total)
colnames(memory) <- c("Memory","Total")
# Representing memory as percent of total and keeping whole numbers only
memory$Memory <- round((memory$Memory / memory$Total)*100,0)
memory$execution <- "Graphics Card"

# Adding observations (seconds) as a separate column
memory$seconds <- rownames(memory)

c_memory <- c_memory %>% select(used,total)
colnames(c_memory) <- c("Memory","Total")
# Representing memory as percent of total and keeping whole numbers only
c_memory$Memory <- round((c_memory$Memory / c_memory$Total)*100,0)
c_memory$execution <- "Processor"

# Adding observations (seconds) as a separate column
c_memory$seconds <- rownames(c_memory)

# Joining memory utilization from the two runs into one data frame
MEM <- bind_rows(memory, c_memory)

setwd('~/Documents/datascience/finalproject')

# Merging all of the data frames into one
ALL <- Reduce(function(...) merge(..., by=c("seconds","execution"), all.x=TRUE), list(MEM, CPU, DISK, CPU_TEMP, GPU_TEMP))
colnames(ALL) <- c("seconds", "execution", "Memory Utilization", "TotalMem", "Processor Utilization", "Disk Utilization", "Processor Temperature", "Graphics Temperature")
ALL <- ALL %>% select(-TotalMem)
# Converting temperatures to percentage. 98C can be considered maximum for both CPU and GPU
ALL$`Processor Temperature` <- round((ALL$`Processor Temperature` / 98 )*100,0)
ALL$`Graphics Temperature` <- round((ALL$`Graphics Temperature` / 98 )*100,0)

# Converting to long format for easy graphing
ALL <- ALL %>% gather(key="Hardware",value="Utilization", c(-execution,-seconds))

# Saving into an RDS file to later load into R Shiny global.R
saveRDS(ALL, 'shinyapp/data/ALL.RDS')
