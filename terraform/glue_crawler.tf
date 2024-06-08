data "aws_subnet" "database_subnet" {
  id = module.vpc.database_subnets[0]
}

# Glue catalog database
resource "aws_glue_catalog_database" "glue_database" {
  name = var.aws_glue_catalog_database_name
}

# Glue connection to RDS MYSQL
resource "aws_glue_connection" "mysql_connection" {
  name = "mysql-connection"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${aws_db_instance.mysql_database.endpoint}/${aws_db_instance.mysql_database.db_name}"
    SECRET_ID           = data.aws_secretsmanager_secret.mysql_secret.name
  }

  physical_connection_requirements {
    availability_zone      = data.aws_subnet.database_subnet.availability_zone
    security_group_id_list = aws_db_instance.mysql_database.vpc_security_group_ids
    subnet_id              = data.aws_subnet.database_subnet.id
  }
}

resource "aws_glue_crawler" "rds_glue_crawler" {
  name          = var.aws_glue_crawler_name
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_crawler_role.arn

  jdbc_target {
    connection_name = aws_glue_connection.mysql_connection.name
    path            = "${aws_db_instance.mysql_database.db_name}/%"
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DEPRECATE_IN_DATABASE"
  }
}