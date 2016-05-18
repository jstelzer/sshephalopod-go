#!/usr/bin/env make -f

export GOPATH = $(CURDIR):$(CURDIR)/vendor

.PHONY: devel

CONFIG_BUCKET=sshephalopod-config-bucket
KEYPAIR_BUCKET=sshephalopod-keypair-bucket
DOMAIN=sshephalopod-service-domain.com
IDP_METADATA=https://somewhere.okta.com/app/somejumbleofcharacters/sso/saml/metadata

default: devel

all:
	@echo "use 'make build' to build sshephalopod components"
	@echo "use 'make deploy' to deploy sshephalopod"

build:
	make -C apigateway build

deploy:
	echo something > /tmp/api-gw.id
	IDP_METADATA=$(IDP_METADATA) CONFIG_BUCKET=$(CONFIG_BUCKET) KEYPAIR_BUCKET=$(KEYPAIR_BUCKET) DOMAIN=$(DOMAIN) make -C lambda deploy
	@echo "Deploying API ..."
	make -s -C apigateway deploy > /tmp/api-gw.id
	@echo "Deployed API"
	IDP_METADATA=$(IDP_METADATA) CONFIG_BUCKET=$(CONFIG_BUCKET) KEYPAIR_BUCKET=$(KEYPAIR_BUCKET) DOMAIN=$(DOMAIN) make -C lambda deploy
	rm /tmp/api-gw.id

build-docker:
	docker build -t sshephalopod-deploy --force-rm=true .

deploy-docker:
	docker run -it $(shell echo "$${!AWS_*}" | sed -e 's/AWS/-e AWS/g') sshephalopod-deploy

bin/gb:
	go build -o bin/gb github.com/constabulary/gb/cmd/gb

./bin/server: src/ vendor
	go build -o bin/server server

devel: ./bin/server
	./bin/server

doc:
	godoc -http :6060
