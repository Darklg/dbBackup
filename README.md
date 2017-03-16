# dbBackup
Backup a MySQL database on a shared hosting and keep an history

## Config
Create a config file named `backup-config.sh` in the backup repository.

```#/bin/bash
MYSQL_HOST='';
MYSQL_USER='';
MYSQL_PASS='';
MYSQL_BASE='';
BACKUP_FOLDER='/absolute/path/to/backupfolder';
BACKUP_DAYS=5;
```
