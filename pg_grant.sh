# Created by Shreeyansh

#!/bin/bash

source /home/postgres/SY_cronjobs/pg_env_94.sh

echo -e "\n!!************************************************************************!!\n"

echo -e "List of Users Available:"
echo -e "------------------------"

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -tc "select usename from pg_user where usename!='postgres';"

echo -e "Enter user name to GRANT permission on a table in schema = \c"
read USE

echo -e "\n!!************************************************************************!!\n"

echo -e "List of Databases Available:"
echo -e "----------------------------"

$PGHOME/bin/psql -U $PGUSER -d $PGDATABASE -p $PGPORT -tc "SELECT datname as "Name" FROM pg_database where datname!='template0' and datname!='template1';"

echo -e "Enter database Name You Want to Grant Privileges[postgres]: \c"
read db
db=${db:-postgres}

echo -e "\n!!************************************************************************!!\n"

echo -e "List of Schemas Available:"
echo -e "--------------------------"

$PGHOME/bin/psql -U $PGUSER -d $db -p $PGPORT -tc "SELECT n.nspname AS "Name" FROM pg_catalog.pg_namespace n WHERE n.nspname !~ '^pg_' AND n.nspname <> 'information_schema' ORDER BY 1;"

echo -e "Enter Schema Name You Want to Grant Privileges[public] = \c"
read scm
scm=${scm:-public}
echo -e "\n!!************************************************************************!!\n"

echo -e "List of Tables Available:"
echo -e "-------------------------"

$PGHOME/bin/psql -U $PGUSER -d $db -p $PGPORT -tc "SELECT n.nspname as "Schema", c.relname as "Name" FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE c.relkind IN ('r','s','')  AND n.nspname !~ '^pg_toast' AND n.nspname ~ '^($scm)$' ORDER BY 1,2;"

echo -e "Enter Table Name You Want to Grant Privileges= \c"
read TAB

echo -e "\n!!************************************************************************!!\n"

echo -e "The Following commands are available for GRANT privileges on Table/Schema\n"

echo -e " 1. Granting SELECT privilege on Table\n 2. Granting INSERT privilege on Table\n 3. Granting DELETE privilege on Table\n 4. Granting UPDATE privilege on Table\n 5. Granting TRUNCATE privilege on Table\n 6. Granting TRIGGER privilege on Table\n 7. Granting REFERENCES privilege on Table\n 8. Granting All privileges on Table\n 9. Granting All privileges on all Tables in a SCHEMA\n"

echo -e "!!************************************************************************!!\n"

#echo -e "Do you want to continue ?"

echo -e "Enter Any One Option Among the Above Available Commands: \c"
read op

if [ $op = 1 ]; then
	echo -e "\nAre you sure you want to continue? [ Y | N ]: \c"
	read yn
		if [ "$yn" = Y -o "$yn" = y ]; then
			$PGHOME/bin/psql -d $db -c "GRANT select on $scm.$TAB to $USE;"
			echo -e "\nGranted SELECT privilege on Table $TAB"
		else
			exit
		fi
elif [ $op = 2 ]; then
	echo -e "\nAre you sure you want to continue? [ Y | N ]: \c"
	read yn
		if [ "$yn" = Y -o "$yn" = y ]; then
			$PGHOME/bin/psql -d $db -c "GRANT insert on $scm.$TAB to $USE;"
			echo -e "\nGranted INSERT privilege on Table $TAB"
		else
			exit
		fi
elif [ $op = 3 ]; then
	echo -e "\nAre you sure you want to continue? [ Y | N ]: \c"
	read yn
		if [ "$yn" = Y -o "$yn" = y ]; then
			$PGHOME/bin/psql -d $db -c "GRANT delete on $scm.$TAB to $USE;"
			echo -e "\nGranted DELETE privilege on Table $TAB"
		else
			exit
		fi
elif [ $op = 4 ]; then
	echo -e "\nAre you sure you want to continue? [ Y | N ]: \c"
	read yn
		if [ "$yn" = Y -o "$yn" = y ]; then
			$PGHOME/bin/psql -d $db -c "GRANT update on $scm.$TAB to $USE;"
			echo -e "\nGranted UPDATE privilege on Table $TAB"
		else
			exit
		fi
elif [ $op = 5 ]; then
	echo -e "\nAre you sure you want to continue? [ Y | N ]: \c"
	read yn
		if [ "$yn" = Y -o "$yn" = y ]; then
			$PGHOME/bin/psql -d $db -c "GRANT truncate on $scm.$TAB to $USE;"
			echo -e "\nGranted TRUNCATE privilege on Table $TAB"
		else
			exit
		fi
elif [ $op = 6 ]; then
	echo -e "\nAre you sure you want to continue? [ Y | N ]: \c"
	read yn
		if [ "$yn" = Y -o "$yn" = y ]; then
			$PGHOME/bin/psql -d $db -c "GRANT trigger on $scm.$TAB to $USE;"
			echo -e "\nGranted TRIGGER privilege on Table $TAB"
		else
			exit
		fi
elif [ $op = 7 ]; then
	echo -e "\nAre you sure you want to continue? [ Y | N ]: \c"
	read yn
		if [ "$yn" = Y -o "$yn" = y ]; then
			$PGHOME/bin/psql -d $db -c "GRANT references on $scm.$TAB to $USE;"
			echo -e "\nGranted REFERENCES privilege on Table $TAB"
		else
			exit
		fi
elif [ $op = 8 ]; then
	echo -e "\nAre you sure you want to continue? [ Y | N ]: \c"
	read yn
		if [ "$yn" = Y -o "$yn" = y ]; then
			$PGHOME/bin/psql -d $db -c "GRANT ALL on $scm.$TAB to $USE;"
			echo -e "\nGranted All privileges on Table $TAB"
		else
			exit
		fi
elif [ $op = 9 ]; then
	echo -e "\nAre you sure you want to continue? [ Y | N ]: \c"
	read yn
		if [ "$yn" = Y -o "$yn" = y ]; then
			$PGHOME/bin/psql -d $db -c "GRANT ALL ON ALL TABLES IN SCHEMA $scm TO $USE;"
			echo -e "\nGranted All privileges on all Tables in  $scm"
		else
			exit
		fi
	exit
fi

echo -e "\n!!************************************************************************!!\n"
