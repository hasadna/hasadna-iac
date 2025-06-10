#!/usr/bin/env bash

set -euo pipefail

if ! which unzip 2>&1 >/dev/null; then
  apt update && apt install -y unzip
fi
if ! which pipx 2>&1 >/dev/null; then
  apt update && apt install -y pipx python3-pip
fi

exec pipx run -qq --spec https://github.com/hasadna/hasadna-k8s/archive/refs/heads/master.zip hasadna-k8s "$@"
