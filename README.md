# dbBackup
Backup a MySQL database on a shared hosting and keep an history

## Config
Create a config file named `backup-config.sh` in the backup repository.

```#/bin/bash
DBBK_MYSQL_HOST='';
DBBK_MYSQL_USER='';
DBBK_MYSQL_PASS='';
DBBK_MYSQL_BASE='';
DBBK_FOLDER='/absolute/path/to/backupfolder';
DBBK_DAYS=5;
```
