#
# Copyright © 2020, Keith Packard
#
# This file is released under a Creative Commons Attribution 4.0
# International License.
#

.SUFFIXES: .adoc .pdf .html

ADOC_FILES=riscv-semihosting-spec.adoc
PDF_FILES=$(ADOC_FILES:.adoc=.pdf)
HTML_FILES=$(ADOC_FILES:.adoc=.html)

SPEC_VERSION = 0.2
SPEC_DATE = 2020-04-05

ATTRIBUTES=-B. --attribute="revdate=$(SPEC_DATE)" --attribute="version=$(SPEC_VERSION)"

all: $(HTML_FILES) $(PDF_FILES)


.adoc.html:
	asciidoctor $(ATTRIBUTES) -b html5 $*.adoc

.adoc.pdf:
	asciidoctor-pdf $(ATTRIBUTES) $*.adoc

clean:
	rm -f $(PDF_FILES) $(HTML_FILES)
