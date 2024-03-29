develop: ## Run development server.
	gulp develop

build: ## Build for deployment.
	gulp build

build-debug: ## Build for debugging.
	gulp build

cache: ## Generate media cache.
	gulp cache

deploy: build ## Build and deploy to server. Needs .env variables to be set.
	bash ./source/scripts/deploy.sh



# The following makes this file self-documenting.
# See: https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
