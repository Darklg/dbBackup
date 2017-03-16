#!/bin/bash

echo '################';
echo '# DB Backup';
echo '# v 0.1.1';
echo '# By @Darklg';
echo '################';
echo '';

###################################
## Basic vars
###################################

# Get absolute path to the script
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"

###################################
## Config
###################################

CONFIG_FILE="${SCRIPT_PATH}/backup-config.sh";
if [[ ! -f "${CONFIG_FILE}" ]];then
    echo "# You must have a config file !";
    return 0;
else
    echo "# Loading user config";
    . "${CONFIG_FILE}";
fi;

###################################
## Install & Clean
###################################

if [[ ! -d "${BACKUP_FOLDER}" ]];then
    echo "# Creating backup folder";
    mkdir "${BACKUP_FOLDER}";
fi;

echo "# Deleting backups older than ${BACKUP_DAYS} days.";
find "${BACKUP_FOLDER}"* -mtime +"${BACKUP_DAYS}" -exec rm {} \;

###################################
## Backup
###################################

BACKUP_FILE="${BACKUP_FOLDER}/backup-${MYSQL_BASE}-$(date +"%Y%m%d-%H%M%S").sql";

echo "# Backup database";
mysqldump -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASS}" "${MYSQL_BASE}" > "${BACKUP_FILE}";

echo "# Compress backup";
gzip "${BACKUP_FILE}";

###################################
## Good to go
###################################

echo "# Backup is over !";
