help:
	@echo "dev"
	@echo "build"
dev:
	hugo -D server --disableFastRender
build:
	hugo

.PHONY: dev build help