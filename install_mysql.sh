#!/bin/bash

set -e

# Update packages
sudo yum update -y

# Download and install MySQL Yum repo
sudo yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm

# Install MySQL server
sudo yum install -y mysql-community-server

# Start MySQL
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Change MySQL port from 3306 to 3307
sudo sed -i 's/^port=3306/port=3307/' /etc/my.cnf || echo -e "\nport=3307" | sudo tee -a /etc/my.cnf

# Restart MySQL with new port
sudo systemctl restart mysqld

# Get temporary root password from log
TEMP_PASS=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# Secure MySQL root user and create admin user
MYSQL_ROOT_PASSWORD="Admin@123"
MYSQL_ADMIN_PASSWORD="admin_user"

# Run mysql_secure_installation steps and create new user
sudo mysql --connect-expired-password -uroot -p"$TEMP_PASS" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE USER 'admin'@'%' IDENTIFIED BY '$MYSQL_ADMIN_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
