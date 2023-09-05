##
## Database management
## -------------------
.PHONY: orm-install
orm-install: ## Create the databse + Loading minimales fixtures. For production environnement add ENV=PROD
	$(CONSOLE) doctrine:database:drop --if-exists --force --env=$(ENV)
	$(CONSOLE) doctrine:database:create --env=$(ENV)
	$(CONSOLE) doctrine:schema:update --force --env=$(ENV)
	$(CONSOLE) doctrine:migrations:sync-metadata-storage --env=$(ENV)
	$(CONSOLE) doctrine:migrations:version --add --all --no-interaction --env=$(ENV)
	make orm-load-minimal

.PHONY: orm-sync-force
orm-sync-force: ## Force the database schema to be sync with the mapping files
	$(CONSOLE) doctrine:schema:update --force --env=$(ENV)
	$(CONSOLE) doctrine:migrations:sync-metadata-storage --env=$(ENV)
	$(CONSOLE) doctrine:migrations:version --add --all --no-interaction --env=$(ENV)

.PHONY: orm-update
orm-update: ## Update the database with migrations
	$(CONSOLE) doctrine:migrations:migrate --no-interaction --allow-no-migration --env=$(ENV)

.PHONY: orm-prev
orm-prev: ## Revert database to last migration
	$(CONSOLE) doctrine:migrations:migrate prev --env=$(ENV)

.PHONY: orm-status
orm-status: ## Show ORM status (Migrations, Mapping, Synch). For production environnement add ENV=PROD
	$(CONSOLE) doctrine:migrations:status --no-interaction --env=$(ENV)
	$(CONSOLE) doctrine:schema:validate --env=$(ENV)

.PHONY: orm-show-diff
orm-show-diff: ## Dump the SQL needed to update the database schema to match the current mapping metadata.  For production environnement add ENV=PROD
	$(CONSOLE) doctrine:schema:update --dump-sql --env=$(ENV)

.PHONY: orm-diff
orm-diff: ## Generate a migration by comparing your current database to your mapping information.
	$(CONSOLE) doctrine:migra:diff --no-interaction --env=$(ENV)

.PHONY: orm-load-minimal olm
orm-load-minimal: ## Load fixtures from the minimal group to the database
	$(CONSOLE) doctrine:fixtures:load --group=minimal --no-interaction --env=$(ENV)
olm: orm-load-minimal

.PHONY: orm-load-fake olf
orm-load-fake: ## Load fixtures from the fake group to the database
	$(CONSOLE) doctrine:fixtures:load --group=fake --no-interaction --append --env=$(ENV)
olf: orm-load-fake

.PHONY: orm-load-volume olv
orm-load-volume: ## Load fixtures from the volume group to the database
	$(CONSOLE) doctrine:fixtures:load --group=volume --no-interaction --append --env=$(ENV)
olv: orm-load-volume
