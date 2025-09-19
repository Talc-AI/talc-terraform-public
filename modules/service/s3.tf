resource "aws_s3_bucket" "dataset_bucket" {
  bucket = "${var.s3_bucket_prefix}${var.environment_name}-datasets"
}

resource "aws_s3_bucket" "file_storage" {
  bucket = "${var.s3_bucket_prefix}${var.environment_name}-talc-file-storage"
}


resource "aws_s3_bucket_lifecycle_configuration" "uploads__expire_after_one_day" {
  bucket = aws_s3_bucket.file_storage.id

  timeouts {
    create = "10m"
  }

  rule {
    id     = "auto-delete-objects"
    status = "Enabled"

    filter {
      prefix = "medsvc/uploads/"
    }

    expiration {
      days = var.s3_file_storage_lifecycle_expiration_days
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "results__expire_after_one_day" {
  bucket = aws_s3_bucket.file_storage.id

  timeouts {
    create = "10m"
  }

  rule {
    id     = "auto-delete-objects"
    status = "Enabled"

    filter {
      prefix = "medsvc/results/"
    }

    expiration {
      days = var.s3_file_storage_lifecycle_expiration_days
    }
  }
}
