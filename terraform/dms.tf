# Replication Task: Required Configurations for Replicating Data from a Source to a Destination ("EC2 Instance")
module "database_migration_service" {
  source  = "terraform-aws-modules/dms/aws"
  version = "2.2.0"

  # Subnet group
  repl_subnet_group_name        = module.vpc.database_subnet_group_name
  repl_subnet_group_description = "DMS Subnet group for ${module.vpc.database_subnet_group_name}"
  repl_subnet_group_subnet_ids  = module.vpc.database_subnets

  # Instance
  create_repl_instance                       = true
  repl_instance_allocated_storage            = 50 #(default)
  repl_instance_engine_version               = "3.5.2"
  repl_instance_class                        = "dms.t2.micro"
  repl_instance_id                           = "${var.aws_project_name}-ReplInstance"
  repl_instance_multi_az                     = false
  repl_instance_publicly_accessible          = false
  repl_instance_vpc_security_group_ids       = [module.security_group_rds.security_group_id]
  repl_instance_preferred_maintenance_window = "sun:10:30-sun:14:30"

  create_access_iam_role = true
  #access_iam_role_path = aws_iam_role.dms_role.arn
  access_secret_arns = [
    module.secrets_manager_mysql.secret_arn
  ]
  access_target_s3_bucket_arns = [
    module.s3_bucket[0].s3_bucket_arn,
    "${module.s3_bucket[0].s3_bucket_arn}/*"
  ]

  # Source/target config
  endpoints = {
    mysql-source = {
      database_name = aws_db_instance.mysql_database.db_name
      endpoint_id   = "mysql-source"
      endpoint_type = "source"
      engine_name   = aws_db_instance.mysql_database.engine
      #extra_connection_attributes = "secretsManagerEndpointOverride=${module.vpc_endpoints.endpoints["secretsmanager"]["dns_entry"][0]["dns_name"]}"
      secrets_manager_arn = module.secrets_manager_mysql.secret_arn
      tags                = { EndpointType = "source" }
    }
  }

  s3_endpoints = {
    s3-destination = {
      endpoint_id      = "s3-target"
      endpoint_type    = "target"
      engine_name      = "s3"
      parquet_version  = "parquet-2-0"
      bucket_folder    = "raw/"
      bucket_name      = module.s3_bucket[0].s3_bucket_id
      compression_type = "GZIP"
      #service_access_role_arn = aws_iam_role.s3_role.arn
      data_format = "parquet"
      tags        = { EndpointType = "target" }
    }
  }

  # Regra que a maquina(EC2) vai executar a task
  replication_tasks = {
    s3_import = {
      replication_task_id = "mysqlToS3"
      migration_type      = "full-load"
      table_mappings      = file("./dms_config/table_mappings.json")
      source_endpoint_key = "mysql-source"
      target_endpoint_key = "s3-destination"
      tags                = { Task = "mysql-to-s3" }
    }
  }

  tags = var.aws_project_tags
}