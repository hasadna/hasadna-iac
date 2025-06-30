#!/usr/bin/env bash

set -euo pipefail

if [ "$1" == "initialize" ]; then
  exec docker run --pull always -it --network host \
    -v `pwd`:/home/atlantis/hasadna-iac ghcr.io/hasadna/hasadna-iac/atlantis:latest "$@"
elif [ -e "/etc/hasadna/iac.env" ]; then
  exec docker run --pull always -it --network host \
    --env-file /etc/hasadna/iac.env \
    -v `pwd`:/home/atlantis/hasadna-iac ghcr.io/hasadna/hasadna-iac/atlantis:latest "$@"
else
  echo Run initialize first and create /etc/hasadna/iac.env
  exit 1
fi
