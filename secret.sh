#!/bin/bash

# Get just the host/port from AWS Secrets
SECRET=$(aws secretsmanager get-secret-value --secret-id mysql-credentials --query SecretString --output text)
DB_HOST=$(echo $SECRET | jq -r '.host')
DB_PORT=$(echo $SECRET | jq -r '.port')

# Now connect WITHOUT showing the password
QUERY="SELECT * FROM employees.employees LIMIT 5;"
mysql --login-path=local -h $DB_HOST -P $DB_PORT -e "$QUERY"