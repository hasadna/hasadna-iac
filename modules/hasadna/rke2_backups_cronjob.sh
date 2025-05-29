#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/.kopia.env"
"$(dirname "$0")/kopia_connect.sh"
if ! kopia snapshot create $(cat "$(dirname "$0")/.kopia.backup_paths"); then
  echo "Kopia snapshot creation failed"
  exit 1
fi
echo "Kopia snapshots created successfully"
for backup_path in $(cat "$(dirname "$0")/.kopia.backup_paths"); do
  if ! [ -d "$backup_path" ]; then
    echo "Backup path $backup_path does not exist"
    exit 1
  fi
done
echo "All backup paths verified successfully"
if ! curl "${STATUSCAKE_HEATBEAT_URL}"; then
  echo "Failed to send StatusCake heartbeat"
  exit 1
fi
echo "StatusCake heartbeat sent successfully"
echo "Great Success!"
