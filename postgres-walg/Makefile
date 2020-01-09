NAME   := lsirepfl/postgres-walg
TAG    := $$(git log -1 --pretty=%h)
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

.PHONY:build
build:
	@echo ${IMG}
	@curl -LO https://github.com/wal-g/wal-g/releases/download/v0.2.14/wal-g.linux-amd64.tar.gz
	@curl -LO https://www.exoscale.com/static/files/sos-certs.pem
	@docker build -t ${IMG} .
	@docker tag ${IMG} ${LATEST}
 
push: 
	@docker push ${NAME}
 
