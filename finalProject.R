library(tidyr)
library(ggplot2)
library(jsonlite)
library(tibble)
library(dplyr)
setwd('~/Documents/datascience/finalproject/gpulog')

# GPU run
# Memory stats
# free -w -m -s 1 -c 1 | egrep -v 'Swap|total' >> $LOGDIR/memory.out
memCols = c("measurement", "total", "used", "free", "shared", "buffers", "cache", "available")
memory <- read.table('memory.out', col.names = memCols)
memory <- memory %>% select(-measurement)

# Disk stats
# iostat -xyh -d /dev/nvme0n1p2 1 1 | egrep -v 'Linux|Device|nvme' >> $LOGDIR/disk.out
diskCols = c("rs", "ws", "rkBs", "wkBs", "rrqms", "wrqms", "rrqm",  "wrqm", "rawait", "wawait", "aqusz", "rareqsz", "wareqsz",  "svctm",  "util")
disk <- read.table('disk.out', col.names = diskCols)
disk <- disk %>% select(util)
disk$util <- as.numeric(gsub("%","",disk$util))
disk$seconds <- rownames(disk)
disk$execution <- "Graphics Card"

# CPU stats
# mpstat -P all 1 1 | grep -v Average | awk -F'all' '{print $2}' >> $LOGDIR/cpu.out &
cpuCols = c("usr", "nice", "sys", "iowait", "irq", "soft", "steal", "guest", "gnice", "idle")
cpu <- read.table('cpu.out', col.names = cpuCols)
cpu <- cpu %>% select(idle)
# Swapping values to represent utilization instead of idle time
cpu$idle <- 100 - cpu$idle
# Changing column name from idle to utilization
colnames(cpu)[colnames(cpu) == "idle" ] <- "utilization"
cpu$execution <- "Graphics Card"
cpu$seconds <- rownames(cpu)

# CPU Temp
# sensors | grep Package | awk -F"+" '{print $2}' | awk -F"°" '{print $1}' >> $LOGDIR/cputemp.out
cpuTemp <- read.table('cputemp.out', col.names = "Temperature")
cpuTemp$execution <- "Processor"
# Adding seconds for CUDA run
cpuTemp$seconds <- rownames(cpuTemp)

# GPU Temp
# nvidia-smi -q -d temperature | grep 'GPU Current' | awk -F":" '{print $2}' | cut -c2-3 >> $LOGDIR/gputemp.out
gpuTemp <- read.table('gputemp.out', col.names = "Temperature")
gpuTemp$execution <- "Graphics Card"
# Adding seconds for CUDA run
gpuTemp$seconds <- rownames(gpuTemp)

# CPU run
setwd('~/Documents/datascience/finalproject/cpulog')
# Memory stats
memCols = c("measurement", "total", "used", "free", "shared", "buffers", "cache", "available")
c_memory <- read.table('memory.out', col.names = memCols)
c_memory <- c_memory %>% select(-measurement)

# Disk stats
diskCols = c("rs", "ws", "rkBs", "wkBs", "rrqms", "wrqms", "rrqm",  "wrqm", "rawait", "wawait", "aqusz", "rareqsz", "wareqsz",  "svctm",  "util")
c_disk <- read.table('disk.out', col.names = diskCols)
c_disk <- c_disk %>% select(util)
c_disk$util <- as.numeric(gsub("%","",c_disk$util))
c_disk$seconds <- rownames(c_disk)
c_disk$execution <- "Processor"

# CPU stats
cpuCols = c("usr", "nice", "sys", "iowait", "irq", "soft", "steal", "guest", "gnice", "idle")
c_cpu <- read.table('cpu.out', col.names = cpuCols)
c_cpu <- c_cpu %>% select(idle)
c_cpu$execution <- "Processor"
c_cpu$seconds <- rownames(c_cpu)
c_cpu$idle <- 100 - c_cpu$idle
colnames(c_cpu)[colnames(c_cpu) == "idle"] <- "utilization"

# CPU Temp
c_cpuTemp <- read.table('cputemp.out', col.names = "Temperature")
c_cpuTemp$execution <- "Processor"
# Adding  seconds as a column
c_cpuTemp$seconds <- rownames(c_cpuTemp)

# GPU Temp
c_gpuTemp <- read.table('gputemp.out', col.names = "Temperature")
c_gpuTemp$execution <- "Graphics Card"
# Adding seconds as a clolumn
c_gpuTemp$seconds <- rownames(c_gpuTemp)

# Joining GPU temperatures from the two runs into one data frame
GPU_TEMP <- bind_rows(gpuTemp, cpuTemp)

# Joining CPU temperatures from the two runs into one data frame
CPU_TEMP <- bind_rows(c_gpuTemp, c_cpuTemp)

# Joining disk utilization from the two runs into one data frame
DISK <- bind_rows(disk, c_disk)

CPU <- bind_rows(cpu, c_cpu)

# Keeping only used memory column from both CPU and CUDA runs
memory <- memory %>% select(used,total)
colnames(memory) <- c("Memory","Total")
# Representing memory as percent of total
memory$Memory <- (memory$Memory / memory$Total)*100
memory$execution <- "Graphics Card"

# Adding observations (seconds) as a separate column
memory$seconds <- rownames(memory)

c_memory <- c_memory %>% select(used,total)
colnames(c_memory) <- c("Memory","Total")
# Representing memory as percent of total
c_memory$Memory <- (c_memory$Memory / c_memory$Total)*100
c_memory$execution <- "Processor"

# Adding observations (seconds) as a separate column
c_memory$seconds <- rownames(c_memory)

MEM <- bind_rows(memory, c_memory)

# plot memory usage versus time for both processor and GPU runs
ggplot(MEM, aes(x=seconds, y=Memory, color=execution)) + geom_smooth(aes(group=execution), method="auto", se=FALSE) + 
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
  ggtitle("Memory Usage")

# plot disk utilization versus time for both processor and GPU runs
ggplot(DISK, aes(x=seconds, y=util, color=execution)) + geom_smooth(aes(group=execution), method="auto", se=FALSE) + 
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
  ggtitle("Disk Utilization")

# plot processor utilization versus time for both processor and GPU runs
ggplot(CPU, aes(x=seconds, y=utilization, color=execution)) + geom_smooth(aes(group=execution), method="auto", se=FALSE) + 
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
  ggtitle("Processor Utilization")

# plot CPU temperature versus time for both processor and GPU runs
ggplot(CPU_TEMP, aes(x=seconds, y=Temperature, color=execution)) + geom_smooth(aes(group=execution), method="auto", se=FALSE) +
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
  ggtitle("Processor Heat Signature")

# plot GPU temperature versus time for both processor and GPU runs
ggplot(GPU_TEMP, aes(x=seconds, y=Temperature, color=execution)) + geom_smooth(aes(group=execution), method="auto", se=FALSE) +
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
  ggtitle("GPU Heat Signature")

setwd('~/Documents/datascience/finalproject')
saveRDS(DISK, 'shinyapp/data/disk.RDS')
saveRDS(CPU, 'shinyapp/data/cpu.RDS')
saveRDS(MEM, 'shinyapp/data/mem.RDS')
saveRDS(CPU_TEMP, 'shinyapp/data/cpuTemp.RDS')
saveRDS(GPU_TEMP, 'shinyapp/data/gpuTemp.RDS')

