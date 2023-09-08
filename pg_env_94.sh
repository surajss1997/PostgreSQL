#!/bin/sh

export CUSTNAME='karvy egov erp'
export HOSTNAME=`hostname`

export DATE=`date +%Y-%m-%d`
export TIME=`date +%k:%M:%S`
export TODAY=$DATE":"$TIME

# **********************************  Main Database Information ***********************************

export PGHOME=/usr/pgsql-9.4
export PGDATA=/var/lib/pgsql/9.4/data
export PGPORT=6432
#export PGPASSWORD=postgres   
export PGDATABASE=egov_ap_live_db
export PGUSER=postgres
#export PGSCHEMA=public
# *********************   Destnations for storing Backups, Cron Logs, Archives etc *********************

#export PGBACKUP=/backup/pg_logical
#export PGARCHBACKUP=/backup/pg_online
#export PGARCH=/Archive
#export PGCRONJOBS=/home/postgres/SY_cronjobs
#export PGDBJOBS=/home/postgres/SY_dbascripts
export PGCRONLOGS=/var/lib/pgsql/logs
export PGLOGS=$PGDATA/pg_log

# **************************   Creation on Date wise folder under PGLOG ***************************

#mkdir -p $PGBACKUP/$DATE
mkdir -p $PGCRONLOGS/$DATE
#mkdir -p $PGARCHBACKUP/$DATE
# **********************************  Replication Server Details *********************************
