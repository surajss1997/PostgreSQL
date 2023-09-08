
# Created by Shreeyansh

#!/bin/bash

source /home/postgres/SY_cronjobs/pg_env_94.sh

echo -e "\n!!************************************************************************!!\n"

echo -e "\nThis script will give you the username and DDL command fired by them\n"
echo -e "\n-------------------------------------------------------------------------\n"
echo -e "\nCREATE:\n"

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select A.usename as \"User Name\",B.query as \"Query\", B.queryid as \"Queryid\" from pg_user A, pg_stat_statements B where A.usesysid=B.userid and B.query ilike '%crEate %'"

echo -e "\n-------------------------------------------------------------------------\n"
echo -e "\nALTER:\n"

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select A.usename as \"User Name\",B.query as \"Query\", B.queryid as \"Queryid\" from pg_user A, pg_stat_statements B where A.usesysid=B.userid and B.query ilike '%alter %'"

echo -e "\n-------------------------------------------------------------------------\n"
echo -e "\nDROP:\n"

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select A.usename as \"User Name\",B.query as \"Query\", B.queryid as \"Queryid\" from pg_user A, pg_stat_statements B where A.usesysid=B.userid and B.query ilike '%drop %'"


echo -e "\n-------------------------------------------------------------------------\n"
echo -e "\nDELETE:\n"

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select A.usename as \"User Name\",B.query as \"Query\", B.queryid as \"Queryid\" ,total_time as \"Total Time\", calls as \"Calls\", rows as \"Rows Affected\"
from pg_user A, pg_stat_statements B where A.usesysid=B.userid and B.query ilike '%delete %'"

echo -e "\n-------------------------------------------------------------------------\n"
echo -e "\nUPDATE:\n"

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -c "select A.usename as \"User Name\",B.query as \"Query\", B.queryid as \"Queryid\" ,total_time as \"Total Time\", calls as \"Calls\", rows as \"Rows Affected\"
from pg_user A, pg_stat_statements B where A.usesysid=B.userid and B.query ilike '%update %'"
