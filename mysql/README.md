#Description
Script for backup MySQL locally and to Azure Blob Storage

#Requirements
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli-apt?view=azure-cli-latest)

#Backups setup
1. Create Azure Blob Storage account
```
root@Ubuntu:~# az login
root@Ubuntu:~# az storage account create -n mybackup -g mybackupgroup -l westus --sku Standard_LRS
root@Ubuntu:~# az storage container create --account-name mybackup -n mysql-backup
```

2. Get storage account key
```
root@Ubuntu:~# az storage account keys list -n mybackup
```

3. Put credentials to the `/root/backup_scripts/.env` file
```
DB_USER_MYSQL=''
DB_PASSWORD_MYSQL=''
AZURE_STORAGE_ACCOUNT=''
AZURE_STORAGE_ACCESS_KEY=''
```
4. Place the scripts to the `/root/backup_scripts/` folder
5. Create logs folder
```
root@Ubuntu:~# mkdir /var/log/backups/
```
6. Add the jobs to the crontab
```
1 0 * * * /bin/bash /root/backup_scripts/mysql_backup.sh
```