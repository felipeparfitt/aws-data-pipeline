aws_project_name               = "aws-data-pipeline"
aws_region                     = "us-east-2"
aws_id                         = 612649281430
aws_rds_username               = "admin"
aws_vpc_cidr                   = "10.0.0.0/16"
aws_vpc_name                   = "vpc-aws-data-pipeline"
aws_security_group_name        = "managed-mwaa-sg"
aws_security_group_name_lambda = "lambda-sg"
aws_security_group_name_rds    = "rds-sg"
aws_project_tags = {
  Terraform   = "true"
  Environment = "dev"
  Project     = "aws-data-pipeline"
}
