# adapted from https://github.com/mcolyer/docker-postgres-wale
FROM postgres:12

MAINTAINER Semion Sidorenko

RUN apt-get update && apt-get install -y python3-pip lzop pv && pip3 --no-cache-dir install wal-e[aws]  && \
   apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /etc/wal-e.d/ && chown postgres.postgres /etc/wal-e.d/
ADD fix-acl.sh /docker-entrypoint-initdb.d/
ADD setup-wale.sh /docker-entrypoint-initdb.d/
