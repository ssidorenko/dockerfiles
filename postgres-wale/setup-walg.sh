#!/bin/bash

# Verify required environment variables are set
: "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID does not exist}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY does not exist}"
: "${ARCHIVE_S3_PREFIX:?ARCHIVE_S3_PREFIX does not exist}"

# Assumption: the group is trusted to read secret information
umask u=rwx,g=rx,o=

# Create the archival wal-g environment
mkdir -p /etc/wal-g.d/env-archive
echo "$AWS_SECRET_ACCESS_KEY" > /etc/wal-g.d/env-archive/AWS_SECRET_ACCESS_KEY
echo "$AWS_ACCESS_KEY_ID" > /etc/wal-g.d/env-archive/AWS_ACCESS_KEY_ID
echo "$ARCHIVE_S3_PREFIX" > /etc/wal-g.d/env-archive/WALG_S3_PREFIX
echo "$AWS_ENDPOINT" > /etc/wal-g.d/env-archive/AWS_ENDPOINT

# Setup the archive wal-g configuration
echo "wal_level = archive" >> /var/lib/postgresql/data/postgresql.conf
echo "archive_mode = on" >> /var/lib/postgresql/data/postgresql.conf
echo "archive_command = 'envdir /etc/wal-g.d/env-archive /usr/local/bin/wal-g wal-push %p'" >> /var/lib/postgresql/data/postgresql.conf
echo "archive_timeout = 60" >> /var/lib/postgresql/data/postgresql.conf

# Restore from the latest backup if RESTORE_S3_PREFIX is set
if [ "$RESTORE_S3_PREFIX" != "" ]; then
  mkdir -p /etc/wal-g.d/env-restore
  cp /etc/wal-g.d/env-archive/* /etc/wal-g.d/env-restore/
  echo "$RESTORE_S3_PREFIX" > /etc/wal-g.d/env-restore/WALG_S3_PREFIX

  if [ ! -f /var/lib/postgresql/data/recovery.done ]; then
    pg_ctl -D "$PGDATA" -m immediate stop

    /usr/bin/envdir /etc/wal-g.d/env-restore /usr/local/bin/wal-g backup-fetch --blind-restore /var/lib/postgresql/data/ LATEST
    echo "restore_command = '/usr/bin/envdir /etc/wal-g.d/env-restore /usr/local/bin/wal-g wal-fetch \"%f\" \"%p\"'" >> /var/lib/postgresql/data/recovery.conf
    chown postgres:postgres /var/lib/postgresql/data/recovery.conf

    pg_ctl -D "$PGDATA" -o "-c listen_addresses=''" start -t 600

    echo "Resetting Password"
    psql --username postgres <<EOSQL
      ALTER USER "$POSTGRES_USER" WITH SUPERUSER PASSWORD '$POSTGRES_PASSWORD';
EOSQL
    echo "Complete"
  fi
fi
