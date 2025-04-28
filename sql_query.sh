#!/bin/bash

# AWS Secrets Manager secret ID (replace with your actual secret ID)
SECRET_ID="MySQL-credentials_v7"

# Retrieve the secret from AWS Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id $SECRET_ID --query SecretString --output text)

# Extract MySQL credentials from the secret
HOST=$(echo $SECRET_JSON | jq -r .db_host)
USER=$(echo $SECRET_JSON | jq -r .db_user)
PASSWORD=$(echo $SECRET_JSON | jq -r .db_pass)
DATABASE=$(echo $SECRET_JSON | jq -r .db_name)

# Debug: print credentials (avoid printing password in production)
echo "MySQL Credentials:"
echo "HOST: $HOST"
echo "PORT: 3307"
echo "USER: $USER"
# echo "PASSWORD: $PASSWORD"  # Don't print passwords in production
echo "DATABASE: $DATABASE"

# MySQL query
QUERY="SELECT * FROM employees LIMIT 10;"

# Debug: print the query
echo "Running query: $QUERY"

# Connect to MySQL and execute the query
mysql -h $HOST -P 3307 -u $USER -p"$PASSWORD" -e "$QUERY" $DATABASE

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "MySQL query executed successfully!"
else
    echo "MySQL query failed."
    exit 1
fi
