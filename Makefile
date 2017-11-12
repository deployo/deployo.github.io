help:
	@echo "dev"
	@echo "build"
dev:
	hugo -D server
build:
	hugo

.PHONY: dev build help