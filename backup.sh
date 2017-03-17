#!/bin/bash

echo '################';
echo '# DB Backup';
echo '# v 0.2.0';
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

# Create a temporary MySQL config file
echo "
[mysqldump]
user=${MYSQL_USER}
password=${MYSQL_PASS}
" > "${SCRIPT_PATH}my.cnf";

###################################
## Install & Clean
###################################

if [[ ! -d "${BACKUP_FOLDER}" ]];then
    echo "# Creating backup folder";
    mkdir "${BACKUP_FOLDER}";
fi;

if [[ ! -d "${BACKUP_FOLDER}" ]];then
    echo "# The backup folder could not been created";
    return 0;
fi;

echo "# Deleting backups older than ${BACKUP_DAYS} days.";
find "${BACKUP_FOLDER}"* -mtime +"${BACKUP_DAYS}" -exec rm {} \;

###################################
## Backup
###################################

BACKUP_NAME="backup-${MYSQL_BASE}-$(date +"%Y%m%d-%H%M%S").sql";
BACKUP_FILE="${BACKUP_FOLDER}/${BACKUP_NAME}";
BACKUP_FILE_GZ="${BACKUP_FOLDER}/${BACKUP_NAME}.gz";

echo "# Backup database";
mysqldump --defaults-file="${SCRIPT_PATH}my.cnf" -h "${MYSQL_HOST}" "${MYSQL_BASE}" > "${BACKUP_FILE}";

echo "# Compress backup";
gzip "${BACKUP_FILE}";

###################################
## Good to go
###################################

rm "${SCRIPT_PATH}my.cnf";
echo "# Backup is over";
echo "# -> ${BACKUP_NAME}.gz : $(($(wc -c <"${BACKUP_FILE_GZ}")/1024))KB";
