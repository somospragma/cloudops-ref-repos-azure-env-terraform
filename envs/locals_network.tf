locals {

  #############################################
  ### VNETS AND SUBNETS NAME
  #############################################
  # ===== VNETS (Naming: {PROJECT}_{LAYER}_VNET_{ENV}) =====
  vnet_name = "${local.prefix}_VNET_${var.environment}"

  # ===== SUBNETS (Naming: {PROJECT}_{LAYER}_{PURPOSE}_SUBNET) =====
  subnet_aks       = "${local.prefix}_${var.environment}_AKS_SUBNET"
  subnet_web       = "${local.prefix}_${var.environment}_WEB_SUBNET"
  subnet_databases = "${local.prefix}_${var.environment}_DB_SUBNET"
  subnet_redis     = "${local.prefix}_${var.environment}_REDIS_SUBNET"
  subnet_endpoint  = "${local.prefix}_${var.environment}_ENDPOINT_SUBNET"
  subnet_function  = "${local.prefix}_${var.environment}_FUNCTION_SUBNET"
  subnet_key_vault = "${local.prefix}_${var.environment}_KV_SUBNET"


  #############################################
  ### VNET + DNS VALUES
  #############################################
  vnet_address_space = ["10.135.0.0/20"]
  dns_servers        = ["10.109.0.43", "10.110.48.15", "10.246.4.67"]


  #############################################
  ### AKS Kubernetes Networks (Las redes del AKS deben ser unicas y no pueden solaparce con ninguna otra red)
  #############################################
  aks_pod_cidr        = "10.245.0.0/16"
  aks_service_cidr    = "10.100.0.0/20"
  aks_dns_services_ip = "10.100.0.10"


  #############################################
  ### SUBNETS VALUES
  #############################################
  subnets = {
    (local.subnet_aks) = {
      address_prefixes = ["10.135.0.0/22"]
    }

    (local.subnet_databases) = {
      address_prefixes = ["10.135.4.0/24"]
    }

    (local.subnet_web) = {
      address_prefixes  = ["10.135.6.0/26"]
      service_endpoints = []
    }

    (local.subnet_endpoint) = {
      address_prefixes = ["10.135.5.128/27"]
    }

    (local.subnet_redis) = {
      address_prefixes  = ["10.135.5.192/27"]
      service_endpoints = []
    }

    (local.subnet_function) = {
      address_prefixes  = ["10.135.5.0/25"]
      service_endpoints = []
    }

    (local.subnet_key_vault) = {
      address_prefixes = ["10.135.5.160/27"]
    }
  }

  #############################################
  ### NETWORK SECURITY GROUPS VALUES
  #############################################
  nsg_apim = "${local.prefix}_APIM_NSG"


  #############################################
  ### Routes
  #############################################
  # ===== PROXIMO SALTO O HOST =====
  next_hop_fortigate_mercantil = "10.105.1.4"


  # ===== ROUTE TABLE NAME =====
  route_table_fortigate = "${var.project_name}-${var.layer_name}-${var.environment}-UDR-FGT-RT"

  # ===== RUTAS MANUALES NAME =====
  route_out_internet = "${var.project_name}-${var.layer_name}-${var.environment}-OUT-INTERNET"


  # ===== RUTAS DINÁMICAS DESDE SUBNETS =====
  subnet_routes_map = {
    (local.subnet_aks) = {
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = local.next_hop_fortigate_mercantil
    }
    (local.subnet_databases) = {
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = local.next_hop_fortigate_mercantil
    }
    (local.subnet_web) = {
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = local.next_hop_fortigate_mercantil
    }
    (local.subnet_endpoint) = {
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = local.next_hop_fortigate_mercantil
    }
    (local.subnet_redis) = {
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = local.next_hop_fortigate_mercantil
    }
    (local.subnet_function) = {
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = local.next_hop_fortigate_mercantil
    }
    (local.subnet_key_vault) = {
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = local.next_hop_fortigate_mercantil
    }
  }

  # ===== RUTAS MANUALES =====
  manual_routes = {
    (local.route_out_internet) = {
      address_prefix      = "0.0.0.0/0"
      next_hop_type       = "VirtualAppliance"
      next_hop_ip_address = local.next_hop_fortigate_mercantil
    }
  }

  ## Logica de locals para generar las rutas y tablas de rutas
  # ===== RUTAS GENERADAS DESDE SUBNETS =====
  auto_routes = {
    for subnet_name, subnet_config in local.subnet_routes_map :
    subnet_name => {
      address_prefix      = local.subnets[subnet_name].address_prefixes[0]
      next_hop_type       = subnet_config.next_hop_type
      next_hop_ip_address = subnet_config.next_hop_ip_address
    }
  }

  # ===== RUTAS FINALES (AUTO + MANUALES) =====
  all_routes = merge(local.auto_routes, local.manual_routes)
}