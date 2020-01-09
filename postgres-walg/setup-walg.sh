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
echo "$AWS_S3_FORCE_PATH_STYLE" > /etc/wal-g.d/env-archive/AWS_S3_FORCE_PATH_STYLE
echo "$WALG_S3_CA_CERT_FILE" > /etc/wal-g.d/env-archive/WALG_S3_CA_CERT_FILE

# Setup the archive wal-g configuration
echo "wal_level = archive" >> /var/lib/postgresql/data/postgresql.conf
echo "archive_mode = on" >> /var/lib/postgresql/data/postgresql.conf
echo "archive_command = 'envdir /etc/wal-g.d/env-archive /usr/local/bin/wal-g wal-push %p'" >> /var/lib/postgresql/data/postgresql.conf
echo "archive_timeout = 60" >> /var/lib/postgresql/data/postgresql.conf
echo "restore_command = '/usr/bin/envdir /etc/wal-g.d/env-restore /usr/local/bin/wal-g wal-fetch \"%f\" \"%p\"'" >> /var/lib/postgresql/data/postgresql.conf

chown -R postgres:postgres /etc/wal-g.d
