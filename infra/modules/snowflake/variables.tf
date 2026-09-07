variable "product_name" {
  type        = string
  description = "Product name used in the database name; hyphens become underscores and letters become uppercase."
  nullable    = false

  validation {
    condition     = length(trimspace(var.product_name)) > 0 && var.product_name == trimspace(var.product_name)
    error_message = "product_name must not be empty or contain leading or trailing whitespace."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment: prod uses seven days of database retention; dev and stage use one day."
  nullable    = false

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be dev, stage, or prod."
  }
}
