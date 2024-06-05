output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.mysql_database.address
  sensitive   = true
}
output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.mysql_database.port
  sensitive   = true
}
output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.mysql_database.username
  sensitive   = true
}
# output "mysqldb_password" {
#   description = "RDS MYSQL secret password"
#   value       = jsondecode(data.aws_secretsmanager_secret_version.mysql_secret_version.secret_string).password
#   sensitive   = true
# }
