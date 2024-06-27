data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name                               = var.aws_vpc_name
  cidr                               = var.aws_vpc_cidr
  create_database_subnet_group       = true
  create_database_subnet_route_table = true
  create_database_nat_gateway_route  = true
  #create_database_internet_gateway_route = true

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(var.aws_vpc_cidr, 8, k + 1)] #"10.0.k+1.0/16+8"
  public_subnets   = [for k, v in local.azs : cidrsubnet(var.aws_vpc_cidr, 8, k + 100)]
  database_subnets = [for k, v in local.azs : cidrsubnet(var.aws_vpc_cidr, 8, k + 200)]

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = merge(var.aws_project_tags, { "for-use-with-amazon-emr-managed-policies" : "true" })
}

module "security_group_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"

  name   = var.aws_security_group_name_rds
  vpc_id = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = 6
      source_security_group_id = module.security_group_lambda.security_group_id
      description              = "Allow MySQL traffic from lambda sg group"
    }
  ]

  ingress_with_self = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      description = "Allow all inbound traffic from the same security group - Ingress rule for glue connection"
    }
  ]
  egress_rules = ["all-all"]
}

module "security_group_lambda" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"

  name        = var.aws_security_group_name_lambda
  description = "Security group for Lambda"
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]
}


module "security_group_mwaa" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"

  name   = var.aws_security_group_name_mwaa
  vpc_id = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTPS access from anywhere"
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow PostgreSQL traffic"
    }
  ]
  ingress_with_self = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Self-referencing rule allowing all inbound traffic"
    }
  ]
  egress_rules = ["all-all"]

  tags = var.aws_project_tags
}