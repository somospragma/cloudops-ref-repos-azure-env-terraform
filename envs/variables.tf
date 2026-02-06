################################################
### General Variables
################################################
variable "layer_name" {
  type        = string
  description = "Nombre de la capa (BE, FE, etc.)"
}

variable "project_name" {
  type        = string
  description = "Nombre del proyecto abreviado"
}

variable "location_primary" {
  type        = string
  description = "Ubicación de los recursos"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, qa, prod, etc.)"

  validation {
    condition     = contains(["dev", "DEV", "qa", "QA", "prod", "PROD"], var.environment)
    error_message = "environment debe ser uno de: dev, qa, prod."
  }
}

variable "tags" {
  type        = map(string)
  description = "Etiquetas comunes"
}


################################################
### Container Registry
################################################
variable "acr_sku" {
  description = "SKU del Azure Container Registry"
  type        = string

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku debe ser uno de: Basic, Standard, Premium."
  }
}

variable "georeplications_location" {
  description = "Geolocalización Secundaria"
  type        = string
}


################################################
#### AKS
################################################
################################################
#### AKS
################################################
variable "sku_tier" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "private_cluster_enabled" {
  description = "Configuracion de cluster privado"
  type        = bool
}

variable "default_node_pool_config" {
  description = "Configuración del node pool por defecto"
  type = object({
    name              = string
    vm_size           = string
    node_count        = number
    os_disk_size_gb   = number
    os_disk_type      = optional(string, "Managed")
    type              = string
    min_count         = optional(number)
    max_count         = optional(number)
    zones             = optional(list(string))
    node_labels       = optional(map(string), {})
    node_taints       = optional(list(string))
    upgrade_max_surge = optional(string)
  })
  default = {
    name            = "default"
    vm_size         = "Standard_DS2_v2"
    node_count      = 1
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
  }
}

variable "network_profile" {
  description = "Configuración de red para el clúster"
  type = object({
    network_plugin      = string
    network_policy      = optional(string)
    load_balancer_sku   = string
    outbound_type       = string
    network_plugin_mode = optional(string)
  })
}

variable "auto_scaler_profile" {
  description = "Configuración del perfil de escalado automático del cluster AKS"
  type = object({
    enabled                          = bool
    balance_similar_node_groups      = optional(bool)
    expander                         = optional(string)
    max_graceful_termination_sec     = optional(number)
    max_node_provisioning_time       = optional(string)
    max_unready_nodes                = optional(number)
    max_unready_percentage           = optional(number)
    new_pod_scale_up_delay           = optional(string)
    scale_down_delay_after_add       = optional(string)
    scale_down_delay_after_delete    = optional(string)
    scale_down_delay_after_failure   = optional(string)
    scan_interval                    = optional(string)
    scale_down_unneeded              = optional(string)
    scale_down_unready               = optional(string)
    scale_down_utilization_threshold = optional(number)
    empty_bulk_delete_max            = optional(number)
    skip_nodes_with_local_storage    = optional(bool)
    skip_nodes_with_system_pods      = optional(bool)
  })
}

################################################
### Pool de usuario
#################################################
variable "user_node_pool_name" {
  description = "Nombre del pool de nodos de usuario, no mas de 6 caracteres"
  type        = string
}

variable "user_vm_size" {
  description = "Tamaño de VM para los nodos de usuario"
  type        = string
}

variable "auto_scaling_enabled" {
  description = "Etiquetas para habilitar auto scaling"
  type        = bool
}

variable "eviction_policy" {
  description = "Politica para maquinas virtuales, puede ser: Deallocate, Delete"
  type        = string
}

variable "user_max_pods" {
  description = "Número máximo de pods por nodo en el pool de usuario"
  type        = number
}

variable "user_min_count" {
  description = "Número mínimo de nodos en el pool de usuario"
  type        = number
}
variable "user_max_count" {
  description = "Número máximo de nodos en el pool de usuario"
  type        = number
}
variable "user_node_labels" {
  description = "Etiquetas para los nodos del pool de usuario"
  type        = map(string)
}

variable "user_os_disk_size_gb" {
  description = "Tamaño del disco OS para los nodos de usuario en GB"
  type        = number
}

variable "user_node_count" {
  description = "Número de nodos en el pool de usuario"
  type        = number
}


