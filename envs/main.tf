#############################################
# main.tf  (BACK)
#############################################

################################################
#  Resource Groups
################################################
module "resource_groups" {
  source          = "./modules/azure_resource_group"
  resource_groups = local.resource_groups
  tags            = local.tags
}

################################################
#  Virtual Network
################################################
module "vnet" {
  source                  = "./modules/azure_virtual_network/vnet"
  environment             = var.environment
  name                    = local.vnet_name
  location                = module.resource_groups.resource_groups[local.rg_network].location
  resource_group_name     = module.resource_groups.resource_groups[local.rg_network].name
  address_space           = local.vnet_address_space
  dns_servers             = local.dns_servers
  bgp_community           = null
  ddos_protection_plan_id = null

  # Diagnostics Settings
  project_name_diag               = var.project_name
  layer_name_diag                 = var.layer_name
  environment_diag                = var.environment
  log_analytics_workspace_id_diag = module.log_analytics_workspace.workspace_id
  enable_diagnostic_settings      = var.enable_diagnostic_settings

  tags = local.tags
}

################################################
#  Subnets
################################################
module "subnets" {
  source               = "./modules/azure_subnet"
  resource_group_name  = module.resource_groups.resource_groups[local.rg_network].name
  virtual_network_name = module.vnet.vnet_name
  subnets              = local.subnets

  depends_on = [module.vnet]
}

################################################
#  Container Registry
################################################
module "azure_container_registry" {
  source                        = "./modules/azure_container_registry"
  acr_name                      = local.acr_name
  location                      = module.resource_groups.resource_groups[local.rg_container].location
  resource_group_name           = module.resource_groups.resource_groups[local.rg_container].name
  sku                           = var.acr_sku
  admin_enabled                 = false
  retention_policy_in_days      = 7
  public_network_access_enabled = false
  anonymous_pull_enabled        = false
  network_rule_bypass_option    = "AzureServices"

  #Encryption with Customer Managed Key (CMK)
  identity_type         = "UserAssigned"
  data_endpoint_enabled = true
  identity_ids          = [module.user_identity.user_identity_ids[local.user_identity_acr]]

  client_ids       = module.user_identity.user_identity_client_ids[local.user_identity_acr]
  key_vault_key_id = module.keyvault_keys.versionless_id["azure_container_registry_key"]


  #Geolocalization ACR Secundary
  georeplications_location = var.georeplications_location

  # Private Endpoint
  create_private_endpoint            = var.enable_private_endpoints
  private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_endpoint]
  private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
  private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
  private_endpoint_subresource_names = ["registry"]
  private_endpoint_environment       = var.environment
  private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
  private_endpoint_resource_name     = "ACR"

  # Diagnostics Settings
  project_name_diag               = var.project_name
  layer_name_diag                 = var.layer_name
  environment_diag                = var.environment
  log_analytics_workspace_id_diag = module.log_analytics_workspace.workspace_id
  enable_diagnostic_settings      = var.enable_diagnostic_settings

  tags = local.tags

  depends_on = [module.subnets, module.keyvault, module.keyvault_keys]

}

################################################
#  Kubernetes Cluster
################################################
module "aks" {
  source                  = "./modules/azure_kubernetes_cluster/aks_cluster"
  resource_group_name     = module.resource_groups.resource_groups[local.rg_aks].name
  location                = module.resource_groups.resource_groups[local.rg_aks].location
  cluster_name            = local.aks_name
  dns_prefix              = local.dns_prefix
  kubernetes_version      = var.kubernetes_version
  sku_tier                = var.sku_tier
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = "System"

  default_node_pool = merge(
    local.aks_default_node_pool,
    {
      vnet_subnet_id = module.subnets.subnet_ids[local.subnet_aks]
    }
  )

  key_vault_secrets_provider = {
    rotation_enabled  = false
    rotation_interval = "2m"
  }

  network_profile     = local.aks_network_profile
  auto_scaler_profile = local.aks_auto_scaler_profile

  # Diagnostics Settings
  project_name_diag               = var.project_name
  layer_name_diag                 = var.layer_name
  environment_diag                = var.environment
  log_analytics_workspace_id_diag = module.log_analytics_workspace.workspace_id
  enable_diagnostic_settings      = var.enable_diagnostic_settings

  tags = local.tags

  depends_on = [module.resource_groups, module.subnets, module.keyvault]
}

