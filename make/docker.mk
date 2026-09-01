##
## Docker commands
## ---------------
DEV_UID := $(shell id -u)

.PHONY: docker-fetch df
docker-fetch: ## Fetch smartbooster/symfony-docker stack files
	git remote add docker git@github.com:smartbooster/symfony-docker.git
	git fetch docker
	git checkout docker/main .
	make docker-generate-lock
	git remote remove docker
	make docker-post-fetch
df: docker-fetch ## Alias for docker-fetch

.PHONY: docker-generate-lock
docker-generate-lock: ## Generate the symfony-docker.lock to track which version of the stack is install on the project
	rm -f symfony-docker.lock
	touch symfony-docker.lock
	echo -n 'hash: ' >> symfony-docker.lock
	git rev-parse docker/main >> symfony-docker.lock
	echo 'fetch_time: '$(shell date +%Y-%m-%dT%H:%M:%S) >> symfony-docker.lock
	echo -n 'version: ' >> symfony-docker.lock
	git rev-parse docker/main | xargs git tag --contains >> symfony-docker.lock

.PHONY: docker-post-fetch
docker-post-fetch: ## Post smartbooster/symfony-docker fetch process to clean unwanted files to be sync
	git restore --staged .env.skeleton
	rm -f .env.skeleton
	git restore --staged CHANGELOG.md
	rm -f CHANGELOG.md
	git restore --staged package.json
	git restore package.json
	git restore --staged README.md
	git restore README.md
	git restore --staged yarn.lock
	git restore yarn.lock
	git restore --staged .gitignore
	git restore .gitignore
	git restore --staged .gitlab-ci.yml
	git restore .gitlab-ci.yml
	git restore --staged docs
	rm -r docs
	git restore --staged .github
	rm -rf .github
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
	env $(cat .env | grep -v '^#') docker compose build php --pull --build-arg DEV_UID=$(DEV_UID)

.PHONY: build-no-cache
build-no-cache: ## Rebuild the docker image without docker cached images
	make check-missing-env
	env $(cat .env | grep -v '^#') docker compose build php --pull --no-cache --build-arg DEV_UID=$(DEV_UID)

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

##
## Docker image security scans
## ---------------------------
DOCKER_IMAGE := $(shell grep '^APPLICATION=' .env | cut -d= -f2)php:latest
# osv-scanner and dockle are run through docker (nothing to install). Their images have no docker cli,
# so the local image is exported as an archive in a temporary directory and scanned from there, then cleaned up.
SCAN_SAVE_IMAGE := dir=$$(mktemp -d); docker save $(DOCKER_IMAGE) -o "$$dir/image.tar"
# Cleanup done explicitly at the end of each target (an EXIT trap is not run when sh execs the last command)
SCAN_CLEANUP := status=$$?; rm -rf "$$dir"; exit $$status
SCAN_DOCKER_RUN := docker run --rm -v "$$dir":/archive:ro
OSV_SCAN_IMAGE := ghcr.io/google/osv-scanner:latest scan image --archive /archive/image.tar
DOCKLE_SCAN_IMAGE := goodwithtech/dockle:latest --exit-code 1 --exit-level warn --input /archive/image.tar

.PHONY: docker-scan-osv
docker-scan-osv: ## Scan the docker image vulnerabilities (CVE) with osv-scanner (run through docker, nothing to install)
	@$(SCAN_SAVE_IMAGE); \
	$(SCAN_DOCKER_RUN) $(OSV_SCAN_IMAGE); \
	$(SCAN_CLEANUP)

.PHONY: docker-scan-osv-html
docker-scan-osv-html: ## Scan the docker image with OSV and serve an HTML report available on http://localhost:8000/
	@$(SCAN_SAVE_IMAGE); \
	$(SCAN_DOCKER_RUN) -i -p 8000:8000 $(OSV_SCAN_IMAGE) --serve; \
	$(SCAN_CLEANUP)

.PHONY: docker-lint
docker-lint: ## Lint the Dockerfile with hadolint (run through docker, nothing to install)
	docker run --rm -v $(CURDIR):/work -w /work hadolint/hadolint hadolint Dockerfile && echo "hadolint: no issue found"

.PHONY: docker-scan-dockle
docker-scan-dockle: ## Check the docker image best practices with dockle (run through docker, nothing to install)
	# The .dockleignore of the project root is mounted in the container so that its exceptions are applied
	@$(SCAN_SAVE_IMAGE); \
	$(SCAN_DOCKER_RUN) -v "$(PWD)/.dockleignore":/project/.dockleignore:ro -w /project $(DOCKLE_SCAN_IMAGE) \
	&& echo "dockle: no issue found"; \
	$(SCAN_CLEANUP)

.PHONY: docker-scan
docker-scan: ## Run all the docker image security scans (osv-scanner + hadolint + dockle)
	make docker-lint
	make docker-scan-dockle
	make docker-scan-osv

