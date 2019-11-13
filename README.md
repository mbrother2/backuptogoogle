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
Usage: butgg.sh [options] [command]

Options:
  --help      show this help message and exit
  --setup     setup or reset all scripts & config file
    no-build  setup or reset all scripts & config file without build gdrive
  --update    update to latest version
  --uninstall uninstall butgg.sh
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
[ 13/11/2019 15:45:50 ] Cheking network...
[ 13/11/2019 15:45:50 ] Connect Github successful
[ 13/11/2019 15:45:50 ] Connect Google successful
[ 13/11/2019 15:45:50 ] Checking OS...
[ 13/11/2019 15:45:50 ] OS supported
[ 13/11/2019 15:45:50 ] Downloading script cron file from github...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  5808  100  5808    0     0   7932      0 --:--:-- --:--:-- --:--:--  7934
[ 13/11/2019 15:45:52 ] Check md5sum for file cron_backup.sh successful
[ 13/11/2019 15:45:52 ] Downloading setup file from github...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  8840  100  8840    0     0  21396      0 --:--:-- --:--:-- --:--:-- 21508
[ 13/11/2019 15:45:53 ] Check md5sum for file butgg.sh successful
/usr/bin/git
[ 13/11/2019 15:45:53 ] Downloading go from Google...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  122M  100  122M    0     0  10.6M      0  0:00:11  0:00:11 --:--:-- 11.1M
[ 13/11/2019 15:46:04 ] Extracting go lang...
[ 13/11/2019 15:46:08 ] Cloning gdrive project from Github...
Cloning into 'gdrive'...
remote: Enumerating objects: 1458, done.
remote: Total 1458 (delta 0), reused 0 (delta 0), pack-reused 1458
Receiving objects: 100% (1458/1458), 465.06 KiB | 267.00 KiB/s, done.
Resolving deltas: 100% (873/873), done.
[ 13/11/2019 15:46:13 ] Build your own gdrive!
Please go to URL to create your own Google credential:
https://github.com/mbrother2/backuptogoogle/wiki/Create-own-Google-credential-step-by-step
 Your Google API client_id: 782896115405-qs2evi3rqlnkjm2vond8onilq9xxxxxx.apps.googleusercontent.com
 Your Google API client_secret: g7p_kcdNEq_ULsfxrTxxxxxx
[ 13/11/2019 15:46:38 ] Building gdrive...
[ 13/11/2019 15:46:40 ] Setting up gdrive credential...
Authentication needed
Go to the following url in your browser:
https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=782896115405-qs2evi3rqlnkjm2vond8onilq9xxxxxx.apps.googleusercontent.com&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive&state=state

Enter verification code: 4/tAGVY9GiMGqcITmQZquhvbWZkq81CBnHYOdAlVhgFOGUYEOSmxxxxxx
User: mbr other, backupxxxxxx@gmail.com
Used: 
Free: 16.1 GB
Total: 16.1 GB
Max upload size: 5.2 TB
[ 13/11/2019 15:47:10 ] Setting up cron backup...
 Which directory do you want to upload to Google Drive?(default /home/thanh1/backup): 
 How many days you want to keep backup on Google Drive?(default 7): 

[ 13/11/2019 15:47:31 ] +-----
[ 13/11/2019 15:47:31 ] | SUCESSFUL! Your information:
[ 13/11/2019 15:47:31 ] | Backup dir      : /home/thanh1/backup
[ 13/11/2019 15:47:31 ] | Log file        : /home/thanh1/.gdrive/butgg.conf
[ 13/11/2019 15:47:31 ] | Log file        : /home/thanh1/.gdrive/butgg.log
[ 13/11/2019 15:47:31 ] | Keep backup     : 7 days
[ 13/11/2019 15:47:31 ] | butgg.sh file   : /home/thanh1/bin/butgg.sh
[ 13/11/2019 15:47:31 ] | Cron backup file: /home/thanh1/bin/cron_backup.sh
[ 13/11/2019 15:47:31 ] | Gdrive bin file : /home/thanh1/bin/gdrive
[ 13/11/2019 15:47:31 ] | Cron backup     : 0 0 * * * sh /home/thanh1/bin/cron_backup.sh >/dev/null 2>&1
[ 13/11/2019 15:47:31 ] | Google token    : /home/thanh1/.gdrive/token_v2.json
[ 13/11/2019 15:47:31 ] +-----

 If you get trouble when use butgg.sh please report here:
 https://github.com/mbrother2/backuptogoogle/issues
```
```
butgg.sh --setup no-build
```
Setup or reset all scripts & config file without build gdrive
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
[ 13/11/2019 15:47:46 ] ---
[ 13/11/2019 15:47:47 ] Start upload to Google Drive...
[ 13/11/2019 15:47:47 ] Directory 13_11_2019 existed. Skipping...
[ 13/11/2019 15:47:48 ] Uploading file /home/thanh1/backup/a.txt to directory 13_11_2019...
[ 13/11/2019 15:47:51 ] [UPLOAD] Uploaded file /home/thanh1/backup/a.txt to directory 13_11_2019
[ 13/11/2019 15:47:51 ] Uploading directory /home/thanh1/backup/backup2 to directory 13_11_2019...
[ 13/11/2019 15:47:52 ] [UPLOAD] Uploaded directory /home/thanh1/backup/backup2 to directory 13_11_2019
[ 13/11/2019 15:47:52 ] Uploading file /home/thanh1/backup/b.txt to directory 13_11_2019...
[ 13/11/2019 15:47:55 ] [UPLOAD] Uploaded file /home/thanh1/backup/b.txt to directory 13_11_2019
[ 13/11/2019 15:47:55 ] Finish! All files and directories in /home/thanh1/backup are uploaded to Google Drive in directory 13_11_2019
[ 13/11/2019 15:47:55 ] Directory 06_11_2019 does not exist. Nothing need remove!
```