################################################
#### Storage account
################################################
# variable "storage_account_config" {
#   description = "Configuración del Storage Account"
#   type = object({
#     account_tier                  = string
#     account_replication_type      = string
#     account_kind                  = string
#     public_network_access_enabled = bool
#     allow_nested_items_to_be_public = bool
#     customer_managed_key = object({
#       key_vault_name              = string
#       key_name                    = string
#       user_assigned_identity_name = string
#     })
#     network_rules = object({
#       default_action             = string
#       bypass                     = list(string)
#       ip_rules                   = list(string)
#       virtual_network_subnet_ids = list(string)
#     })
#   })
# }


################################################
##===== Variables para Cosmos DB Account =====
################################################
variable "cosmos_db_config" {
  description = "Configuración de la cuenta de Cosmos DB"
  type = object({
    offer_type           = string
    kind                 = string
    mongo_server_version = string
    consistency_policy = object({
      consistency_level       = string
      max_interval_in_seconds = number
      max_staleness_prefix    = number
    })
  })
}

variable "geo_locations" {
  description = "Lista de ubicaciones geográficas con su prioridad de conmutación por error para CosmosDB"
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool)
  }))
}


######################################
# Service Bus – Namespace
######################################
variable "sb_sku" {
  type        = string
  description = "SKU del Service Bus Namespace"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sb_sku)
    error_message = "sb_sku debe ser uno de: Basic, Standard, Premium."
  }
}

variable "sb_capacity" {
  type        = number
  description = "Capacidad del Service Bus (unidades de mensaje)"

  validation {
    condition     = contains([0, 1, 2, 4], var.sb_capacity)
    error_message = "sb_capacity debe ser uno de: 0, 1, 2, 4."
  }
}

######################################
# Topics y suscripciones
######################################
variable "sb_topics" {
  description = "Mapa de tópicos: cada tópico tiene sus propiedades y a su vez un bloque 'subscriptions' anidado."
  type = object({
    partitioning_enabled                    = bool
    max_size_in_megabytes                   = number
    requires_duplicate_detection            = bool
    duplicate_detection_history_time_window = string
    express_enabled                         = bool
    max_message_size_in_kilobytes           = optional(number)
    default_message_ttl                     = string
    auto_delete_on_idle                     = string
    support_ordering                        = bool
  })
}


variable "sb_subscription" {
  description = "Mapa para suscripciones independientes al namespace"
  type = object({
    max_delivery_count                        = number
    lock_duration                             = string
    requires_session                          = bool
    dead_lettering_on_message_expiration      = bool
    dead_lettering_on_filter_evaluation_error = bool
    default_message_ttl                       = string
    auto_delete_on_idle                       = string
    batched_operations_enabled                = bool
    client_scoped_subscription_enabled        = bool
  })
}



##################################################
# ========== Variables for Redis cache ==========
##################################################
variable "redis_capacity" {
  description = "Capacidad de la instancia de Redis Cache"
  type        = number

  validation {
    condition     = contains([0, 1, 2, 3, 4, 5, 6], var.redis_capacity)
    error_message = "redis_capacity debe ser uno de: 0, 1, 2, 3, 4, 5, 6."
  }
}

variable "redis_family" {
  description = "Familia de la instancia de Redis Cache (C para Standard/Premium)"
  type        = string

  validation {
    condition     = contains(["C", "P"], var.redis_family)
    error_message = "redis_family debe ser uno de: C (Standard), P (Premium)."
  }
}

variable "redis_sku" {
  description = "SKU de la instancia de Redis Cache (Basic, Standard, Premium)"
  type        = string

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.redis_sku)
    error_message = "redis_sku debe ser uno de: Basic, Standard, Premium."
  }
}

variable "redis_version" {
  description = "Versión instancia de Redis Cache"
  type        = string

  validation {
    condition     = can(regex("^(4|6|7)(\\.[0-9])?$", var.redis_version))
    error_message = "redis_version debe ser una versión válida: 4, 6, o 7 (ej: 6, 7.0)."
  }
}



##################################################
# ========== Variables for Key Vault ==========
##################################################
variable "sku_name_kv" {
  type        = string
  description = "SKU del Key Vault"

  validation {
    condition     = contains(["standard", "premium"], lower(var.sku_name_kv))
    error_message = "sku_name debe ser uno de: standard, premium."
  }
}



