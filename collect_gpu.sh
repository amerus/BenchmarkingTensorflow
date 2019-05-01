#!/bin/bash
# Written by Sergey Motorny. April 2019. Collecting hardware utilization metrics while training Tensorflow to look for Waldo.
# Dedicated training on GPU. CPU version of the script is also available.

# Setting project home directory
WHDIR="/home/motorns/Documents/datascience/finalproject"

# Setting log directory for collected hardware metrics
LOGDIR=$WHDIR/gpulog

# Setting timeout vallue for network training time on GPU
RUNTIME='75m'

# Setting location of the main Tensorflow model training file for Object Detection
MODEL_MAIN='/home/motorns/.local/lib/python3.6/site-packages/tensorflow/models/research/object_detection'

# Setting home directory for model training (checkpoints, etc.)
MODEL_DIR=$WHDIR/waldo/localTrainingGPU

# Setting pipeline file location for the model
PIPELINE=$WHDIR/waldo

# Remove logs from the previous run
if [ ! -z "$(ls $LOGDIR)" ]; then
   list=$(find $LOGDIR -maxdepth 2 -name '*.out')
   for i in $list
   do
      rm $i
   done
fi

# Checking if the log directory exists. If not, creating it.
if [ ! -d $LOGDIR ]; then
    mkdir $LOGDIR
fi

# Removing checkpoints from the previous run
if [ ! -z "$(ls $MODEL_DIR)" ]; then
   list=$(find $MODEL_DIR -maxdepth 2) 
   for i in $list; do
     rm $i
   done
   rmdir $MODEL_DIR/eval_0
fi

# Checking if the model checkpoint directory exists. If not, creating it.
if [ ! -d $MODEL_DIR ]; then
   mkdir $MODEL_DIR
fi

# Setting environment variables needed for Tensorflow. LD_LIBRARY_PATH points to libcupti library.
export LD_LIBRARY_PATH=/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64

# Training the network on GPU. Executing for a fixed amount of runtime.
timeout $RUNTIME python3 $MODEL_MAIN/model_main.py --pipeline_config_path=$PIPELINE/pipeline.config --model_dir=$MODEL_DIR &

# Saving process id of the benchmark script into a variable
PSModel=$!

# Sleeping for 5 seconds while Tensorflow warms up
sleep 5

# While the process id of the training script exists, continue collecting data
while test -d /proc/$PSModel; do
       # Using sensors from lm-sensors package for logging CPU temperature
       sensors | grep Package | awk -F"+" '{print $2}' | awk -F"°" '{print $1}' >> $LOGDIR/cputemp.out &
       PScputemp=$!
       # Using nvidia-smi for logging GPU temperature
       nvidia-smi -q -d temperature | grep 'GPU Current' | awk -F":" '{print $2}' | cut -c2-3 >> $LOGDIR/gputemp.out &
       PSgputemp=$!
       # Using mpstat for logging CPU utilization
       mpstat -P all 1 1 | grep -v Average | awk -F'all' '{print $2}' >> $LOGDIR/cpu.out &
       PScpu=$!
       # Using iostat for logging disk utilization 
       iostat -xyh -d /dev/nvme0n1p2 1 1 | egrep -v 'Linux|Device|nvme' >> $LOGDIR/disk.out &
       PSdisk=$!
       # Using free for logging memory utilization
       free -w -m -s 1 -c 1 | egrep -v 'Swap|total' >> $LOGDIR/memory.out &
       PSmem=$!
       # Waiting for all of the background processes to complete before continuing data collection. Keeping the metrics collection synchronized.
       wait $PScputemp $PSgputemp $PSdisk $PSmem $PScpu
done
PSloop=$!

### Exporting inference graph from collected data. This portion is unique to Object Detection and training to find Waldo. ###

# Settting location of the Object Detection model export inference graph script 
MODEL_INFERENCE='/home/motorns/.local/lib/python3.6/site-packages/tensorflow/models/research/object_detection'

# Setting local inference graph directory
INFERENCE_DIR=$WHDIR/waldo/inferenceGraphGPU

# Checking if the inference graph directory exists. If not, creating it.
if [ ! -d $INFERENCE_DIR ]; then 
   mkdir $INFERENCE_DIR
fi

# Checking if inference graph directory has contents. If does, removing and recreating it.
if [ ! -z "$(ls $INFERENCE_DIR)" ]; then
   list=$(find $INFERENCE_DIR -maxdepth 3)
   for i in $list; do
      rm $i
   done
   rmdir $INFERENCE_DIR/saved_model/variables
   rmdir $INFERENCE_DIR/saved_model
fi

# Finding the last saved checkpoint
LAST_CHECKPOINT=$(ls -ltr $MODEL_DIR | grep -o 'model.ckpt-[0-9]*.meta'| grep -o '[0-9]*'| tail -1)

wait $PSloop

# Exporting the trained model into a reference graph
python3 $MODEL_INFERENCE/export_inference_graph.py --pipeline_config_path $PIPELINE/pipeline.config --trained_checkpoint_prefix $MODEL_DIR/model.ckpt-$LAST_CHECKPOINT --output_directory $INFERENCE_DIR
