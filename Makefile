RES_DIR		:= src/resources
SRC_DIR		:= src/main/java
TEST_DIR	:= src/test/java
MANIFEST	:= $(RES_DIR)/manifest.txt
PROJECT		:= $(shell basename "$(shell pwd)")
VERSION		:= 1.0.0
PACKAGE		:= com.dwightaspencer.$(PROJECT)
JARFILE		:= $(PROJECT)-$(VERSION).jar
JAVAC		:= javac -Xlint:unchecked -g
OUTPUT		:= $(JARFILE) resume.pdf
DEPS		:= cv.pdf Dockerfile truepolyglot
TAG		:= $(PROJECT):$(VERSION)
sources		:= 

ifeq ($(OS), "Windows")
	sources	:= $(shell dir /s /B *.java)
endif

ifeq ($(OS),"Windows_NT")
	sources	:= $(shell dir /s /B *.java)
else
	sources := $(shell find $(SRC_DIR) -type f -name "*.java")
endif
classes		:= $(sources:.java=.class)

.PHONY: all clean distclean deps test

define DOCKERFILE
FROM truepolyglot:latest AS build
ARG OUTPUT=resume.pdf
ENV OUTPUT $$OUTPUT
WORKDIR /src
COPY cv.pdf /src/
COPY *.jar /src/
RUN truepolyglot szippdf \
      --pdffile /src/cv.pdf \
      --zipfile /src/*.jar \
      --acrobat-compatibility $$OUTPUT

FROM scratch AS assets
COPY --from=build /src/resume.pdf /
endef

all: deps build

deps: $(DEPS)
	
build: $(OUTPUT)

clean:
	@-rm -f $(classes)

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
	@jar cfm $@ $(MANIFEST) -C $(SRC_DIR) $(<:$(SRC_DIR)/%=%)

truepolyglot:
	@$(MAKE) -C $@

resume.pdf: $(DEPS) $(JARFILE)
	@docker build --rm -t $(TAG) .
	@docker save $(TAG) | tar -tvf - | awk '/layer.tar/ { system("docker save $(TAG) | tar -xf- -O "$$NF" | tar -xvf -"); }'
