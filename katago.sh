#!/bin/sh

docker run --rm --gpus all -i \
  -v "$(pwd)/default_gtp.cfg:/app/default_gtp.cfg:ro" \
  -v "$(pwd)/default_model.bin.gz:/app/default_model.bin.gz" \
  --device /dev/nvidia0 --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools --device /dev/nvidiactl \
  darkness4/katago:cuda11.4.2-cudnn8-ubuntu20.04-trt8.2.0.6-ea \
  $@
