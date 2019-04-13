#!/bin/bash

# Remove logs from the previous run. It will generate errors on first run.
rm /home/motorns/Documents/datascience/finalproject/gpulog/*.out

# Check if log directory exists. If does not, create it.
LOGDIR=$(pwd)/gpulog
if [ ! -d $LOGDIR ]; then
    mkdir $LOGDIR
fi

# set environment variables needed for benchmarks to execute. PYTHONPATH is the location of tensorflow models. LD_LIBRARY_PATH points to libcupti library.
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64

# benchmark execution for a speific amount of time. In our case, run for 5 minutes.
timeout 15m python3 /home/motorns/.local/lib/python3.6/site-packages/tensorflow/models/research/object_detection/model_main.py --pipeline_config_path=/home/motorns/Documents/datascience/finalproject/waldo/pipeline.config --model_dir=/home/motorns/Documents/datascience/finalproject/waldo/localTrainingGPU &

# sleeping for 5 seconds while the benchmark script performs warm-up procedure
sleep 5

# saving process id of the benchmark script into a variable
PID=`ps -ef|grep 'model_main.py' | head -1 | awk -F" " '{print $2}'`

# while the process id of the benchmark script exists, collect data
while test -d /proc/$PID; do
     # use sensors from lm-sensors package for CPU temperature
     sensors | grep Package | awk -F"+" '{print $2}' | awk -F"°" '{print $1}' >> $LOGDIR/cputemp.out &
     PScputemp=$!
     # use nvidia-smi for GPU temperature
     nvidia-smi -q -d temperature | grep 'GPU Current' | awk -F":" '{print $2}' | cut -c2-3 >> $LOGDIR/gputemp.out &
     PSgputemp=$!
     # use mpstat for CPU utilization
     mpstat -P all 1 1 | grep -v Average | awk -F'all' '{print $2}' >> $LOGDIR/cpu.out &
     PScpu=$!
     # use iostat for disk utilization 
     iostat -xyh -d /dev/nvme0n1p2 1 1 | egrep -v 'Linux|Device|nvme' >> $LOGDIR/disk.out &
     PSdisk=$!
     # use free for memory utilization
     free -w -m -s 1 -c 1 | egrep -v 'Swap|total' >> $LOGDIR/memory.out &
     PSmem=$!
     ITER+=1
     # wait for all of the background processes to complete before continuing with data collection. keeping data collection synchronized.
     wait $PScputemp $PSgputemp $PSdisk $PSmem $PScpu
done
