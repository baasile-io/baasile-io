#!/bin/bash

if [ -z "$1" ]
then
  echo "Specify Heroku app as first argument"
  exit 1
fi

DUMP_URL=`heroku pg:backups public-url --app $1`

echo "${DUMP_URL}"

if [ ! -z "${DUMP_URL}" ]
then
  curl -o tmp/latest_pg_dump.dump ${DUMP_URL}
fi

docker-compose run baasile_io rails pg_dump:import
