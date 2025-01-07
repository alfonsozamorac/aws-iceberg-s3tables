
variable "region" {
  description = "Location"
  type        = string
  default     = "us-east-2"
}

variable "aws_user" {
  description = "AWS User"
  type        = string
}

variable "table_bucket" {
  description = "Name of Namespace"
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
  default = {
    name = "poc-tablebucket"
    maintenance_configuration = {
      iceberg_unreferenced_file_removal = {
        status = "enabled"
        settings = {
          non_current_days  = 1
          unreferenced_days = 1
        }
      }
    }
  }
}

variable "s3tables_namespace" {
  description = "Name of Table"
  type        = string
  default     = "iceberg_namespace"
}

variable "s3tables_table" {
  description = "value"
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
  default = {
    name = "iceberg_table"
    maintenance_configuration = {
      iceberg_compaction = {
        status = "enabled"
        settings = {
          target_file_size_mb = "512"
        }
      }
      iceberg_snapshot_management = {
        status = "enabled"
        settings = {
          max_snapshot_age_hours = "1"
          min_snapshots_to_keep  = "1"
        }
      }
    }
  }
}

variable "s3bucket_aux" {
  description = "S3 Bucket for aux files"
  type        = string
  default     = "s3tables-aux"
}