################################################
#  User Node Pool (AKS)
################################################
module "userpool" {
  source               = "./modules/azure_kubernetes_cluster/cluster_nodes_pool"
  user_node_pool_name  = local.aks_user_node_pool.name
  aks_subnet_id        = module.subnets.subnet_ids[local.subnet_aks]
  aks_id               = module.aks.cluster_id
  user_vm_size         = local.aks_user_node_pool.vm_size
  user_max_pods        = local.aks_user_node_pool.max_pods
  user_node_labels     = local.aks_user_node_pool.node_labels
  user_node_count      = local.aks_user_node_pool.node_count
  user_os_disk_size_gb = local.aks_user_node_pool.os_disk_size_gb
  auto_scaling_enabled = local.aks_user_node_pool.auto_scaling_enabled
  user_max_count       = local.aks_user_node_pool.max_count
  user_min_count       = local.aks_user_node_pool.min_count
  eviction_policy      = local.aks_user_node_pool.eviction_policy

  depends_on = [module.aks]
}

################################################
#  Sql Server
################################################
module "sql_server" {
  source                      = "./modules/azure_mssql/sql_server"
  sql_server_name             = local.sql_server_name
  resource_group_name         = module.resource_groups.resource_groups[local.rg_databases].name
  location                    = module.resource_groups.resource_groups[local.rg_databases].location
  sql_server_version          = "12.0"
  minimum_tls_version         = "1.2"
  azuread_authentication_only = false
  login_username              = var.sql_admin_username
  object_id                   = var.sql_admin_object_id

  # Private Endpoint
  create_private_endpoint            = var.enable_private_endpoints
  private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_databases]
  private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
  private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
  private_endpoint_subresource_names = ["sqlServer"]
  private_endpoint_environment       = var.environment
  private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
  private_endpoint_resource_name     = "SQL"

  tags = local.tags

  # lifecycle = {
  #   prevent_destroy = true
  #   ignore_changes =  [tags]
  # }

  depends_on = [module.resource_groups, module.vnet, module.subnets, module.keyvault, module.keyvault_keys]
}

################################################
#  Sql Database
################################################
module "sql_database" {
  source = "./modules/azure_mssql/sql_database"

  sql_server_id = module.sql_server.server_id
  sql_databases = local.sql_databases
  tags          = local.tags

  identity_type = "UserAssigned"
  identity_ids  = [module.user_identity.user_identity_ids[local.user_identity_databases]]

  # Diagnostics Settings
  project_name_diag               = var.project_name
  layer_name_diag                 = var.layer_name
  environment_diag                = var.environment
  log_analytics_workspace_id_diag = module.log_analytics_workspace.workspace_id
  enable_diagnostic_settings      = var.enable_diagnostic_settings

  # lifecycle = {
  #   prevent_destroy = true
  #   ignore_changes =  [tags]
  # }

  depends_on = [module.sql_server, module.keyvault, module.keyvault_keys]
}

################################################
#  Cosmos DB
################################################
module "cosmosdb" {
  source                        = "./modules/azure_cosmosdb/azure_cosmosdb_account"
  name_cosmosdb                 = local.cosmosdb_account_name
  location                      = module.resource_groups.resource_groups[local.rg_databases].location
  resource_group_name           = module.resource_groups.resource_groups[local.rg_databases].name
  cosmos_db_config              = var.cosmos_db_config
  automatic_failover_enabled    = false
  geo_locations                 = var.geo_locations
  public_network_access_enabled = false

  #Data Encryption
  identity_type = "UserAssigned"
  identity_ids  = [module.user_identity.user_identity_ids[local.user_identity_cosmom]]

  # key_vault_key_id = module.keyvault_keys.versionless_id["cosmosdb_key"] - Aplicar Cifrado Manualmente Posteriormente

  # Private Endpoint
  create_private_endpoint            = var.enable_private_endpoints
  private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_databases]
  private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
  private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
  private_endpoint_subresource_names = ["MongoDB"]
  private_endpoint_environment       = var.environment
  private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
  private_endpoint_resource_name     = "COSMOSDB"

  # Diagnostics Settings
  project_name_diag               = var.project_name
  layer_name_diag                 = var.layer_name
  environment_diag                = var.environment
  log_analytics_workspace_id_diag = module.log_analytics_workspace.workspace_id
  enable_diagnostic_settings      = var.enable_diagnostic_settings

  tags = local.tags


  depends_on = [module.resource_groups, module.keyvault, module.keyvault_access_policy, module.keyvault_keys, module.user_identity]
}

