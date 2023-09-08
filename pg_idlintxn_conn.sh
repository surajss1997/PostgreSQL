# Created by Shreeyansh

#!bin/bash
source /var/lib/pgsql/script/pg_env_94.sh
echo -e "PostgreSQL Cluster  Details\n\nDatabase Name = $PGDATABASE\nPort = $PGPORT\nData Directory = $PGDATA\n"

#echo -e "IDLE in Transaction Connections\n"

n=`$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -Atc "select count(*) from pg_stat_activity where state='idle in transaction'"`

if [ $n -eq 0 ]
then
echo -e "\nNo Session in state: idle in transaction\n"
else
echo -e "\nFollowing $n sessions are in state: idle in transaction\n"

$PGHOME/bin/psql -p $PGPORT -d $PGDATABASE -U $PGUSER -c "select datname as \"Database\" ,usename as \"User Name\",pid as \"Pid\",query_start as \"Start Time\",now()- query_start as \"Running Since\",substr(query,1,50) as \"Query\", backend_xid as \"Transaction Id\", state from pg_stat_activity where state='idle in transaction'"
fi

