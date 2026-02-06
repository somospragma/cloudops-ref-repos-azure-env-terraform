# 📈 Observabilidad y Operación - Nova BackEnd

Este documento describe cómo se instrumenta la observabilidad de la capa BackEnd: Log Analytics, Diagnostic Settings y consideraciones operativas.

## 📊 Log Analytics Workspace

- Módulo `log_analytics_workspace` crea un workspace dedicado por ambiente:
  - Nombre: `${var.project_name}-${var.layer_name}-${var.environment}-LAW`.  
  - Ubicado en el Resource Group de monitoreo.  
  - `sku` y `retention_in_days` parametrizados en `*.tfvars`.

- Uso principal:
  - Consolidar logs de plataforma (AKS, APIM, SQL, Cosmos, Redis, ACR, Storage, Functions).  
  - Servir como base para consultas KQL, dashboards y alertas (configuradas fuera de este repo si aplica).

## 🧪 Diagnostic Settings

Varios módulos incluyen parámetros estándar para habilitar **Diagnostic Settings**:

- Parámetros típicos:
  - `project_name_diag`, `layer_name_diag`, `environment_diag`.  
  - `log_analytics_workspace_id_diag`.  
  - `enable_diagnostic_settings` (controlado por `*.tfvars`).

- Recursos cubiertos (entre otros):
  - VNet (tráfico, flujos).  
  - ACR.  
  - AKS.  
  - APIM.  
  - SQL Server / Databases.  
  - Cosmos DB.  
  - Redis Cache.  
  - Storage Account.  
  - Function App.

## 🏷️ Tags y trazabilidad

- Todos los módulos reutilizan el mapa de `tags` definido en `locals_common.tf`, que incluye al menos:
  - `Project`, `Layer`, `Environment`, `CostCenter`, `IaC`, `ManagedBy`, `Location`.  
- Esto facilita:
  - Filtrado de recursos por proyecto/capa/ambiente.  
  - Asignación de costos.  
  - Gobernanza y reportes.

## 🧰 Operación diaria (alto nivel)

- **Revisión de despliegues**:  
  - Validar en el pipeline de Azure DevOps los resultados de `plan` y `apply` (ver `despliegue-ci-cd.md`).

- **Monitoreo proactivo** (fuera de este repo):  
  - Crear alertas en Azure Monitor / Log Analytics para los componentes críticos (AKS, APIM, SQL, Cosmos, Redis, Service Bus).  
  - Configurar dashboards para seguimiento de salud y capacidad.

- **Gestión de cambios**:  
  - Todo cambio de configuración se hace vía Terraform + pipelines (no manualmente en portal).  
  - Respetar la promoción DEV → QA → PRD con validaciones y aprobaciones.

## 🔗 Relación con WAF

- **Excelencia Operacional**: centralización de logs y métricas, uso de tags, parámetro único para habilitar Diagnostic Settings.  
- **Confiabilidad**: capacidad de detectar fallos rapidamente mediante monitoreo homogéneo.  
- **Optimización de Costos**: retención ajustable por ambiente y posibilidad de supervisar costos de logs.
