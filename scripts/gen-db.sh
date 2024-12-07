#!/bin/bash
#
#  gen-db.sh
#  SwiftRepairPOS
#
#  Created by Milo Hehmsoth on 12/6/24.
#

## Gather .env variables
ENVFILE=./.env
if [ -f "$ENVFILE" ]
then
  export $(cat $ENVFILE | sed 's/#.*//g' | xargs)
else
  echo "No .env file found, aborting... Run this script in the working directory of this package."
  exit
fi

docker run -d --name swift-repair-pos-test \
  -e POSTGRES_DB=$(echo $DATABASE_NAME) \
  -e POSTGRES_USER=$(echo $DATABASE_USERNAME) \
  -e POSTGRES_PASSWORD=$(echo $DATABASE_PASSWORD) \
  -p 5433:5432 postgres:latest -c log_statement=all
  
docker run -d --name swift-repair-pos \
  -e POSTGRES_DB=$(echo $DATABASE_NAME) \
  -e POSTGRES_USER=$(echo $DATABASE_USERNAME) \
  -e POSTGRES_PASSWORD=$(echo $DATABASE_PASSWORD) \
  -p 5432:5432 postgres:latest -c log_statement=all
