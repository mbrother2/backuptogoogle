#!/bin/bash

# Set variables
GITHUB_LINK="https://raw.githubusercontent.com/mbrother2/backuptogoogle/master"
GDRIVE_BIN="/usr/sbin/gdrive"
CRON_BACKUP="/usr/sbin/cron_backup.sh"
LOG_FILE="/var/log/backuptogoogle.log"

# Color variables
BLUE='\e[94m'
GRAY='\e[90m'
GREEN='\e[32m'
PURPLE='\e[35m'
RED='\e[31m'
YELLOW='\e[33m'
REMOVE='\e[0m'

# Change color of words
change_color(){
    case $1 in
          blue) echo -e "${BLUE}$2${REMOVE}";;
          gray) echo -e "${GRAY}$2${REMOVE}";;
         green) echo -e "${GREEN}$2${REMOVE}";;
        purple) echo -e "${PURPLE}$2${REMOVE}";;
           red) echo -e "${RED}$2${REMOVE}";;
        yellow) echo -e "${YELLOW}$2${REMOVE}";;
             *) echo "$2";;
    esac
}

check_md5sum(){
    curl -o $2 ${GITHUB_LINK}/$1
    ORIGIN_MD5=`curl -s ${GITHUB_LINK}/MD5SUM | grep $1 | awk '{print $1}'`
    LOCAL_MD5=`md5sum $2 | awk '{print $1}'`
    if [ "${ORIGIN_MD5}" == "${LOCAL_MD5}" ]
    then
        show_write_log "Check md5sum for file $1 successful"
    else
        show_write_log "`change_color red [CHECKS][FAIL]` Can not check md5sum for file $1. Exit!"
        exit 1
    fi
}

# Write log
show_write_log(){
    echo "`date "+[ %d/%m/%Y %H:%M:%S ]"` $1" | tee -a ${LOG_FILE}
}

# Check network
check_network(){
    show_write_log "Cheking network..."
    if ping -c 1 -w 1 raw.githubusercontent.com > /dev/null
    then
        show_write_log "Network OK!"
    else
        show_write_log "`change_color red [CHECKS][FAIL]` Can not connect to Github file, please check your network"
        exit 1
    fi
}

# Detect OS
detect_os(){
    show_write_log "Checking OS..."
    if [ -f /etc/redhat-release ]
    then
        CRON_FILE="/var/spool/cron/root"        
    elif [ -f /usr/bin/lsb_release ]
    then
        CRON_FILE="/var/spool/cron/crontabs/root"
    else
        show_write_log "Sorry! We do not support your OS."
        exit 1
    fi
    show_write_log "OS supported!"
}

# Change backup config file
change_backup_config(){
    if [ ! -z $2 ]
    then
        sed -i "s#^$1=.*#$1=\"$2\"#g" ${CRON_BACKUP}
    fi
}

# Download file from Github
download_file(){
    show_write_log "Downloading gdrive file from github..."
    check_md5sum gdrive_linux "${GDRIVE_BIN}"
    show_write_log "Downloading script cron file from github..."
    check_md5sum cron_backup.sh "${CRON_BACKUP}"
    chmod 755 ${GDRIVE_BIN} ${CRON_BACKUP}
}

# Setup gdrive credential
setup_credential(){
    show_write_log "Setting up gdrive credential..."
    gdrive about
}

# Set up cron backup
setup_cron(){
    show_write_log "Setting up cron backup..."
    read -p " Which directory do you want to upload to Google Drive?(default /backup): " BACKUP_DIR
    read -p " How many days you want to keep backup on Google Drive?(default 7): " DAY_REMOVE
    if [ ! -d ${BACKUP_DIR:-/backup} ]
    then
        show_write_log "`change_color red [WARNING]` Directory ${BACKUP_DIR:-/backup} does not exist! Ensure you will be create it after."
        sleep 3
    fi
    change_backup_config BACKUP_DIR ${BACKUP_DIR}
    change_backup_config LOG_FILE ${LOG_FILE}
    change_backup_config DAY_REMOVE ${DAY_REMOVE}
    echo "PATH=$PATH" >> ${CRON_FILE}
    echo "0 0 * * * sh /usr/sbin/cron_backup.sh >/dev/null 2>&1" >> ${CRON_FILE}
    systemctl restart crond
}

show_info(){
    echo ""
    show_write_log "SUCESSFUL! Your information:"
    show_write_log "---"
    show_write_log "Backup dir : ${BACKUP_DIR:-/backup}"
    show_write_log "Log file   : ${LOG_FILE}"
    show_write_log "Keep backup: ${DAY_REMOVE:-7} days"
    show_write_log "---"
    show_write_log "Gdrive bin file : ${GDRIVE_BIN}"
    show_write_log "Google token    : /root/.gdrive/token_v2.json"
    show_write_log "Cron backup file: ${CRON_BACKUP}"
    show_write_log "Cron backup     : 0 0 * * * sh ${CRON_BACKUP} >/dev/null 2>&1"
    echo ""
    echo " If you get trouble when use backuptogoogle please go to following URLs:"
    echo " https://backuptogoogle.com"
    echo " https://github.com/mbrother2/backuptogoogle"
}

# Main functions
check_network
detect_os
download_file
setup_credential
setup_cron
show_info