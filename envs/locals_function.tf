locals {

  # ===== APP SERVICE PLAN (Naming: {PROJECT}_{LAYER}_{ENV}_ASP) =====
  app_service_plan_name = "${local.prefix}_${var.environment}_ASP"

  # ===== APP SERVICE PLAN CONFIGURATION =====
  app_service_plan_config = {
    os_type                      = "Linux"
    sku_name                     = "FC1"
    per_site_scaling             = false
    maximum_elastic_worker_count = 1
  }

  # ===== FUNCTION WORKLOADS CONFIGURATION =====
  function_apps = {
    "FUNC_REDIS_CACHE" = {
      function_app_name                 = lower("${var.project_name}-${var.layer_name}-${var.environment}-AZF-RED-CCH")
      storage_container_type            = "blobContainer"
      storage_container_endpoint        = "${module.storage_account.storage_primary_blob_endpoint}"
      storage_authentication_type       = "UserAssignedIdentity"
      storage_user_assigned_identity_id = module.user_identity.user_identity_ids[local.user_identity_function]

      runtime_name           = "java"
      runtime_version        = 17
      maximum_instance_count = 50
      instance_memory_in_mb  = 2048
      https_only             = true

      public_network_access_enabled = false

      identity_type = "UserAssigned"
      identity_ids  = [module.user_identity.user_identity_ids[local.user_identity_function]]

      ## private endpoint configuration
      create_private_endpoint            = true
      private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_function]
      private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
      private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
      private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
      private_endpoint_environment       = var.environment
      private_endpoint_resource_name     = "RED-CCH"
      private_endpoint_subresource_names = var.function_app_private_endpoint_subresource_names
    }

  }
}