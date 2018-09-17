#!/bin/bash
DB_NAME_MYSQL=bmoss
BACKUP_DIR=/var/backup/mysql
DATE=$(date +%Y_%m_%d_%H%M)
LOG=/var/log/backups/mysql.log
RETENTION=30
CONTAINER_NAME=mysql-backup

source /root/backup_scripts/.env
echo "###Backup is started at $DATE" >>$LOG
mysqldump -u$DB_USER_MYSQL -p$DB_PASSWORD_MYSQL  $DB_NAME_MYSQL 2>>$LOG | gzip > $BACKUP_DIR/mysql_backup_$DATE.gz 2>>$LOG
if [ "$?" -eq 0 ]
then
        find $BACKUP_DIR -name "*.gz" -mtime +$RETENTION -exec /bin/rm {} \; 2>>$LOG
        echo "Local backup is completed at $DATE" >>$LOG
else
        echo "Local backup is failed at $DATE" >>$LOG
fi

az storage blob upload --account-name $AZURE_STORAGE_ACCOUNT --container-name $CONTAINER_NAME --account-key $AZURE_STORAGE_ACCESS_KEY --name $(date +%Y_%m_%d)/mysql_backup_$(hostname -s)_$DATE.gz --file $BACKUP_DIR/mysql_backup_$DATE.gz
echo "Azure backup is completed at $DATE" >>$LOG