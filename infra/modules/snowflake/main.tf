locals {
  prefix = upper(replace("${var.product_name}_${var.environment}", "-", "_"))
}

resource "snowflake_database" "product" {
  name                        = "${local.prefix}_DB"
  comment                     = "Governed database for ${var.product_name} ${var.environment}"
  data_retention_time_in_days = var.environment == "prod" ? 7 : 1
}

resource "snowflake_schema" "curated" {
  database = snowflake_database.product.name
  name     = "CURATED"
  comment  = "Curated analytical datasets"
}

resource "snowflake_schema" "audit" {
  database = snowflake_database.product.name
  name     = "AUDIT"
  comment  = "Application and retrieval audit datasets"
}

output "database_name" {
  description = "Name of the product database containing the CURATED and AUDIT schemas."
  value       = snowflake_database.product.name
}
