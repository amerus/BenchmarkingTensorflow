#!/bin/bash
python3 /home/motorns/.local/lib/python3.6/site-packages/tensorflow/models/research/object_detection/export_inference_graph.py --pipeline_config_path /home/motorns/Documents/datascience/finalproject/waldo/pipeline.config --trained_checkpoint_prefix /home/motorns/Documents/datascience/finalproject/waldo/localTrainingGPU/model.ckpt-6245 --output_directory /home/motorns/Documents/datascience/finalproject/waldo/inferenceGraphGPU
