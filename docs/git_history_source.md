# How to get the .git history of an installed vendor

If you work on bundle inside a project, it's simpler to get git sources inside bundle in this project rather than open it on standalone.
You can modify elements and use it directly into parent project, and you can push it directly.

To do that, Firstly you must require bundle on "normal" way.
```shell
composer req smartbooster/symfony-docker
```

Then you have to reinstall bundle with option `--prefer-source`

```shell
composer reinstall smartbooster/symfony-docker --prefer-source
```

After you can open this project from vendor folder in new ide project or add a second remote.

For add a second remote on phpstorm, got to Git -> Manage Remotes ... then add with "+".