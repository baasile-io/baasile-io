#!/bin/bash

trap ctrl_c SIGINT

function ctrl_c() {
  echo "INTERRUPTED"
  docker-compose stop
  exit
}

# remove unexpected pids files
rm -rf tmp/pids

# stop previous running Baasile IO local platform
docker-compose stop

# start Baasile IO local platform
echo "Running Baasile IO"
docker-compose -f docker-compose.yml up --build --remove-orphans -d

echo "Running ./scripts/watch_letter_opener.sh"
./scripts/watch_letter_opener.sh