locals {
  storage_count = var.create_managed_storage ? 1 : 0
  storage_name  = "${var.product_name}-${var.environment}-uc"
  storage_tags = merge(var.tags, {
    Product     = var.product_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Databricks managed storage"
  })
}

data "aws_caller_identity" "storage" {
  count = local.storage_count
}

data "aws_partition" "storage" {
  count = local.storage_count
}

resource "aws_s3_bucket" "managed" {
  count         = local.storage_count
  bucket_prefix = "${local.storage_name}-"
  force_destroy = false
  tags          = local.storage_tags

  lifecycle {
    precondition {
      condition     = var.managed_storage_kms_key_arn != null
      error_message = "managed_storage_kms_key_arn is required when creating managed storage."
    }
  }
}

resource "aws_s3_bucket_public_access_block" "managed" {
  count                   = local.storage_count
  bucket                  = aws_s3_bucket.managed[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "managed" {
  count  = local.storage_count
  bucket = aws_s3_bucket.managed[0].id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "managed" {
  count  = local.storage_count
  bucket = aws_s3_bucket.managed[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "managed" {
  count  = local.storage_count
  bucket = aws_s3_bucket.managed[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.managed_storage_kms_key_arn
    }
    bucket_key_enabled = true
  }
}

data "aws_iam_policy_document" "storage_tls" {
  count = local.storage_count
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.managed[0].arn, "${aws_s3_bucket.managed[0].arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "managed" {
  count  = local.storage_count
  bucket = aws_s3_bucket.managed[0].id
  policy = data.aws_iam_policy_document.storage_tls[0].json
}

# Construct the future role ARN to avoid a dependency cycle: the role trust policy
# needs the external ID returned by this credential. External-location creation
# below performs storage validation after the role and its policy exist.
resource "databricks_storage_credential" "managed" {
  count           = local.storage_count
  name            = "${local.catalog_name}_managed"
  comment         = "Terraform-managed credential for ${local.catalog_name} storage"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  skip_validation = true
  aws_iam_role {
    role_arn = "arn:${data.aws_partition.storage[0].partition}:iam::${data.aws_caller_identity.storage[0].account_id}:role/${local.storage_name}"
  }
}

data "databricks_aws_unity_catalog_assume_role_policy" "managed" {
  count                 = local.storage_count
  aws_account_id        = data.aws_caller_identity.storage[0].account_id
  aws_partition         = data.aws_partition.storage[0].partition
  role_name             = local.storage_name
  external_id           = databricks_storage_credential.managed[0].aws_iam_role[0].external_id
  unity_catalog_iam_arn = databricks_storage_credential.managed[0].aws_iam_role[0].unity_catalog_iam_arn
}

data "databricks_aws_unity_catalog_policy" "managed" {
  count          = local.storage_count
  aws_account_id = data.aws_caller_identity.storage[0].account_id
  aws_partition  = data.aws_partition.storage[0].partition
  bucket_name    = aws_s3_bucket.managed[0].id
  role_name      = local.storage_name
  kms_name       = var.managed_storage_kms_key_arn
}

resource "aws_iam_role" "managed" {
  count              = local.storage_count
  name               = local.storage_name
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.managed[0].json
  tags               = local.storage_tags
}

resource "aws_iam_role_policy" "managed" {
  count  = local.storage_count
  name   = "unity-catalog-storage"
  role   = aws_iam_role.managed[0].id
  policy = data.databricks_aws_unity_catalog_policy.managed[0].json
}

resource "databricks_external_location" "managed" {
  count           = local.storage_count
  name            = "${local.catalog_name}_managed"
  url             = "s3://${aws_s3_bucket.managed[0].id}/managed"
  credential_name = databricks_storage_credential.managed[0].id
  comment         = "Managed table storage for ${local.catalog_name}"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  skip_validation = false

  depends_on = [
    aws_iam_role_policy.managed,
    aws_s3_bucket_public_access_block.managed,
    aws_s3_bucket_ownership_controls.managed,
    aws_s3_bucket_versioning.managed,
    aws_s3_bucket_server_side_encryption_configuration.managed,
    aws_s3_bucket_policy.managed,
  ]
}

output "managed_storage_bucket_name" {
  description = "Dedicated managed-storage bucket, or null when using existing storage."
  value       = try(aws_s3_bucket.managed[0].id, null)
}

output "managed_storage_role_arn" {
  value = try(aws_iam_role.managed[0].arn, null)
}

output "catalog_storage_root" {
  value = databricks_catalog.product.storage_root
}
