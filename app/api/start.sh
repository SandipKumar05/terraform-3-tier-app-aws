#!/bin/bash
export PORT=3001
export DBUSER=sandip
export DBPASS=qwerty123
export DBHOST=api-postgresql.cdqm8mcee0oh.us-east-1.rds.amazonaws.com
export DBPORT=5432
export DB=postgres

npm start 2>&1 | tee /home/ubuntu/web.log