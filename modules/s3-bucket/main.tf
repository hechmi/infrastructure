variable "bucket_name" { type = string }
variable "environment" { type = string }
variable "versioning_enabled" { type = bool; default = true }
variable "encryption_enabled" { type = bool; default = true }
variable "tags" { type = map(string); default = {} }

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = merge(var.tags, { Environment = var.environment })
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.encryption_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "id" { value = aws_s3_bucket.this.id }
output "arn" { value = aws_s3_bucket.this.arn }
output "bucket_name" { value = aws_s3_bucket.this.bucket }
