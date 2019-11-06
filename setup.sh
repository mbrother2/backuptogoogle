#!/bin/bash
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

# Download gdrive file
echo "Downloading gdrive file from github..."
curl -o ${GDRIVE_BIN} ${GITHUB_LINK}/gdrive_linux
chmod 755 ${GDRIVE_BIN}

# Download script cron file
echo ""
echo "Downloading script cron file from github..."
curl -o ${CRON_BACKUP} ${GITHUB_LINK}/cron_backup.sh
chmod 755 ${CRON_BACKUP}

# Setup gdrive credential
echo ""
echo "Setting up gdrive credential..."
gdrive about

# Set up cron backup
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
echo "* * * * * sh /usr/sbin/cron_backup.sh >/dev/null 2>&1" >> ${CRON_FILE}
systemctl restart crond
