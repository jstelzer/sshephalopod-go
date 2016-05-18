ZIPFILE=sshephalopod
SOURCES=SigningPreAuth.js \
	Metadata.js \
	CreateCAKeypair.js \
	SigningRequestPassport.js \
	LookupMetadata.js \
	saml_sp.key saml_sp.crt idp.crt \
	bin \
	keys
ZIP_ARGS="-9rq"
REV=$(shell git show-ref --head -s ^HEAD)

CONFIG_BUCKET?=sshephalopod-code-tokyo
DOMAIN?=fridayclub.realestate.com.au
KEYPAIR_BUCKET?=sshephalopod-keys-tokyo
IDP_METADATA?=https://rea.okta.com/app/exk13t140gl0MQ5sX1d8/sso/saml/metadata

CONFIG=config.json
KEYPAIR_NAME=$(DOMAIN)-sshephalopod-ca

.PHONY: deploy

all:
	@echo "make upload: publish zipfile to S3 in DEV"
	@echo "make deploy: update the stacks in DEV"

zip: $(SOURCES) node_modules
	rm -f $(ZIPFILE).zip
	zip $(ZIP_ARGS) $(ZIPFILE).zip $(SOURCES) node_modules

upload: zip
	aws s3 cp $(ZIPFILE).zip s3://$(CONFIG_BUCKET)/$(ZIPFILE)-$(REV).zip
	aws s3 cp $(CONFIG) s3://$(KEYPAIR_BUCKET)/$(CONFIG)

deploy: upload onlydeploy

onlydeploy:
	./deploy.sh $(CONFIG_BUCKET) $(ZIPFILE)-$(REV).zip \
		$(IDP_METADATA) $(DOMAIN) $(KEYPAIR_BUCKET) $(KEYPAIR_NAME)
