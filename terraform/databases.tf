# MYSQL DATABASE
resource "aws_db_instance" "mysql_database" {
  # Engine options
  engine         = "mysql"
  engine_version = "8.0.35"

  # Availability and durability
  multi_az = false

  # Settings
  identifier                  = "${var.aws_project_name}-mysqldb-${var.aws_id}"
  username                    = var.aws_rds_username
  manage_master_user_password = true

  # Instance configuration
  instance_class = "db.t3.micro"

  # Storage
  storage_type          = "gp2" # general purpose SSD
  allocated_storage     = 20    # Memory GiB
  max_allocated_storage = 0     # Autoscalling disable

  # Connectivity 
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [module.security_group_rds.security_group_id]
  publicly_accessible    = true

  # Tags
  tags = merge(var.aws_project_tags, { Database = "mysql" })

  # Additional configuration
  db_name = "mysqldb"
  # Snapshot = copia dos dados; Neste caso, não sera criado um copia (sem backup) ao ser deletado
  skip_final_snapshot = true
}