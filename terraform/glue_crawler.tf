locals {
  delta_tables = [
    "sales_people_by_total",
    "sales_people_by_month",
    "sales_people_by_product",
    "sales_people_by_product_month",
    "top_selling_products",
    "top_selling_products_by_month",
    "top_spending_clients",
    "top_spending_clients_by_age_group"
  ]

  delta_paths = [
    for delta_table in local.delta_tables :
    "s3://${module.s3_bucket[0].s3_bucket_id}/gold/${delta_table}"
  ]

}

# Glue catalog database
resource "aws_glue_catalog_database" "glue_database" {
  name = var.aws_glue_catalog_database_name
}

# AWS Gluer crawler
resource "aws_glue_crawler" "s3_raw_data" {
  name          = var.aws_glue_crawler_raw_name
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_crawler_role.arn


  s3_target {
    path = "s3://${module.s3_bucket[0].s3_bucket_id}/raw"
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DEPRECATE_IN_DATABASE"
  }

  tags = var.aws_project_tags
}

resource "aws_glue_crawler" "s3_gold_layer" {
  name          = var.aws_glue_crawler_gold_name
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_crawler_role.arn

  delta_target {
    delta_tables   = local.delta_paths
    write_manifest = "false"
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DEPRECATE_IN_DATABASE"
  }

  tags = var.aws_project_tags
}