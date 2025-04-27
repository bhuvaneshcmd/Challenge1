#!/bin/bash

# MySQL credentials
HOST='54.91.246.162'
PORT='3307'
USER='admin'
PASSWORD='Admin@123'
DATABASE='employees'

# Debug: print credentials
echo "MySQL Credentials:"
echo "HOST: $HOST"
echo "PORT: $PORT"
echo "USER: $USER"
echo "PASSWORD: $PASSWORD"  # Don't print passwords in production, this is just for debugging

# MySQL query
QUERY="SELECT * FROM employees LIMIT 10;"

# Debug: print the query
echo "Running query: $QUERY"

# Connect to MySQL and execute the query

mysql -h $HOST -P $PORT -u $USER -p"$PASSWORD" -e "$QUERY" $DATABASE

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "MySQL query executed successfully!"
else
    echo "MySQL query failed."
    exit 1
fi
