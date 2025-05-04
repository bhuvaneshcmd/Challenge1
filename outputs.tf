output "ec2_public_ip" {
  description = "Public IP address of the MySQL server"
  value       = aws_instance.mysql_server.public_ip
}

output "mysql_secret_arn" {
  description = "ARN of the MySQL credentials secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.mysql_credentials_v12.arn
}

output "mysql_connection_instructions" {
  description = "Instructions to connect to MySQL"
  value       = <<-EOT
    Connect to MySQL using:
    mysql -h ${aws_instance.mysql_server.public_ip} -P 3307 -u admin -p
    Password: Retrieve from AWS Secrets Manager (ARN: ${aws_secretsmanager_secret.mysql_credentials_v12.arn})
  EOT
}