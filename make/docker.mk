##
## Docker commands
## ---------------
.PHONY: up
up: ## Start the project stack with docker
	docker compose up

.PHONY: build
build: ## Rebuild the docker image
	sudo rm -rf var/data
	docker compose build --pull

.PHONY: build-no-cache
build-no-cache: ## Rebuild the docker image with already downloaded image in docker cache
	sudo rm -rf var/data
	docker compose build --pull --no-cache

.PHONY: down
down: ## Kill the project stack with docker
	docker compose down

.PHONY: ps
ps: ## List containers from project
	docker compose ps

.PHONY: ssh
ssh: ## Access to the php container in interactive mode
	docker compose exec --user=dev php bash

.PHONY: ssh-root
ssh-root: ## Access to the php container in interactive mode as root
	docker compose exec php bash

.PHONY: mysql
mysql: ## Access to the mysql container in interactive mode
	docker compose exec --user=mysql mysql bash
