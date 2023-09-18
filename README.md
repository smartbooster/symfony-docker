# Symfony Docker

Development stack based on [Docker](https://www.docker.com/) to run projects with [Symfony](https://symfony.com) + [Node](https://nodejs.org/fr).

## Setup the docker stack from an empty repository

```shell
git clone git@gitlab.com:path/your/project-name.git
cd nouveau-projet
git remote add docker git@github.com:smartbooster/symfony-docker.git
git fetch docker
git checkout docker/main .
mv .env.skeleton .env
git remote remove docker
```

Replace the string *to_replace* in the **APPLICATION** env variable with the client-project format from the project repository.
(see "Environment variables" for other all variable configuration)

Then run the following command:
```shell
make up
```

Once the containers have finished being initialized, you will see the following line "MySQL init process done. Ready for start up."

Then open another terminal and run the following command to install the latest stable version of Symfony.

```shell
make install
# Enter your user password to run sudo commands
# Further on, the prompt will ask you "Do you want to include Docker configuration from recipes?", press enter to continue
```

When you see "Install complete!" on the prompt, go to http://localhost/ to check that the installation worked, if so, commit adding files.

## Environment variables

Default values of .env:

```dotenv
APPLICATION=to_replace # Use to have a unique name on the PHP image build as well as for the database name
NODE_VERSION=18 # default value positioned in docker-compose if not specified in .env
PHP_VERSION=8.2 # default value positioned in docker-compose if not specified in .env
```

If you change the values post `make up` then stop everything with a `make down` then do a `make build` so that docker rebuilds the images with the correct versions.

## Setup the docker stack in an existing repository

```shell
git remote add docker git@github.com:smartbooster/symfony-docker.git
git fetch docker
git checkout docker/main .
rm .env.skeleton
git restore README.md
git remote remove docker
```

Check that the changes in the directories docker and make, as well as the docker-compose.yml and Dockerfile files, are consistent then commit.

## Contributing

Pull requests are welcome.

Thanks to [everyone who has contributed](https://github.com/smartbooster/symfony-docker/contributors) already.

---

*This project is supported by [SmartBooster](https://www.smartbooster.io)*
