#!/bin/bash

# Set variables
GITHUB_LINK="https://raw.githubusercontent.com/mbrother2/backuptogoogle/master"
GO_FILE="go1.12.5.linux-amd64"
BUTGG_CONF="${HOME}/.gdrive/butgg.conf"
DF_BACKUP_DIR="${HOME}/backup"
DF_LOG_FILE="${HOME}/.gdrive/butgg.log"
DF_DAY_REMOVE="7"
GDRIVE_BIN="${HOME}/bin/gdrive"
CRON_BACKUP="${HOME}/bin/cron_backup.sh"
SETUP_FILE="${HOME}/bin/butgg.sh"
CRON_TEMP="${HOME}/.gdrive/old_cron"

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

# Create necessary directory
create_dir(){
    [[ ! -d ${HOME}/$1 ]] && mkdir -p ${HOME}/$1
    if [ ! -d ${HOME}/$1 ]
    then
        echo "Can not create directory ${HOME}/$1. Exit"
        exit 1
    fi
    echo 1 >> ${HOME}/$1/test.txt
    if [ $? -ne 0 ]
    then
        echo "Can not write to ${HOME}/$1. Exit"
        exit 1
    fi
    rm -f ${HOME}/$1/test.txt
}

# Prepare setup
pre_setup(){
    which git
    if [ $? -ne 0 ]
    then
        echo "Command git not found. Please check again. Exit"
        exit 1
    fi
    create_dir bin
    create_dir .gdrive
}

# Check network
check_network(){
    show_write_log "Cheking network..."
    if ping -c 1 -w 1 raw.githubusercontent.com > /dev/null
    then
        show_write_log "Connect Github successful"
    else
        show_write_log "`change_color red [CHECKS][FAIL]` Can not connect to Github file, please check your network. Exit"
        exit 1
    fi
    if ping -c 1 -w 1 dl.google.com > /dev/null
    then
        show_write_log "Connect Google successful"
    else
        show_write_log "`change_color red [CHECKS][FAIL]` Can not connect to Github file, please check your network. Exit"
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
        show_write_log "Sorry! We do not support your OS. Exit"
        exit 1
    fi
    show_write_log "OS supported!"
}

# Download file from Github
download_file(){
    show_write_log "Downloading script cron file from github..."
    check_md5sum cron_backup.sh "${CRON_BACKUP}"
    show_write_log "Downloading setup file from github..."
    check_md5sum butgg.sh "${SETUP_FILE}"
    chmod 755 ${CRON_BACKUP} ${SETUP_FILE}
}

# Build GDRIVE_BIN
build_gdrive(){
    cd $HOME/.gdrive
    show_write_log "Downloading go from Google..."
    curl -o ${GO_FILE}.tar.gz https://dl.google.com/go/${GO_FILE}.tar.gz
    show_write_log "Extracting go lang..."
    tar -xf ${GO_FILE}.tar.gz
    show_write_log "Cloning gdrive project from Github..."
    git clone https://github.com/gdrive-org/gdrive.git
    show_write_log "Build your own gdrive!"
    read -p " Your Google API client_id: " gg_client_id
    read -p " Your Google API client_secret: " gg_client_secret
    sed -i "s#^const ClientId =.*#const ClientId = \"${gg_client_id}\"#g" $HOME/.gdrive/gdrive/handlers_drive.go
    sed -i "s#^const ClientSecret =.*#const ClientSecret = \"${gg_client_secret}\"#g" $HOME/.gdrive/gdrive/handlers_drive.go
    show_write_log "Building gdrive..."
    cd $HOME/.gdrive/gdrive
    $HOME/.gdrive/go/bin/go get github.com/prasmussen/gdrive
    $HOME/.gdrive/go/bin/go build -ldflags '-w -s'
    mv $HOME/.gdrive/gdrive/gdrive $HOME/bin/gdrive
    chmod 755 $HOME/.gdrive/gdrive
    rm -f $HOME/.gdrive/${GO_FILE}.tar.gz
    rm -rf $HOME/.gdrive/go
    rm -rf $HOME/.gdrive/gdrive
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
    [[ -z "${BACKUP_DIR}" ]] && BACKUP_DIR="${DF_BACKUP_DIR}"
    [[ -z "${DAY_REMOVE}" ]] && DAY_REMOVE="${DF_DAY_REMOVE}"
    echo "LOG_FILE=${DF_LOG_FILE}" > ${BUTGG_CONF}
    echo "BACKUP_DIR=${BACKUP_DIR}" >> ${BUTGG_CONF}
    echo "DAY_REMOVE=${DAY_REMOVE}" >> ${BUTGG_CONF}
    if [ ! -d ${BACKUP_DIR} ]
    then
        show_write_log "`change_color yellow [WARNING]` Directory ${BACKUP_DIR} does not exist! Ensure you will be create it after."
        sleep 3
    fi
    crontab -l > ${CRON_TEMP}
    CHECK_CRON=`cat ${CRON_TEMP} | grep -c "cron_backup.sh"`
    if [ ${CHECK_CRON} -eq 0 ]
    then
        echo "PATH=$PATH" >> ${CRON_TEMP}
        echo "0 0 * * * sh ${CRON_BACKUP} >/dev/null 2>&1" >> ${CRON_TEMP}
        crontab ${CRON_TEMP}
        if [ $? -ne 0 ]
        then
            show_write_log "Can not setup cronjob to backup! Please check again"
            SHOW_CRON="`change_color yellow [WARNING]` Can not setup cronjob to backup"
        else
            show_write_log "Setup cronjob to backup successful"
            SHOW_CRON="0 0 * * * sh ${CRON_BACKUP} >/dev/null 2>&1"
        fi
    else
        SHOW_CRON=`cat ${CRON_TEMP} | grep "cron_backup.sh"`
    fi
    rm -f  ${CRON_TEMP}
}

show_info(){
    echo ""
    show_write_log "SUCESSFUL! Your information:"
    show_write_log "---"
    show_write_log "Backup dir : ${BACKUP_DIR}"
    show_write_log "Log file   : ${DF_LOG_FILE}"
    show_write_log "Keep backup: ${DAY_REMOVE} days"
    show_write_log "---"
    show_write_log "butgg.sh file   : ${SETUP_FILE}"
    show_write_log "Cron backup file: ${CRON_BACKUP}"
    show_write_log "Gdrive bin file : ${GDRIVE_BIN}"
    show_write_log "Cron backup     : ${SHOW_CRON}"
    show_write_log "Google token    : ${HOME}/.gdrive/token_v2.json"

    echo ""
    echo " If you get trouble when use backuptogoogle please go to following URLs:"
    echo " https://backuptogoogle.com"
    echo " https://github.com/mbrother2/backuptogoogle"
}

_setup(){
    pre_setup
    check_network
    detect_os
    download_file
    build_gdrive
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
    echo "Usage: butgg.sh [options]"
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
    *)           echo "No such command: $1. Please use butgg.sh --help" ;;
esac