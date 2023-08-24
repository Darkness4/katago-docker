#!/bin/sh

SCRIPTPATH="$(dirname "$(realpath "$0")")"

podman run --rm -i \
  --device nvidia.com/gpu=all \
  --group-add keep-groups \
  -v "$SCRIPTPATH/default_gtp.cfg:/app/default_gtp.cfg:ro" \
  -v "$SCRIPTPATH/default_model.bin.gz:/app/default_model.bin.gz" \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  docker.io/darkness4/katago:latest \
  $@
