.DEFAULT_GOAL := default

CD	:= cd
REQUIRED_LEAN_VERSION	:= 4.32.0
REQUIRED_TOOLCHAIN	:= leanprover/lean4:v$(REQUIRED_LEAN_VERSION)

TOOLCHAIN		:= $(strip $(shell cat lean-toolchain 2>/dev/null))
ifneq ($(TOOLCHAIN),$(REQUIRED_TOOLCHAIN))
$(error lean-toolchain specifies '$(TOOLCHAIN)' but expected '$(REQUIRED_TOOLCHAIN)')
endif

LEAN_PREFIX := $(shell lean --print-prefix 2>/dev/null)
ifeq ($(LEAN_PREFIX),)
$(error Lean not found. Ensure Lean 4 is installed and available on your PATH.)
endif

LEAN_VERSION		:= $(shell lean --version 2>/dev/null | sed -n 's/.*version \([0-9.]*\).*/\1/p')
ifneq ($(LEAN_VERSION),$(REQUIRED_LEAN_VERSION))
$(error Active Lean version is '$(LEAN_VERSION)', but $(REQUIRED_LEAN_VERSION) is required.)
endif

LAKE	:= LD_LIBRARY_PATH="$(LEAN_PREFIX)/lib" lake --keep-toolchain
RM	:= rm -rf

MODULES := BreakfastTime Test
MODULE ?= $(firstword $(MODULES))
LINT_THREADS ?= 1
LINT_MODULES ?= $(shell find $(MODULES:%=%.lean) $(MODULES) -type f \
	-name '*.lean' 2>/dev/null | sed -e 's/\.lean$$//' -e 's|/|.|g' | sort -u)

.PHONY: all default build build-all lint lint-all test run run-all clean help

default: build test run ## Default goal: build, test, and run puzzle modules

all: build-all run-all ## Build and test all puzzle modules

help: ## Show this help message
	@echo ""
	@echo "Default goal: ${.DEFAULT_GOAL}"
	@awk 'BEGIN { \
	FS = ":.*##"; \
	printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} \
	/^[a-zA-Z_-]+:.*?##/ \
	{ printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' \
	$(MAKEFILE_LIST)

build: ## Build a specific module: make build MODULE=BreakfastTime
	@$(LAKE) build $(MODULE)

build-all: ## Build every puzzle module
	@for m in $(MODULES); do $(LAKE) build $$m; done

lint: build-all ## Run linter in isolated processes: make lint [MODULE=...]
	@$(LAKE) check-lint
ifeq ($(origin MODULE),command line)
	@LEAN_NUM_THREADS=$(LINT_THREADS) $(LAKE) lint -- $(MODULE)
else
	@for m in $(LINT_MODULES); do \
		LEAN_NUM_THREADS=$(LINT_THREADS) $(LAKE) lint -- $$m || exit 1; \
	done
endif

lint-all: lint ## Lint all puzzle modules in isolated processes

test: ## Run the LSpec test suite
	@$(LAKE) test

run: ## Run a specific module executable: make run MODULE=BreakfastTime
	@$(LAKE) build $(MODULE)Exe && $(LAKE) exe $(MODULE)Exe

run-all: ## Run every puzzle executable
	@for m in $(MODULES); do \
		exe="$${m}Exe"; $(LAKE) build "$$exe" && $(LAKE) exe "$$exe"; \
	done

clean: ## Clean the build artifacts
	@$(LAKE) clean

update: ## Update the dependencies using Lake
	@$(LAKE) update
