#!/bin/bash

# Setup variables
BACKUP_DIR="/backup"
LOG_FILE="/var/log/backuptogoogle.log"
DAY_REMOVE="7"
FIRST_OPTION=$1

# Date variables
TODAY=`date +"%d_%m_%Y"`
OLD_BACKUP_DAY=`date +%d_%m_%Y -d "-${DAY_REMOVE} day"`

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

# Show processing and write log
show_write_log(){
    [[ "${FIRST_OPTION}" == "-v" ]] && echo `date "+[ %d/%m/%Y %H:%M:%S ]"` $1
    echo `date "+[ %d/%m/%Y %H:%M:%S ]"` $1 >> ${LOG_FILE}
}


# Check infomations before upload to Google Drive
check_info(){
    show_write_log "---"
    if [ ! -d "${BACKUP_DIR}" ]
    then       
        show_write_log "`change_color red [CHECKS][FAIL]` Directory ${BACKUP_DIR} do not exist"
        exit 1
    fi
}

# Run upload to Google Drive
run_upload(){
    show_write_log "Start upload to Google Drive..."
    CHECK_BACKUP_DIR=`gdrive list -m 100000 --name-width 0 | grep -c "${TODAY}"`
    if [ ${CHECK_BACKUP_DIR} -eq 0 ]
    then
        show_write_log "Directory ${TODAY} does not exist. Creating..."
        ID_DIR=`gdrive mkdir ${TODAY} | awk '{print $2}'`
    else
        show_write_log "Directory ${TODAY} existed. Skipping..."
        ID_DIR=`gdrive list -m 100000 --name-width 0 | grep "${TODAY}" | head -1 | awk '{print $1}'`
    fi
    if [ ${#ID_DIR} -ne 33 ]
    then
        show_write_log "`change_color red [CREATE][FAIL]` Can not create directory ${TODAY}"
        exit 1
    elif [ ${CHECK_BACKUP_DIR} -eq 0 ]
    then
        show_write_log "`change_color green [CREATE]` Created directory ${TODAY} with ID ${ID_DIR}"
    else
        :
    fi
    for i in $(ls -1 ${BACKUP_DIR})
    do
        show_write_log "Uploading file ${BACKUP_DIR}/$i to directory ${TODAY}..."                
        UPLOAD_FILE=`gdrive upload -p ${ID_DIR} --recursive ${BACKUP_DIR}/$i`
        if [[ "${UPLOAD_FILE}" == *"Error"* ]] || [[ "${UPLOAD_FILE}" == *"Fail"* ]]
        then
            show_write_log "`change_color red [UPLOAD][FAIL]` Can not upload backup file! ${UPLOAD_FILE}"
            show_write_log "Something wrong!!! Exit."
            exit
        else
            show_write_log "`change_color green [UPLOAD]` Uploaded file ${BACKUP_DIR}/$i to directory ${TODAY}"
        fi
    done
    show_write_log "Finish! All files in ${BACKUP_DIR} are uploaded to Google Drive in directory ${TODAY}"
}

remove_old_dir(){
    OLD_BACKUP_ID=`gdrive list -m 100000 --name-width 0 | grep "${OLD_BACKUP_DAY}" | awk '{print $1}'`
    if [ "${OLD_BACKUP_ID}" != "" ]
    then
        gdrive delete -r ${OLD_BACKUP_ID}
        OLD_BACKUP_ID=`gdrive list -m 100000 --name-width 0 | grep "${OLD_BACKUP_DAY}" | awk '{print $1}'`
        if [ "${OLD_BACKUP_ID}" == "" ]
        then
            show_write_log "`change_color green [REMOVE]` Removed directory ${OLD_BACKUP_DAY}"
        else
            show_write_log "`change_color red [REMOVE][FAIL]` Directory ${OLD_BACKUP_DAY} exists but can not remove!"
        fi
    else
        show_write_log "Directory ${OLD_BACKUP_DAY} does not exist. Nothing need remove!"
    fi
}

# Main functions
check_info
run_upload
remove_old_dir