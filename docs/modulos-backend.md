# 🧩 Módulos Terraform BackEnd - Nova Digital

Este documento resume los **módulos Terraform** utilizados en la capa BackEnd de Nova Digital, qué servicios crean y cómo se relacionan entre sí. Sirve como guía rápida para que alguien nuevo entienda “qué módulo hace qué”.

> Nota: Los nombres de módulos y fuentes corresponden al código de `envs/dev/main.tf` (y se replican en QA/PRD con los mismos módulos y distinta parametrización).

## Visión general

- Todos los módulos provienen del repositorio corporativo `infra-channels-azure-iac-modules` en Azure DevOps.
- La parametrización (nombres, tamaños, SKUs, flags) se hace vía `variables.tf`, `locals_*.tf` y archivos `*.tfvars` por ambiente.
- Esta capa BackEnd actúa como **consumidor** de esos módulos corporativos, sin redefinir recursos “a mano” salvo algunos casos puntuales (App Service Plan y Storage Container para Functions).

## Módulos de base y gobierno

| Módulo                   | Archivo       | Recurso lógico                    | Descripción breve |
|--------------------------|--------------|-----------------------------------|-------------------|
| `module "resource_groups"` | main.tf    | Grupos de recursos                | Crea todos los Resource Groups de AKS, APIM, APPS, Container, Databases, Messaging, Monitoring, Network, Security, Storage y User Identity según `locals_resource_groups.tf`. |
| `module "log_analytics_workspace"` | main.tf | Observabilidad                  | Crea el Log Analytics Workspace `<project>-<layer>-<env>-LAW` usado por los Diagnostic Settings. |
| `module "user_identity"` | main.tf     | Managed Identities                | Crea las identidades gestionadas de usuario para AKS, ACR, APIM, Bases de datos, Cosmos, Functions y Storage según `locals_identity_management.tf`. |

## Red y conectividad

| Módulo                    | Recurso lógico        | Descripción |
|---------------------------|-----------------------|-------------|
| `module "vnet"`          | Virtual Network       | Crea la VNet principal de BackEnd con espacio de direcciones definido en `*.tfvars` y nombre derivado de `locals_network.tf`. |
| `module "subnets"`       | Subnetting            | Crea las subredes de AKS, APIM (o WEB en DEV), DB, Redis, Endpoints y Functions a partir del mapa `subnets` de `locals_network.tf`. |
| `module "network_security_group_apim"` | NSG APIM | Crea el NSG asociado a la subnet de APIM. |
| `azurerm_subnet_network_security_group_association` | Asociación NSG/subnet | Asocia el NSG de APIM a la subnet correspondiente. |
| `module "private_dns_zones"` | Private DNS       | Crea zonas DNS privadas y vínculos con la VNet cuando `private_dns_create_vnet_links` es true. |
| `module "route_table_fortigate"` | Rutas/UDR     | Crea la tabla de rutas que envía el tráfico hacia el firewall Fortigate según `subnet_routes_map` y `all_routes` en `locals_network.tf`. |

## Cómputo y plataforma de ejecución

| Módulo / Recurso        | Recurso lógico          | Descripción |
|-------------------------|-------------------------|-------------|
| `module "azure_container_registry"` | ACR       | Crea el Azure Container Registry con geo-replicación, integraciones de identidad y Private Endpoint opcional. |
| `module "aks"`        | AKS (cluster)           | Crea el clúster de Kubernetes (control plane + node pool por defecto) usando la configuración de `locals_aks.tf` y variables de AKS. Módulo: `azure_kubernetes_cluster/aks_cluster`. |
| `module "userpool"`   | AKS (user node pool)    | Crea el pool de nodos de usuario independiente del pool de sistema. Módulo: `azure_kubernetes_cluster/cluster_nodes_pool`. |
| `azurerm_service_plan "function_plan"` | App Service Plan | Crea el plan de App Service para Functions (Flex Consumption) con configuración definida en `locals_function.tf`. |
| `azurerm_storage_container "function_app_deployment"` | Contenedor de despliegue | Crea el contenedor de Storage donde se almacenan los paquetes de Function App. |
| `module "function_app"` | Azure Functions        | Crea la Function App, la integra con el App Service Plan, Storage y la identidad gestionada, y configura Private Endpoint e IP restrictions. |