################################################
##======== Variables for Function App =======
################################################
variable "function_app_service_plan_kind" {
  description = "Tipo de App Service Plan (Linux, Windows, elastic)"
  type        = string
}

variable "function_app_service_plan_sku_tier" {
  description = "Tier del SKU del App Service Plan (ElasticPremium, PremiumV2, etc.)"
  type        = string
}

variable "function_app_service_plan_sku_size" {
  description = "Tamaño del SKU del App Service Plan (EP1, EP2, etc.)"
  type        = string
}


# ========== Variables for Function App Private Endpoint ==========
variable "function_app_private_endpoint_subresource_names" {
  description = "Lista de subrecursos para el Private Endpoint de la Function App (sites, scm)"
  type        = list(string)
}



################################################
##======= Variables for Private DNS ========
################################################
variable "private_dns_create_vnet_links" {
  description = "Crear Virtual Network Links para las Private DNS Zones"
  type        = bool
}



################################################
##======= Variables for Private Endpoints =======
################################################
variable "enable_private_endpoints" {
  description = "Habilitar Private Endpoints para todos los recursos"
  type        = bool
}



################################################
##===== Variables Diagnostic Settings =======
################################################
variable "enable_diagnostic_settings" {
  description = "Habilitar Diagnostic Settings para enviar logs y métricas a Log Analytics"
  type        = bool
}

variable "log_analytics_sku" {
  description = "SKU del Log Analytics Workspace"
  type        = string
}

variable "log_retention_days" {
  description = "Días de retención de logs en el ambiente"
  type        = number
}



################################################
### SQL Server
################################################
variable "sql_admin_username" {
  description = "Correo del administrador SQL en EntraID"
  type        = string
}

variable "sql_admin_object_id" {
  description = "Object ID del administrador SQL en EntraID"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", lower(var.sql_admin_object_id)))
    error_message = "sql_admin_object_id debe ser un UUID válido en formato estándar (ej: 550e8400-e29b-41d4-a716-446655440000)."
  }
}



################################################
# ===== Variables for Storage Account =====
################################################
variable "storage_account_tier" {
  description = "Tier del Storage Account (Standard o Premium)"
  type        = string
}

variable "storage_account_replication_type" {
  description = "Tipo de replicación del Storage Account (LRS, GRS, ZRS, etc.)"
  type        = string
}

variable "storage_account_kind" {
  description = "Tipo de Storage Account (Storage, StorageV2, BlobStorage)"
  type        = string
}

variable "storage_account_public_network_access_enabled" {
  description = "Habilitar acceso público al Storage Account"
  type        = bool
}

variable "storage_account_shared_access_key_enabled" {
  description = "Habilitar shared access keys"
  type        = bool
}

variable "storage_account_network_rules_default_action" {
  description = "Acción por defecto para network rules (Deny o Allow)"
  type        = string
}

variable "storage_account_network_rules_bypass" {
  description = "Servicios que pueden hacer bypass de las network rules"
  type        = list(string)
}

variable "storage_account_network_rules_ip_rules" {
  description = "Lista de IPs permitidas en network rules"
  type        = list(string)
}

variable "storage_account_network_rules_virtual_network_subnet_ids" {
  description = "Lista de subnet IDs permitidas en network rules"
  type        = list(string)
}


# ===== Private Endpoint Variables for Storage Account =====
variable "storage_account_create_private_endpoint" {
  description = "Crear Private Endpoint para Storage Account"
  type        = bool
}

variable "storage_account_private_endpoint_subresource_names" {
  description = "Subrecursos para el Private Endpoint (blob, file, queue, table)"
  type        = list(string)
}


################################################
### App Configuration
################################################
variable "app_config_sku" {
  description = "SKU del App Configuration"
  type        = string

  validation {
    condition     = contains(["free", "standard"], lower(var.app_config_sku))
    error_message = "app_config_sku debe ser uno de: free, standard."
  }
}

variable "app_config_create_private_endpoint" {
  description = "Crear Private Endpoint para App Configuration"
  type        = bool
}

variable "app_config_endpoint_subresource" {
  description = "Subrecursos para el Private Endpoint de App Configuration"
  type        = list(string)
}