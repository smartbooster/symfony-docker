# Symfony Docker

Installeur basé sur [Docker](https://www.docker.com/) pour faire tourner des projets [Symfony](https://symfony.com) + Node.

## Synchro de la stack docker dans repository projet vide

```shell
git clone git@gitlab.com:smartbooster/path/nouveau-projet.git
cd nouveau-projet
git remote add docker git@gitlab.com:smartbooster/hosting/symfony-docker.git
git fetch docker
git checkout docker/main .
cp .env.skeleton .env
git remote remove docker
```

Remplacez la chaine to_replace dans la variable d'env APPLICATION par le format client-projet du repository projet.  
(cf. "Environments variables" pour les autres paramètres d'install ajustables)

Puis lancer la commande suivante :
```shell
make up
```

Une fois que les containers ont fini d'être initialisés, vous verrez la ligne suivante "MySQL init process done. Ready for start up." 

Ouvrez alors un autre terminal et lancer la commande suivante pour installer la dernière version stable de Symfony.

```shell
make install
```

Rendez-vous sur http://localhost/ pour vérifier que l'install puis commiter.

## Environments variables

Valeurs par défaut du .env :

```dotenv
# Utiliser pour avoir un nom unique sur le build de l'image PHP ainsi que pour le nom de la database
APPLICATION=php
NODE_VERSION=18
PHP_VERSION=8.2
```

Si vous changer les valeurs post make up alors arrêter tous avec make down puis faite un make build pour que docker rebuild les images avec les bonnes versions.

## Synchro de la stack docker dans repository existant

```shell
git remote add docker git@gitlab.com:smartbooster/hosting/symfony-docker.git
git fetch docker
git checkout docker/main .
rm .env.skeleton
git restore README.md
git remote remove docker
```

Vérifier que les changements dans les dossiers docker, make ainsi que sur les fichiers docker-compose.yml et Dockerfile soient cohérent puis commiter.