## Exposición de APIs

| Módulo                        | Recurso lógico          | Descripción |
|-------------------------------|-------------------------|-------------|
| `module "apim"`             | Azure API Management    | Crea la instancia de APIM (Developer/otros SKUs), vinculada a subnet propia, identidad gestionada y Log Analytics. |
| `module "apim_policy_fragments"` | APIM policy fragments | Publica los fragmentos de políticas XML desde `envs/<env>/policies/apim` definidos en `locals_apim.tf`. |
| *(comentado)* `module "apim_identity_provider_entraid"` | Identity Provider | Preparado para integrar APIM con Key Vault y Entra ID, usando secretos en Key Vault (no activo por defecto). |

## Datos y mensajería

| Módulo                     | Recurso lógico   | Descripción |
|----------------------------|------------------|-------------|
| `module "sql_server"`     | SQL Server       | Crea el servidor SQL con TLS 1.2, autenticación Entra ID y Private Endpoint opcional. |
| `module "sql_database"`   | SQL Databases    | Crea las bases de datos lógicas definidas en `locals_sql_database.tf` (ej. `SQL_NOVA`). |
| `module "cosmosdb"`       | Cosmos DB        | Crea la cuenta Cosmos (modo MongoDB) con geo-replicación y Private Endpoint opcional. |
| `module "cosmosdb_mongo_database"` | Mongo DB | Crea la base de datos Mongo dentro de la cuenta Cosmos con autoscaling de throughput. |
| `module "redis_cache"`    | Azure Cache Redis| Crea la instancia Redis (normalmente Premium) con TLS 1.2 y configuración preparada para Private Endpoint. |
| `module "sb_namespace"`   | Service Bus NS   | Crea el Service Bus Namespace con SKU y capacidad parametrizables. |
| `module "sb_topics"`      | Topics           | Crea el tópico principal de eventos (nombre desde locals). |
| `module "sb_subscriptions"` | Subscriptions  | Crea las suscripciones al tópico según la configuración de `sb_subscription`. |

## Seguridad y secretos

| Módulo                     | Recurso lógico         | Descripción |
|----------------------------|------------------------|-------------|
| `module "keyvault"`      | Azure Key Vault        | Crea el Key Vault de la capa BackEnd con Private Endpoint, soft delete y purge protection. |
| `module "keyvault_access_policy"` | KV Access Policies | Define las Access Policies para el cliente actual y la identidad de APIM, permitiendo acceso a secretos/certificados. |
| *(comentado)* `module "apply_resource_lock"` | Azure Policy / Locks | Preparado para aplicar Resource Locks CanNotDelete a recursos críticos usando `resource_lock_policy.json`. |

## Almacenamiento

| Módulo                     | Recurso lógico        | Descripción |
|----------------------------|-----------------------|-------------|
| `module "storage_account"` | Storage Account      | Crea la cuenta de almacenamiento principal (para datos generales y soporte de Functions), con network rules y Private Endpoint opcional. |

## Cómo leer main.tf

1. Identifica el **dominio** (red, cómputo, datos, seguridad, observabilidad) en los encabezados de comentarios de `main.tf`.
2. Dentro de cada dominio, localiza los bloques `module` y revisa:
   - `source` → ruta del módulo en `nova-digital-infraestructure-core-tf`.
   - Parámetros → la mayoría provienen de `locals_*.tf` y `variables.tf`.
3. Cruza esos parámetros con:
   - `locals_*.tf` → naming, mapas y defaults corporativos.
   - `*.tfvars` → valores concretos por ambiente (SKUs, tamaños, flags).

Con este mapa de módulos + el resto de documentación (arquitectura, redes, datos, seguridad y parámetros), una persona nueva debería poder seguir de forma clara qué módulo crea qué servicio y cómo se distribuye la infraestructura en esta capa BackEnd.
