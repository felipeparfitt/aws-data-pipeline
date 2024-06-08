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

variable "aws_security_group_name" {
  description = "Security group name"
  type        = string
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

variable "aws_glue_crawler_name" {
  description = "Glue crawler name"
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