################################################
#  Cosmos DB Mongo Database
################################################
module "cosmosdb_mongo_database" {
  source = "./modules/azure_cosmosdb/azure_cosmosdb_mongo_database"

  resource_group_name   = module.resource_groups.resource_groups[local.rg_databases].name
  cosmos_databases      = local.cosmos_databases
  cosmosdb_account_name = module.cosmosdb.cosmosdb_account_name

  depends_on = [module.cosmosdb, module.keyvault, module.keyvault_access_policy, module.keyvault_keys, module.user_identity]
}

################################################
#  Redis Cache
################################################
module "redis_cache" {
  source              = "./modules/azure_redis_cache"
  location            = module.resource_groups.resource_groups[local.rg_messaging].location
  resource_group_name = module.resource_groups.resource_groups[local.rg_messaging].name
  redis_name          = local.redis_name
  redis_capacity      = var.redis_capacity
  redis_sku           = var.redis_sku
  redis_version       = var.redis_version
  redis_family        = var.redis_family
  redis_tls_version   = "1.2"

  redis_patch_day_of_week    = "Sunday"
  redis_patch_start_hour_utc = 2

  # Private Endpoint
  create_private_endpoint            = var.enable_private_endpoints
  private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_redis]
  private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
  private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
  private_endpoint_subresource_names = ["redisCache"]
  private_endpoint_environment       = var.environment
  private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
  private_endpoint_resource_name     = "REDIS"

  # Diagnostics Settings
  project_name_diag               = var.project_name
  layer_name_diag                 = var.layer_name
  environment_diag                = var.environment
  log_analytics_workspace_id_diag = module.log_analytics_workspace.workspace_id
  enable_diagnostic_settings      = var.enable_diagnostic_settings

  tags = local.tags

  #   lifecycle = {
  #   prevent_destroy = true
  #   ignore_changes =  [tags]
  # }

  depends_on = [module.subnets, module.keyvault, module.keyvault_keys]
}

################################################
#  Key Vault
################################################
module "keyvault" {
  source              = "./modules/azure_keyvault/key_vault"
  key_vault_name      = local.keyvault_name
  location            = module.resource_groups.resource_groups[local.rg_security].location
  resource_group_name = module.resource_groups.resource_groups[local.rg_security].name
  sku_name            = var.sku_name_kv

  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  enabled_for_disk_encryption   = true
  public_network_access_enabled = true
  rbac_authorization_enabled    = false

  # Private Endpoint
  create_private_endpoint            = var.enable_private_endpoints
  private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_key_vault]
  private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
  private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
  private_endpoint_subresource_names = ["vault"]
  private_endpoint_environment       = var.environment
  private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
  private_endpoint_resource_name     = "KV"

  # Diagnostics Settings
  project_name_diag               = var.project_name
  layer_name_diag                 = var.layer_name
  environment_diag                = var.environment
  log_analytics_workspace_id_diag = module.log_analytics_workspace.workspace_id
  enable_diagnostic_settings      = var.enable_diagnostic_settings

  tags = local.tags

  # lifecycle = {
  #   prevent_destroy = true
  #   ignore_changes =  [access_policy, network_acls, public_network_access_enabled, tags]
  # }

  depends_on = [module.vnet, module.subnets]
}
################################################
#  Key Vault Access Policy
################################################
module "keyvault_access_policy" {
  source = "./modules/azure_keyvault/key_vault_access_policy"

  key_vault_id    = module.keyvault.key_vault_id
  access_policies = local.kv_access_policies

  depends_on = [module.keyvault]
}


################################################
#  Key Vaults Keys Cifrado
################################################
module "keyvault_keys" {
  source = "./modules/azure_keyvault/key_vault_keys"

  key_vault_id = module.keyvault.key_vault_id
  keys         = local.kv_keys_values

  depends_on = [module.keyvault, module.keyvault_access_policy]
}


################################################ 
#  User Identity
################################################
module "user_identity" {
  source              = "./modules/azure_user_assigned_identity"
  location            = module.resource_groups.resource_groups[local.rg_user_identity].location
  resource_group_name = module.resource_groups.resource_groups[local.rg_user_identity].name
  user_identities     = local.user_identities
  tags                = local.tags

  #   lifecycle = {
  #   prevent_destroy = true
  #   ignore_changes =  [tags]
  # }  
}


################################################
#  Service Bus Namespace
################################################
module "sb_namespace" {
  source              = "./modules/azure_service_bus/namespace"
  namespace_name      = local.servicebus_namespace
  location            = module.resource_groups.resource_groups[local.rg_messaging].location
  resource_group_name = module.resource_groups.resource_groups[local.rg_messaging].name
  sku                 = var.sb_sku
  capacity            = var.sb_capacity

