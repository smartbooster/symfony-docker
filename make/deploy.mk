##
## Deploy
## ----------
.PHONY: deploy-revision
deploy-revision: ## Create deploy revision file
	touch public/revision.txt
	rm public/revision.txt
	touch public/revision.txt
	echo "Hash : "$(shell git rev-parse HEAD) >> public/revision.txt
	echo "Build date : "$(shell date +%Y-%m-%d:%H-%M) >> public/revision.txt
