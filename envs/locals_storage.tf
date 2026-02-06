locals {
  # ===== STORAGE ACCOUNT (Naming: {project}{layer}{env}st - sin guiones, lowercase, max 24 chars) =====
  storage_account_name = substr(lower("${var.project_name}${var.layer_name}${var.environment}ST"), 0, 24)

  # ===== STORAGE ACCOUNT CONFIGURATION =====
  storage_account_config = {
    account_tier                  = var.storage_account_tier
    account_replication_type      = var.storage_account_replication_type
    account_kind                  = var.storage_account_kind
    public_network_access_enabled = var.storage_account_public_network_access_enabled
    shared_access_key_enabled     = var.storage_account_shared_access_key_enabled

    customer_managed_key = {
      user_assigned_identity_id = module.user_identity.user_identity_ids[local.user_identity_storage]
      key_vault_key_id          = module.keyvault_keys.versionless_id["storage_account_key"]
    }

    network_rules = {
      default_action             = var.storage_account_network_rules_default_action
      bypass                     = var.storage_account_network_rules_bypass
      ip_rules                   = var.storage_account_network_rules_ip_rules
      virtual_network_subnet_ids = var.storage_account_network_rules_virtual_network_subnet_ids
    }

    owner         = local.tags["Layer"]      # Centralizado en locals_common.tf desde tags
    cost_center   = local.tags["CostCenter"] # Centralizado en locals_common.tf desde tags
    department    = local.tags["Project"]    # Centralizado en locals_common.tf desde tags
    creation_date = formatdate("YYYY-MM-DD", timestamp())
    created_by    = "Terraform"
  }
}