#!/bin/sh

#export CUSTNAME='HCL'
export HOSTNAME=`hostname`

export DATE=`date +%Y-%m-%d`
export TIME=`date +%k:%M:%S`
export TODAY=$DATE":"$TIME

# **********************************  Main Database Information ***********************************

export PGHOME=/opt/PostgreSQL/10.2
export PGDATA=/DATA/postgres/10.2/master
export PGPORT=5444
export PGPASSWORD=postgres   
export PGDATABASE=postgres
export PGUSER=postgres
export PGSCHEMA=public
# *********************   Destnations for storing Backups, Cron Logs, Archives etc *********************

export PGBACKUP=/BACKUP/pg_logical
export PGARCHBACKUP=/BACKUP/pg_online
export PGARCH=/Archive
export PGCRONJOBS=/home/postgres/SY_cronjobs
export PGDBJOBS=/home/postgres/SY_dbascripts
export PGCRONLOGS=/home/postgres/logs
export PGLOGS=$PGDATA/log

# **************************   Creation on Date wise folder under PGLOG ***************************

mkdir -p $PGBACKUP/$DATE
mkdir -p $PGCRONLOGS/$DATE
mkdir -p $PGARCHBACKUP/$DATE
# **********************************  Replication Server Details *********************************
#export MASTER_IP=127.0.0.1 # Applicable if relication is setup
export REPHOSTNAME=127.0.0.1
export REPPGDATA=/DATA/postgres/10.2/slave
export REPPORT=5445
export REPUSER=rep

