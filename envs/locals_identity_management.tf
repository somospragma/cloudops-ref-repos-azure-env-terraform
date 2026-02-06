locals {

  # ===== User Identity Management (Naming: {PROJECT}_{LAYER}_{PURPOSE}_SUBNET) =====
  user_identity_aks        = "${local.prefix}_AKS_IDENT_${var.environment}"
  user_identity_acr        = "${local.prefix}_ACR_IDENT_${var.environment}"
  user_identity_web        = "${local.prefix}_WEB_IDENT_${var.environment}"
  user_identity_databases  = "${local.prefix}_DB_IDENT_${var.environment}"
  user_identity_cosmom     = "${local.prefix}_COSMON_IDENT_${var.environment}"
  user_identity_function   = "${local.prefix}_FUNCTION_IDENT_${var.environment}"
  user_identity_storage    = "${local.prefix}_ST_IDENT_${var.environment}"
  user_identity_servicebus = "${local.prefix}_SB_IDENT_${var.environment}"
  user_identity_appconfig  = "${local.prefix}_APPCFG_IDENT_${var.environment}"

  user_identities = {
    (local.user_identity_aks)        = {}
    (local.user_identity_acr)        = {}
    (local.user_identity_web)        = {}
    (local.user_identity_databases)  = {}
    (local.user_identity_cosmom)     = {}
    (local.user_identity_function)   = {}
    (local.user_identity_storage)    = {}
    (local.user_identity_servicebus) = {}
    (local.user_identity_appconfig)  = {}
  }

}