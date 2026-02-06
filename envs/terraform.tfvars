################################################
# ===== General Variables =====
################################################
environment      = "DEV"
layer_name       = "FE"
project_name     = "NOVA"
location_primary = "eastus"


################################################
# ===== General Tags =====
################################################
tags = {
  role        = "FrontEnd"
  Application = "Nova Digital"
  CostCenter  = "NOVA-FE"
  IaC         = "Terraform Cloud"
  Layer       = "FrontEnd"
  ManagedBy   = "Terraform Cloud"
}

################################################
# ==== Private Endopint =====
################################################
enable_private_endpoints = true


################################################
# ==== Log Analytics Workspace =====
################################################
log_analytics_sku  = "PerGB2018"
log_retention_days = 30


################################################
# ==== Diagnostic Settings =====
################################################
enable_diagnostic_settings = true


################################################
#  Container Registry
################################################
acr_sku                  = "Premium"
georeplications_location = "eastus2"


################################################
# ===== AKS =====
################################################
kubernetes_version      = "1.34.0"
private_cluster_enabled = true
sku_tier                = "Free"
default_node_pool_config = {
  name            = "systempool"
  vm_size         = "Standard_D4s_v3"
  node_count      = 1
  os_disk_size_gb = 64
  os_disk_type    = "Managed"
  type            = "VirtualMachineScaleSets"
  min_count       = 1
  max_count       = 2
  node_labels = {
    "role" = "system"
  }
}
network_profile = {
  network_plugin      = "azure"
  network_plugin_mode = "overlay"
  network_policy      = "azure"
  load_balancer_sku   = "standard"
  outbound_type       = "loadBalancer"
}

auto_scaler_profile = {
  enabled = true
}

# ===== Cluster - Userpool =====
user_node_pool_name  = "userpl"
user_vm_size         = "Standard_D4s_v3"
user_os_disk_size_gb = 128
user_node_count      = 2
user_min_count       = 2
user_max_count       = 12
user_max_pods        = 110
auto_scaling_enabled = true
user_node_labels = {
  "role" = "user"
}
eviction_policy = "Delete"


################################################
# ===== SQL Database =====
################################################
sql_admin_username  = "carango_pragma@mercantilbanco.com.pa"
sql_admin_object_id = "f71ae8d3-c132-4521-bee9-4cf7f1825ae5"


################################################
# ===== Cosmos DB Acccount =====
################################################
cosmos_db_config = {
  offer_type           = "Standard"
  kind                 = "MongoDB"
  mongo_server_version = "7.0"

  consistency_policy = {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
}


geo_locations = [
  {
    location          = "eastus"
    failover_priority = 0
  },
  # {
  #   location          = "eastus2"
  #   failover_priority = 1
  # }
]


#############################################
# Service Bus Namespace
#############################################
sb_sku      = "Standard"
sb_capacity = 0


#############################################
# Topics & Subscriptions
#############################################
sb_topics = {
  partitioning_enabled                    = false
  max_size_in_megabytes                   = 1024
  requires_duplicate_detection            = false
  duplicate_detection_history_time_window = "PT10M"
  express_enabled                         = false
  #  max_message_size_in_kilobytes           = 1024
  default_message_ttl = "P7D"
  auto_delete_on_idle = "P14D"
  support_ordering    = false
}


sb_subscription = {
  max_delivery_count                        = 10
  lock_duration                             = "PT1M"
  requires_session                          = false
  dead_lettering_on_message_expiration      = false
  dead_lettering_on_filter_evaluation_error = false
  default_message_ttl                       = "P1D"
  auto_delete_on_idle                       = "P14D"
  batched_operations_enabled                = true
  client_scoped_subscription_enabled        = false
}

################################################
# ===== Redis Cache =====
################################################
redis_sku      = "Standard"
redis_family   = "C"
redis_capacity = 0
redis_version  = "6"


################################################
# ===== Key Vault =====
################################################
sku_name_kv = "standard"



################################################
# ===== Function App =====
################################################
# Private Endpoint Configuration
function_app_service_plan_kind     = "elastic"
function_app_service_plan_sku_tier = "ElasticPremium"
function_app_service_plan_sku_size = "EP1"

function_app_private_endpoint_subresource_names = ["sites"]

################################################
# ===== Storage Account =====
################################################
storage_account_tier                          = "Standard"
storage_account_replication_type              = "LRS"
storage_account_kind                          = "StorageV2"
storage_account_public_network_access_enabled = false
storage_account_shared_access_key_enabled     = true

storage_account_network_rules_default_action             = "Deny"
storage_account_network_rules_bypass                     = ["AzureServices", "Logging", "Metrics"]
storage_account_network_rules_ip_rules                   = []
storage_account_network_rules_virtual_network_subnet_ids = [] # Se configurará dinámicamente desde locals

# Private Endpoint Configuration
storage_account_create_private_endpoint            = true
storage_account_private_endpoint_subresource_names = ["blob"]



################################################
# ===== Private DNS Zones =====
################################################
private_dns_create_vnet_links = false


################################################
# ===== App Configuration =====
################################################
app_config_sku                     = "standard"
app_config_create_private_endpoint = true
app_config_endpoint_subresource    = ["configurationStores"]


################################################
# ===== Peerings =====
################################################
# peering_name = "MBPFGTVNET-NOVA_BE_VNET_PRD"
# peerings = {
#     "MBPFGTVNET-NOVA_BE_VNET_PRD" = {
#         key = "MBPFGTVNET-NOVA_BE_VNET_PRD"
#         allow_virtual_network_access  = true
#         allow_forwarded_traffic       = true
#         allow_gateway_transit         = false
#         use_remote_gateways           = false
#     }  
# }
# peerings = {
#    "MBPFGTVNET-NOVA_BE_VNET_PRD" = 
#     {
#         allow_virtual_network_access  = true
#         allow_forwarded_traffic       = true
#         allow_gateway_transit         = false
#         use_remote_gateways           = false
#     }
# }