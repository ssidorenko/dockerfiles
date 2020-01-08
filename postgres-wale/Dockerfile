FROM golang as builder
RUN apt update && apt install git make
RUN go get github.com/wal-g/wal-g; cd $GOPATH/src/github.com/wal-g/wal-g && make install && make deps && make pg_build

# adapted from https://github.com/mcolyer/docker-postgres-wale
FROM postgres:12

MAINTAINER Semion Sidorenko
COPY --from=builder /usr/local/go/bin/wal-g  /usr/local/bin

RUN mkdir -p /etc/wal-g.d/ && chown postgres.postgres /etc/wal-g.d/
ADD fix-acl.sh /docker-entrypoint-initdb.d/
ADD setup-walg.sh /docker-entrypoint-initdb.d/
