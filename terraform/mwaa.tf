resource "aws_mwaa_environment" "name" {
  name                            = var.aws_mwaa_environment_name
  airflow_version                 = var.aws_airflow_version
  weekly_maintenance_window_start = var.aws_weekly_maintenance_window_start
  webserver_access_mode           = var.aws_webserver_access_mode

  source_bucket_arn = module.s3_bucket[1].s3_bucket_arn
  dag_s3_path       = "dags/"

  environment_class  = var.aws_mwaa_environment_class
  execution_role_arn = aws_iam_role.mwaa-role.arn

  max_workers = var.aws_max_workers
  min_workers = var.aws_min_workers

  airflow_configuration_options = {
    "core.dag_file_processor_timeout" = 150
    "core.dagbag_import_timeout"      = 90
    "secrets.backend"                 = "airflow.providers.amazon.aws.secrets.secrets_manager.SecretsManagerBackend"
    "secrets.backend_kwargs"          = "{\"connections_prefix\": \"${var.aws_mwaa_connections_prefix}\",\"variables_prefix\": \"${var.aws_mwaa_variables_prefix}\"}"
  }

  network_configuration {
    subnet_ids         = slice(module.vpc.private_subnets, 0, 2)
    security_group_ids = [module.security_group_mwaa.security_group_id]

  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "DEBUG"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "WARNING"
    }

    worker_logs {
      enabled   = true
      log_level = "WARNING"
    }
  }


  # Allow to ignore the changes in requirement.txt ...
  lifecycle {
    ignore_changes = [
      requirements_s3_object_version,
      plugins_s3_object_version,
    ]
  }

  tags = var.aws_project_tags
}

locals {
  secrets = {
    "AWS_REGION"                 = var.aws_region
    "AWS_GLUE_DATABASE_NAME"     = var.aws_glue_catalog_database_name
    "AWS_LAMBDA_FUNCTION_NAME"   = var.aws_lambda_function_name
    "AWS_GLUE_CRAWLER_RAW_NAME"  = var.aws_glue_crawler_raw_name
    "AWS_GLUE_CRAWLER_GOLD_NAME" = var.aws_glue_crawler_gold_name
    "EMR_SERVICE_ROLE"           = var.aws_emr_service_role_name
    "EMR_JOB_FLOW_ROLE"          = var.aws_emr_ec2_profile_name
    "PATH_S3_LOGS"               = "s3://${module.s3_bucket[2].s3_bucket_id}/elasticmapreduce"
    "EMR_SUBNET_EC2_ID"          = module.vpc.public_subnets[0]
    "ETL_SCRIPT_S3_PATH"         = "s3://${module.s3_bucket[1].s3_bucket_id}/emr_functions/emr_delta_lake.py"
    "ETL_PYFILES_S3_PATH"        = "s3://${module.s3_bucket[1].s3_bucket_id}/emr_functions/emr_delta_transformation.py"
    "DMS_REPL_TASK_ARN"          = module.database_migration_service.replication_tasks["s3_import"].replication_task_arn
    "DELTA_LAKE_BUCKET_NAME"     = module.s3_bucket[0].s3_bucket_id
  }
}



module "secrets_manager_mwaa" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.1.2"

  for_each = local.secrets

  name        = "${var.aws_mwaa_variables_prefix}/${each.key}"
  description = "Secret for ${var.aws_project_name}-MWAA"

  # Secret
  recovery_window_in_days = 0
  secret_string           = each.value

  #kms_key_id = aws_kms_key.this.id (Uses default aws/secretsmanager)

  tags = var.aws_project_tags
}