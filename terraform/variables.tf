
variable "region" {
  description = "Location"
  type        = string
}

variable "aws_user" {
  description = "AWS User"
  type        = string
}

variable "s3bucket_aux" {
  description = "S3 Bucket for aux files"
  type        = string
}

variable "s3tables_namespace" {
  description = "S3Tables Namespace"
  type        = string
}

variable "table_bucket" {
  description = "S3Tables Bucket"
  type = object({
    name = string
    maintenance_configuration = optional(object({
      iceberg_unreferenced_file_removal = object({
        status = string
        settings = object({
          non_current_days  = number
          unreferenced_days = number
        })
      })
    }))
  })
}

variable "s3tables_table" {
  description = "S3Tables Table"
  type = object({
    name = string
    maintenance_configuration = optional(object({
      iceberg_compaction = object({
        status = string
        settings = object({
          target_file_size_mb = string
        })
      })
      iceberg_snapshot_management = object({
        status = string
        settings = object({
          max_snapshot_age_hours = string
          min_snapshots_to_keep  = string
        })
      })
    }))
  })
}

