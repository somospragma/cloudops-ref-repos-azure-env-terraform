# 💾 Datos y Almacenamiento - Nova BackEnd

Este documento describe los componentes de datos y almacenamiento de la capa BackEnd: SQL Database, Cosmos DB, Redis Cache, Storage Account y Service Bus.

## 🗄️ Azure SQL Database

- **Definición**:
  - Módulo `sql_server` crea el servidor lógico SQL.  
  - Módulo `sql_database` crea las bases de datos lógicas definidas en `locals_sql_database.tf`.

- **Características principales**:
  - `sql_server_version = "12.0"`.  
  - `minimum_tls_version = "1.2"`.  
  - `azuread_authentication_only = true` (solo Entra ID).

- **Bases de datos** (ejemplo inicial):

| Nombre lógico | Collation                          | SKU  | Tamaño máx (GB) | Zona redundante | Comentario |
|---------------|------------------------------------|------|-----------------|-----------------|-----------|
| `SQL_NOVA`    | `SQL_Latin1_General_CP1_CI_AS`     | `S1` | 250             | false           | Base de datos principal BackEnd |

- **Seguridad**:
  - Acceso restringido por red mediante Private Endpoint (subnet `subnet_endpoint`).  
  - Autenticación mediante Entra ID, admin configurado con `sql_admin_object_id` (no se expone en documentación).

## 🌌 Azure Cosmos DB (Mongo)

- **Cuenta Cosmos DB**:
  - Módulo `cosmosdb` crea la cuenta con modo `MongoDB`.  
  - `consistency_level = "Session"`.  
  - `automatic_failover_enabled = true`.

- **Geo-replicación** (definida en `geo_locations`):

| Ubicación | Prioridad de failover |
|-----------|------------------------|
| `eastus`  | 0 (primario)          |
| `eastus2` | 1 (secundario)        |

- **Base de datos Mongo**:
  - Módulo `cosmosdb_mongo_database` crea la base de datos lógica (nombre derivado en `locals_common.tf`).  
  - `autoscale_settings_max_throughput` parametrizable (ej. 1000 RU/s iniciales).

- **Seguridad**:
  - `public_network_access_enabled = false`.  
  - Private Endpoint sobre `subnet_endpoint` con subresource `"MongoDB"`.

## ⚡ Azure Cache for Redis

- **Definición**:
  - Módulo `redis_cache` crea la instancia con los parámetros declarados en `variables.tf` y `*.tfvars`.

- **Características principales**:
  - TLS `1.2`.  
  - SKU `Premium` (según `redis_sku` y `redis_family`).  
  - Capacidad configurada por ambiente (`redis_capacity`).

- **Seguridad**:
  - Private Endpoint configurable con subresource `"redisCache"`.  
  - Ubicada en Resource Group de mensajería.

## 📦 Storage Account

- **Definición**:
  - Módulo `storage_account` crea la cuenta siguiendo el naming `<project><layer><env>ST` (hasta 24 caracteres).  
  - Configuración base en `locals_storage.tf` y variables en `*.tfvars`.

- **Configuración clave**:
  - `account_tier`, `account_replication_type`, `account_kind` parametrizables.  
  - `public_network_access_enabled = false`.  
  - `shared_access_key_enabled = true` (se puede deshabilitar si se migra completamente a identidades gestionadas).

- **Network Rules**:
  - `default_action = "Deny"`.  
  - `bypass = ["AzureServices", "Logging", "Metrics"]`.  
  - `virtual_network_subnet_ids` se ajusta dinámicamente para incluir subnets internas (por defecto, la subnet de Functions).

- **CMK (Customer Managed Keys)**:
  - Preparado en `locals_storage.tf` para habilitar cifrado con claves en Key Vault si se requieren controles adicionales.

## ✉️ Azure Service Bus

- **Namespace**:
  - Módulo `sb_namespace` crea un namespace con SKU `Standard`.  
  - `local_auth_enabled = true` y `public_network_access_enabled = false`.  
  - TLS mínimo `1.2`.

- **Topics y Subscriptions**:
  - Módulo `sb_topics` define un tópico principal (nombre desde `locals_common.tf`).  
  - Módulo `sb_subscriptions` crea suscripciones con configuración declarativa.

- **Parámetros relevantes (definidos en `*.tfvars`)**:

| Parámetro          | Descripción                                      |
|--------------------|--------------------------------------------------|
| `sb_sku`           | SKU del namespace (Basic/Standard/Premium).     |
| `sb_capacity`      | Capacidad de mensajería.                         |
| `sb_topics`        | Configuración del tópico (TTL, tamaño, etc.).    |
| `sb_subscription`  | Configuración de suscripciones (TTL, retries).   |

## 🔗 Relación con WAF

- **Confiabilidad**: geo-replicación en Cosmos, redundancia de datos y colas para desacoplar componentes.  
- **Seguridad**: acceso privado a datos (SQL, Cosmos, Redis, Storage, Service Bus) mediante endpoints privados y TLS 1.2.  
- **Eficiencia de Rendimiento**: uso de Redis para caching y Service Bus para controlar carga y picos.  
- **Optimización de Costos**: SKUs parametrizables por ambiente y posibilidades de ajuste dinámico de throughput y tamaños.
