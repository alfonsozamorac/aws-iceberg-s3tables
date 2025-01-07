resource "aws_iam_role" "s3tables_role_for_lakeformation" {
  name = "S3TablesRoleForLakeFormation"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LakeFormationDataAccessPolicy"
        Effect = "Allow"
        Principal = {
          Service = "lakeformation.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:SetContext",
          "sts:SetSourceIdentity"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3tables_lakeformation_policy" {
  name        = "LakeFormationDataAccessPermissionsForS3TableBucket"
  description = "IAM policy for Lake Formation data access and S3 tables permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LakeFormationPermissionsForS3ListTableBucket"
        Effect = "Allow"
        Action = [
          "s3tables:ListTableBuckets"
        ]
        Resource = ["*"]
      },
      {
        Sid    = "LakeFormationDataAccessPermissionsForS3TableBucket"
        Effect = "Allow"
        Action = [
          "s3tables:CreateTableBucket",
          "s3tables:GetTableBucket",
          "s3tables:CreateNamespace",
          "s3tables:GetNamespace",
          "s3tables:ListNamespaces",
          "s3tables:DeleteNamespace",
          "s3tables:DeleteTableBucket",
          "s3tables:CreateTable",
          "s3tables:DeleteTable",
          "s3tables:GetTable",
          "s3tables:ListTables",
          "s3tables:RenameTable",
          "s3tables:UpdateTableMetadataLocation",
          "s3tables:GetTableMetadataLocation",
          "s3tables:GetTableData",
          "s3tables:PutTableData"
        ]
        Resource = [
          "arn:aws:s3tables:${var.region}:${data.aws_caller_identity.current.account_id}:bucket/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetTable",
          "glue:GetTables",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:DeleteTable",
          "glue:GetDatabase",
          "glue:CreateDatabase",
          "glue:DeleteDatabase",
          "glue:GetDatabases"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "lakeformation:GrantPermissions",
          "lakeformation:RevokePermissions",
          "lakeformation:GetDataAccess",
          "lakeformation:ListPermissions"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lakeformation_policy" {
  role       = aws_iam_role.s3tables_role_for_lakeformation.id
  policy_arn = aws_iam_policy.s3tables_lakeformation_policy.arn
}

resource "aws_lakeformation_resource" "s3_table_resource" {
  arn             = "arn:aws:s3tables:${var.region}:${data.aws_caller_identity.current.account_id}:bucket/*"
  role_arn        = aws_iam_role.s3tables_role_for_lakeformation.arn
  with_federation = true
}

resource "aws_iam_role_policy_attachment" "attach_lakeformation_policy_2" {
  role       = aws_iam_role.s3tables_role_for_lakeformation.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin"
}

resource "aws_iam_role_policy" "lakeformation_custom_permissions" {
  role = aws_iam_role.s3tables_role_for_lakeformation.id
  name = "LakeFormationCustomPermissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:PassConnection",
          "lakeformation:RegisterResource"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_athena_workgroup" "workgroup" {
  name          = "s3tables"
  force_destroy = true

  configuration {
    result_configuration {
      output_location = "s3://${var.s3bucket_aux}/athena-output/"
    }
  }

  state = "ENABLED"
}

resource "aws_iam_role" "example_role" {
  name = "ExampleRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "athena.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "athena_query_policy" {
  name        = "AthenaQueryPolicy"
  description = "Policy that grants permission to run queries in Athena"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "athena_query_policy_attachment" {
  role       = aws_iam_role.example_role.name
  policy_arn = aws_iam_policy.athena_query_policy.arn
}

#resource "aws_lakeformation_permissions" "table_permissions" {
#  permissions = ["ALL"]
#  principal   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.aws_user}"
#
#  table {
#    catalog_id = "${data.aws_caller_identity.current.account_id}:s3tablescatalog/${var.table_bucket.name}"
#    database_name = var.s3tables_namespace
#    name          = var.s3tables_table.name
#  }
#}