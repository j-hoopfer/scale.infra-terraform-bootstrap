# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  tags = merge(
    var.common_tags,
    {
      Name        = var.bucket_name
      Purpose     = "Terraform State Storage"
      Environment = var.environment
    }
  )
}

# Enable Versioning (Critical for state recovery)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Use "aws:kms" for KMS encryption
    }
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle Policy (Cleanup old versions of object after 90 days)
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {} # Apply to all objects

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
