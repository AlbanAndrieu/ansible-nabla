# —— Inspired by ———————————————————————————————————————————————————————————————
# https://www.strangebuzz.com/en/snippets/the-perfect-makefile-for-symfony

# Setup ————————————————————————————————————————————————————————————————————————

# Parameters
SHELL         = bash
ME            = $(shell whoami)

# Executables: local only
DOCKER        = docker

# Misc
.DEFAULT_GOAL = build
.PHONY       =  # Not needed here, but you can put your all your targets to be sure
	            # there is no name conflict between your files and your targets.

## —— 🐝 The Strangebuzz Docker Makefile 🐝 ———————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— All 🎵 ———————————————————————————————————————————————————————————————
.PHONY: all
all: clean build

## —— Clean 🧹 ———————————————————————————————————————————————————————————————
.PHONY: clean
clean: ## Cleaning for ansible
	@echo "=> Cleaning for ansible..."
	rm -Rf artifacts/
	rm -Rf collections/

## —— Tests Ansible 🧪🔗 —————————————————————————————————————————————————————————————————
.PHONY: test
test: ## Run all tests
	@echo "=> Testing ansible..."
	ansible-lint ansible/

## —— Ansible 🐝 ————————————————————————————————————————————————————————————————
.PHONY: build-ansible
build-ansible: ## Build workstation with ansible
	@echo "=> Building for ansible..."
	pip install -r requirements.txt
	ansible-galaxy install -r requirements.yml
	@echo "=> Building ansible..."
	./scripts/setup.sh

## —— Build 🚀 —————————————————————————————————————————————————————————————————
.PHONY: build
build: build-ansible

## —— Up ✅ —————————————————————————————————————————————————————————————————
.PHONY: up
up:
	@echo "up"

.PHONY: down
down:
	@echo "down"

.PHONY: run
run: down up

## —— Formating 🧪🔗 ———————————————————————————————————————————————————————————————
.PHONY: fmt
fmt: ## Run formating
	@echo "=> Executing formating..."
	shfmt -i 2 -ci -w *.sh || true
	ansible-lint --write ./

## —— Ansible Kong 🐝 ———————————————————————————————————————————————————————————————
.PHONY: ansible-kong
ansible-kong: ## Add kong
	@echo "=> Add kong..."
	ansible-playbook playbooks/kong.yml --inventory envs/dev/inventory.ini  --limit gra1apigtwdev1 -vv
