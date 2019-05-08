#### Gathering and Analyzing Hardware Performance Data During Deep Network Training
### Tensorflow, Object Detection, Faster R-CNN with Inception, Bash Script, and R Shiny
### Overview
   The project focuses on collecting and analyzing hardware benchmarks while training a deep learning network. Training deep learning networks is a resource-intensive and time-consuming process. Building a well-performing pipeline requires identifying low throughput areas and mitigating them with either software tuning or hardware upgrades. Low throughput areas depend on the variability of chosen models, data types, and individual programming styles. Objective benchmark measurement is necessary in order to successfully address heavy system load and uneven utilization of the underlying components. The project consists of a Bash shell script, which collects five system metrics: processor temperature, processor utilization, disk input/output utilization, memory usage, and GPU temperature. Each metric is collected while training Tensorflow's object detection (Faster R-CNN) model to look for Waldo. The metrics are visualized via an interactive R Shiny application.
### Motivation
### Null and Alternative Hypotheses

**Null Hypothesis**
   Training Tensorflow deep neural network on the CPU and the GPU does not yield any quantifiably observable diffirences. Hardware utilization is objectively the same.

**Alternative Hypothesis**
   Training Tensorflow deep neural network on the CPU and the GPU yields different hardware utilization patterns, which are clearly quantifiable and observable.
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
