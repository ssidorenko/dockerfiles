#!/bin/bash

# Restore from the latest backup if RESTORE_S3_PREFIX is set and data dir is empty
if [ "$RESTORE_S3_PREFIX" != "" ] && [ -s "$PGDATA/PG_VERSION" ]; then
  echo "Restoring backup"
  mkdir -p /etc/wal-g.d/env-restore
  cp /etc/wal-g.d/env-archive/* /etc/wal-g.d/env-restore/
  echo "$RESTORE_S3_PREFIX" > /etc/wal-g.d/env-restore/WALG_S3_PREFIX

  if [ ! -f /var/lib/postgresql/data/recovery.done ]; then
    /usr/lib/postgresql/$PG_MAJOR/bin/pg_ctl -D "$PGDATA" -m immediate stop
    if /usr/bin/envdir /etc/wal-g.d/env-restore /usr/local/bin/wal-g backup-fetch /tmp/pgdata LATEST; then
        rm -rf $PGDATA/*
        mv /tmp/pgdata/* $PGDATA/
        touch /var/lib/postgresql/data/recovery.signal
        /usr/lib/postgresql/$PG_MAJOR/bin/pg_ctl -D "$PGDATA" -o "-c listen_addresses=''" start -t 600

        echo "Resetting Password"
        echo "ALTER USER \"$POSTGRES_USER\" WITH SUPERUSER PASSWORD '$POSTGRES_PASSWORD';" | psql --username postgres
        echo "Complete"
    else
        echo "Empty data folder but no backup to restore from! Creating a new database."
    fi
  fi
fi
