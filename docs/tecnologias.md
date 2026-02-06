# 🧰 Tecnologías y Componentes - Nova BackEnd

Este documento detalla las principales tecnologías utilizadas en la infraestructura como código de la capa BackEnd de .

## 🧱 Infraestructura como Código

- **Terraform**  
  - Se utiliza como herramienta principal de IaC.  
  - Versiones soportadas: `>= 1.14.0` (ver `backend.tf`).  
  - Organización modular basada en módulos corporativos alojados en Azure DevOps.

- **Módulos corporativos de Terraform (Azure DevOps)**  
  Los recursos principales se crean a través de módulos estándar del repositorio corporativo `infra-channels-azure-iac-modules`, por ejemplo:
  - `azure_resource_group`  
  - `azure_virtual_network/vnet`  
  - `azure_subnet`  
  - `azure_network_security_group`  
  - `azure_container_registry`  
  - `azure_kubernetes_cluster/aks_cluster` y `azure_kubernetes_cluster/cluster_nodes_pool` (user pool)  
  - `azure_mssql/sql_server` y `azure_mssql/sql_database`  
  - `azure_cosmosdb/*`  
  - `azure_redis_cache`  
  - `azure_service_bus/*`  
  - `azure_keyvault/*`  
  - `azure_apim/*`  
  - `azure_log_analytics`  
  - `azure_storage_account`  
  - `azure_private_dns/*`  
  - `azure_route`

## ☁️ Plataforma Cloud

- **Microsoft Azure**  
  - Suscripción corporativa del banco.  
  - Restricciones y lineamientos de seguridad propios (segmentación, uso de firewall, endpoints privados, etc.).

## 🔐 Identidad y Seguridad

- **Azure AD / Entra ID**  
  - Proveedor `azuread` para gestionar relaciones con identidades.  
  - Uso de `data.azurerm_client_config` para asociar tenant, subscription y object IDs.

- **Managed Identities (User Assigned)**  
  - Identidades dedicadas para AKS, ACR, APIM, SQL/Cosmos, Functions y Storage, definidas en `locals_identity_management.tf`.

- **Azure Key Vault**  
  - Gestor centralizado de secretos, certificados y claves.  
  - Integrado con APIM y otros servicios mediante identidades gestionadas.

## 🔄 Mensajería y Datos

- **Azure SQL Database**  
  - Servidor SQL y bases de datos lógicas diferenciadas.  
  - Autenticación mediante Entra ID y TLS mínimo 1.2.

- **Azure Cosmos DB (Mongo)**  
  - Modo MongoDB con geo-replicación y consistencia `Session`.

- **Azure Cache for Redis**  
  - Cache distribuido para mejorar latencia en el acceso a datos.

- **Azure Service Bus**  
  - Namespace, topics y subscriptions para integración basada en eventos.

## 🧮 Observabilidad

- **Azure Monitor / Log Analytics**  
  - Workspace dedicado por capa/entorno (`<project>-<layer>-<env>-LAW`).  
  - Uso de Diagnostic Settings en múltiples recursos.

## 🚀 CI/CD

- **Azure DevOps Pipelines**  
  - Archivo `azure-pipelines.yml` que extiende el template `main.yml` del repositorio `mercantil-pipeline-template-IAC`.  
  - La plantilla corporativa incorpora:  
    - Validaciones de sintaxis y formato de Terraform.  
    - Escáneres de seguridad (Checkov, TFLint, OPA baseline, etc.) según configuración corporativa.  
    - Estimación de costos (Infracost) donde aplique.  
    - Gates y aprobaciones manuales para despliegues hacia QA/PRD.

## 📐 Alineamiento con lineamientos corporativos

- Uso obligatorio de **tags corporativos** (Project, Layer, Environment, CostCenter, IaC, ManagedBy, Location).  
- Uso de **naming conventions** consistentes en todos los recursos.  
- Preferencia por **endpoints privados** y **autenticación basada en identidades gestionadas** en lugar de claves secretas.
