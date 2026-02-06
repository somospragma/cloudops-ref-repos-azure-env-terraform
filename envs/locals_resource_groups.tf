locals {

  # El ${local.prefix} se define en locals_common.tf
  # ===== RESOURCE GROUPS (Naming: {PROJECT}_{LAYER}_{PURPOSE}_{ENV}) =====
  rg_aks           = "${local.prefix}_RG_AKS_${var.environment}"
  rg_webs          = "${local.prefix}_RG_WEB_${var.environment}"
  rg_apps          = "${local.prefix}_RG_APPS_${var.environment}"
  rg_container     = "${local.prefix}_RG_CONTAINER_${var.environment}"
  rg_databases     = "${local.prefix}_RG_DATABASES_${var.environment}"
  rg_messaging     = "${local.prefix}_RG_MESSAGING_${var.environment}"
  rg_monitoring    = "${local.prefix}_RG_MONITORING_${var.environment}"
  rg_network       = "${local.prefix}_RG_NETWORK_${var.environment}"
  rg_security      = "${local.prefix}_RG_SECURITY_${var.environment}"
  rg_storage       = "${local.prefix}_RG_STORAGE_${var.environment}"
  rg_user_identity = "${local.prefix}_RG_USER_IDENTITY_${var.environment}"

  resource_groups = {
    (local.rg_aks)           = { location = var.location_primary }
    (local.rg_webs)          = { location = var.location_primary }
    (local.rg_apps)          = { location = var.location_primary }
    (local.rg_container)     = { location = var.location_primary }
    (local.rg_databases)     = { location = var.location_primary }
    (local.rg_messaging)     = { location = var.location_primary }
    (local.rg_monitoring)    = { location = var.location_primary }
    (local.rg_network)       = { location = var.location_primary }
    (local.rg_security)      = { location = var.location_primary }
    (local.rg_storage)       = { location = var.location_primary }
    (local.rg_user_identity) = { location = var.location_primary }
  }

}