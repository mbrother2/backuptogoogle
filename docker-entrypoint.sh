#!/usr/bin/env bash

DF_BACKUP_DIR="/root/backup"
DF_TAR_BEFORE_UPLOAD="No"
DF_SYNC_FILE="No"
DF_LOG_FILE="/root/.gdrive/butgg.log"
DF_DAY_REMOVE="7"
DF_GDRIVE_ID="None"
DF_EMAIL_USER="None"
DF_EMAIL_PASS="None"
DF_EMAIL_TO="None"
BUTGG_CONF="/root/.gdrive/butgg.conf"
LOG_FILE="/root/.gdrive/butgg.log"
GDRIVE_BIN="/root/bin/gdrive"

set -e

OPTION=$1

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

# Write log
show_write_log(){
    echo "`date "+[ %d/%m/%Y %H:%M:%S ]"` $1" | tee -a ${LOG_FILE}
}
# Write config
write_config(){
    if [ "$3" == "" ]
    then
        VAR=$1
        eval "$VAR"="$2"
        if [ -f ${BUTGG_CONF} ]
        then
            sed -i "/^$1/d" ${BUTGG_CONF}
        fi
        echo "$1=$2" >> ${BUTGG_CONF}
    else
        VAR=$1
        eval "$VAR"="$3"
        if [ -f ${BUTGG_CONF} ]
        then
            sed -i "/^$1/d" ${BUTGG_CONF}
        fi
        echo "$1=$3" >> ${BUTGG_CONF}
    fi
}

# Build gdrive
build_gdrive(){
    if [ ! -f ${GDRIVE_BIN} ]
    then
        cd /root/gdrive
        sed -i "s#^const ClientId =.*#const ClientId = \"${GG_CLIENT_ID}\"#g" handlers_drive.go
        sed -i "s#^const ClientSecret =.*#const ClientSecret = \"${GG_CLIENT_SECRET}\"#g" handlers_drive.go
        go get github.com/prasmussen/gdrive
        go build -ldflags '-w -s'
        mv /root/gdrive/gdrive ${GDRIVE_BIN}
        chmod 755 ${GDRIVE_BIN}
        show_write_log "Build gdrive successful."
    fi
}

# Setup cron
setup_cron(){
    echo "0 0 * * * /usr/local/bin/cron_backup.bash" >> /root/cron.txt
    crontab /root/cron.txt
    rm -f /root/cron.txt
    crond -f -L /dev/stdout
}

# Setup gdrive credential
setup_credential(){
    ${GDRIVE_BIN} about
    show_write_log "Setup gdrive credential successful."
}

# Set up config file
setup_config(){
    show_write_log "Setting up config file..."
    echo ""
    if [ -z ${DAY_REMOVE} ]
    then
        read -p " How many days do you want to keep backup on Google Drive?(default ${DF_DAY_REMOVE}): " DAY_REMOVE
    fi
    if [ -z ${SYNC_FILE} ]
    then
        echo ""
        echo "Read more https://github.com/mbrother2/backuptogoogle/wiki/What-is-the-option-SYNC_FILE%3F"
        read -p " Do you want only sync file(default no)(y/n): " SYNC_FILE
    fi
    if [ -z ${GDRIVE_ID} ]
    then
        echo ""
        echo "Read more https://github.com/mbrother2/backuptogoogle/wiki/Get-Google-folder-ID"
        if [ "${SYNC_FILE}" == "y" ]
        then
            echo "Because you choose sync file method, so you must enter exactly Google folder ID here!"
        fi
        read -p " Your Google folder ID(default ${DF_GDRIVE_ID}): " GDRIVE_ID
    fi
    if [ -z ${TAR_BEFORE_UPLOAD} ]
    then
        if [ "${SYNC_FILE}" == "y" ]
        then
            TAR_BEFORE_UPLOAD=${DF_TAR_BEFORE_UPLOAD}
        else
            read -p " Do you want compress directory before upload?(default no)(y/n): " TAR_BEFORE_UPLOAD
        fi
    fi
    if [[ -z ${EMAIL_USER} ]] && [[ -z ${EMAIL_PASS} ]] && [[ -z ${EMAIL_TO} ]]
    then
        echo ""
        echo "Read more https://github.com/mbrother2/backuptogoogle/wiki/Turn-on-2-Step-Verification-&-create-app's-password-for-Google-email"
        read -p " Do you want to send email if upload error(default no)(y/n): " SEND_EMAIL
        if [ "${SEND_EMAIL}" == "y" ]
        then
            read -p " Your Google email user name: " EMAIL_USER
            read -p " Your Google email password: " EMAIL_PASS
            read -p " Which email will be receive notify?: " EMAIL_TO
        fi
    fi
    if [ "${SYNC_FILE}" == "y" ]
    then
        SYNC_FILE="Yes"
    else
        SYNC_FILE="No"
    fi
    if [ "${TAR_BEFORE_UPLOAD}" == "y" ]
    then
        TAR_BEFORE_UPLOAD="Yes"
    else
        TAR_BEFORE_UPLOAD=${DF_TAR_BEFORE_UPLOAD}
    fi
    echo "LOG_FILE=${LOG_FILE}" > ${BUTGG_CONF}
    write_config BACKUP_DIR "${DF_BACKUP_DIR}" "${DF_BACKUP_DIR}"
    write_config DAY_REMOVE "${DF_DAY_REMOVE}" "${DAY_REMOVE}"
    write_config GDRIVE_ID  "${DF_GDRIVE_ID}"  "${GDRIVE_ID}"
    write_config EMAIL_USER "${DF_EMAIL_USER}" "${EMAIL_USER}"
    write_config EMAIL_PASS "${DF_EMAIL_PASS}" "${EMAIL_PASS}" 
    write_config EMAIL_TO   "${DF_EMAIL_TO}"   "${EMAIL_TO}"
    write_config SYNC_FILE  "${DF_SYNC_FILE}"  "${SYNC_FILE}"
    write_config TAR_BEFORE_UPLOAD "${DF_TAR_BEFORE_UPLOAD}" "${TAR_BEFORE_UPLOAD}"
    if [ ! -d ${BACKUP_DIR} ]
    then
        show_write_log "`change_color yellow [WARNING]` You does not mount your backup dir in host machine to ${BACKUP_DIR} on container! Please recreate container and ensure your backup dir has mounted to container."
        exit 1
    fi   
    show_write_log "Setup config file successful"    
}

show_write_log "---"

case "${OPTION}" in
    build)
        build_gdrive 
        ;;
    credential)
        build_gdrive
        setup_credential
        ;;
    config)
        setup_config
        ;;
    setup)
        build_gdrive
        setup_credential
        setup_config
        ;;
    cron)
        build_gdrive
        setup_credential
        setup_config
        setup_cron 
        ;;
esac
