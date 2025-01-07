resource "aws_s3_bucket" "tmp_bucket" {
  bucket        = var.s3bucket_aux
  force_destroy = true
}

resource "aws_emrserverless_application" "example" {
  name          = "emr-iceberg-s3tables"
  release_label = "emr-7.5.0"
  type          = "spark"

  initial_capacity {
    initial_capacity_type = "Driver"

    initial_capacity_config {
      worker_count = 1
      worker_configuration {
        cpu    = "2 vCPU"
        memory = "10 GB"
      }
    }
  }
  network_configuration {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.private_sg.id]
  }
}

resource "aws_iam_role" "emr_serverless_role" {
  name = "EMR-Serverless-Execution-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "emr-serverless.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.emr_serverless_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "s3tables_full_access" {
  role       = aws_iam_role.emr_serverless_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3TablesFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_access" {
  role       = aws_iam_role.emr_serverless_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_cloudwatch_log_group" "emr_cloudwatch" {
  name = "/emr-serverless/s3tablesjobs"
}