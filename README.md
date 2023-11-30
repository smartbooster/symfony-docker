# Symfony Docker

Development stack based on [Docker](https://www.docker.com/) to run projects with [Symfony](https://symfony.com) + [Node](https://nodejs.org/fr).

## Setup the docker stack from an empty repository

```shell
git clone git@gitlab.com:path/your/project-name.git
cd project-name
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

## Setup the docker stack in an existing repository for the first time

If you have any hidden files in .docker directory, you can delete them as they will be now kept in the docker directory.

Be sure that the docker stack of the project is stop before doing the following command :

```shell
sudo rm -rf var/data/
git remote add docker git@github.com:smartbooster/symfony-docker.git
git fetch docker
git checkout docker/main .
make docker-post-fetch
```

- Don't forget to set APPLICATION variable in the .env and the MYSQL_ADDON_URI to be mysql://dev:dev@mysql:3306/{APPLICATION} (replace {APPLICATION} with the value of APPLICATION)
- Then do a `make up`, wait to see "MySQL init process done. Ready for start up.", and on another terminal do a `make install`.
- Check that the project still works the same as before fetching the docker stack.
- Check that the changes in the directories docker and make, as well as the docker-compose.yml and Dockerfile files, are consistent then commit them on your project repository.

## Fetch the symfony-docker files update on a setup repo with the stack

From now if you need to fetch the latest changes from smartbooster/symfony-docker on your well configure repository you only need to run the following command (be sure to stop your stack before that) :

```shell
make docker-fetch 
# or its shortcut : 
make df
```

And as always relaunch the stack (make up, make install), check the diffs and commit any changes that feels relevant to you.

## Push docker/make related files from the project to the symfony-docker stack

If you happen to changes docker/make files from your project, and feel like it might be a generic enhancement that need to be push on every project with the symfony-docker stack, here is what to do :

- Add the smartbooster/symfony-docker remote if it's not on your remote list anymore
- Be sure that your docker/make changes on the project are put on a dedicated commit (without any project related files)
- Cherry-pick that commit into the docker remote history
- Give it a proper branch name, push it and make a GitHub Pull Request, and ping @mathieu-ducrot for review
- Once the PR is accepted and merged, other project can now do a `make df` to benefit the latest changes

## How to use Blackfire

Create a .env.blackfire file and fill in with your credentials :

```dotenv
BLACKFIRE_SERVER_ID=your_server_id
BLACKFIRE_SERVER_TOKEN=your_server_token
```

Restart the docker stack if it was already running without the env var, enjoy profiling !

## Contributing

Pull requests are welcome.

Thanks to [everyone who has contributed](https://github.com/smartbooster/symfony-docker/contributors) already.

---

*This project is supported by [SmartBooster](https://www.smartbooster.io)*
