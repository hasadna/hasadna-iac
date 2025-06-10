#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/.kopia.env"
kopia repository connect s3 --bucket=$BUCKET --region=$REGION
