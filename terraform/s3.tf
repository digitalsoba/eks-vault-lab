resource "aws_s3_bucket" "vault-backend-storage-s3" {
  bucket        = var.s3_storage_backend_name
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name        = var.s3_storage_backend_name
    Environment = "Dev"
  }
}