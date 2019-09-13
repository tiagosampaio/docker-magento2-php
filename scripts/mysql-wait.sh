#!/bin/sh
# wait until MySQL is really available
# Reference: https://cweiske.de/tagebuch/docker-mysql-available.htm
maxcounter=45

counter=1
while ! mysql --protocol TCP -h database -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "show databases;" > /dev/null 2>&1; do
    sleep 1
    counter=`expr $counter + 1`
    if [ $counter -gt $maxcounter ]; then
        >&2 echo "We have been waiting for MySQL too long already; failing."
        exit 1
    fi;
done
