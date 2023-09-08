#!/bin/sh

. /home/postgres/SY_cronjobs/pg_env_10.sh

filename="`ls -rth $PGLOGS | tail -1`"
file=$PGLOGS/$filename
START=$(date +"%T.%3N")
st=$(date | awk '{print " "$1" "$2" "$3" '$START' "$5" "$6" "}')
SCRIPTNAME=pg_error_log.sh
echo  "\n********************************************************************************" > "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
echo  "\nLog file name: $filename" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
echo  "\nScript: $SCRIPTNAME: Start Time: $st\n" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"

echo  "\n\n-------------------------------------Warnings------------------------------------------------\n" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"

find "$PGLOGS" -type f -name "$filename" |while read file
  do
    RESULT=$(grep "WARNING" "$file")
      if [ ! -z "$RESULT" ]
         then
            echo "Error(s) in $filename: $RESULT" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
     fi
  done

echo  "\n\n-------------------------------------Hints------------------------------------------------\n" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"

find "$PGLOGS" -type f -name "$filename" |while read file
  do
    RESULT=$(grep "HINT" "$file")
      if [ ! -z "$RESULT" ]
         then
            echo "Error(s) in $filename: $RESULT" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
     fi
  done

echo  "\n-------------------------------------Standard Errors------------------------------------------------\n">>"$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"

find "$PGLOGS" -type f -name "$filename" |while read file
  do
    RESULT=$(grep "ERROR" "$file")
      if [ ! -z "$RESULT" ]
         then
            echo "Error(s) in $filename: $RESULT" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
     fi
  done

echo  "\n\n-------------------------------------FATAL------------------------------------------------\n" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"

find "$PGLOGS" -type f -name "$filename" |while read file
  do
    RESULT=$(grep "FATAL" "$file")
      if [ ! -z "$RESULT" ]
         then
            echo "Error(s) in $filename: $RESULT" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
     fi
done
#sort $PGCRONLOGS/$DATE/pg_error_log_$DATE.log | uniq -u > "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
echo "\n\n-------------------------------------Count------------------------------------\n"  >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
total_error=`grep ERROR $file | wc -l`
total_fatal=`grep FATAL $file | wc -l`
total_hints=`grep HINT  $file | wc -l`
total_warning=`grep WARNING $file | wc -l`

#Default Values=0 if not exists
total_error=${total_error:-0}
total_fatal=${total_fatal:-0}
total_hints=${total_hints:-0}
total_warning=${total_warning:-0}

echo  "Total Warnings = $total_warning" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
echo  "Total Fatal    = $total_fatal" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
echo  "Total Errors   = $total_error" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
echo  "Total Hints    = $total_hints" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"

END=$(date +"%T.%3N")
en=$(date | awk '{print " "$1" "$2" "$3" '$END' "$5" "$6" "}')
StartDate=$(date -u -d "$st" +"%s.%3N")
FinalDate=$(date -u -d "$en" +"%s.%3N")
#Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N") #| awk '{print " "$1" "hr:" "$2" "min:" "$3" "sec" "$5" "$6" "}')
Exe=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S:%3N" | awk '{print substr($1,1,2)"hr:" substr($1,4,2)"min:" substr($1,7,2)"sec:" substr($1,10,3)"ms"}')
sed -i "9s/^/\nTotal Execution Time (HH:MM:SS:MS) :  $Exe\n/" "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"
sed -i "8s/^/Script: $SCRIPTNAME: End Time  : $en /" "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"

echo  "\n" >> "$PGCRONLOGS/$DATE/pg_error_log_$DATE.log"

# mail -s "Critical Disk Space on Partition "$partition" Space: "$space" - HOSTNAME=`hostname` " neerajreddy.singadi@shreeyansh.com <$EDBCRONLOGS/$DATE/edb_disk_space_$DATE.log
