.PHONY: help
help:
	@echo "dev"
	@echo "build"
	@echo "deploy"

.PHONY: dev
dev:
	hugo -D server --disableFastRender --buildFuture

.PHONY: build
build:
	hugo

.PHONY: deploy
deploy: build
	./node_modules/.bin/firebase deploy