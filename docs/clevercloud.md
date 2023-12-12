# Clever Cloud

We use **Clever Cloud** has our main PaaS of choice to deploy our project.
Here is a compilation of doc about to interact between the infra stack of the project and Clever Cloud.

## Import a backup from a Clever Cloud add-on down to a local project

Sometimes, we must import distant server SQL database to check unexpected behavior with our local debugging tools.    
That why each developer needs to know this procedure in order to be independent for such intervention. 

1. First find your add-on from the Clever Cloud console, then click on the Backups menu to list all available dumps and click on the download link you want to import.

![Clever Cloud downloading databases](images/cc_download_db.png)

Check the type of the downloaded file.  
If it's a `.gz`, you can extract it with the following command :

```bash
zcat mysql_idXXXXXX.sql.gz > dump.sql
```

2. Now empty your current local database using the following Makefile command:

```bash
# ssh into the php container of the local project stack
make ssh
# and then recreate the database
make orm-db-recreate
```

_This will recreate an empty database and ease import by not having any `CREATE TABLE` collision._ 

3. Then open **MySQL Workbench**, click on your configured local connection, then on left panel choose _Administration > Management > Data Import/Restore_.

![Clever Cloud downloading databases](images/sql_workbench_import.png)

- On **Import Options** select Import from Self-Contained File and select your download dump.sql via the "..." button
- On **Default Target Schema** select the database name of the project
- Then click on the **Start Import** button

When you see the line "Import of /home/user/Downloads/dump.sql has finished" on the Log screen that mean MySQL Workbench has correctly imported the dump.

4. Finally, check that your ORM is still in sync with imported database with the following command

```bash
make orm-status
# if there is any migration that needs to be processed, run the final command
make orm-update
```

You are now good to debug the downloaded server database on your local machine!