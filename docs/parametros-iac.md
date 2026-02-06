# 📊 Parámetros de la IaC - Nova BackEnd

Este documento resume los parámetros principales de Terraform usados para configurar la infraestructura BackEnd de Nova Digital.

> **Nota de Reutilización**: En este repositorio de referencia se incluye un archivo `terraform.tfvars` con valores de ejemplo (típicamente DEV). Para un proyecto real multidimensional, se deben crear archivos `dev.tfvars`, `qa.tfvars` y `prod.tfvars` con los valores específicos de cada ambiente.

> Nota: no se documentan valores sensibles (IDs de objetos, correos, etc.), solo su propósito.

## Parámetros generales

| Parámetro        | Descripción                                      | Tipo    |
|------------------|--------------------------------------------------|---------|
| environment      | Ambiente lógico (DEV, QA, PRD).                  | string  |
| layer_name       | Nombre de la capa (ej. "BE").                  | string  |
| project_name     | Nombre abreviado del proyecto ("NOVA").        | string  |
| location_primary | Región primaria de despliegue (ej. "eastus").  | string  |
| tags             | Mapa de tags corporativos obligatorios.         | map     |

## Red y conectividad

| Parámetro           | Descripción                                  | Tipo        |
|---------------------|----------------------------------------------|-------------|
| vnet_address_space  | Lista de prefijos CIDR para la VNet.        | list(string)|
| dns_servers         | Lista de servidores DNS personalizados.     | list(string)|
| enable_private_endpoints | Habilita creación de endpoints privados.| bool        |

## Observabilidad

| Parámetro           | Descripción                                  | Tipo   |
|---------------------|----------------------------------------------|--------|
| log_analytics_sku   | SKU del Log Analytics Workspace.            | string |
| log_retention_days  | Días de retención de logs.                  | number |
| enable_diagnostic_settings | Activa Diagnostic Settings en recursos.| bool  |

## Container Registry (ACR)

| Parámetro               | Descripción                                             | Tipo   |
|-------------------------|---------------------------------------------------------|--------|
| acr_sku                 | SKU de ACR (Basic, Standard, Premium).                 | string |
| georeplications_location | Región secundaria para geo-replicación de ACR.        | string |

## AKS y pools de nodos

| Parámetro                | Descripción                                           | Tipo   |
|--------------------------|-------------------------------------------------------|--------|
| kubernetes_version       | Versión de Kubernetes del clúster.                   | string |
| private_cluster_enabled  | Habilita clúster privado.                             | bool   |
| sku_tier                 | Tier del clúster (por ejemplo, Free).                | string |
| default_node_pool_config | Objeto con configuración del pool de sistema.         | object |
| network_profile          | Objeto de red para AKS (plugin, LB, outbound, etc.). | object |
| auto_scaler_profile      | Perfil de auto-escalado del clúster.                 | object |
| user_node_pool_name      | Nombre del pool de usuario.                          | string |
| user_vm_size             | Tamaño de VM para el pool de usuario.                | string |
| user_node_count          | Número de nodos iniciales del pool de usuario.       | number |
| user_min_count           | Número mínimo de nodos del pool de usuario.          | number |
| user_max_count           | Número máximo de nodos del pool de usuario.          | number |
| user_max_pods            | Máximo de pods por nodo.                             | number |
| auto_scaling_enabled     | Indica si el pool de usuario usa auto-scaling.       | bool   |
| user_node_labels         | Etiquetas para los nodos del pool de usuario.        | map    |
| user_os_disk_size_gb     | Tamaño del disco OS para los nodos de usuario.       | number |
| eviction_policy          | Política para nodos (Deallocate/Delete).             | string |

## SQL Database

| Parámetro           | Descripción                                         | Tipo   |
|---------------------|-----------------------------------------------------|--------|
| sql_admin_username  | Usuario administrador con Entra ID (UPN).          | string |
| sql_admin_object_id | Object ID en Entra ID del administrador SQL.        | string |

## Cosmos DB (Mongo)

