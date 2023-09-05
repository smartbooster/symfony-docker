##
## Bundle
## ------
.PHONY: bundle-push-assets bpa
bundle-push-assets: ## Push project assets into smartbooster/platform-core-bundle stubs/assets
	sh ./vendor/smartbooster/platform-core-bundle/scripts/push_assets.sh
bpa: bundle-push-assets

.PHONY: bp
bp: bpa

.PHONY: bundle-fetch-assets bfa
bundle-fetch-assets: ## Fetch smartbooster/platform-core-bundle stub/assets into project assets
	sh vendor/smartbooster/platform-core-bundle/scripts/fetch_assets.sh
bfa: bundle-fetch-assets

.PHONY: bf
bf: bfa
