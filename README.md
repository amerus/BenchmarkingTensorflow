#### Gathering and Analyzing Hardware Performance Data During Deep Network Training
### Tensorflow, Object Detection, Faster R-CNN with Inception, Bash Script, and R Shiny
### Overview
   The project focuses on collecting and analyzing hardware benchmarks while training a deep learning network. Training deep learning networks is a resource-intensive and time-consuming process. Building a well-performing pipeline requires identifying low throughput areas and mitigating them with either software tuning or hardware upgrades. Low throughput areas depend on the variability of chosen models, data types, and individual programming styles. Objective benchmark measurement is necessary in order to successfully address heavy system load and uneven utilization of the underlying components. The project consists of a Bash shell script, which collects five system metrics: processor temperature, processor utilization, disk input/output utilization, memory usage, and GPU temperature. Each metric is collected while training Tensorflow's object detection (faster R-CNN with inception) model to look for Waldo. The metrics are visualized via an interactive R Shiny application.
### Motivation
#### General Motivation
System Administration and Engineering is a profession tasked with continuous evaluation and improvement of system performance. Kernel and end-user processes generate utilization spikes. Frequently, the spikes are uneven with a particular system resource causing a system-wide slowdown. Shared servers used for training deep learning networks are in need of constant optimization, which is frequently unique to a specific training type. Having a shell script, which can collect system utilization paired with an interactive R Shiny application will help System Engineers perform custom infrastructure tuning.
#### Specific Motivation
Currently, I am a Senior Systems Administrator at a research university. My infrastructure has been expanding. I am involved in helping laboratories collect video data and use Tensorflow (DeepLabCut) for video analysis. I am frequently asked if investing in a CUDA-compatible graphics card will accelerate network training. The obvious answer is, "yes, it will". However, I always wanted to make this answer clear and quantifiable. Dedicated GPU units are expensive. They consume more electricity and generate additional heat. However, when dealing with Tensorflow and object detection models, do they accelerate the research process pipeline?
### Null and Alternative Hypotheses

**Null Hypothesis**

**Part A:**
   Training Tensorflow deep neural network on the CPU vs. the GPU does not yield any quantifiably observable diffirences. Hardware utilization is objectively the same. 

**Part B:**
   Training Tensorflow object detection model on the CPU vs. the GPU does not accelerate research process. 
   
**Alternative Hypothesis**

**Part A:**
   Training Tensorflow deep neural network on the CPU vs. the GPU yields different hardware utilization patterns, which are clearly quantifiable and observable.

**Part B:**
   Training Tensorflow object detection model on the CPU vs. GPU has potential to accelerate research process.
