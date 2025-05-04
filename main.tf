provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "mysql_server" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  key_name      = "key-pair"
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  
  user_data = file("mysql-setup.sh")
  tags = {
    Name = "mysql-server-instance"
  }
  depends_on    =[aws_secretsmanager_secret.mysql_credentials_v12]
}


resource "aws_security_group" "mysql_sg" {
  name        = "allow_ssh"
  description = "Allow SSH and MySQL Custom Port"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3307
    to_port     = 3307
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
resource "aws_secretsmanager_secret" "mysql_credentials_v12" { 
  name        = "prod/mysql/admin-credentials_v12"
  description = "MySQL admin credentials for production"
}

resource "random_password" "mysql_admin" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret_version" "mysql_credentials_version_v12" {
  secret_id = aws_secretsmanager_secret.mysql_credentials_v12.id
  secret_string = jsonencode({
    username = var.mysql_admin_username
    password = random_password.mysql_admin.result
    host     = aws_instance.mysql_server.public_ip
    port     = "3307"
  })
}