#!/bin/sh

podman run --rm -i \
  -v "$(pwd)/default_gtp.cfg:/app/default_gtp.cfg:ro" \
  -v "$(pwd)/default_model.bin.gz:/app/default_model.bin.gz" \
  --security-opt=label=disable \
  --hooks-dir=/usr/share/containers/oci/hooks.d/ \
  docker.io/darkness4/katago:latest \
  $@
