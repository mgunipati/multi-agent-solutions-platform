locals {
  name = "${var.product_name}-${var.environment}"
  tags = merge(var.tags, {
    Product     = var.product_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_kms_key" "application" {
  description             = "${local.name} application encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_kms_alias" "application" {
  name          = "alias/${local.name}"
  target_key_id = aws_kms_key.application.key_id
}

resource "aws_s3_bucket" "audit" {
  bucket_prefix = "${local.name}-audit-"
  tags          = local.tags
}

resource "aws_s3_bucket_public_access_block" "audit" {
  bucket                  = aws_s3_bucket.audit.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "audit" {
  bucket = aws_s3_bucket.audit.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.application.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_secretsmanager_secret" "application" {
  name                    = "${local.name}/application"
  kms_key_id              = aws_kms_key.application.arn
  recovery_window_in_days = 30
  tags                    = local.tags
}

