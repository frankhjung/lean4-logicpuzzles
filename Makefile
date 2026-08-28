.DEFAULT_GOAL := default

CD	:= cd
LEAN_PREFIX := $(shell lean --print-prefix 2>/dev/null)
ifeq ($(LEAN_PREFIX),)
$(error Lean not found. Please ensure Lean 4 is installed and available in your PATH.)
endif
LAKE	:= LD_LIBRARY_PATH="$(LEAN_PREFIX)/lib" lake
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
printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"; \
} \
/^[a-zA-Z_-]+:.*?##/ \
{ printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' \
$(MAKEFILE_LIST)

build: ## Build a specific module: make build MODULE=BreakfastTime
	@$(LAKE) build $(MODULE)

build-all: ## Build every puzzle module
	@for m in $(MODULES); do $(LAKE) build $$m; done

lint: ## Run the linter
	@$(LAKE) check-lint
	@$(LAKE) lint

test: ## Test a specific module: make test MODULE=BreakfastTime
	@$(LAKE) build $(MODULE) && $(LAKE) env lean $(MODULE)/Test.lean

test-all: ## Test every puzzle module
	@for m in $(MODULES); do $(LAKE) build $$m && $(LAKE) env lean $$m/Test.lean; done

run: ## Run a specific module executable: make run MODULE=BreakfastTime
	@$(LAKE) build $(MODULE)Exe && $(LAKE) exe $(MODULE)Exe

run-all: ## Run every puzzle executable
	@for m in $(MODULES); do exe="$${m}Exe"; $(LAKE) build "$$exe" && $(LAKE) exe "$$exe"; done

clean: ## Clean the build artifacts
	@$(LAKE) clean

update: ## Update the dependencies using Lake
	@$(LAKE) update