  local_auth_enabled            = true
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"

  identity_type = "UserAssigned"
  identity_ids  = [module.user_identity.user_identity_ids[local.user_identity_servicebus]]

  #Condicional para configurar el CMK si el SKU es Premium
  customer_managed_key = var.sb_sku == "Premium" ? {
    create_cmk_for_sku        = true
    key_vault_key_id          = module.keyvault_keys.versionless_id["sb_namespace_key"]
    user_assigned_identity_id = module.user_identity.user_identity_ids[local.user_identity_servicebus]
    } : {
    create_cmk_for_sku = false
  }

  # Private Endpoint Temporarily disabled solo funciona con Premium SKU
  sb_conditional_private_endpoint = var.sb_sku == "Premium" ? {
    create_private_endpoint            = true
    private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_endpoint]
    private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
    private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
    private_endpoint_subresource_names = ["namespace"]
    private_endpoint_environment       = var.environment
    private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
    private_endpoint_resource_name     = "SB"
    } : {
    create_private_endpoint            = false
    private_endpoint_subnet_id         = null
    private_endpoint_resource_group    = null
    private_endpoint_location          = null
    private_endpoint_subresource_names = []
    private_endpoint_environment       = null
    private_endpoint_project_name      = null
    private_endpoint_resource_name     = null
  }

  # Diagnostics Settings
  project_name_diag               = var.project_name
  layer_name_diag                 = var.layer_name
  environment_diag                = var.environment
  log_analytics_workspace_id_diag = module.log_analytics_workspace.workspace_id
  enable_diagnostic_settings      = var.enable_diagnostic_settings

  tags = local.tags

  #   lifecycle = {
  #   prevent_destroy = true
  #   ignore_changes =  [tags]
  # }  

  depends_on = [module.subnets, module.user_identity, module.keyvault, module.keyvault_keys]
}

###############################################
#  Service Bus Topics
###############################################
module "sb_topics" {
  source                  = "./modules/azure_service_bus/topic"
  servicebus_namespace_id = module.sb_namespace.service_bus_namespace_id
  topic_name              = local.servicebus_topic
  topic_config            = var.sb_topics

  depends_on = [module.sb_namespace]
}

################################################
#  Service Bus Subscriptions
################################################
module "sb_subscriptions" {
  source              = "./modules/azure_service_bus/subscription"
  subscription_name   = local.servicesbus_subscription
  topic_id            = module.sb_topics.topic_id
  subscription_config = var.sb_subscription

  depends_on = [module.sb_topics]
}

################################################
#  Log Analytics Workspace
################################################
module "log_analytics_workspace" {
  source              = "./modules/azure_log_analytics"
  workspace_name      = local.log_analytics_workspace_name
  location            = module.resource_groups.resource_groups[local.rg_monitoring].location
  resource_group_name = module.resource_groups.resource_groups[local.rg_monitoring].name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  tags                = local.tags
}


################################################
#  Storage Account
################################################
module "storage_account" {
  source               = "./modules/azure_storage_account"
  name_storage_account = local.storage_account_name
  resource_group_name  = module.resource_groups.resource_groups[local.rg_storage].name
  location             = module.resource_groups.resource_groups[local.rg_storage].location
  environment          = var.environment

  storage_account_config = merge(
    local.storage_account_config,
    {
      network_rules = merge(
        local.storage_account_config.network_rules,
        {
          virtual_network_subnet_ids = length(var.storage_account_network_rules_virtual_network_subnet_ids) > 0 ? var.storage_account_network_rules_virtual_network_subnet_ids : [module.subnets.subnet_ids[local.subnet_function]]
        }
      )
    }
  )

  # Private Endpoint Configuration
  create_private_endpoint            = var.storage_account_create_private_endpoint
  private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_endpoint]
  private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
  private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
  private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
  private_endpoint_environment       = var.environment
  private_endpoint_resource_name     = "ST"
  private_endpoint_subresource_names = var.storage_account_private_endpoint_subresource_names

  tags = local.tags

  #   lifecycle = {
  #   prevent_destroy = true
  #   ignore_changes =  [tags]
  # }   

  depends_on = [module.resource_groups, module.subnets, module.user_identity, module.keyvault, module.keyvault_keys]
}

