#!/usr/bin/env bash

set -euo pipefail

KEEP_ALIVE_FILE="/etc/hasadna/dev_servers_keepalive"
FORCED_SHUTDOWN_FILE="/etc/hasadna/forced_shutdown"

if [ -f $FORCED_SHUTDOWN_FILE ]; then
  touch $KEEP_ALIVE_FILE
  rm $FORCED_SHUTDOWN_FILE
fi

force_shutdown() {
  echo "${1}, force shutdown"
  touch $FORCED_SHUTDOWN_FILE
  shutdown -h now
  exit 0
}

if [ "$(cat /proc/uptime | cut -d'.' -f1)" -gt 604800 ]; then
  force_shutdown "System uptime is more than 7 days"
fi

if ! [ -f "$KEEP_ALIVE_FILE" ]; then
  force_shutdown "Keep alive file not found"
fi

if [ "$(($(date +%s) - $(stat -c %Y "$KEEP_ALIVE_FILE")))" -gt 86400 ]; then
    force_shutdown "Keep alive file is older than 1 day"
fi
