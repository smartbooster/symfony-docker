##
## Docker commands
## ---------------
ifndef APPLICATION
$(error APPLICATION is not defined. Please set it before running this command.)
endif

.PHONY: docker-fetch df
docker-fetch: ## Fetch smartbooster/symfony-docker stack files
	sudo rm -rf var/data/
	git remote add docker git@github.com:smartbooster/symfony-docker.git
	git fetch docker
	git checkout docker/main .
	make docker-post-fetch
df: docker-fetch

.PHONY: docker-post-fetch
docker-post-fetch: ## Post smartbooster/symfony-docker fetch process to clean unwanted files to be sync
	rm -f .env.skeleton
	git restore --staged package.json
	git restore package.json
	git restore --staged README.md
	git restore README.md
	git restore --staged yarn.lock
	git restore yarn.lock
	git remote remove docker
	echo Fetch smartbooster/symfony-docker complete!

.PHONY: up
up: ## Start the project stack with docker
	docker compose up

.PHONY: build
build: ## Build the docker image with already downloaded image in docker cache
	sudo rm -rf var/data
	docker compose build --pull

.PHONY: build-no-cache
build-no-cache: ## Rebuild the docker image without docker cached images
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
