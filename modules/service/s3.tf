resource "aws_s3_bucket" "dataset_bucket" {
  bucket = "${var.environment_name}-datasets"
}
