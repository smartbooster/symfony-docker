##
## Docker commands
## ---------------

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
	git restore --staged .env.skeleton
	rm -f .env.skeleton
	git restore --staged package.json
	git restore package.json
	git restore --staged README.md
	git restore README.md
	git restore --staged yarn.lock
	git restore yarn.lock
	git remote remove docker
	echo Fetch smartbooster/symfony-docker complete!

.PHONY: check-missing-env
check-missing-env: ## Prevent sub make call if missing env variable
	if [ -z "$$(cat .env | grep '^APPLICATION=')" ]; then \
		echo "Error: APPLICATION is not defined in .env"; \
		exit 1; \
	fi

.PHONY: up
up: ## Start the project stack with docker
	make check-missing-env
	env $(cat .env | grep -v '^#') docker compose up

.PHONY: build
build: ## Build the docker image with already downloaded image in docker cache
	make check-missing-env
	sudo rm -rf var/data
	env $(cat .env | grep -v '^#') docker compose build --pull

.PHONY: build-no-cache
build-no-cache: ## Rebuild the docker image without docker cached images
	make check-missing-env
	sudo rm -rf var/data
	env $(cat .env | grep -v '^#') docker compose build --pull --no-cache

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
