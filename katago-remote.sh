#!/bin/sh
# katago-remote.sh

set -e

SCRIPTPATH="$(dirname "$(realpath "$0")")"

# Change this if you want to use an another model, see https://katagotraining.org
RELEASE=kata1-b18c384nbt-s7192213760-d3579182099

# Copy config file to remote server
scp "$SCRIPTPATH/default_gtp.cfg" remote-user@remote-machine:/tmp/default_gtp.cfg

ssh remote-user@remote-machine "set -e
rm -f /tmp/katago.sqsh
enroot remove -f -- katago || true
enroot import -o /tmp/katago.sqsh -- docker://registry-1.docker.io#darkness4/katago:latest
enroot create -n katago -- /tmp/katago.sqsh
if [ ! -f /tmp/default_model.bin.gz ]; then
  curl -fsSL https://media.katagotraining.org/uploaded/networks/models/kata1/$RELEASE.bin.gz -o /tmp/default_model.bin.gz
fi

enroot start  \
  --mount /tmp/default_gtp.cfg:/app/default_gtp.cfg:ro,x-create=file,bind \
  --mount /tmp/default_model.bin.gz:/app/default_model.bin.gz:ro,x-create=file,bind \
  katago \
  $@"
