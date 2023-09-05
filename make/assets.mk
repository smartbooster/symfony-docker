##
## Assets
## ------
.PHONY: assets-bundle
assets-bundle:
	$(CONSOLE) assets:install --symlink --relative --env=$(ENV)

.PHONY: assets-dev ad
assets-dev: assets-bundle ## Compile the assets in dev mode. Shortcut command "make ad"
assets-dev:
	yarn run dev
ad: assets-dev

.PHONY: assets-watch aw
assets-watch: assets-bundle ## Enable the watcher on the assets. Shortcut command "make aw"
	yarn run watch
aw: assets-watch

.PHONY: assets-build ab
assets-build: override ENV=prod ## Compile the assets in production mode. Shortcut command "make ab"
assets-build: assets-bundle
assets-build:
	yarn run build
ab: assets-build
