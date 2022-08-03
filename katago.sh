#!/bin/sh

docker run --rm --gpus all -i \
  -v "$(pwd)/default_gtp.cfg:/app/default_gtp.cfg:ro" \
  -v "$(pwd)/default_model.bin.gz:/app/default_model.bin.gz" \
  --device /dev/nvidia0 --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools --device /dev/nvidiactl \
  docker.io/darkness4/katago:latest \
  $@
