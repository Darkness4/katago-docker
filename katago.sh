#!/bin/sh

set -e

SCRIPTPATH="$(dirname "$(realpath "$0")")"

RELEASE=kata1-b18c384nbt-s7192213760-d3579182099

if [ ! -f default_model.bin.gz ]; then
  curl -fsSL https://media.katagotraining.org/uploaded/networks/models/kata1/$RELEASE.bin.gz -o "$SCRIPTPATH/default_model.bin.gz"
fi

podman run --rm -it \
  --device nvidia.com/gpu=all \
  --group-add keep-groups \
  -v "$SCRIPTPATH/default_gtp.cfg:/app/default_gtp.cfg:ro" \
  -v "$SCRIPTPATH/default_model.bin.gz:/app/default_model.bin.gz:ro" \
  docker.io/darkness4/katago:latest \
  $@
