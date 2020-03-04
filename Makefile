RES_DIR			:= src/resources
SRC_DIR			:= src/main/java
TEST_DIR		:= src/test/java
MANIFEST		:= $(RES_DIR)/manifest.txt
PROJECT			:= $(shell basename "$(shell pwd)")
VERSION			:= 1.0.0
PACKAGE			:= com.dwightaspencer.$(PROJECT)
JARFILE			:= $(PROJECT)-$(VERSION).jar
JAVAC			:= javac -Xlint:unchecked -g
OUTPUT			:= $(JARFILE) resume.pdf
DEPS			:= cv.pdf truepolyglot Dockerfile 
TAG			:= $(PROJECT):$(VERSION)
IPFS_PIN		:= https://api.pinata.cloud/pinning/pinFileToIPFS
PINATA_API_KEY		:= $(shell printenv PINATA_API_KEY)
PINATA_SECRET_API_KEY	:= $(shell printenv PINATA_API_KEY)
CURL			:= $(shell which curl)
CURL_OPTS		:= -X POST
CURL_OPTS		+= -H 'Content-Type:multipart/form-data'
CURL_OPTS		+= -H 'pinata_api_key:'"$(PINATA_API_KEY)"
CURL_OPTS		+= -H 'pinata_secret_api_key:'"$(PINATA_SECRET_API_KEY)" 
sources			:= 

ifeq ($(OS), "Windows")
	sources	:= $(shell dir /s /B *.java)
endif

ifeq ($(OS),"Windows_NT")
	sources	:= $(shell dir /s /B *.java)
else
	sources := $(shell find $(SRC_DIR) -type f -name "*.java")
endif
classes		:= $(sources:.java=.class)

.PHONY: all clean distclean deps test truepolyglot

define DOCKERFILE
FROM truepolyglot:latest AS build
ARG INPUT=cv.pdf
ENV INPUT=cv.pdf
ARG OUTPUT=resume.pdf
ENV OUTPUT $$OUTPUT
ARG JARFILE=$(JARFILE)
ENV JARFILE=$(JARFILE)
WORKDIR /src
COPY $$INPUT /src/
COPY $$JARFILE /src/
RUN truepolyglot szippdf \
      --pdffile /src/$$INPUT \
      --zipfile /src/$$JARFILE \
      --acrobat-compatibility $$OUTPUT

FROM scratch AS assets
COPY --from=build /src/resume.pdf /
endef

all: deps build

deps: $(DEPS)

build: $(OUTPUT)

clean:
	@-rm -f $(classes) *.tmp

distclean: clean
	@-rm $(OUTPUT) Dockerfile

%.class: %.java
	@$(JAVAC) $<

%.pdf: %.groff
	@groff -t -Tpdf -R -p -z -mom $< > $@

export DOCKERFILE
Dockerfile:
	@echo "$$DOCKERFILE" > $@

test: TestAll.class
	@java -classpath $(TEST_DIR):$(SRC_DIR) junit.textui.TestRunner TestAll

$(JARFILE): $(classes)
	@jar cvfm $@ $(MANIFEST) -C $(SRC_DIR) $(<:$(SRC_DIR)/%=%)
	@jar uvf $@ -C $(RES_DIR) res/

index: $(JARFILE)
	@jar i $<

truepolyglot:
	@$(MAKE) -C $@

release: resume.pdf
	@$(CURL) $(CURL_OPTS) $(IPFS_PIN) -Ffile=@$<


resume.pdf: $(DEPS) $(JARFILE)
	@docker build --rm -t $(TAG) .
	@docker save $(TAG) | tar -tvf - | awk '/layer.tar/ { system("docker save $(TAG) | tar -xf- -O "$$NF" | tar -xvf -"); }'
