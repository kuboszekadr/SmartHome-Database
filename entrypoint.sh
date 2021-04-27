#!/bin/bash

echo "Starting Postgres services..."

# start pgagent job
/usr/bin/pgagent dbname=postgres user="postgres"
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start process: pg_agent: $status"
  exit $status
fi

# start postgres
postgres -c config_file=/etc/postgresql/11/main/postgresql.conf
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start second process: $status"
  exit $status
fi

echo "Init finished"