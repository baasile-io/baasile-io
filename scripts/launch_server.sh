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

if [ "$?" == "0" ]
then

  echo "Waiting for http://baasile-io-demo.dev:3042 to respond..."
  until curl --output /dev/null --silent --head --fail "http://baasile-io-demo.dev:3042"
  do
    echo "Waiting for http://baasile-io-demo.dev:3042 to respond..."
    sleep 10
  done

  echo "Running ./scripts/watch_letter_opener.sh"
  ./scripts/watch_letter_opener.sh

fi