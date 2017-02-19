#!/bin/bash

# remove unexpected pids files
rm -rf tmp/pids

# stop previous running Baasile IO local platform
docker-compose stop

# start Baasile IO local platform
docker-compose -f docker-compose.yml up --build --remove-orphans