locals {
  # ===== PRIVATE DNS ZONES CONFIGURATION =====
  # Zonas DNS privadas para diferentes servicios de Azure
  private_dns_zones = {
    # Storage Account
    "privatelink-blob" = {
      zone_name = "privatelink.blob.core.windows.net"
    }
    "privatelink-file" = {
      zone_name = "privatelink.file.core.windows.net"
    }
    "privatelink-queue" = {
      zone_name = "privatelink.queue.core.windows.net"
    }
    "privatelink-table" = {
      zone_name = "privatelink.table.core.windows.net"
    }

    # Key Vault
    "privatelink-keyvault" = {
      zone_name = "privatelink.vaultcore.azure.net"
    }

    # SQL Server
    "privatelink-sql" = {
      zone_name = "privatelink.database.windows.net"
    }

    # Cosmos DB
    "privatelink-cosmosdb" = {
      zone_name = "privatelink.documents.azure.com"
    }

    # Service Bus
    "privatelink-servicebus" = {
      zone_name = "privatelink.servicebus.windows.net"
    }

    # Redis Cache
    "privatelink-redis" = {
      zone_name = "privatelink.redis.cache.windows.net"
    }

    # Azure Container Registry
    "privatelink-acr" = {
      zone_name = "privatelink.azurecr.io"
    }

    # Function App
    "privatelink-functions" = {
      zone_name = "privatelink.azurewebsites.net"
    }
  }

  # ===== VIRTUAL NETWORK LINKS CONFIGURATION =====
  # Links para asociar VNets a las Private DNS Zones
  # Nota: virtual_network_id se asignará en main.tf usando module.vnet
  private_dns_vnet_links = var.private_dns_create_vnet_links ? {
    for zone_key, zone_config in local.private_dns_zones : zone_key => {
      name                 = "${zone_key}-link-${var.environment}"
      registration_enabled = false
    }
  } : {}
}