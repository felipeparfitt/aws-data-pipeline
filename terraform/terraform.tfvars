aws_project_name                    = "aws-data-pipeline"
aws_region                          = "us-east-2"
aws_id                              = 612649281430
aws_rds_username                    = "admin"
environment                         = "dev"
aws_vpc_cidr                        = "10.0.0.0/16"
aws_vpc_name                        = "vpc-aws-data-pipeline"
aws_security_group_name_mwaa        = "managed-mwaa-sg"
aws_security_group_name_lambda      = "lambda-sg"
aws_security_group_name_rds         = "rds-sg"
aws_glue_crawler_role_name          = "aws-data-pipeline-glue-crawler-role"
aws_glue_catalog_database_name      = "aws-data-pipeline-glue-database"
aws_glue_crawler_raw_name           = "aws-data-pipeline-glue-crawler-raw"
aws_glue_crawler_gold_name          = "aws-data-pipeline-glue-crawler-gold"
aws_glue_connection_name            = "aws-data-pipeline-glue-connection"
aws_lambda_function_name            = "populate-mysql-rds"
python_version                      = "python3.11"
aws_mysql_db_name                   = "mysqldb"
aws_emr_service_role_name           = "emr-service-role"
aws_emr_ec2_role_name               = "EMR_EC2_DefaultRole"
aws_emr_ec2_profile_name            = "emr-ec2-role-profile"
aws_dms_role_name                   = "dms-role"
aws_min_workers                     = 1
aws_max_workers                     = 3
aws_mwaa_environment_class          = "mw1.small"
aws_weekly_maintenance_window_start = "SUN:19:00"
aws_mwaa_role_name                  = "mwaa-execution-role"
aws_mwaa_role_policy_name           = "mwaa-execution-role-policy"
aws_airflow_version                 = "2.8.1"
aws_webserver_access_mode           = "PUBLIC_ONLY"
aws_mwaa_environment_name           = "mwaa-env-public-only"
aws_mwaa_variables_prefix           = "airflow/variables"
aws_mwaa_connections_prefix         = "airflow/connections"
aws_bucket_names = [
  "delta-lake",
  "mwaa",
  "emr-logs"
]
aws_project_tags = {
  Terraform   = "true"
  Environment = "dev"
  Project     = "aws-data-pipeline"
}