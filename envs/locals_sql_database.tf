locals {
  # ===== SQL SERVER AND DATABASES (Naming: {project}-{layer}-{env}-sql) =====
  sql_server_name = substr(lower("${var.project_name}-${var.layer_name}-${var.environment}-sql"), 0, 63)

  sql_database_bmbel = substr(lower("sql_${var.layer_name}_${var.project_name}_BMBEL"), 0, 63)

  # ===== SQL Databases =====
  sql_databases = {
    (local.sql_database_bmbel) = {
      collation            = "SQL_Latin1_General_CP1_CI_AS"
      sku_name             = "S1" # Las bases de datos tienen restricciones y solo se pueden usar tamaños basados en DTUs
      max_size_gb          = 250
      zone_redundant       = false
      license_type         = "LicenseIncluded"
      storage_account_type = "Local"

      transparent_data_encryption_enabled                        = true
      transparent_data_encryption_key_vault_key_id               = module.keyvault_keys.key_uris["sql_database_key"]
      transparent_data_encryption_key_automatic_rotation_enabled = true
    }
    # Agrega más bases de datos aquí si es necesario
    # (local.sql_database_bmbel) = {
    #   collation      = "SQL_Latin1_General_CP1_CI_AS"
    #   sku_name       = "S2"
    #   max_size_gb    = 500
    #   zone_redundant = true
    #   license_type   = "LicenseIncluded"
    #   transparent_data_encryption_enabled = true
    #   transparent_data_encryption_key_vault_key_id = module.keyvault_keys.key_uris["sql_database_key"]  
    # }
  }
}