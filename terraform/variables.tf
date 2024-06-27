variable "aws_project_name" {
  type        = string
  description = "Data pipeline project name"
  nullable    = false
}

variable "aws_region" {
  type        = string
  description = "AWS Region to deploy resources for development"
  nullable    = false
}

variable "aws_id" {
  type        = string
  description = "AWS Account ID"
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Environment type: dev or prod"
  nullable    = false
}

variable "aws_rds_username" {
  type        = string
  description = "Amazon RDS username"
  nullable    = false
}

variable "aws_vpc_cidr" {
  description = "VPC cidr range block"
  type        = string
  nullable    = false
}

variable "aws_vpc_name" {
  description = "VPC name"
  type        = string
  nullable    = false
}

variable "aws_project_tags" {
  description = "Project tags"
  type        = map(any)
  nullable    = false
}

variable "aws_security_group_name_rds" {
  description = "Rds security group name"
  type        = string
  nullable    = false
}

variable "aws_security_group_name_lambda" {
  description = "Lambda security group name"
  type        = string
  nullable    = false
}

variable "aws_glue_crawler_role_name" {
  description = "Glue crawler role name"
  type        = string
  nullable    = false
}

variable "aws_glue_catalog_database_name" {
  description = "Glue catalog database name"
  type        = string
  nullable    = false
}

variable "aws_glue_crawler_raw_name" {
  description = "Raw data Glue crawler name"
  type        = string
  nullable    = false
}

variable "aws_glue_crawler_gold_name" {
  description = "Gold layer Glue crawler name"
  type        = string
  nullable    = false
}

variable "aws_glue_connection_name" {
  description = "Glue connection name"
  type        = string
  nullable    = false
}

variable "aws_lambda_function_name" {
  description = "Lambda function name"
  type        = string
  nullable    = false
}

variable "python_version" {
  description = "Python version used on lambda function"
  type        = string
  nullable    = false
}

variable "aws_bucket_names" {
  description = "S3 bucket names"
  type        = list(string)
  nullable    = false
}

variable "aws_mysql_db_name" {
  description = "MYSQL database name"
  type        = string
  nullable    = false
}

variable "aws_emr_service_role_name" {
  description = "EMR service role name"
  type        = string
  nullable    = false
}

variable "aws_emr_ec2_role_name" {
  description = "EMR EC2 role name"
  type        = string
  nullable    = false
}

variable "aws_emr_ec2_profile_name" {
  description = "EMR EC2 proflie name"
  type        = string
  nullable    = false
}

variable "aws_dms_role_name" {
  description = "DMS role name"
  type        = string
  nullable    = false
}

variable "aws_mwaa_environment_name" {
  type        = string
  description = "Name of the MWAA environment"
  nullable    = false
}

variable "aws_mwaa_environment_class" {
  description = "Type of mwaa environment class"
  type        = string
  nullable    = false
}

variable "aws_weekly_maintenance_window_start" {
  description = "Weekly mwaa maintenance time"
  type        = string
  nullable    = false
}

variable "aws_airflow_version" {
  description = "Airflow version"
  type        = string
  nullable    = false
}

variable "aws_mwaa_role_name" {
  description = "mwaa role name"
  type        = string
  nullable    = false
}

variable "aws_mwaa_role_policy_name" {
  description = "MWAA role policy name"
  type        = string
  nullable    = false
}

variable "aws_webserver_access_mode" {
  description = "Amazon MWAA - Apache Airflow web server: private or public"
  type        = string
  nullable    = false
}

variable "aws_max_workers" {
  description = "The maximum number of workers your environment is permitted to scale up to"
  type        = string
  nullable    = false
}

variable "aws_min_workers" {
  description = "The minimum number of workers always present in your environment"
  type        = string
  nullable    = false
}

variable "aws_security_group_name_mwaa" {
  description = "Security group name for mwaa"
  type        = string
  nullable    = false
}

variable "aws_mwaa_variables_prefix" {
  description = "Prefix used for MWAA variables stored in Secrets Manager as the backend"
  type        = string
  nullable    = false
}

variable "aws_mwaa_connections_prefix" {
  description = "Prefix used for MWAA connections stored in Secrets Manager as the backend"
  type        = string
  nullable    = false
}