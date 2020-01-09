# adapted from https://github.com/mcolyer/docker-postgres-wale
FROM postgres:12

MAINTAINER Semion Sidorenko
RUN apt-get update --fix-missing && \
    apt-get install -y daemontools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ADD wal-g.linux-amd64.tar.gz /usr/local/bin/
RUN mkdir -p /etc/wal-g.d/ && chown postgres.postgres /etc/wal-g.d/
ADD sos-certs.pem /etc/wal-g.d/
ADD fix-acl.sh /docker-entrypoint-initdb.d/
ADD setup-walg.sh /docker-entrypoint-initdb.d/01-setup-walg.sh
ADD restore-walg.sh /docker-entrypoint-initdb.d/02-restore-walg.sh
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres"]
