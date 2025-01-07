region             = "us-east-2"
s3bucket_aux       = "s3tables-aux"
s3tables_namespace = "iceberg_namespace"

table_bucket = {
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

s3tables_table = {
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