| Parámetro              | Descripción                                      | Tipo   |
|------------------------|--------------------------------------------------|--------|
| cosmos_db_config       | Objeto con configuración de la cuenta Cosmos.   | object |
| geo_locations          | Lista de ubicaciones y prioridades de failover. | list   |
| autoscale_settings_max_throughput | Throughput máximo en RU/s.           | number |

## Service Bus

| Parámetro      | Descripción                                  | Tipo   |
|----------------|----------------------------------------------|--------|
| sb_sku         | SKU del namespace (Basic, Standard, Premium).| string |
| sb_capacity    | Capacidad del namespace.                     | number |
| sb_topics      | Objeto con configuración del tópico.         | object |
| sb_subscription| Objeto con configuración de suscripciones.   | object |

## Redis Cache

| Parámetro      | Descripción                                  | Tipo   |
|----------------|----------------------------------------------|--------|
| redis_sku      | SKU de Redis (Basic, Standard, Premium).     | string |
| redis_family   | Familia (C para Standard, P para Premium).   | string |
| redis_capacity | Capacidad (0-6).                             | number |
| redis_version  | Versión de Redis.                            | string |

## Key Vault

| Parámetro   | Descripción                         | Tipo   |
|-------------|-------------------------------------|--------|
| sku_name_kv | SKU de Key Vault (standard, etc.). | string |

## API Management

| Parámetro       | Descripción                            | Tipo   |
|-----------------|----------------------------------------|--------|
| sku_name_apim   | SKU de APIM (Developer, etc.).        | string |
| publisher_name  | Nombre del publicador de las APIs.    | string |
| publisher_email | Correo de contacto del publicador.    | string |

## Function App

| Parámetro                                  | Descripción                                             | Tipo   |
|--------------------------------------------|---------------------------------------------------------|--------|
| function_app_create_private_endpoint       | Crea endpoint privado para la Function App.            | bool   |
| function_app_private_endpoint_subresource_names | Lista de subresources para el Private Endpoint.   | list   |
| function_app_service_plan_kind             | Tipo de App Service Plan (p.ej. elastic).              | string |
| function_app_service_plan_sku_tier         | Tier del plan (ElasticPremium, etc.).                  | string |
| function_app_service_plan_sku_size         | Tamaño del plan (EP1, etc.).                           | string |
| function_runtime_name                      | Runtime (p.ej. java).                                  | string |
| function_runtime_version                   | Versión del runtime (p.ej. 17).                        | number |
| function_maximum_instance_count            | Máximo de instancias de Function App.                  | number |
| function_instance_memory_in_mb             | Memoria por instancia en MB.                           | number |

## Storage Account

| Parámetro                                       | Descripción                                            | Tipo   |
|-------------------------------------------------|--------------------------------------------------------|--------|
| storage_account_tier                            | Tier de almacenamiento (Standard/Premium).            | string |
| storage_account_replication_type                | Tipo de replicación (LRS, GRS, etc.).                 | string |
| storage_account_kind                            | Tipo de cuenta (StorageV2, etc.).                     | string |
| storage_account_public_network_access_enabled   | Habilita acceso público a la cuenta.                  | bool   |
| storage_account_shared_access_key_enabled       | Habilita claves de acceso compartidas.                | bool   |
| storage_account_network_rules_default_action    | Acción por defecto de reglas de red.                  | string |
| storage_account_network_rules_bypass            | Lista de bypass (AzureServices, Logging, Metrics).    | list   |
| storage_account_network_rules_ip_rules          | Lista de IPs permitidas.                              | list   |
| storage_account_network_rules_virtual_network_subnet_ids | Lista de subnets permitidas.                  | list   |
| storage_account_create_private_endpoint         | Crea endpoint privado para Storage.                   | bool   |
| storage_account_private_endpoint_subresource_names | Subresources (p.ej. blob).                          | list   |

## DNS Privado

| Parámetro                 | Descripción                                          | Tipo  |
|---------------------------|------------------------------------------------------|-------|
| private_dns_create_vnet_links | Indica si se crean links de VNet a zonas privadas.| bool |
