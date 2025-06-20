#!/bin/bash

set -euo pipefail

cd /home/atlantis
export TEMPDIR=$(mktemp -d)
trap 'echo "Cleaning up..."; rm -rf $TEMPDIR' EXIT
(
  . .bash_env
  python hasadna-iac/bin/docker_entrypoint.py "$@"
)
if [ "$1" == "shell" ]; then
  . $TEMPDIR/env
  cd /home/atlantis/hasadna-iac
  bash
fi
