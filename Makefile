# We include the .env so that the APPLICATION env variable is included in the docker compose
include .env

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
	docker compose exec --user=dev php composer install
	docker compose exec --user=dev php yarn install
	docker compose exec --user=dev php make assets-dev
	# Stopping the install at this step if the doctrine-fixtures-bundle is not installed or if the minimal/fake groups are not defined
	docker compose exec --user=dev php make orm-install
	docker compose exec --user=dev php make orm-load-fake
	echo Install complete!
endif

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
