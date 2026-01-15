##
## Bundle
## ------
PLATFORM_CORE_SCRIPTS=vendor/smartbooster/platform-core-bundle/scripts

.PHONY: platform-core-bundle-install pcbi
platform-core-bundle-install: ## Post platform-core-bundle require command to run to complete his install process
	sh $(PLATFORM_CORE_SCRIPTS)/fetch_assets.sh
	sh $(PLATFORM_CORE_SCRIPTS)/fetch_config.sh
	sh $(PLATFORM_CORE_SCRIPTS)/fetch_fixtures.sh
	sh $(PLATFORM_CORE_SCRIPTS)/fetch_src.sh
	sh $(PLATFORM_CORE_SCRIPTS)/fetch_templates.sh
	sh $(PLATFORM_CORE_SCRIPTS)/fetch_tests.sh
	mkdir documentation
	cp ./vendor/smartbooster/platform-core-bundle/stubs/documentation/* ./documentation
	# Redéfinition du cache:clear en 2 temps
	composer config --unset scripts.auto-scripts.'assets:install %PUBLIC_DIR%'
	composer config --unset scripts.auto-scripts.cache:clear
	composer config scripts.auto-scripts.'cache:clear --no-warmup' symfony-cmd
	composer config scripts.auto-scripts.cache:warmup symfony-cmd
	composer config scripts.auto-scripts.'assets:install %PUBLIC_DIR%' symfony-cmd
	# Set the composer autoloader config to avoid conflict between phpunit and symfony/phpunit-bridge when launching tests
	composer config optimize-autoloader true
	composer config prepend-autoloader false
	composer dump-autoload
	yarn install
	make assets-dev
	make orm-install
	printf "\t\$$(CONSOLE) cmd:smart-entity-schema-load --env=\$$(ENV)\n" >> make/install.mk
	printf "\t\$$(CONSOLE) cmd:smart-editable-email-load --env=\$$(ENV)\n" >> make/install.mk
	printf "\t\$$(CONSOLE) cmd:smart-parameter-load --env=\$$(ENV)\n" >> make/install.mk
	echo Bundle install complete!
pcbi: platform-core-bundle-install ## Alias for platform-core-bundle-install

crud: ## platform-core-bundle command to generate CRUDController
	$(CONSOLE) make:smart:crud
crud-fake: ## platform-core-bundle command to generate fake CRUDController
	$(CONSOLE) make:smart:crud --fake
