locals {
  static_web_app = {

    "Empresa" = {
      name     = "${var.project_name}-${var.layer_name}-SWA-EMPRESA-${var.environment}"
      sku_tier = "Standard"
      location = "eastus2"

      private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_endpoint]
      private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
      private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
      private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
      private_endpoint_environment       = var.environment
      private_endpoint_resource_name     = "SWA"
      private_endpoint_subresource_names = ["staticSites"]

    }
    "Personas" = {
      name     = "${var.project_name}-${var.layer_name}-SWA-PERSONAS-${var.environment}"
      sku_tier = "Standard"
      location = "eastus2"

      private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_endpoint]
      private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
      private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
      private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
      private_endpoint_environment       = var.environment
      private_endpoint_resource_name     = "SWA"
      private_endpoint_subresource_names = ["staticSites"]

    }
    "Backoffice" = {
      name     = "${var.project_name}-${var.layer_name}-SWA-BACKOFFICE-${var.environment}"
      sku_tier = "Standard"
      location = "eastus2"

      private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_endpoint]
      private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
      private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
      private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
      private_endpoint_environment       = var.environment
      private_endpoint_resource_name     = "SWA"
      private_endpoint_subresource_names = ["staticSites"]

    }

    "Prisma-Design" = {
      name     = "${var.project_name}-${var.layer_name}-SWA-PRISMA-DESIGN-${var.environment}"
      sku_tier = "Standard"
      location = "eastus2"

      private_endpoint_subnet_id         = module.subnets.subnet_ids[local.subnet_endpoint]
      private_endpoint_resource_group    = module.resource_groups.resource_groups[local.rg_network].name
      private_endpoint_location          = module.resource_groups.resource_groups[local.rg_network].location
      private_endpoint_project_name      = "${var.project_name}-${var.layer_name}"
      private_endpoint_environment       = var.environment
      private_endpoint_resource_name     = "SWA"
      private_endpoint_subresource_names = ["staticSites"]

    }
  }
}