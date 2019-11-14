# backuptogoogle (butgg.sh)
# What can this script do?
- Complie gdrive (https://github.com/gdrive-org/gdrive) on your server with your Google credential
- Create cron auto backup
- Auto remove old backup on Google Drive
- Run upload from to Google Drive whenever you want
- Detail log
# Structure
```
$HOME/$USER
         ├── bin
         │    ├── butgg.sh
         │    ├── cron_backup.sh
         │    └── gdrive
         └── .gdrive
              ├── butgg.conf
              ├── butgg.log
              └── token_v2.json
```
# OS support(x86_64):
- CentOS
- Debian
- Ubuntu
---
# How to use
Run command:
```
curl -o butgg.sh https://raw.githubusercontent.com/mbrother2/backuptogoogle/master/butgg.sh
sh butgg.sh --setup
```
# Create own Google credential step by step
https://github.com/mbrother2/backuptogoogle/wiki/Create-own-Google-credential-step-by-step
# Options
Run command `sh butgg.sh --help` to show all options( After install you only need run `butgg.sh --help`)
```
butgg.sh - Backup to Google Drive solution

Usage: butgg.sh [options] [command]

Options:
  --help       show this help message and exit
  --setup      setup or reset all scripts & config file
    config     only setup config
    credential only setup credential
    only-build only build gdrive bin
    no-build   setup butgg without build gdrive
    no-update  setup butgg without update script
  --update     update to latest version
  --uninstall  remove all butgg scripts and .gdrive directory
```
# Command
###### 1. Help
```
butgg.sh --help
```
Show help message and exit
###### 2. Setup
```
butgg.sh --setup
```
Set up or reset all scripts & config file
##### Example
```
[thanh1@centos7 ~]$ sh butgg.sh --setup
[ 14/11/2019 10:54:25 ] Cheking network...
[ 14/11/2019 10:54:25 ] Connect Github successful
[ 14/11/2019 10:54:26 ] Connect Google successful
[ 14/11/2019 10:54:26 ] Checking OS...
[ 14/11/2019 10:54:26 ] OS supported
[ 14/11/2019 10:54:26 ] Downloading script cron file from github...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  5808  100  5808    0     0   7944      0 --:--:-- --:--:-- --:--:--  7956
[ 14/11/2019 10:54:27 ] Check md5sum for file cron_backup.sh successful
[ 14/11/2019 10:54:27 ] Downloading setup file from github...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11151  100 11151    0     0  26427      0 --:--:-- --:--:-- --:--:-- 26424
[ 14/11/2019 10:54:28 ] Check md5sum for file butgg.sh successful
/usr/bin/git
[ 14/11/2019 10:54:28 ] Downloading go from Google...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  122M  100  122M    0     0  10.1M      0  0:00:12  0:00:12 --:--:-- 11.0M
[ 14/11/2019 10:54:40 ] Extracting go lang...
[ 14/11/2019 10:54:45 ] Cloning gdrive project from Github...
Cloning into 'gdrive'...
remote: Enumerating objects: 1458, done.
remote: Total 1458 (delta 0), reused 0 (delta 0), pack-reused 1458
Receiving objects: 100% (1458/1458), 465.06 KiB | 228.00 KiB/s, done.
Resolving deltas: 100% (873/873), done.
[ 14/11/2019 10:54:49 ] Build your own gdrive!
Please go to URL to create your own Google credential:
https://github.com/mbrother2/backuptogoogle/wiki/Create-own-Google-credential-step-by-step
 Your Google API client_id: 782896115405-qs2evi3rqlnkjm2vond8onilq9xxxxxx.apps.googleusercontent.com
 Your Google API client_secret: g7p_kcdNEq_ULsfxrTxxxxxx
[ 14/11/2019 10:55:02 ] Building gdrive...
[ 14/11/2019 10:55:03 ] Build gdrive successful
[ 14/11/2019 10:55:04 ] Setting up gdrive credential...
Authentication needed
Go to the following url in your browser:
https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=782896115405-qs2evi3rqlnkjm2vond8onilq9xxxxxx.apps.googleusercontent.com&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive&state=state

Enter verification code: 4/tQEqtaOpkPsX1keXGuZWQsPMB5AF0mZ7a_FiiSheYnYuSBejxxxxxx
User: mbr other, backupxxxxxx@gmail.com
Used: 
Free: 16.1 GB
Total: 16.1 GB
Max upload size: 5.2 TB
[ 14/11/2019 10:55:29 ] Setup gdrive credential successful
[ 14/11/2019 10:55:29 ] Setting up config file...
 Which directory do you want to upload to Google Drive?(default /home/thanh1/backup): /home/thanh1/backup2/backup
 How many days you want to keep backup on Google Drive?(default 7): 30
[ 14/11/2019 10:55:47 ] [WARNING] Directory /home/thanh1/backup2/backup does not exist! Ensure you will be create it after.
[ 14/11/2019 10:55:50 ] Setup config file successful
[ 14/11/2019 10:55:50 ] Setting up cron backup...
[ 14/11/2019 10:55:50 ] Cron backup existed. Skip

[ 14/11/2019 10:55:50 ] +-----
[ 14/11/2019 10:55:50 ] | SUCESSFUL! Your information:
[ 14/11/2019 10:55:50 ] | Backup dir      : /home/thanh1/backup2/backup
[ 14/11/2019 10:55:50 ] | Config file     : /home/thanh1/.gdrive/butgg.conf
[ 14/11/2019 10:55:50 ] | Log file        : /home/thanh1/.gdrive/butgg.log
[ 14/11/2019 10:55:50 ] | Keep backup     : 30 days
[ 14/11/2019 10:55:50 ] | butgg.sh file   : /home/thanh1/bin/butgg.sh
[ 14/11/2019 10:55:50 ] | Cron backup file: /home/thanh1/bin/cron_backup.sh
[ 14/11/2019 10:55:50 ] | Gdrive bin file : /home/thanh1/bin/gdrive
[ 14/11/2019 10:55:50 ] | Cron backup     : 0 0 * * * sh /home/thanh1/bin/cron_backup.sh >/dev/null 2>&1
[ 14/11/2019 10:55:50 ] | Google token    : /home/thanh1/.gdrive/token_v2.json
[ 14/11/2019 10:55:50 ] +-----

 If you get trouble when use butgg.sh please report here:
 https://github.com/mbrother2/backuptogoogle/issues
```
```
butgg.sh --setup config
```
Only edit butgg.conf
```
butgg.sh --setup credential
```
Only reset Google Drive token
```
butgg.sh --setup only-build
```
Only build gdrive bin
```
butgg.sh --setup no-build
```
Setup butgg without build gdrive
```
butgg.sh --setup no-update
```
Setup butgg without update script
###### 3. Update
```
butgg.sh --update
```
Update to latest version
###### 4. Uninstall
```
butgg.sh --uninstall
```
Remove all butgg scripts and .gdrive directory
###### 5. Run upload to Google Drive immediately
```
cron_backup.sh
```
Run upload to Google Drive immediately without show log
```
cron_backup.sh -v
```
Run upload to Google Drive immediately with show log detail
##### Example
```
[thanh1@centos7 ~]$ cron_backup.sh -v
[ 14/11/2019 10:58:54 ] ---
[ 14/11/2019 10:58:55 ] Start upload to Google Drive...
[ 14/11/2019 10:58:56 ] Directory 14_11_2019 existed. Skipping...
[ 14/11/2019 10:58:57 ] Uploading file /home/thanh1/backup2/backup/a.txt to directory 14_11_2019...
[ 14/11/2019 10:58:59 ] [UPLOAD] Uploaded file /home/thanh1/backup2/backup/a.txt to directory 14_11_2019
[ 14/11/2019 10:58:59 ] Uploading file /home/thanh1/backup2/backup/b.txt to directory 14_11_2019...
[ 14/11/2019 10:59:02 ] [UPLOAD] Uploaded file /home/thanh1/backup2/backup/b.txt to directory 14_11_2019
[ 14/11/2019 10:59:02 ] Uploading directory /home/thanh1/backup2/backup/thanh1 to directory 14_11_2019...
[ 14/11/2019 10:59:03 ] [UPLOAD] Uploaded directory /home/thanh1/backup2/backup/thanh1 to directory 14_11_2019
[ 14/11/2019 10:59:03 ] Uploading directory /home/thanh1/backup2/backup/thanh2 to directory 14_11_2019...
[ 14/11/2019 10:59:04 ] [UPLOAD] Uploaded directory /home/thanh1/backup2/backup/thanh2 to directory 14_11_2019
[ 14/11/2019 10:59:04 ] Finish! All files and directories in /home/thanh1/backup2/backup are uploaded to Google Drive in directory 14_11_2019
[ 14/11/2019 10:59:05 ] Directory 15_10_2019 does not exist. Nothing need remove!
```
