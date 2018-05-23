VERSION         ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo latest)
IMAGE           := rubykube/toolbox:$(VERSION)

default: build

build:
	echo '>Building the toolbox Docker image...'
	docker build -t $(IMAGE) .

push:
	docker push $(IMAGE)