### Previous Work
#### Tensorflow Own Benchmarking (limitations)
Tensorflow has several own [benchmark utilities](https://github.com/tensorflow/benchmarks). I have unsuccessfully tried working with them. I was surprised to find very little documentation on how to use these benchmarking instruments. Additionally, I was bewildered by the fact that tf_cnn_benchmark required installation and configuration of Google cloud services. I could not find a good reason to install and configure Google cloud services on my research servers just to benchmark Tensorflow training runs. Finally, it did not seem that anything was collecting disk, memory, processor, and temperature at the same (and equal) time intervaals. Hence, I have finally decided to write my own script.
#### Find Wally
I work at a research facility, which uses Tensorflow for markerless tracking of primates. Rules of engagement dictate that I cannot share or distribute the media collected at the facility. Hence, I had to find a proxy object detection mechanism. Being a dad of two boys, I was elated to stumble upon Tadej Magajna's [HereIsWally](https://github.com/tadejmagajna/HereIsWally) project. There is no harm in working while having fun, is there? 
### Data Collection Script
The script I wrote uses Bourne Again Shell (BASH) to set several variables, train Tensorflow network for a set amount of time, collect hardware metrics, and export the resulting Tensorflow chekpoint into a ready to be used inference database. In theory, it should not be difficult to modify the script to execute a different model or run on a different hardware. In the long run, I'd like to package it into a Docker image together with several pre-configured Tensorflow models. The repository has two versions of the script, since my hypotheses deal with GPU vs. CPU training comparisons. I wanted to have a clear way to run the script (and save the results into different directories). collect_cpu.sh trains the model on the processor while collect_gpu.sh does the same using the GPU. 
### Python Script Modification(s)
#### model_train.py
The GPU card, which was used for this project is GeForce RTX 2070 with Max-Q Design. 
CUDA libraries were failing to load from inside of Tensorflow until I added the following line:

   ```config.gpu_options.allow_growth = True```

Current Tensorflow suppresses output by default, so I also had to add the following two lines to be able to see loss values:
   ```
   tf.logging.set_verbosity(tf.logging.INFO)
   config = tf.ConfigProto()
   sess = tf.Session(config=config)
   ```
I also wanted to save checkpoints every 60 seconds because my shell script ran training script for a limited amount of time (75 minutes). Hence, I added the save_checkpoints_secs=60 parameter: 

   ```config = tf.estimator.RunConfig(model_dir=FLAGS.model_dir, save_checkpoints_secs=60)```

#### find_wally_GPU.sh and find_wally_CPU.sh
These scripts are modified versions of Tadej's [find_wally_pretty.sh](https://github.com/tadejmagajna/HereIsWally/blob/master/find_wally_pretty.py). I wanted to be able to find Waldo in a scripted manner saving output files into a separate directory. Hence, I've added the following to the bottom of the file:

    plt.axis("off")
    fig = ax.imshow(image_np)
    orig = args.image_path
    p = re.compile(r'(\d+\.\w{3}$)')
    m = p.search(orig)
    filename = file_output + m.group(1)
    fig.axes.get_xaxis().set_visible(False)
    fig.axes.get_yaxis().set_visible(False)
    plt.savefig(filename,bbox_inches="tight",pad_inches = 0)
    plt.close()

I also had to import regular expressions and set inference graph location and output directory:
   ```   
   import re

   model_path = '/home/motorns/Documents/datascience/finalproject/waldo/inferenceGraphCPU/frozen_inference_graph.pb'
   file_output = './images/cpu/'
   ```
I modified confidence score to be low, so I could see Tensorflow mistakes:
   ```
   if scores[0][0] < 0.0001:
        sys.exit('Wally not found :(')
   ```
Finally, I was able to run a simple terminal for loop:
   ```
   for i in *jpg; do
      python3 find_wally_GPU.sh $i
   done
   ```
The loop will go through Wally images looking for him and saving the resulting matplotlib figures into files with the same names but corresponding (cpu or gpu) directories.

### Tested Hardware
This script was tested on the following hardware
<table style = "border: none">
  <tr>
     <td colspan=4>
       Gigabyte Aero 15x Laptop
     </td>
  </tr>
  <tr>
    <td>
     Processor
    </td>
    <td>
     RAM
    </td>
    <td>
     Graphics Card
    </td>
    <td>
     Hard Drive
    </td>
  </tr>
  <tr>
    <td>
     Intel 6-core i9-8950HK CPU @ 2.90GHz
    </td>
    <td>
     32 GB, Speed: 2667 MT/s
    </td>
    <td>
     GeForce RTX 2070 with Max-Q Design
    </td>
    <td>
     Intel SSD Pro 7600p/760p/E 6100p Series 
    </td>
  <tr>
  </tr>
</table>

### Conda Environment File

Anaconda environment file contains remnants from trying (and failing) to use Tensorflow's own benchmarking utilities. However, it does work and is needed to train the network. It can be created:
```
   conda env create -f benchmark.yml
```
It will create an environment named bench, which can then be imported:
```
   conda activate bench
```
### R Shiny Application

Every control of the R Shiny application works with every ggplot graph. Selecting several hardware components adds a side-by-side comparison panel. Feel free to inspect interactivity screenshots for visual examples.

### Findings

CPU-trained model was a lot less accurate as seen in the app because 75 minutes of training translated into only 3,421 steps. When training for the same time on the GPU, the model was able to complete 34,264 steps (ten times as many). As also seen in the app, processor utilization is minimal when GPU training is taking place. Hece, in theory, GPU training is beneficial on a shared server. While the graphics card is doing the heavy lifting, the processor is free to perform other tasks. One surprise finding was the difficulty of temperature control during the GPU training run. Both the graphics card and the processor temperatures were climbing steadily with the GPU getting dangerously close to 98 Celsius. Heat damage is a real threat for Tensorflow on GPU.

### Portability and Future Work

Template portability needs work. Ideally, the entire project should be compiled into a Docker image (with docker-compose instructions). Environment variables should control directory structures, run times, and the variables should propagate all the way into application controls and outputs. Models should also be easily swapped with minimal effort.

### Interactivity Screenshots

<table style = "border: none">
  <tr>
    <td> 
      <img src="https://user-images.githubusercontent.com/33165031/57023340-58a7d900-6bf7-11e9-9fd3-ad7af02898b0.gif"> 
    </td>
    <td>
      <img src="https://user-images.githubusercontent.com/33165031/57024705-dd482680-6bfa-11e9-9778-a57bd95e1dc7.gif">
    </td>
  </tr>
  <tr>
    <td>
    <img src="https://user-images.githubusercontent.com/33165031/57023767-85a8bb80-6bf8-11e9-95b0-7b3f15464581.gif">
    </td>
    <td>
    <img src="https://user-images.githubusercontent.com/33165031/57024935-6eb79880-6bfb-11e9-96ff-ee752077383d.gif">
    </td>
  </tr>
</table>

<hr width="50%">

### Live Demo

Click below to see live demo of the final R Shiny App:

   [Tensorflow Benchmarking](https://amerus.shinyapps.io/TensorflowBenchmarking)
