# Terraform backend S3 bucket and optional DynamoDB for state locking

resource "random_string" "rand" {
  length  = 8
  upper   = false
  special = false
}

locals {
  full_name = "${var.namespace}-${random_string.rand.result}"
}

resource "aws_s3_bucket" "this" {
  bucket        = local.full_name
  force_destroy = var.force_destroy_state
  tags          = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "this" {
  count        = var.enable_locking ? 1 : 0
  name         = "${local.full_name}-lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}
