#### Gathering and Analyzing Hardware Performance Data During Deep Network Training
### Tensorflow, Object Detection, Faster R-CNN with Inception, Bash Script, and R Shiny
### Overview
   The project focuses on collecting and analyzing hardware benchmarks while training a deep learning network. Training deep learning networks is a resource-intensive and time-consuming process. Building a well-performing pipeline requires identifying low throughput areas and mitigating them with either software tuning or hardware upgrades. Low throughput areas depend on the variability of chosen models, data types, and individual programming styles. Objective benchmark measurement is necessary in order to successfully address heavy system load and uneven utilization of the underlying components. The project consists of a Bash shell script, which collects five system metrics: processor temperature, processor utilization, disk input/output utilization, memory usage, and GPU temperature. Each metric is collected while training Tensorflow's object detection (Faster R-CNN) model to look for Waldo. The metrics are visualized via an interactive R Shiny application.
### Motivation
#### General Motivation
System Administration and Engineering is a profession tasked with continuous evaluation and improvement of system performance. Kernel and end-user processes generate utilization spikes. Frequently, the spikes are uneven with a particular system resource causing a system-wide slowdown. Shared servers used for training deep learning networks are in need of constant optimization, which is frequently unique to a specific training type. Having a shell script, which can collect system utilization paired with an interactive R Shiny application will help System Engineers perform custom infrastructure tuning.
#### Specific Motivation
Currently, I am a Senior Systems Administrator at a research university. My infrastructure has been expanding. I am involved in helping laboratories collect video data and use Tensorflow (DeepLabCut) for video analysis. I am frequently asked if investing in a CUDA-compatible graphics card will accelerate network training. The obvious answer is, "yes, it will". However, I always wanted to make this answer clear and quantifiable. Dedicated GPU units are expensive. They consume more electricity and generate additional heat. However, when dealing with Tensorflow and object detection models, do they accelerate the research process pipeline?
### Null and Alternative Hypotheses

**Null Hypothesis**
#### Part A:
   Training Tensorflow deep neural network on the CPU vs. the GPU does not yield any quantifiably observable diffirences. Hardware utilization is objectively the same. 
#### Part B:
   Training Tensorflow object detection model on the CPU vs. the GPU does not accelerate research process. 
**Alternative Hypothesis**
#### Part A:
   Training Tensorflow deep neural network on the CPU vs. the GPU yields different hardware utilization patterns, which are clearly quantifiable and observable.
#### Part B:
   Training Tensorflow object detection model on the CPU vs. GPU has potential to accelerate research process.
### Previous Work
#### Tensorflow Own Benchmarking (limitations)
#### Find Wally
### Data Collection Script
### Tested Hardware
### R Shiny Application
### Findings
### Portability and Future Work
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

[Live Demo](https://amerus.shinyapps.io/TensorflowBenchmarking/)
