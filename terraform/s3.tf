module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  count         = length(var.aws_bucket_names)
  bucket        = "${var.aws_project_name}-${var.aws_bucket_names[count.index]}-${var.environment}-${var.aws_id}"
  force_destroy = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning = {
    enabled = var.aws_bucket_names[count.index] == "mwaa" ? true : false
  }

  tags = var.aws_project_tags
}

resource "aws_s3_object" "emr_folder" {
  bucket = module.s3_bucket[1].s3_bucket_id

  for_each = fileset("../include/emr_functions", "*.py")
  key      = "emr_functions/${each.value}"
  source   = "../include/emr_functions/${each.value}"
  etag     = filemd5("../include/emr_functions/${each.value}")
}

resource "aws_s3_object" "dags" {
  bucket = module.s3_bucket[1].s3_bucket_id

  for_each = fileset("../dags", "**")
  key      = "dags/${each.value}"
  source   = "../dags/${each.value}"
  etag     = filemd5("../dags/${each.value}")
}