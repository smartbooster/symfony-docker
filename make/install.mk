##
## Installation and update
## -------
.PHONY: init-rw-files
init-rw-files: ## Fix rights of var & public/files folders
	sudo mkdir -p ./var/cache
	sudo chmod -R 777 ./var/cache
	sudo chmod -R 777 ./var/log
	mkdir -p public/files
	sudo chmod -R 777 public/files
	sudo chmod -R 777 docker/xdebug_profile

SYMFONY_INSTALL_VERSION?=lts
.PHONY: install-symfony
install-symfony: ## Install a new fresh version of symfony
	make check-missing-env
	# Adding env variables for doctrine
	echo "" >> .env
	echo "###> doctrine/doctrine-bundle ###" >> .env
	echo "MYSQL_ADDON_URI=mysql://dev:dev@mysql:3306/$(shell cat .env | grep APPLICATION= | cut -d= -f2)" >> .env
	echo "MYSQL_ADDON_VERSION=8.0" >> .env
	echo "###< doctrine/doctrine-bundle ###" >> .env
	rm -f .env.skeleton
	# Install SF project in a temporary folder
	docker compose exec --user=dev php git config --global user.email "dev@smartbooster.io"
	docker compose exec --user=dev php git config --global user.name "Smartbooster"
	docker compose exec --user=dev php symfony new --dir=project --version=$(SYMFONY_INSTALL_VERSION) --webapp --debug
	# Moving sources to project root and deleting temp folder
	sed -n '16,20p' project/.env >> ./.env # get the random APP_ENV and APP_SECRET generated by the install
	rm -rf project/var project/.env.test project/.gitignore project/docker-compose.yml project/docker-compose.override.yml
	mv project/* ./
	rm -rf project
	make init-rw-files
	# Fix doctrine.yaml + removal of unnecessary bundles/files from SF webapp
	sed '3,4c\        url: "%env(resolve:MYSQL_ADDON_URI)%"\n        server_version: "%env(resolve:MYSQL_ADDON_VERSION)%"' -i config/packages/doctrine.yaml
	sed '5,8d' -i config/packages/doctrine.yaml
	rm config/packages/messenger.yaml
	docker compose exec --user=dev php composer remove symfony/doctrine-messenger symfony/notifier symfony/asset-mapper symfony/stimulus-bundle symfony/ux-turbo
	docker compose exec --user=dev php composer remove --dev phpunit/phpunit
	rm -r assets
	# While https://github.com/getsentry/sentry-symfony/issues/806 isn't fix we wont pass to doctrine/orm:v3
	docker compose exec --user=dev php composer require --no-interaction doctrine/orm:^2.18 doctrine/dbal:^3.8
	# The symfony/maker-bundle update his dependencies to allow nikic/php-parser:^5 but phpmetrics/phpmetrics:^2.8 only works with the previous version so that why we downgrade it for now
	docker compose exec --user=dev php composer require --no-interaction --dev nikic/php-parser:^4.18
	# Add SmartBooster bundles
	docker compose exec --user=dev php composer config --json extra.symfony.endpoint '["https://api.github.com/repos/smartbooster/standard-bundle/contents/recipes.json", "flex://defaults"]'
	docker compose exec --user=dev php composer require --dev --no-interaction smartbooster/standard-bundle:^1
	docker compose exec --user=dev php composer require --no-interaction smartbooster/core-bundle:^1
	git restore package.json
	rm src/DataFixtures/AppFixtures.php
	mkdir -p config/serialization
	# Add default robots.txt
	touch public/robots.txt
	echo "User-agent: *" >> public/robots.txt
	echo "Disallow: /" >> public/robots.txt
	# Run Tests and database status to check that everything works fine
	docker compose exec --user=dev php make phpunit
	docker compose exec --user=dev php make orm-status
	echo Install complete!

.PHONY: remove-symfony
remove-symfony: ## Remove all symfony related files of the repository
	sudo rm -rf bin config migrations node_modules public project src templates tests translations vendor ./var/cache ./var/log/php/* \
		make/dev.mk \
		make/qualimetry.mk \
		make/test.mk \
		composer.json \
		composer.lock \
		phpcs.xml \
		phpstan.neon \
		phpunit.xml.dist \
		symfony.lock \
		symfony-docker.lock

.PHONY: install
install: ## Install the project. MUST BY RUN OUTSIDE OF THE DOCKER CONTAINER !
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
update:: orm-update orm-status ## Update the project (database migration, custom project command, ...)
