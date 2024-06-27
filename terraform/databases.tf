# MYSQL DATABASE
resource "aws_db_instance" "mysql_database" {
  # Engine options
  engine         = "mysql"
  engine_version = "8.0.35"

  # Availability and durability
  multi_az = false

  # Settings
  identifier = "${var.aws_project_name}-mysqldb-${var.aws_id}"
  username   = var.aws_rds_username
  password   = random_password.mysql_password.result

  # Instance configuration
  instance_class = "db.t3.micro"

  # Storage
  storage_type          = "gp2" # general purpose SSD
  allocated_storage     = 20    # Memory GiB
  max_allocated_storage = 0     # Autoscalling disable

  # Connectivity 
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [module.security_group_rds.security_group_id]
  publicly_accessible    = false

  # Tags
  tags = merge(var.aws_project_tags, { Database = "mysql" })

  # Additional configuration
  db_name = var.aws_mysql_db_name
  # Without backup when deleted
  skip_final_snapshot = true
}

# data "aws_secretsmanager_secret" "mysql_secret" {
#   arn = aws_db_instance.mysql_database.master_user_secret[0]["secret_arn"]
# }

resource "random_password" "mysql_password" {
  length           = 16
  special          = true
  override_special = "_%+=~!#$^*<>-"
}

module "secrets_manager_mysql" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.1.2"

  name_prefix = "MySQL-secret-"
  description = "Secret for ${var.aws_project_name}-mysqldb"

  # Secret
  recovery_window_in_days = 0
  secret_string = jsonencode(
    {
      username = var.aws_rds_username
      password = random_password.mysql_password.result
      port     = aws_db_instance.mysql_database.port
      host     = aws_db_instance.mysql_database.address
    }
  )
  #kms_key_id = aws_kms_key.this.id (Uses default aws/secretsmanager)

  tags = merge(var.aws_project_tags, { Database = "mysql" })
}
