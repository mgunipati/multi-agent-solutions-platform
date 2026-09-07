mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = { account_id = "123456789012" }
  }
  mock_data "aws_partition" {
    defaults = { partition = "aws" }
  }
}

mock_provider "databricks" {}

variables {
  product_name                = "storage-test"
  environment                 = "dev"
  catalog_owner               = "storage-admins"
  managed_storage_kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"
}

run "managed_storage_graph" {
  command = plan
  variables {
    create_managed_storage = true
  }
  # Planning the full graph verifies the credential -> trust policy -> role ->
  # external location -> catalog dependency chain has no bootstrap cycle.
  assert {
    condition     = length(aws_s3_bucket.managed) == 1 && length(databricks_external_location.managed) == 1
    error_message = "Managed storage must provision both the backing bucket and the governed location."
  }
}

run "existing_storage_does_not_provision_foundation" {
  command = plan
  variables {
    catalog_storage_root = "s3://existing-authorized-location/catalog"
  }
  assert {
    condition     = length(aws_s3_bucket.managed) == 0 && length(aws_iam_role.managed) == 0 && length(databricks_storage_credential.managed) == 0 && databricks_catalog.product.storage_root == "s3://existing-authorized-location/catalog"
    error_message = "Existing storage must be reused without creating a second foundation."
  }
}

run "reject_conflicting_storage_modes" {
  command = plan
  variables {
    create_managed_storage = true
    catalog_storage_root   = "s3://existing-authorized-location/catalog"
  }
  expect_failures = [databricks_catalog.product]
}

run "require_encryption_key" {
  command = plan
  variables {
    create_managed_storage      = true
    managed_storage_kms_key_arn = null
  }
  expect_failures = [aws_s3_bucket.managed]
}
