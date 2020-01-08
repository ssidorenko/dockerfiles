NAME   := lsirepfl/postgres-wale
TAG    := $$(git log -1 --pretty=%h)
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

.PHONY:build
build:
	@echo ${IMG}
	@docker build -t ${IMG} .
	@docker tag ${IMG} ${LATEST}
 
push: 
	@docker push ${NAME}
 
