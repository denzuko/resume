FROM alpine:latest

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="" \
      org.label-schema.description="Example project description in 300 chars or less" \
      org.label-schema.url="e.g. https://www.example.com/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vendor="Dwight Spencer" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

ENV REPO=$VCS_URL
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
