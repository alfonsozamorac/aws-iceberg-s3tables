
output "table_bucket" {
  description = "Bucket Table name"
  value       = aws_s3tables_table_bucket.table_bucket.name
}

output "table_bucket_arn" {
  description = "Bucket Table ARN"
  value       = "arn:aws:s3tables:${var.region}:${data.aws_caller_identity.current.account_id}:bucket/${aws_s3tables_table_bucket.table_bucket.name}"
}

output "emr_app_id" {
  value = aws_emrserverless_application.example.id
}

output "region" {
  value = var.region
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "bucket_aux" {
  value = aws_s3_bucket.tmp_bucket.bucket
}

output "namespace" {
  value = aws_s3tables_namespace.namespace.namespace
}

output "table" {
  value = aws_s3tables_table.table.name
}

output "emr_role" {
  value = aws_iam_role.emr_serverless_role.arn
}

output "group_cloudwatch" {
  value = aws_cloudwatch_log_group.emr_cloudwatch.name
}

output "athena_workgroup" {
  value = aws_athena_workgroup.workgroup.name
}