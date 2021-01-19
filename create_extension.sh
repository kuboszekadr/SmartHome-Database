#!/bin/bash

psql -U "$POSTGRES_USER" -W postgres -c "CREATE EXTENSION pgagent"
psql -f src/model.sql -U "$POSTGRES_USER" 
psql -f src/data.sql -U "$POSTGRES_USER" 