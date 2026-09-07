terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    databricks = { source = "databricks/databricks", version = "~> 1.0" }
    snowflake  = { source = "snowflakedb/snowflake", version = "~> 2.20" }
  }
  backend "s3" {}
}
provider "aws" { region = var.aws_region }
provider "databricks" {}
provider "snowflake" {}
module "aws" {
  source       = "../../modules/aws"
  product_name = var.product_name
  environment  = "prod"
  tags         = var.tags
}
module "databricks" {
  count                       = var.enable_databricks ? 1 : 0
  source                      = "../../modules/databricks"
  product_name                = var.product_name
  environment                 = "prod"
  catalog_owner               = var.databricks_catalog_owner
  create_managed_storage      = var.databricks_create_managed_storage
  managed_storage_kms_key_arn = module.aws.kms_key_arn
  tags                        = var.tags
  catalog_storage_root        = var.databricks_catalog_storage_root
}
module "snowflake" {
  count        = var.enable_snowflake ? 1 : 0
  source       = "../../modules/snowflake"
  product_name = var.product_name
  environment  = "prod"
}
