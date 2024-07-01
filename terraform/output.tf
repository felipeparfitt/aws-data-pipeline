output "AWS_REGION" {
  description = "AWS Region to deploy resources for development"
  value       = var.aws_region
  sensitive   = false
}
output "AWS_GLUE_DATABASE_NAME" {
  description = "AWS glue database name"
  value       = var.aws_glue_catalog_database_name
  sensitive   = false
}
output "AWS_LAMBDA_FUNCTION_NAME" {
  description = "AWS Lambda function name"
  value       = var.aws_lambda_function_name
  sensitive   = false
}
output "AWS_GLUE_CRAWLER_RAW_NAME" {
  description = "AWS glue crawler name for raw data"
  value       = var.aws_glue_crawler_raw_name
  sensitive   = false
}
output "AWS_GLUE_CRAWLER_GOLD_NAME" {
  description = "AWS glue crawler name for gold layer"
  value       = var.aws_glue_crawler_gold_name
  sensitive   = false
}
output "EMR_SERVICE_ROLE" {
  description = "EMR service role name"
  value       = var.aws_emr_service_role_name
  sensitive   = false
}
output "EMR_JOB_FLOW_ROLE" {
  description = "EMR EC2 profile role name"
  value       = var.aws_emr_ec2_profile_name
  sensitive   = false
}
output "PATH_S3_LOGS" {
  description = "S3 path to EMR logs"
  value       = "s3://${module.s3_bucket[2].s3_bucket_id}/elasticmapreduce"
  sensitive   = false
}
output "EMR_SUBNET_EC2_ID" {
  description = "Subnet ID for EMR cluster"
  value       = module.vpc.public_subnets[0]
  sensitive   = false
}
output "ETL_SCRIPT_S3_PATH" {
  description = "S3 path to etl function"
  value       = "s3://${module.s3_bucket[1].s3_bucket_id}/emr_functions/emr_delta_lake.py"
  sensitive   = false
}
output "ETL_PYFILES_S3_PATH" {
  description = "S3 path to etl auxiliar pyfiles"
  value       = "s3://${module.s3_bucket[1].s3_bucket_id}/emr_functions/emr_delta_transformation.py"
  sensitive   = false
}
output "DMS_REPL_TASK_ARN" {
  description = "DMS replication task arn"
  value       = module.database_migration_service.replication_tasks["s3_import"].replication_task_arn
  sensitive   = false
}
output "DELTA_LAKE_BUCKET_NAME" {
  description = "Bucket name for delta lake"
  value       = module.s3_bucket[0].s3_bucket_id
  sensitive   = false
}