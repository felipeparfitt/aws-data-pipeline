module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.4.0"

  function_name = var.aws_lambda_function_name
  description   = "Fuction that creates and populates tables in mysql RDS"
  handler       = "insert_into_rds.populate_rds"
  runtime       = var.python_version
  timeout       = 900

  source_path = "../include/lambda_functions"

  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.lambda_security_group.security_group_id]


  attach_network_policy = true
  attach_policy         = true
  policy                = aws_iam_policy.secret_total_access_policy.arn

  environment_variables = {
    AWS_REGION_USED    = var.aws_region
    AWS_PROJECT_PREFIX = var.aws_project_name
    MYSQL_USER         = aws_db_instance.mysql_database.username
    MYSQL_HOST         = aws_db_instance.mysql_database.address
    MYSQL_PORT         = aws_db_instance.mysql_database.port
    MYSQL_DB           = aws_db_instance.mysql_database.db_name
  }
}