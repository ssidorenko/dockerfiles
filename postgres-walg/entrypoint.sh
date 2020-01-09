#!/bin/bash

set -e

if [ "$1" = 'postgres' ]; then

  if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo $PGDATA/PG_VERSION does not exist
  else
    echo $PGDATA/PG_VERSION exist, ensuring wal-e is set to run
    . ./docker-entrypoint-initdb.d/01-setup-walg.sh
  fi

  /usr/local/bin/docker-entrypoint.sh $1
fi

exec "$@"
