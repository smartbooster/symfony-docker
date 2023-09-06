.PHONY: install-symfony
install-symfony:
	# Ajout des variables d'env en vue de doctrine
	echo "" >> .env
	echo "###> doctrine/doctrine-bundle ###" >> .env
	echo "MYSQL_ADDON_URI=mysql://dev:dev@mysql:3306/${APPLICATION}" >> .env
	echo "MYSQL_ADDON_VERSION=8.0" >> .env
	echo "###< doctrine/doctrine-bundle ###" >> .env
	rm -f .env.skeleton
	# Install projet SF dans un dossier temporaire
	docker compose exec --user=dev php git config --global user.email "dev@smartbooster.io"
	docker compose exec --user=dev php git config --global user.name "Smartbooster"
	docker compose exec --user=dev php symfony new --dir=project --version=stable --webapp --debug
	# Déplacement des sources à la racine du projet et suppression du dossier temporaire
	sed -n '16,20p' project/.env >> ./.env # récup le APP_ENV et le APP_SECRET aléatoire généré par l'install
	rm -rf project/var project/.env.test project/.gitignore project/docker-compose.yml project/docker-compose.override.yml
	mv project/* ./
	rm -rf project
	# Fix des droits des dossiers var & public/files
	sudo mkdir ./var/cache
	sudo chmod -R 777 ./var/cache
	sudo chmod -R 777 ./var/log
	mkdir -p public/files
	sudo chmod -R 777 public/files
	# Fix du doctrine.yaml + suppression des bundles inutiles du SF webapp
	sed '3,4c\        url: "%env(resolve:MYSQL_ADDON_URI)%"\n        server_version: "%env(resolve:MYSQL_ADDON_VERSION)%"' -i config/packages/doctrine.yaml
	sed '5,8d' -i config/packages/doctrine.yaml
	rm config/packages/messenger.yaml
	docker compose exec --user=dev php composer remove symfony/doctrine-messenger

.PHONY: remove-symfony
remove-symfony:
	sudo rm -rf bin config migrations node_modules public projet src templates tests translations vendor ./var/cache ./var/log/php/* composer.json composer.lock phpunit.xml.dist symfony.lock yarn.lock
