# Lambda policy to access secrets manager
resource "aws_iam_policy" "secret_total_access_policy" {
  name   = "secret_total_access_policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": "arn:aws:secretsmanager:${var.aws_region}:${var.aws_id}:secret:*"
        },
        {
            "Effect": "Allow",
            "Action": "secretsmanager:ListSecrets",
            "Resource": "*"
        }
    ]
}
EOF
}

# GLUE ROLE POLICY
resource "aws_iam_role" "glue_crawler_role" {
  name               = var.aws_glue_crawler_role_name #"${var.aws_project_name}-glue-crawler-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "glue.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole_role_policy" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# TESTAR SEM ESSAS 2 POLICIES
resource "aws_iam_role_policy_attachment" "glue_crawler_secret_access" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = aws_iam_policy.secret_total_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "rds_full_access_policy" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
}