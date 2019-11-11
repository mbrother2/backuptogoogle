#!/bin/bash

# Set variables
GITHUB_LINK="https://raw.githubusercontent.com/mbrother2/backuptogoogle/master"
BUTGG_CONF="${HOME}/.gdrive/butgg.conf"
DF_BACKUP_DIR="${HOME}/backup"
DF_LOG_FILE="${HOME}/.gdrive/butgg.log"
DF_DAY_REMOVE="7"
GDRIVE_BIN="${HOME}/.gdrive/script/gdrive"
CRON_BACKUP="${HOME}/.gdrive/script/cron_backup.sh"
SETUP_FILE="${HOME}/.gdrive/script/butgg.sh"

# Color variables
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
REMOVE='\e[0m'

# Change color of words
change_color(){
    case $1 in
         green) echo -e "${GREEN}$2${REMOVE}";;
           red) echo -e "${RED}$2${REMOVE}";;
        yellow) echo -e "${YELLOW}$2${REMOVE}";;
             *) echo "$2";;
    esac
}

# Check MD5 of downloaded file
check_md5sum(){
    curl -o $2 ${GITHUB_LINK}/$1
    ORIGIN_MD5=`curl -s ${GITHUB_LINK}/MD5SUM | grep $1 | awk '{print $1}'`
    LOCAL_MD5=`md5sum $2 | awk '{print $1}'`
    if [ "${ORIGIN_MD5}" == "${LOCAL_MD5}" ]
    then
        show_write_log "Check md5sum for file $1 successful"
    else
        show_write_log "`change_color red [CHECKS][FAIL]` Can not verify md5sum for file $1. Exit!"
        exit 1
    fi
}

# Write log
show_write_log(){
    echo "`date "+[ %d/%m/%Y %H:%M:%S ]"` $1" | tee -a ${DF_LOG_FILE}
}

# Prepare setup
pre_setup(){
    [[ ! -d ${HOME}/.gdrive/script ]] && mkdir -p ${HOME}/.gdrive/script
    if [ ! -d ${HOME}/.gdrive/script ]
    then
        echo "Can not create directory ${HOME}/.gdrive/script. Exit"
        exit 1
    fi
    echo 1 >> ${HOME}/.gdrive/script/test.txt
    if [ $? -ne 0 ]
    then
        echo "Can not write to ${HOME}/.gdrive/script. Exit"
        exit 1
    fi    
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
        CRON_FILE="/var/spool/cron/${USER}"        
    elif [ -f /usr/bin/lsb_release ]
    then
        CRON_FILE="/var/spool/cron/crontabs/${USER}"
    else
        show_write_log "Sorry! We do not support your OS."
        exit 1
    fi
    show_write_log "OS supported!"
}

# Change backup config file
change_backup_config(){
    if [ "$3" == "" ]
    then
        VAR=$1
        eval "$VAR"="$2"
    else
        VAR=$1
        eval "$VAR"="$3"
    fi
    sed -i "s#^$1=.*#$1=\"$2\"#g" ${BUTGG_CONF}
}

# Download file from Github
download_file(){
    show_write_log "Downloading gdrive file from github..."
    check_md5sum gdrive_linux "${GDRIVE_BIN}"
    show_write_log "Downloading script cron file from github..."
    check_md5sum cron_backup.sh "${CRON_BACKUP}"
    show_write_log "Downloading setup file from github..."
    check_md5sum butgg.sh "${SETUP_FILE}"
    chmod 755 ${GDRIVE_BIN} ${CRON_BACKUP} ${SETUP_FILE}
}

# Setup gdrive credential
setup_credential(){
    show_write_log "Setting up gdrive credential..."
    gdrive about
}

# Set up cron backup
setup_cron(){
    show_write_log "Setting up cron backup..."
    read -p " Which directory do you want to upload to Google Drive?(default ${DF_BACKUP_DIR}): " BACKUP_DIR
    read -p " How many days you want to keep backup on Google Drive?(default ${DF_DAY_REMOVE}): " DAY_REMOVE    
    change_backup_config BACKUP_DIR ${DF_BACKUP_DIR} ${BACKUP_DIR}
    change_backup_config DAY_REMOVE ${DF_DAY_REMOVE} ${DAY_REMOVE}
    if [ ! -d ${BACKUP_DIR} ]
    then
        show_write_log "`change_color yellow [WARNING]` Directory ${BACKUP_DIR} does not exist! Ensure you will be create it after."
        sleep 3
    fi
    echo "PATH=$PATH" >> ${CRON_FILE}
    if [ $? -ne 0 ]
    then
        show_write_log "Can not setup cronjob to backup! Please check file ${CRON_FILE}"
        SHOW_CRON="`change_color yellow [WARNING]` Can not setup cronjob to backup"
    else
        CHECK_CRON=`cat ${CRON_FILE} | grep -c "cron_backup.sh"`
        if [ ${CHECK_CRON} -eq 0 ]
        then
            echo "0 0 * * * sh ${CRON_BACKUP} >/dev/null 2>&1" >> ${CRON_FILE}
            show_write_log "Setup cronjob to backup successful"
            SHOW_CRON=="0 0 * * * sh ${CRON_BACKUP} >/dev/null 2>&1"
            systemctl restart crond
        fi
    fi
}

show_info(){
    echo ""
    show_write_log "SUCESSFUL! Your information:"
    show_write_log "---"
    show_write_log "Backup dir : ${BACKUP_DIR}"
    show_write_log "Log file   : ${DF_LOG_FILE}"
    show_write_log "Keep backup: ${DAY_REMOVE} days"
    show_write_log "---"
    show_write_log "Gdrive bin file : ${GDRIVE_BIN}"
    show_write_log "Google token    : ${HOME}/.gdrive/token_v2.json"
    show_write_log "Cron backup file: ${CRON_BACKUP}"
    show_write_log "Cron backup     : ${SHOW_CRON}"
    echo ""
    echo " If you get trouble when use backuptogoogle please go to following URLs:"
    echo " https://backuptogoogle.com"
    echo " https://github.com/mbrother2/backuptogoogle"
}

_setup(){
    pre_setup
    echo "LOG_FILE=${DF_LOG_FILE}" > ${BUTGG_CONF}
    echo "BACKUP_DIR=${DF_BACKUP_DIR}" > ${BUTGG_CONF}
    echo "DAY_REMOVE=${DF_DAY_REMOVE}" > ${BUTGG_CONF}
    check_network
    detect_os
    download_file
    setup_credential
    setup_cron
    show_info
}

_update(){
    pre_setup
    check_network
    detect_os
    download_file
}

_uninstall(){
    rm -rf ${HOME}/.gdrive
    rm -f ${GDRIVE_BIN}
    rm -f ${CRON_BACKUP}
    rm -f ${SETUP_FILE}
    echo "Uninstall butgg.sh successful"
}

_help(){
    echo "butgg.sh - Backup to Google Drive solution"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help      show this help message and exit"
    echo "  --setup     setup or reset all scripts & config file"
    echo "  --update    update to latest version"
    echo "  --uninstall uninstall butgg.sh"
}

# Main functions
case $1 in
    --help)      _help ;;
    --setup)     _setup ;;
    --update)    _update ;;
    --uninstall) _uninstall ;;
    *)           echo "No such command: $1. Please use $0 --help" ;;
esac