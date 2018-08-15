.PHONY: help
help:
	@echo "dev"
	@echo "build"
	@echo "deploy"

.PHONY: dev
dev:
	hugo -D server --disableFastRender

.PHONY: build
build:
	hugo

.PHONY: deploy
deploy: build
	firebase deploy