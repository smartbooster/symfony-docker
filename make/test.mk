##
## Tests
## -----
.PHONY: phpunit coverage-text coverage-html coverage jest
phpunit: ## Launch all tests
	vendor/bin/simple-phpunit --colors=never

coverage-text: ## Launch all tests with code coverage text
	XDEBUG_MODE=coverage vendor/bin/simple-phpunit --coverage-text

coverage-html: ## Launch all tests with code coverage html
	XDEBUG_MODE=coverage vendor/bin/simple-phpunit --coverage-html build/phpunit

coverage: ## Launch all tests with code coverage html and text for CI
	XDEBUG_MODE=coverage vendor/bin/simple-phpunit --coverage-text --colors=never --coverage-html build/phpunit --coverage-cobertura build/phpunit-cobertura.xml --log-junit build/phpunit-report.xml

jest: ## Launch jest tests
	yarn jest --no-color --collect-coverage
