PROJECT_NAME	:= truepolyglot
PROJECT_DESC	:= "Generate a polyglot file."
PROJECT_URL	:= https://github.com/ansemjo/truepolyglot
PROJECT_VENDOR	:= denzuko
PROJECT_VERSION	:= 1.6.2
VCS_REF		:= $(shell git rev-parse --short HEAD)
VCS_URL		:= https://git.hackade.org/truepolyglot.git
BUILD_DATE	:= $(shell date -u +”%Y-%m-%dT%H:%M:%SZ”)
IMAGE_NAME	:= $(shell basename '$(shell pwd)')
IMAGE_VERSION	:= latest
REGISTRY	:=
DOCKER		:= "$(shell which docker)" 
DOCKERFLAGS	+= --rm -t $(IMAGE_NAME):$(IMAGE_VERSION) .

define Dockerfile
FROM alpine:latest

# Build-time metadata as defined at http://label-schema.org
ARG VCS_REF=$(VCS_REF)
ARG VCS_URL=$(VCS_URL)
ARG VERSION=$(VERSION)
ARG BUILD_DATE=$(BUILD_DATE)

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$$BUILD_DATE \
      org.label-schema.vcs-ref=$$VCS_REF \
      org.label-schema.vcs-url=$$VCS_URL \
      org.label-schema.version=$$VERSION \
      org.label-schema.name=$(PROJECT_NAME) \
      org.label-schema.description=$(PROJECT_DESC) \
      org.label-schema.url=$(PROJECT_URL) \
      org.label-schema.vendor=$(PROJECT_VENDOR) \

ENV VCS_URL $VCS_URL
ENV PYTHONUNBUFFERED=1

WORKDIR /src
COPY requirements.txt /src/

RUN apk add --no-cache --update \
	git \
	ca-certificates \
	curl \
	python3 \
	py3-setuptools build-base &&\
    pip3 install -r requirements.txt

ENTRYPOINT ["truepolyglot"]

endef

.DEFAULT: all
.PHONY: all build clean

all: clean build

Dockerfile:
	@echo "$(Dockerfile)" > $@

build: Dockerfile
	@$(DOCKER) $@ $(DOCKERFLAGS)

login:
	@$(DOCKER) login $(REGISTRY)

publish: login
	@$(DOCKER) tag $(IMAGE_NAME):$(IMAGE_VERSION) $(IMAGE_NAME):$(VCS_REF)
	@$(DOCKER) push $(IMAGE_NAME):$(IMAGE_VERSION)
	@$(DOCKER) push $(IMAGE_NAME):$(VCS_REF)

clean:
	@-$(DOCKER) image rm $(IMAGE_NAME):$(IMAGE_VERSION)