# ################################################
# #  Static Web Apps
# ################################################
module "static_web_apps" {
  source         = "./modules/azure_static_web_apps"
  static_web_app = local.static_web_app

  location            = "eastus2"
  resource_group_name = module.resource_groups.resource_groups[local.rg_webs].name

  tags = local.tags

  # lifecycle = {
  #   prevent_destroy = true
  #   ignore_changes = [repository_url, branch, tags]
  # }

  depends_on = [module.resource_groups]
}

################################################
#  App Service Plan for Function App
################################################
resource "azurerm_service_plan" "function_plan" {
  name                = local.app_service_plan_name
  resource_group_name = module.resource_groups.resource_groups[local.rg_apps].name
  location            = module.resource_groups.resource_groups[local.rg_apps].location

  maximum_elastic_worker_count = local.app_service_plan_config.maximum_elastic_worker_count

  os_type                         = local.app_service_plan_config.os_type
  per_site_scaling_enabled        = local.app_service_plan_config.per_site_scaling
  premium_plan_auto_scale_enabled = false
  sku_name                        = local.app_service_plan_config.sku_name

  tags = local.tags

  #   lifecycle = {
  #   prevent_destroy = true
  #   ignore_changes =  [network_rules, customer_managed_key, tags]
  # }  

  depends_on = [module.resource_groups]
}

################################################
#  Function App
################################################
module "function_app" {
  source              = "./modules/azure_function_app"
  resource_group_name = module.resource_groups.resource_groups[local.rg_apps].name
  location            = module.resource_groups.resource_groups[local.rg_apps].location
  function_apps       = local.function_apps
  service_plan_id     = azurerm_service_plan.function_plan.id
  storage_account_id  = module.storage_account.storage_id

  tags = local.tags

  depends_on = [
    module.resource_groups,
    module.subnets,
    module.storage_account,
    azurerm_service_plan.function_plan,
    module.user_identity
  ]
}


################################################
#  app configuration
################################################
module "app_configuration" {
  source              = "./modules/azure_app_configuration"
  name                = local.app_config_name
  resource_group_name = module.resource_groups.resource_groups[local.rg_webs].name
  location            = module.resource_groups.resource_groups[local.rg_webs].location

  public_network_access      = "Disabled"
  purgue_protection_enabled  = true
  soft_delete_retention_days = 7

  sku = var.app_config_sku

  identity_type = "UserAssigned"
  identity_ids  = [module.user_identity.user_identity_ids[local.user_identity_appconfig]]

  encryption = {
    key_vault_key_id          = module.keyvault_keys.versionless_id["app_config_key"]
    user_assigned_identity_id = module.user_identity.user_identity_client_ids[local.user_identity_appconfig]
  }

  ## private endpoint configuration
  create_private_endpoint            = var.app_config_create_private_endpoint
  private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_endpoint]
  private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
  private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
  private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
  private_endpoint_environment       = var.environment
  private_endpoint_resource_name     = "APPCONF"
  private_endpoint_subresource_names = var.app_config_endpoint_subresource


  tags = local.tags

}

# ###############################################
# # Routes in Networking
# ###############################################
# module "route_table_fortigate" {
#   source              = "./modules/azure_route"
#   route_table_name    = local.route_table_fortigate
#   location            = module.resource_groups.resource_groups[local.rg_network].location
#   resource_group_name = module.resource_groups.resource_groups[local.rg_network].name
#   routes              = local.all_routes
#   subnet_ids = {
#     for subnet_name, subnet_config in local.subnet_routes_map :
#     subnet_name => module.subnets.subnet_ids[subnet_name]
#   }

#   tags = local.tags

#   #   lifecycle = {
#   #   prevent_destroy = true
#   #   ignore_changes =  [tags]
#   # }    

#   depends_on = [module.subnets]
# }

################################################
#  Private DNS Zones
################################################
module "private_dns_zones" {
  source   = "./modules/azure_private_dns/private_dns_zone"
  for_each = var.private_dns_create_vnet_links ? local.private_dns_zones : {}

  zone_name           = each.value.zone_name
  resource_group_name = module.resource_groups.resource_groups[local.rg_network].name

  virtual_network_links = var.private_dns_create_vnet_links ? {
    "${each.key}-link" = {
      name                 = local.private_dns_vnet_links[each.key].name
      virtual_network_id   = module.vnet.vnet_id
      registration_enabled = local.private_dns_vnet_links[each.key].registration_enabled
    }
  } : {}

  tags = local.tags

  depends_on = [module.resource_groups, module.vnet]

}