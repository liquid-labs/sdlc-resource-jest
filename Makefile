.DELETE_ON_ERROR:

SHELL:=bash

SRC:=src
DIST:=dist
QA:=qa

CONFIG_FILES_SRC:=$(SRC)/jest-snapshot-resolver.js $(SRC)/jest.config.js $(SRC)/jest.unit.config.js $(SRC)/jest.integration.config.js $(SRC)/jest.integration.config.js $(SRC)/fix-jsdom-environment.js
CONFIG_FILES_DIST:=$(patsubst $(SRC)/%, $(DIST)/%, $(CONFIG_FILES_SRC))

ALL_JS_FILES_SRC:=$(shell find $(SRC) -name "*.js")

default: all

$(CONFIG_FILES_DIST): $(DIST)/%: $(SRC)/%
	mkdir -p $(dir $@)
	cp $< $@

JEST:=npx jest
TEST_REPORT:=$(QA)/unit-test.txt
TEST_PASS_MARKER:=$(QA)/.unit-test.passed
PRECIOUS_TARGETS+=$(TEST_REPORT)

$(TEST_REPORT) $(TEST_PASS_MARKER) &: package.json $(ALL_JS_FILES_SRC)
	mkdir -p $(dir $@)
	echo -n 'Test git rev: ' > $(TEST_REPORT)
	git rev-parse HEAD >> $(TEST_REPORT)
	( set -e; set -o pipefail; \
		SRJ_CWD_REL_PACKAGE_DIR='.' \
		$(JEST) \
		--config $(SRC)/jest.unit.config.js \
		| tee -a $(TEST_REPORT); \
		touch $(TEST_PASS_MARKER) )
	@[[ -f coverage/coverage-final.json ]] \
		|| echo 'FAILED to create coverage results' >&2

ESLINT:=npx eslint
LINT_REPORT:=$(QA)/lint.txt
LINT_PASS_MARKER:=$(QA)/.lint.passed
PRECIOUS_TARGETS+=$(LINT_REPORT)

LINT_IGNORE_PATTERNS:=--ignore-pattern '$(DIST)/**/*' \
  --ignore-pattern '$(SRC)/test/data/**/*'

$(LINT_REPORT) $(LINT_PASS_MARKER) &: $(ALL_JS_FILES_SRC)
	mkdir -p $(dir $@)
	echo -n 'Test git rev: ' > $(LINT_REPORT)
	git rev-parse HEAD >> $(LINT_REPORT)
	( set -e; set -o pipefail; \
	  $(ESLINT) \
	    --ext .cjs,.js,.mjs,.cjs,.xjs \
	    $(LINT_IGNORE_PATTERNS) \
	    . \
	    | tee -a $(LINT_REPORT); \
	  touch $(LINT_PASS_MARKER) )

lint-fix:
	@( set -e; set -o pipefail; \
	  $(ESLINT) \
	    --ext .js,.mjs,.cjs,.xjs \
	    $(LINT_IGNORE_PATTERNS) \
	    --fix . )

build: $(CONFIG_FILES_DIST)

test: $(TEST_REPORT) $(TEST_PASS_MARKER)

lint: $(LINT_REPORT) $(LINT_PASS_MARKER)

qa: lint test

all: build

default: all

.PHONY: all build default