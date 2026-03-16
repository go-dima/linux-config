#!/bin/bash
# deploy-config.sh calls bare `uname` (no flags) for OS detection.
# We also intercept `uname -s` for any callers that use that form.
if [ $# -eq 0 ] || [ "$1" = "-s" ]; then
  echo "Darwin"
else
  /usr/bin/uname "$@"
fi
