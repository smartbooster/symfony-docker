# Symfony Docker

Development stack based on [Docker](https://www.docker.com/) to run projects with [Symfony](https://symfony.com) + [Node](https://nodejs.org/fr).

## Requirements

To correctly use this stack you must have :
- **Docker** (version ^24)
- **Docker Compose** (v2.x)
- **Git** (^2.43)
- **make** (^4.3)
- Ssh connexion with gitlab (for project hosted on gitlab)

> We use such docker version for the multi `FROM` Dockerfile instruction to work properly.

Checkout our documentations if you need help to install them :

- [Docker documentation](docs/docker.md)
- [Git documentation](docs/git.md)
- [make documentation](docs/make.md)
- [Add gitlab ssh key](docs/gitlab.md)

## Setup

Depending on your current situation, choose among the following the right step to setup the symfony-docker stack :

- [I want to install the stack on an empty repository](#setup-the-docker-stack-from-an-empty-repository)
- [I already have some docker configuration but not this one and I want to replace it](#replace-your-current-project-docker-stack-with-the-smartboostersymfony-docker)
- [I already have the symfony-docker stack installed and want to update it with the latest changes](#fetch-the-symfony-docker-latest-changes-on-an-already-setup-repository)

### Setup the docker stack from an empty repository

```shell
# First clone your project if you haven't and cd into it
git clone git@gitlab.com:path/your/project-name.git
cd project-name
# Add the symfony-docker remote to fetch the stack files
git remote add docker git@github.com:smartbooster/symfony-docker.git
git fetch docker
git checkout docker/main .
mv .env.skeleton .env
rm -r .github docs
rm CHANGELOG.md
# Generate the lock file and remove the remote
make docker-generate-lock
git remote remove docker
```

Replace the string *to_replace* in the **APPLICATION** env variable with the client-project format from the project repository.
(see [Environment variables](#environment-variables) for all variables configurations)

Then run the following command:
```shell
make up
```

Once the containers have finished being initialized, you will see the following line "MySQL init process done. Ready for start up."

Then open another terminal and run the following command to install the latest stable version of Symfony.

```shell
make install
# Enter your user password to run sudo commands required for the init-rw-files Makefile command
# Further on, the prompt will ask you "Do you want to include Docker configuration from recipes?", press n and enter to skip recipe configuration.
```

When you see "Install complete!" on the prompt, go to http://localhost/ to check that the installation worked, if so, commit adding files.

### Replace your current project docker stack with the smartbooster/symfony-docker

If you have any hidden files in .docker directory, you can delete them as they will be now kept in the docker directory.

Be sure that the docker stack of the project is stop before doing the following command :

```shell
git remote add docker git@github.com:smartbooster/symfony-docker.git
git fetch docker
git checkout docker/main .
make docker-generate-lock
git remote remove docker
make docker-post-fetch
```

- Set the following variable in your .env 
  - APPLICATION 
  - PHP_VERSION
  - NODE_VERSION
  - MYSQL_ADDON_URI replace your current value with mysql://dev:dev@mysql:3306/{APPLICATION} (replace {APPLICATION} with the value of APPLICATION)
- Then do a `make up`, wait to see "MySQL init process done. Ready for start up.", and on another terminal do a `make install`.
- Check that the project still works the same as before fetching the docker stack.
- Make sure your `gitlab-ci.yaml` build-image and test jobs have the same content as written in this repository.
- Be sure to add the generated symfony-docker.lock to your committed files to keep track of which version of the stack is setup on your project.
- Check that the changes in the directories docker and make, as well as the docker-compose.yml and Dockerfile files, are consistent then commit them on your project repository.
- On Clever Cloud, go to each environment application and check the value of the `CC_POST_BUILD_HOOK` environment variable. According to your needs, update which files should be set.

All the steps above need to be done only once. Next you can refer to the next section to see how to fetch the latest changes of this stack.

### Fetch the symfony-docker latest changes on an already setup repository

If you need to fetch the latest changes from the smartbooster/symfony-docker repository on your already configured project repository, you only need to run the following command :

```shell
# First be sure to stop your stack before that if needed with the make down command, then do the following :
make docker-fetch 
# or its alias : 
make df
```

Relaunch the stack (`make up` + `make install` on another terminal if some changes are made on the Dockerfile or make/install.mk files).

> A symfony-docker.lock while be generated each time you run the docker-fetch.   
> This file helps you to keep track of which version of the docker stack you are currently using.  
> It should be committed on your project.

Finally, check the diffs and commit any changes that feels relevant to you.

## Working on the symfony-docker stack

### Push docker/make related files from the project to the symfony-docker stack

If you happen to changes docker/make files from your project, and feel like it might be a generic enhancement that need to be push on every project with the symfony-docker stack, here is what to do :

- Add the smartbooster/symfony-docker remote if it's not on your remote list anymore
- Be sure that your docker/make changes on the project are put on a dedicated commit (without any project related files)
- Cherry-pick that commit into the docker remote history
- Give it a proper branch name, push it and make a GitHub Pull Request, and ping @mathieu-ducrot for review
- Once the PR is accepted and merged, other project can now do a `make df` to benefit the latest changes

## Usage

### Makefile command

#### Add extra scripts steps to existing Makefile commands

Some Makefile commands are defined through **Double-Colon Rules** and offer the possibility to add more script to the current command.

For it to work : create a new **make/zproject.mk** file and named the existing `command::` you wish to add script step.
Here is an example of adding the smart parameter loading script :  

```bash
# make/zproject.mk
orm-load-minimal::
	$(CONSOLE) smart:parameter:load
orm-load-fake::
	$(CONSOLE) smart:parameter:load
update::
	$(CONSOLE) smart:parameter:load
```

_The file must be named zproject.mk to guaranty that its content is parsed last and therefore executed after the stack commands content._  
_Here is a link to the [Double-Colon Rules Makefile documentation](https://www.gnu.org/software/make/manual/html_node/Double_002dColon.html) for better understanding._

**This is the list of all available Double-Colon commands that you can add extra scripts steps:**
- All commands from the make/orm.mk file
- The `update` command from the make/install.mk file

If you need more stack commands to be defined through the Double-Colon Rules, please send us a PR.

#### Add custom project Makefile command

You can use the **make/zproject.mk** file to add dedicated custom project Makefile command.

> All commands from this file are project specific and must not be committed to this repository.

If you feel like you are adding a command that is generic and should be added to the stack put her in the dedicated 
make/{category}.mk and refer to the [Working on the symfony-docker stack](#working-on-the-symfony-docker-stack) documentation section.

### Environment variables

Default values of .env:

```dotenv
APPLICATION=to_replace # Use to have a unique name on the PHP image build as well as for the database name
NODE_VERSION=18 # default value positioned in docker-compose if not specified in .env
PHP_VERSION=8.2 # default value positioned in docker-compose if not specified in .env
```

If you change the version values post `make up` then stop everything with a `make down` then do a `make build` so that docker rebuilds the images with the correct versions.

### Fix the Node Error digital envelope routines::unsupported ERR_OSSL_EVP_UNSUPPORTED

If you are compiling your asset with a recent Node version (17+) and still having an old webpack@^4 you could have the 
following error when doing a `yarn run dev` or `yarn run build` :

```bash
node:internal/crypto/hash:69
  this[kHandle] = new _Hash(algorithm, xofLen);
                  ^

Error: error:0308010C:digital envelope routines::unsupported
    at new Hash (node:internal/crypto/hash:69:19)
    at Object.createHash (node:crypto:133:10)
    at module.exports (/app/node_modules/webpack/lib/util/createHash.js:135:53)
    at NormalModule._initBuildHash (/app/node_modules/webpack/lib/NormalModule.js:417:16)
    at /app/node_modules/webpack/lib/NormalModule.js:452:10
    at /app/node_modules/webpack/lib/NormalModule.js:323:13
    at /app/node_modules/loader-runner/lib/LoaderRunner.js:367:11
    at /app/node_modules/loader-runner/lib/LoaderRunner.js:233:18
    at context.callback (/app/node_modules/loader-runner/lib/LoaderRunner.js:111:13)
    at /app/node_modules/babel-loader/lib/index.js:59:103 {
  opensslErrorStack: [ 'error:03000086:digital envelope routines::initialization error' ],
  library: 'digital envelope routines',
  reason: 'unsupported',
  code: 'ERR_OSSL_EVP_UNSUPPORTED'
}
```

If that the case, do the following steps to fix this error :

- Add this environment variable into your .env file : `NODE_OPTIONS=--openssl-legacy-provider`
- Add it to the .gitlab-ci.yml `variables` of the `test` job : `NODE_OPTIONS: '--openssl-legacy-provider'`
- And finally, add it to all Clever Cloud applications where the project is deployed on : `NODE_OPTIONS="--openssl-legacy-provider"`

_Ref link of the issue : https://github.com/webpack/webpack/issues/14532#issuecomment-947012063_

### How to use Blackfire

> Due to [blackfire conflicting with the xdebug extension](https://support.blackfire.platform.sh/hc/en-us/articles/4842942116754-PHP-crashes-with-a-segmentation-fault#check-for-conflicting-extensions), 
> we decided to extract the blackfire.ini from our Dockerfile steps and make it an on demand feature available through a dedicated docker-compose volume line

1. First Uncomment the following line in the docker-compose.yml file :

```yml
php:
  # ...
  volumes:
    - ./:/app
    - ./var/log/php/:/app/var/log
    - ./docker/xdebug_profile/:/tmp/docker_xdebug/
    - ./docker/php/conf.d/blackfire.ini:/usr/local/etc/php/conf.d/blackfire.ini # <= this one
```

> Be sure to have the XDEBUG_MODE env var unset or set with the 'off' value to minimize the impact of xdebug extension on profiling performance. 

2. Next fill in the .env.blackfire file with your credentials :

```dotenv
BLACKFIRE_SERVER_ID=your_server_id
BLACKFIRE_SERVER_TOKEN=your_server_token
```

3. Restart the docker stack, you can now enjoy profiling with Blackfire !

> As mentioned before, be aware that while the blackfire extension is enabled you won't be able to perform the Makefile
> `coverage` test commands (you will be prompted with a Segmentation fault error if you try).  
> So don't forget to comment the blackfire.ini volume line again after you are done profiling with Blackfire.

**Also, the uncommented line and your blackfire credentials changes mustn't be committed to this repository**

## Other documentations
- [Docker documentation](docs/docker.md)
- [Git documentation](docs/git.md)
- [make documentation](docs/make.md)
- [Add gitlab ssh key](docs/gitlab.md)
- [Phpstorm](docs/phpstorm.md)
- [Clevercloud](docs/clevercloud.md)

## Contributing

Pull requests are welcome.

Thanks to [everyone who has contributed](https://github.com/smartbooster/symfony-docker/contributors) already.

---

*This project is supported by [SmartBooster](https://www.smartbooster.io)*
