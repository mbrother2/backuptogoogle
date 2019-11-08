#!/bin/bash

# Set variables
GITHUB_LINK="https://raw.githubusercontent.com/mbrother2/backuptogoogle/master"
GDRIVE_BIN="/usr/sbin/gdrive"
CRON_BACKUP="/usr/sbin/cron_backup.sh"
CRON_FILE="/var/spool/cron/root"

# Change backup config file
change_backup_config(){
    if [ ! -z $2 ]
    then
        sed -i "s#^$1=.*#$1=\"$2\"#g" ${CRON_BACKUP}
    fi
}

# Download file from Github
download_file(){
    echo "Downloading gdrive file from github..."
    curl -o ${GDRIVE_BIN} ${GITHUB_LINK}/gdrive_linux
    echo ""
    echo "Downloading script cron file from github..."
    curl -o ${CRON_BACKUP} ${GITHUB_LINK}/cron_backup.sh
    chmod 755 ${GDRIVE_BIN} ${CRON_BACKUP}
}

# Setup gdrive credential
setup_credential(){
    echo ""
    echo "Setting up gdrive credential..."
    gdrive about
}

# Set up cron backup
setup_cron(){
    echo ""
    echo "Setting up cron backup..."
    echo $PATH >> /var/spool/cron/root
    read -p " Which directory do you want to upload to Google Drive?(default /backup): " BACKUP_DIR
    read -p " Which file do you want to get gdrive log?(default /var/log/gdrive.log): " LOG_FILE
    read -p " How many days you want to keep backup on Google Drive?(default 7): " DAY_REMOVE

    change_backup_config BACKUP_DIR ${BACKUP_DIR}
    change_backup_config LOG_FILE ${LOG_FILE}
    change_backup_config DAY_REMOVE ${DAY_REMOVE}
    echo "PATH=$PATH" >> ${CRON_FILE}
    echo "0 0 * * * sh /usr/sbin/cron_backup.sh >/dev/null 2>&1" >> ${CRON_FILE}
    systemctl restart crond
}

show_info(){
    echo ""
    echo "SUCESSFUL! Your information:"
    echo "---"
    echo "Backup dir : ${BACKUP_DIR:-/backup}"
    echo "Log file   : ${LOG_FILE:-/var/log/gdrive.log}"
    echo "Keep backup: ${DAY_REMOVE:-7} days"
    echo "---"
    echo "Gdrive bin file : ${GDRIVE_BIN}"
    echo "Cron backup file: ${CRON_BACKUP}"
    echo "Cron backup     : 0 0 * * * sh ${CRON_BACKUP} >/dev/null 2>&1"
    echo ""
    echo " If you get trouble when use backuptogoogle please go to following URLs:"
    echo " https://backuptogoogle.com"
    echo " https://github.com/mbrother2/backuptogoogle"
}

# Main functions
download_file
setup_credential
setup_cron
show_info