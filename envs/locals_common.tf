# locals.tf (raíz)
locals {
  # ===== PREFIJOS ESTÁNDAR =====
  prefix = "${var.project_name}_${var.layer_name}"

  # ===== TAGS COMUNES =====
  tags = {
    Project     = var.project_name
    Layer       = var.layer_name
    Environment = var.environment
    role        = var.tags["role"]
    Application = var.tags["Application"]
    CostCenter  = var.tags["CostCenter"]
    IaC         = var.tags["IaC"]
    Location    = var.location_primary
    ManagedBy   = var.tags["ManagedBy"]
    CreatedDate = "2026-01-22" #formatdate("YYYY-MM-DD", timestamp())
  }

  # ===== NOMBRES DE RECUROSS ESTÁNDAR =====
  # ===== ACR (Naming: {project}{layer}{env}acr - sin guiones, lowercase) =====
  acr_name = "${var.project_name}${var.layer_name}${var.environment}ACR"

  # ===== STORAGE (Naming: {project}{layer}{env}st - sin guiones, lowercase, max 24 chars) =====
  storage_name = substr("${var.project_name}${var.layer_name}${var.environment}ST", 0, 24)

  # ===== KEY VAULT (Naming: {project}-{layer}-{env}-kv - max 24 chars) =====
  keyvault_name = substr("${var.project_name}-${var.layer_name}-${var.environment}-KV", 0, 24)

  # ===== REDIS (Naming: {project}-{layer}-{env}-redis) =====
  redis_name = "${var.project_name}-${var.layer_name}-${var.environment}-REDIS"

  # ===== SERVICE BUS (Naming: {project}-{layer}-{env}-sb) =====
  servicebus_namespace     = "${var.project_name}-${var.layer_name}-${var.environment}-SBUS"
  servicebus_topic         = lower("${var.project_name}-tp-transversal-event")
  servicesbus_subscription = lower("${var.project_name}-subs-transversal-event")

  # ===== LOG ANALYTICS WORKSPACE (Naming: {project}-{layer}-{env}-law) =====
  log_analytics_workspace_name = "${var.project_name}-${var.layer_name}-${var.environment}-LAW"

  # ===== APP CONFIGURATION (Naming: {project}-{layer}-{env}-kv - max 24 chars) =====
  app_config_name = "${var.project_name}-${var.layer_name}-${var.environment}-APP-CFG-ENV"

}