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

MODULES := BreakfastTime
MODULE ?= $(firstword $(MODULES))

.PHONY: all default build build-all lint test test-all run run-all clean help

default: build-all lint test-all run-all ## Default goal: build, lint, test, and run all puzzle modules

all: build-all test-all ## Build and test all puzzle modules

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

lint: build-all ## Run the linter
	@$(LAKE) check-lint
	@$(LAKE) lint

test: ## Test a specific module: make test MODULE=BreakfastTime
	@$(LAKE) test -- $(MODULE)

test-all: ## Test every puzzle module
	@$(LAKE) test


run: ## Run a specific module executable: make run MODULE=BreakfastTime
	@$(LAKE) build $(MODULE)Exe && $(LAKE) exe $(MODULE)Exe

run-all: ## Run every puzzle executable
	@for m in $(MODULES); do exe="$${m}Exe"; $(LAKE) build "$$exe" && $(LAKE) exe "$$exe"; done

clean: ## Clean the build artifacts
	@$(LAKE) clean

update: ## Update the dependencies using Lake
	@$(LAKE) update
