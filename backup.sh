#!/bin/bash

echo '################';
echo '# DB Backup';
echo '# v 0.4.0';
echo '# By @Darklg';
echo '################';
echo '';

###################################
## Check requirements
###################################

DBBK_REQUIREMENTS="find gzip mysql mysqldump";
for DBBK_REQ in $DBBK_REQUIREMENTS
do
    command -v "$DBBK_REQ" >/dev/null 2>&1 || { echo >&2 "You need \"${DBBK_REQ}\" to continue."; return 1; }
done;

unset DBBK_REQ;
unset DBBK_REQUIREMENTS;

###################################
## Basic vars
###################################

# Get absolute path to the script
DBBK_SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"

###################################
## Config
###################################

DBBK_CONFIG_FILE="${DBBK_SCRIPT_PATH}/backup-config.sh";
if [ ! -f "${DBBK_CONFIG_FILE}" ]; then
    # No config file : load argument if file
    if [ -f "${1}" ]; then
        echo "# Loading config file specified in argument.";
        . "${1}";
    else
        echo "# You must have a config file. Please create a file named 'backup-config.sh' with this content :";
        echo "######";
        echo "#/bin/bash";
        echo "DBBK_MYSQL_HOST='';";
        echo "DBBK_MYSQL_USER='';";
        echo "DBBK_MYSQL_PASS='';";
        echo "DBBK_MYSQL_BASE='';";
        echo "DBBK_FOLDER='/absolute/path/to/backupfolder';";
        echo "DBBK_DAYS=5;";
        echo "######";
        return 0;
    fi;
else
    echo "# Loading user config";
    . "${DBBK_CONFIG_FILE}";
fi;

# Check if config is ok
if [ -z "${DBBK_DAYS+x}" ] || [ -z "${DBBK_FOLDER+x}" ] || [ -z "${DBBK_MYSQL_USER+x}" ] || [ -z "${DBBK_MYSQL_BASE+x}" ] || [ -z "${DBBK_MYSQL_PASS+x}" ] || [ -z "${DBBK_MYSQL_HOST+x}" ]; then
    echo "# The config file is not valid. Please check the README.";
    return 1
fi

# Create a temporary MySQL config file
echo "
[mysqldump]
user=${DBBK_MYSQL_USER}
password=${DBBK_MYSQL_PASS}

[mysql]
user=${DBBK_MYSQL_USER}
password=${DBBK_MYSQL_PASS}
" > "${DBBK_SCRIPT_PATH}my.cnf";

###################################
## Test MySQL access
###################################

mysql --defaults-file="${DBBK_SCRIPT_PATH}my.cnf" -e exit 2>/dev/null
DBBK_MYSQL_STATUS=$(echo $?);
if [ "${DBBK_MYSQL_STATUS}" -ne 0 ]; then
    echo "# The provided MySQL access are not correct.";
    rm "${DBBK_SCRIPT_PATH}my.cnf";
    return 0;
fi;

###################################
## Install & Clean
###################################

if [ ! -d "${DBBK_FOLDER}" ];then
    echo "# Creating backup folder";
    rm "${DBBK_SCRIPT_PATH}my.cnf";
    mkdir "${DBBK_FOLDER}";
fi;

if [ ! -d "${DBBK_FOLDER}" ];then
    echo "# The backup folder could not be created";
    rm "${DBBK_SCRIPT_PATH}my.cnf";
    return 0;
fi;

###################################
## Backup
###################################

DBBK_NAME="backup-${DBBK_MYSQL_BASE}-$(date +"%Y%m%d-%H%M%S").sql";
DBBK_FILE="${DBBK_FOLDER}/${DBBK_NAME}";
DBBK_FILE_GZ="${DBBK_FOLDER}/${DBBK_NAME}.gz";

echo "# Backup database";
mysqldump --defaults-file="${DBBK_SCRIPT_PATH}my.cnf" -h "${DBBK_MYSQL_HOST}" "${DBBK_MYSQL_BASE}" > "${DBBK_FILE}";

DBBK_FILE_SIZE="$(wc -c <"${DBBK_FILE}")";

if [ "${DBBK_FILE_SIZE}" -lt 4000 ]; then
    echo "/!\\ The backup file seems really small. You should check it. /!\\";
fi;

echo "# Compress backup";
gzip "${DBBK_FILE}";

###################################
## Good to go
###################################

if [ "$DBBK_DAYS" -gt 0 ]; then
    echo "# Deleting backups older than ${DBBK_DAYS} days";
    find "${DBBK_FOLDER}"* -mtime +"${DBBK_DAYS}" -exec rm {} \;
fi;

echo "# Backup is over";
echo "# -> ${DBBK_NAME}.gz : $(($(wc -c <"${DBBK_FILE_GZ}")/1024))KB";

###################################
## Clean up
###################################

rm "${DBBK_SCRIPT_PATH}my.cnf";
unset DBBK_CONFIG_FILE;
unset DBBK_MYSQL_STATUS;
unset DBBK_DAYS;
unset DBBK_FILE;
unset DBBK_FILE_GZ;
unset DBBK_FILE_SIZE;
unset DBBK_FOLDER;
unset DBBK_MYSQL_BASE;
unset DBBK_MYSQL_HOST;
unset DBBK_MYSQL_PASS;
unset DBBK_MYSQL_USER;
unset DBBK_NAME;
unset DBBK_SCRIPT_PATH;
