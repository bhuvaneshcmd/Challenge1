provider "aws" {
  region = "us-east-1"
}

# Get current public IP for SSH restriction
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

# VPC creation
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "examplevpc"
  }
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "internetgateway"
  }
}

# Public Subnet for EC2 instances
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "publicsubnet"
  }
}

# Route Table for Internet Access
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "publicroutetable"
  }
}

# Route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Associate route table with subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

# Security Group for SSH and MySQL 3307 access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH and MySQL Custom Port"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_ip.body}/32"]
  }

  ingress {
    description = "MySQL Custom Port 3307 Access from my IP"
    from_port   = 3307
    to_port     = 3307
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_ip.body}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# MySQL EC2 Instance creation
resource "aws_instance" "mysql_server" {
  ami                         = "ami-084568db4383264d4" # ubuntu AMI
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]

  # User data script to install MySQL, change port, and create admin user
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y mysql-server
    systemctl start mysql
    systemctl enable mysql
    sed -i 's/3306/3307/' /etc/mysql/mysql.conf.d/mysqld.cnf
    systemctl restart mysql

    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Admin@123';"
    mysql -u root -pAdmin@123 -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'Admin@123';"
    mysql -u root -pAdmin@123 -e "GRANT ALL PRIVILEGES ON . TO 'admin'@'%' WITH GRANT OPTION;"
    mysql -u root -pAdmin@123 -e "FLUSH PRIVILEGES;"

    # Allow remote connections
    sed -i "s/^bind-address/#bind-address/" /etc/mysql/mysql.conf.d/mysqld.cnf
    systemctl restart mysql

    # Download and load Employees Sample Database
    apt-get install -y git
    git clone https://github.com/datacharmer/test_db.git /tmp/test_db
    cd /tmp/test_db
    mysql -u root -pAdmin@123 < employees.sql
  EOF

  tags = {
    Name = "mysql-server-instance"
  }
}

# AWS Secrets Manager for MySQL credentials
resource "aws_secretsmanager_secret" "mysql_credentials_v7" {
  name = "MySQL-credentials_v7"
}

# Store MySQL credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "mysql_creds" {
  secret_id = aws_secretsmanager_secret.mysql_credentials_v7.id
  secret_string = jsonencode({
    username = "admin"
    password = "Admin@123"
    host     = aws_instance.mysql_server.public_ip
    port     = "3307"
  })

  depends_on = [aws_instance.mysql_server]
}

# Output MySQL server public IP
output "mysql_server_public_ip" {
  value = aws_instance.mysql_server.public_ip
}