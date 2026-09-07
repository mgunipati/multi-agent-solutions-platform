variable "product_name" {
  type    = string
  default = "multi-agent-solutions"
}
variable "aws_region" {
  type    = string
  default = "us-west-2"
}
variable "enable_databricks" {
  type    = bool
  default = false
}
variable "enable_snowflake" {
  type    = bool
  default = false
}
variable "databricks_catalog_owner" {
  type    = string
  default = "account users"
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "databricks_create_managed_storage" {
  type        = bool
  description = "Provision dedicated S3 managed storage and Unity Catalog access when Databricks is enabled."
  default     = false
}

variable "databricks_catalog_storage_root" {
  type        = string
  description = "Existing authorized catalog storage location; leave null when creating managed storage."
  default     = null
}
