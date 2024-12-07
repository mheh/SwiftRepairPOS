#!/bin/bash
#
#  gen-db.sh
#  SwiftRepairPOS
#
#  Created by Milo Hehmsoth on 12/6/24.
#

## Gather .env variables
ENVFILE=./swiftrepairpos/.env
if [ -f "$ENVFILE" ]
then
  export $(cat $ENVFILE | sed 's/#.*//g' | xargs)
fi

docker run -d --name swift-repair-pos-test \
  -e POSTGRES_USER=$(echo $POSTGRES_USER) -e POSTGRES_PASSWORD=$(echo $POSTGRES_PASSWORD) \
  -p 5433:5432 postgres:latest -c log_statement=all
docker run -d --name swift-repair-pos \
  -e POSTGRES_USER=$(echo $POSTGRES_USER) -e POSTGRES_PASSWORD=$(echo $POSTGRES_PASSWORD) \
  -p 5432:5432 postgres:latest -c log_statement=all
