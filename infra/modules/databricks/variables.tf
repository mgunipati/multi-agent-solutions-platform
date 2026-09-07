variable "product_name" { type = string }
variable "environment" { type = string }
variable "catalog_owner" {
  type        = string
  description = "Databricks principal that owns the Unity Catalog catalog."
}

variable "catalog_storage_root" {
  type        = string
  description = "Managed storage location for the catalog. Required when the metastore has no storage root; use a path within an authorized Unity Catalog external location."
  default     = null
}

variable "create_managed_storage" {
  type        = bool
  description = "Create an S3 bucket, IAM role, storage credential, and external location for this catalog. Mutually exclusive with catalog_storage_root."
  default     = false
  nullable    = false
}

variable "managed_storage_kms_key_arn" {
  type        = string
  description = "Same-account, same-region KMS key used to encrypt the managed storage bucket. Required when create_managed_storage is true."
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
