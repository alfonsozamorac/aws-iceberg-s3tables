

#DATA

data "aws_iam_policy_document" "table_bucket" {
  statement {
    actions = ["s3tables:*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    resources = ["${aws_s3tables_table_bucket.table_bucket.arn}/*"]
  }
}

data "aws_iam_policy_document" "table" {
  statement {
    actions = ["s3tables:*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    resources = ["${aws_s3tables_table.table.arn}"]
  }
}

# RESOURCES

resource "aws_s3tables_table_bucket" "table_bucket" {
  name                      = var.table_bucket.name
  maintenance_configuration = var.table_bucket.maintenance_configuration
}

resource "aws_s3tables_table_bucket_policy" "example" {
  resource_policy  = data.aws_iam_policy_document.table_bucket.json
  table_bucket_arn = aws_s3tables_table_bucket.table_bucket.arn
}

resource "aws_s3tables_namespace" "namespace" {
  namespace        = var.s3tables_namespace
  table_bucket_arn = aws_s3tables_table_bucket.table_bucket.arn
}

resource "aws_s3tables_table" "table" {
  name                      = var.s3tables_table.name
  namespace                 = aws_s3tables_namespace.namespace.namespace
  table_bucket_arn          = aws_s3tables_namespace.namespace.table_bucket_arn
  format                    = "ICEBERG"
  maintenance_configuration = var.s3tables_table.maintenance_configuration
}

resource "aws_s3tables_table_policy" "example" {
  resource_policy  = data.aws_iam_policy_document.table.json
  name             = aws_s3tables_table.table.name
  namespace        = aws_s3tables_table.table.namespace
  table_bucket_arn = aws_s3tables_table.table.table_bucket_arn
}
