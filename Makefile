# On fait le include du .env pour que la variable d'env APPLICATION soit repris dans le docker compose
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
ifeq (,$(wildcard composer.json)) # Si pas de composer.json alors on install Symfony
	make remove-symfony # MDT par sécurité on supprime les potentiels fichiers SF existant avant de refaire l'install
	make install-symfony
else
	docker compose exec --user=dev php composer install
	docker compose exec --user=dev php yarn install
	docker compose exec --user=dev php make assets-dev
	# Arrêt de l'install à cette étape si le doctrine-fixtures-bundle n'est pas installé ou si les group minimal/fake ne sont pas définis
	docker compose exec --user=dev php make orm-install
	docker compose exec --user=dev php make orm-load-fake
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
