locals {
  # ===== Key Vault Access Policies =====
  kv_access_policies = {
    "current_client" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = data.azurerm_client_config.current.object_id
      key_permissions         = ["Get", "List", "WrapKey", "UnwrapKey", "Encrypt", "Decrypt", "GetRotationPolicy", "SetRotationPolicy", "Rotate", "Create", "Update", "Delete", "Import", "Backup", "Restore", "Recover"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
    }

    "module_web" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = module.user_identity.user_identity_principal_ids[local.user_identity_web]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
    }

    "module_function_app" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = module.user_identity.user_identity_principal_ids[local.user_identity_function]
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
    }

    "module_storage" = {
      tenant_id          = data.azurerm_client_config.current.tenant_id
      object_id          = module.user_identity.user_identity_principal_ids[local.user_identity_storage]
      key_permissions    = ["Get", "List", "WrapKey", "UnwrapKey", "Encrypt", "Decrypt"]
      secret_permissions = ["Get", "List"]
    }

    "module_aks" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_id               = module.user_identity.user_identity_principal_ids[local.user_identity_aks]
      key_permissions         = ["Get", "List", "WrapKey", "UnwrapKey", "Encrypt", "Decrypt"]
      secret_permissions      = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
    }

    "module_databases" = {
      tenant_id          = data.azurerm_client_config.current.tenant_id
      object_id          = module.user_identity.user_identity_principal_ids[local.user_identity_databases]
      key_permissions    = ["Get", "List", "WrapKey", "UnwrapKey", "Encrypt", "Decrypt"]
      secret_permissions = ["Get", "List"]
    }

    "module_cosmosdb" = {
      tenant_id          = data.azurerm_client_config.current.tenant_id
      object_id          = module.user_identity.user_identity_principal_ids[local.user_identity_cosmom]
      key_permissions    = ["Get", "List", "WrapKey", "UnwrapKey", "Encrypt", "Decrypt"]
      secret_permissions = ["Get", "List"]
    }

    "module_acr" = {
      tenant_id          = data.azurerm_client_config.current.tenant_id
      object_id          = module.user_identity.user_identity_principal_ids[local.user_identity_acr]
      key_permissions    = ["Get", "List", "WrapKey", "UnwrapKey", "Encrypt", "Decrypt"]
      secret_permissions = ["Get", "List"]
    }

    "module_appconfig" = {
      tenant_id          = data.azurerm_client_config.current.tenant_id
      object_id          = module.user_identity.user_identity_principal_ids[local.user_identity_appconfig]
      key_permissions    = ["Get", "List", "WrapKey", "UnwrapKey", "Encrypt", "Decrypt"]
      secret_permissions = ["Get", "List"]
    }
  }


  # ===== Key Vault Keys Configuration =====

  kv_keys_values = {
    "storage_account_key" = {
      key_name             = upper("${local.storage_account_name}-cmk-key")
      key_type             = "RSA"
      key_size             = 2048
      key_ops              = ["decrypt", "encrypt", "wrapKey", "unwrapKey"]
      rotation_period      = "P90D" # 3 meses
      notify_before_expiry = "P7D"  # avisar 5 días antes
    }

    # Ejemplos para otros servicios:
    "cosmosdb_key" = {
      key_name             = upper("${local.cosmosdb_account_name}-CMK-KEY")
      key_type             = "RSA"
      key_size             = 2048
      key_ops              = ["decrypt", "encrypt", "wrapKey", "unwrapKey"]
      rotation_period      = "P90D"
      notify_before_expiry = "P7D"
    }

    "sb_namespace_key" = {
      key_name             = upper("${local.servicebus_namespace}-CMK-KEY")
      key_type             = "RSA"
      key_size             = 2048
      key_ops              = ["decrypt", "encrypt", "wrapKey", "unwrapKey"]
      rotation_period      = "P90D"
      notify_before_expiry = "P7D"
    }

    "sql_database_key" = {
      key_name             = upper("${local.sql_server_name}-CMK-KEY")
      key_type             = "RSA"
      key_size             = 2048
      key_ops              = ["decrypt", "encrypt", "wrapKey", "unwrapKey"]
      rotation_period      = "P90D"
      notify_before_expiry = "P7D"
    }

    "azure_container_registry_key" = {
      key_name             = upper("${local.acr_name}-CMK-KEY")
      key_type             = "RSA"
      key_size             = 2048
      key_ops              = ["decrypt", "encrypt", "wrapKey", "unwrapKey"]
      rotation_period      = "P90D"
      notify_before_expiry = "P7D"
    }

    "app_config_key" = {
      key_name             = upper("${local.app_config_name}-CMK-KEY")
      key_type             = "RSA"
      key_size             = 2048
      key_ops              = ["decrypt", "encrypt", "wrapKey", "unwrapKey"]
      rotation_period      = "P90D"
      notify_before_expiry = "P7D"
    }

  }
}