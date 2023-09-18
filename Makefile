# Variables
ENV?=dev
CONSOLE=php bin/console

include make/*.mk

##
## Installation and update
## -------
.PHONY: install
install: ## Install the project
ifeq (,$(wildcard composer.json)) # If no composer.json then we install Symfony
	make remove-symfony # MDT to be sure the install works, we delete the potential existing SF files before redoing the installation
	make install-symfony
else
	make init-rw-files
	docker compose exec --user=dev php make install-script
endif

.PHONY: install-script
install-script: ## Install script using project packages config and setting up db (must be call on the php container, use it also on CI)
	composer install
	yarn install
	make assets-dev
	# Stopping the install at this step if the doctrine-fixtures-bundle is not installed or if the minimal/fake groups are not defined
	make orm-install
	make orm-load-fake
	echo Install complete!

.PHONY: update
update: orm-update orm-status

##
## Development
## -----------
.PHONY: debug-env
debug-env: ## Display environment variables used in the container
	$(CONSOLE) debug:container --env-vars --env=$(ENV)

.PHONY: cc
cc: ## Cache clear symfony
	$(CONSOLE) cache:clear --no-warmup --env=$(ENV)
	$(CONSOLE) cache:warmup --env=$(ENV)
