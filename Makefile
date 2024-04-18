# Makefile for RISC-V Doc Template
#
# This work is licensed under the Creative Commons Attribution-ShareAlike 4.0
# International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to
# Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
#
# SPDX-License-Identifier: CC-BY-SA-4.0
#
# Description:
# 
# This Makefile is designed to automate the process of building and packaging 
# the Doc Template for RISC-V Extensions.

DOCKER_RUN := docker run --rm -v ${PWD}:/build -w /build \
riscvintl/riscv-docs-base-container-image:latest

DEPS += src/bibliography.bib
DEPS += src/contributors.adoc
DEPS += src/intro.adoc
DEPS += src/binary-interface.adoc
DEPS += src/index.adoc
DEPS += src/bibliography.adoc

TARGETS += riscv-semihosting.pdf

ASCIIDOCTOR_PDF := asciidoctor-pdf
OPTIONS := --trace \
           -a compress \
           -a mathematical-format=svg \
           -a pdf-fontsdir=docs-resources/fonts \
           -a pdf-theme=docs-resources/themes/riscv-pdf.yml \
           --failure-level=ERROR
REQUIRES := --require=asciidoctor-bibtex \
            --require=asciidoctor-diagram \
            --require=asciidoctor-mathematical

.PHONY: all clean

all: $(TARGETS)

# Preserve all intermediate files
.SECONDARY:

images/%.png: src/%.ditaa
	mkdir -p `dirname $@`
	ditaa $< $@

%.pdf: %.adoc $(DEPS)
	@echo "Checking if Docker is available..."
	@if command -v docker >/dev/null 2>&1 ; then \
		echo "Docker is available, building inside Docker container..."; \
		$(MAKE) build-container/$@; \
		cp -f build-container/$@ $@; \
	else \
		echo "Docker is not available, building without Docker..."; \
		$(MAKE) build-no-container/$@; \
		cp -f build-no-container/$@ $@; \
	fi

build-container/%.pdf: %.adoc $(DEPS)
	@echo "Starting build inside Docker container..."
	@mkdir -p `dirname $@`
	$(DOCKER_RUN) /bin/sh -c "$(ASCIIDOCTOR_PDF) $(OPTIONS) $(REQUIRES) --out-file=$@ $<"
	@echo "Build completed successfully inside Docker container."

build-no-container/%.pdf: %.adoc $(DEPS)
	@echo "Starting build..."
	@mkdir -p `dirname $@`
	$(ASCIIDOCTOR_PDF) $(OPTIONS) $(REQUIRES) --out-file=$@ $<
	@echo "Build completed successfully."

clean:
	@echo "Cleaning up generated files..."
	rm -rf build-container build-no-container $(TARGETS)
	@echo "Cleanup completed."
