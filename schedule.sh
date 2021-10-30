#!/usr/bin/env bash

# enable (-x) debug mode for verbose output
# https://sipb.mit.edu/doc/safe-shell/
#set -eufx -o pipefail

# Run scheduler (poor man crontab ;)
while [[ true ]]
do
  cd /app && php scrapper.php
  sleep 60
done
