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