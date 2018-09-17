#!/bin/bash
DB_NAME_MYSQL=bmoss
BACKUP_DIR=/var/backup/mongodb
DATE=$(date +%Y_%m_%d_%H%M)
LOG=/var/log/backups/mongodb.log
RETENTION=30
CONTAINER_NAME=mongodb-backup

source /root/backup_scripts/.env
echo "###Backup is started at $DATE" >>$LOG
mongodump --db bmoss --out $BACKUP_DIR/$DATE 2>>$LOG
cd $BACKUP_DIR/$DATE && tar -zcvf $BACKUP_DIR/mongo_backup_$DATE.gz .
rm -rf $BACKUP_DIR/$DATE

if [ "$?" -eq 0 ]
then
        find $BACKUP_DIR -name "*.gz" -mtime +$RETENTION -exec /bin/rm {} \; 2>>$LOG
        echo "Local backup is completed at $DATE" >>$LOG
else
        echo "Local backup is failed at $DATE" >>$LOG
fi

az storage blob upload --account-name $AZURE_STORAGE_ACCOUNT --container-name $CONTAINER_NAME --account-key $AZURE_STORAGE_ACCESS_KEY --name $(date +%Y_%m_%d)/mongodb_backup_$(hostname -s)_$DATE.gz --file $BACKUP_DIR/mongo_backup_$DATE.gz
echo "Azure backup is completed at $DATE" >>$LOG