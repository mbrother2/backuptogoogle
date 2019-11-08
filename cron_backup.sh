#!/bin/bash

# Setup variables
BACKUP_DIR="/backup"
LOG_FILE="/var/log/gdrive.log"
DAY_REMOVE="7"

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

# Write time to log file
write_time_log(){
    echo -n `date "+[ %d/%m/%Y %H:%M:%S ]"` >> ${LOG_FILE}
}

# Check infomations before upload to Google Drive
check_info(){
    if [ ! -d "${BACKUP_DIR}" ]
    then
        write_time_log   
        echo `change_color red [CHECKS][FAIL]` " Directory ${BACKUP_DIR} do not exist" >> ${LOG_FILE}
        exit 1
    fi
}

# Run upload to Google Drive
run_upload(){
    for i in $(ls -1 ${BACKUP_DIR})
    do
        CHECK_BACKUP_DIR=`gdrive list -m 100000 --name-width 0 | grep -c "${TODAY}"`
        if [ ${CHECK_BACKUP_DIR} -eq 0 ]
        then
            ID_DIR=`gdrive mkdir ${TODAY} | awk '{print $2}'`
        else
            ID_DIR=`gdrive list -m 100000 --name-width 0 | grep "${TODAY}" | head -1 | awk '{print $1}'`
        fi
        if [ ${#ID_DIR} -ne 33 ]
        then
            write_time_log
            echo " `change_color red [CREATE][FAIL]` Can not create directory ${TODAY}" >> ${LOG_FILE}
            gdrive mkdir ${TODAY} 2>&1 | tee -a ${LOG_FILE}
        else
            if [ ${CHECK_BACKUP_DIR} -eq 0 ]
            then
                write_time_log
                echo " `change_color green [CREATE]` Create directory ${TODAY} with ID ${ID_DIR}" >> ${LOG_FILE}
            fi
            write_time_log
            OLD_BACKUP_ID=`gdrive list -m 100000 --name-width 0 | grep "${OLD_BACKUP_DAY}" | awk '{print $1}'`
            UPLOAD_FILE=`gdrive upload -p ${ID_DIR} ${BACKUP_DIR}/$i`
            if [[ "${UPLOAD_FILE}" == *"Error"* ]] || [[ "${UPLOAD_FILE}" == *"Fail"* ]]
            then
                echo " `change_color red [UPLOAD][FAIL]` Can not upload backup file! ${UPLOAD_FILE}" >> ${LOG_FILE}
            else
                echo " `change_color green [UPLOAD]` Upload file /backup/$i to directory ${TODAY}" >> ${LOG_FILE}
                echo ${UPLOAD_FILE} >> ${LOG_FILE}
            fi
            if [ "${OLD_BACKUP_ID}" != "" ]
            then
                write_time_log
                gdrive delete -r ${OLD_BACKUP_ID}
                OLD_BACKUP_ID=`gdrive list -m 100000 --name-width 0 | grep "${OLD_BACKUP_DAY}" | awk '{print $1}'`
                if [ "${OLD_BACKUP_ID}" == "" ]
                then
                    echo " `change_color green [REMOVE]` Removed directory ${OLD_BACKUP_DAY}" >> ${LOG_FILE}
                else
                    echo " `change_color red [REMOVE][FAIL]` Directory ${OLD_BACKUP_DAY} exists but can not remove!" >> ${LOG_FILE}
                fi
            fi
        fi
    done
}

# Main functions
check_info
run_upload