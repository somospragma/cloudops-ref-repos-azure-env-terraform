locals {
  # ===== AKS (Naming: {project}-{layer}-{env}-AKS) =====
  aks_name = "${var.project_name}-${var.layer_name}-${var.environment}-AKS"

  # ===== DNS Prefix (Naming: {project}{layer}{env}aks - lowercase, sin guiones) =====
  dns_prefix = lower("${var.project_name}${var.layer_name}${var.environment}aks")



  # ===== DEFAULT NODE POOL CONFIGURATION =====
  # Nota: vnet_subnet_id se asignará en main.tf usando module.subnets
  aks_default_node_pool = {
    name                 = var.default_node_pool_config.name
    vm_size              = var.default_node_pool_config.vm_size
    node_count           = var.default_node_pool_config.node_count
    os_disk_size_gb      = var.default_node_pool_config.os_disk_size_gb
    os_disk_type         = var.default_node_pool_config.os_disk_type
    auto_scaling_enabled = var.auto_scaling_enabled
    min_count            = var.default_node_pool_config.min_count
    max_count            = var.default_node_pool_config.max_count
    max_pods             = var.user_max_pods
    zones                = var.default_node_pool_config.zones
    node_labels          = var.default_node_pool_config.node_labels
    node_taints          = var.default_node_pool_config.node_taints
    upgrade_max_surge    = var.default_node_pool_config.upgrade_max_surge
    node_taints          = ["CriticalAddonsOnly=true:NoSchedule"]
  }

  # ===== NETWORK PROFILE CONFIGURATION =====
  aks_network_profile = {
    network_plugin      = var.network_profile.network_plugin
    network_policy      = var.network_profile.network_policy
    network_plugin_mode = var.network_profile.network_plugin_mode
    load_balancer_sku   = var.network_profile.load_balancer_sku
    outbound_type       = var.network_profile.outbound_type
    dns_service_ip      = local.aks_dns_services_ip
    pod_cidr            = local.aks_pod_cidr
    services_cidr       = local.aks_service_cidr
  }

  # ===== AUTO SCALER PROFILE CONFIGURATION =====
  aks_auto_scaler_profile = var.auto_scaler_profile.enabled ? {
    enabled                          = true
    balance_similar_node_groups      = var.auto_scaler_profile.balance_similar_node_groups
    expander                         = var.auto_scaler_profile.expander
    max_graceful_termination_sec     = var.auto_scaler_profile.max_graceful_termination_sec
    max_node_provisioning_time       = var.auto_scaler_profile.max_node_provisioning_time
    max_unready_nodes                = var.auto_scaler_profile.max_unready_nodes
    max_unready_percentage           = var.auto_scaler_profile.max_unready_percentage
    new_pod_scale_up_delay           = var.auto_scaler_profile.new_pod_scale_up_delay
    scale_down_delay_after_add       = var.auto_scaler_profile.scale_down_delay_after_add
    scale_down_delay_after_delete    = var.auto_scaler_profile.scale_down_delay_after_delete
    scale_down_delay_after_failure   = var.auto_scaler_profile.scale_down_delay_after_failure
    scan_interval                    = var.auto_scaler_profile.scan_interval
    scale_down_unneeded              = var.auto_scaler_profile.scale_down_unneeded
    scale_down_unready               = var.auto_scaler_profile.scale_down_unready
    scale_down_utilization_threshold = var.auto_scaler_profile.scale_down_utilization_threshold
    empty_bulk_delete_max            = var.auto_scaler_profile.empty_bulk_delete_max
    skip_nodes_with_local_storage    = var.auto_scaler_profile.skip_nodes_with_local_storage
    skip_nodes_with_system_pods      = var.auto_scaler_profile.skip_nodes_with_system_pods
  } : {}

  # ===== USER NODE POOL CONFIGURATION =====
  # Nota: vnet_subnet_id se asignará en main.tf usando module.subnets
  aks_user_node_pool = {
    name                 = var.user_node_pool_name
    vm_size              = var.user_vm_size
    node_count           = var.user_node_count
    os_disk_size_gb      = var.user_os_disk_size_gb
    auto_scaling_enabled = var.auto_scaling_enabled
    min_count            = var.user_min_count
    max_count            = var.user_max_count
    max_pods             = var.user_max_pods
    node_labels          = var.user_node_labels
    eviction_policy      = var.eviction_policy
  }
}

