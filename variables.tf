variable "allow_ssh_from_cidr" {
  description = "CIDR block to allow SSH access (default: dynamically fetches your public IP)"
  type        = string
  default     = null # Override to restrict to specific IPs (e.g., "203.0.113.1/32")
}
variable "mysql_admin_username" {
  description = "Username for the MySQL admin account"
  type        = string
  default     = "admin"
}