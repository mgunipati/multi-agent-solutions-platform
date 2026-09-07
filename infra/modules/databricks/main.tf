locals { catalog_name = replace("${var.product_name}_${var.environment}", "-", "_") }

resource "databricks_catalog" "product" {
  name         = local.catalog_name
  comment      = "Governed catalog for ${var.product_name} ${var.environment}"
  owner        = var.catalog_owner
  storage_root = var.create_managed_storage ? "${databricks_external_location.managed[0].url}/catalog" : var.catalog_storage_root

  lifecycle {
    precondition {
      condition     = !var.create_managed_storage || var.catalog_storage_root == null
      error_message = "Choose create_managed_storage or an existing catalog_storage_root, not both."
    }
  }
}

resource "databricks_schema" "bronze" {
  catalog_name = databricks_catalog.product.name
  name         = "bronze"
  comment      = "Raw, source-aligned data"
}

resource "databricks_schema" "silver" {
  catalog_name = databricks_catalog.product.name
  name         = "silver"
  comment      = "Validated and standardized data"
}

resource "databricks_schema" "gold" {
  catalog_name = databricks_catalog.product.name
  name         = "gold"
  comment      = "Product-ready data and evaluation outputs"
}

output "catalog_name" { value = databricks_catalog.product.name }
