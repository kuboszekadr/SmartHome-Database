#!/bin/bash

psql -U "$POSTGRES_USER" -W postgres -c "CREATE EXTENSION pgagent"
psql -f src/data.sql -U "$POSTGRES_USER" 