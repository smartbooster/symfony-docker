# On fait le include du .env pour que la variable d'env APPLICATION soit repris dans le docker-compose
include .env

# Variables
ENV?=dev
CONSOLE=php bin/console

include make/*.mk

##
## Installation and update
## -------
.PHONY: init-public-folders
init-public-folders: ## Create no commited folders in public folder with the right permissions
	mkdir -p public/files
	sudo chmod -R 777 public/files

.PHONY: install
install: ## Install the project
	yarn install
ifeq ($(ENV),dev)
	composer install
	make assets-dev
else
	composer install --verbose --prefer-dist --optimize-autoloader --no-progress --no-interaction
	make assets-build
endif
	make orm-install
ifeq ($(ENV),dev)
	make orm-load-fake
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
