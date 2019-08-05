#!/bin/bash -e

set -o xtrace

SKIP_CLONE=false

if [[ "${SKIP_CLONE}" -eq "false" ]]; then
  # clone repo
  echo Condition is true
else
  echo Condition is false
  exit 1
fi
