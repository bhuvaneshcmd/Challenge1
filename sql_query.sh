#!/bin/bash

# MySQL credentials
HOST='54.91.246.162'
PORT='3307'
USER='admin'
PASSWORD='Admin@123'
DATABASE='employees'

# MySQL query
QUERY="SELECT * FROM employees LIMIT 10;"

# Connect to MySQL and execute the query
mysql -h $HOST -P $PORT -u $USER -p$PASSWORD -e "$QUERY" $DATABASE
