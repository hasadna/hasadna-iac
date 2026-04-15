#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/.kopia.env"
"$(dirname "$0")/kopia_connect.sh"
RES=0
if [ "$(cat .kopia.backup_paths_daily)" != "" ]; then
  if ! kopia snapshot create $(cat "$(dirname "$0")/.kopia.backup_paths_daily"); then
    echo "Kopia daily snapshot creation failed"
    RES=1
  else
    echo "Kopia daily snapshot created successfully"
  fi
  for backup_path in $(cat "$(dirname "$0")/.kopia.backup_paths_daily"); do
    if ! [ -d "$backup_path" ]; then
      echo "Backup path $backup_path does not exist"
      RES=1
    fi
  done
else
  echo "No daily backup paths specified, skipping daily snapshot creation"
fi
if [ "$(date +%u)" -eq 6 ]; then
  echo "Today is Saturday, creating weekly snapshots"
  if [ "$(cat .kopia.backup_paths_weekly)" != "" ]; then
    if ! kopia snapshot create $(cat "$(dirname "$0")/.kopia.backup_paths_weekly"); then
      echo "Kopia weekly snapshot creation failed"
      RES=1
    else
      echo "Kopia weekly snapshot created successfully"
    fi
    for backup_path in $(cat "$(dirname "$0")/.kopia.backup_paths_weekly"); do
      if ! [ -d "$backup_path" ]; then
        echo "Backup path $backup_path does not exist"
        RES=1
      fi
    done
  else
    echo "No weekly backup paths specified, skipping weekly snapshot creation"
  fi
fi
if [ $RES -ne 0 ]; then
  echo "One or more backup operations failed, exiting with error"
  exit 1
else
  echo "All backup operations completed successfully"
fi
if ! curl "${STATUSCAKE_HEATBEAT_URL}"; then
  echo "Failed to send StatusCake heartbeat"
  exit 1
fi
echo "StatusCake heartbeat sent successfully"
echo "Great Success!"
