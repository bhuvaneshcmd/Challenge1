#!/bin/bash

# Update package list
sudo apt update

# Install AWS CLI
sudo apt install -y awscli

# Install MySQL Server
sudo apt install -y mysql-server

# Secure MySQL installation (optional; requires expect or manual interaction)
# echo "Running mysql_secure_installation..."
# sudo mysql_secure_installation

# Start and enable MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Allow custom MySQL port (example: 3307)
sudo sed -i 's/3306/3307/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

# Clone repo and run MySQL command (replace values as needed)
git clone https://github.com/your-repo/test_db.git /tmp/test_db

# Assuming a SQL file is there:
sudo mysql -u root < /tmp/test_db/employees.sql
