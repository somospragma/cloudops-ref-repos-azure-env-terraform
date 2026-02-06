# 🏗️ Arquitectura BackEnd

Esta sección describe la arquitectura de infraestructura de la capa **BackEnd** de  implementada con Terraform sobre Microsoft Azure.

## 🎯 Alcance
 
- Entornos: **DEV**, **QA**, **PRD** (carpeta `envs/`).  
- Control de despliegue exclusivamente mediante **pipelines de Azure DevOps** usando la plantilla corporativa de IAC.

## 🔎 Visión general de componentes

A nivel de infraestructura, el BackEnd se compone de los siguientes dominios principales:

1. **Red y conectividad**  
   - VNet dedicada (`NOVA_BE_VNET_<ENV>`).  
   - Subnets para AKS, APIM, bases de datos, Redis, endpoints privados y Functions.  
   - Tablas de rutas hacia el firewall Fortigate.  
   - Network Security Groups (NSG) asociados a subnets críticas.

2. **Cómputo y ejecución**  
   - **AKS** para microservicios contenedorizados.  
   - **Azure Functions (Flex Consumption)** para procesos serverless transaccionales o batch.  
   - **Azure Container Registry (ACR)** como registro privado de imágenes de contenedor.

3. **Exposición y APIs**  
   - **Azure API Management (APIM)** como fachada de APIs para clientes internos/externos (desplegado en QA/PRD, opcional en DEV).  
   - Fragmentos de políticas APIM almacenados en archivos XML y desplegados vía Terraform.

4. **Datos y mensajería**  
   - **Azure SQL Database** para datos relacionales transaccionales.  
   - **Azure Cosmos DB (Mongo)** para datos NoSQL.  
   - **Azure Cache for Redis** para caching distribuido.  
   - **Azure Service Bus** (Namespace, Topics, Subscriptions) para mensajería y eventos.

5. **Seguridad y gestión de secretos**  
   - **Azure Key Vault** para secretos, certificados y claves.  
   - **User Assigned Managed Identities** para AKS, ACR, APIM, SQL/Cosmos, Functions y Storage.  
   - **Azure Policy (Resource Locks)** definida pero opcional, para proteger recursos críticos.

6. **Observabilidad y diagnósticos**  
   - **Log Analytics Workspace** dedicado para la capa BackEnd.  
   - Configuración de **Diagnostic Settings** en la mayoría de recursos (VNet, AKS, APIM, SQL, Cosmos, Redis, ACR, Storage, Function App).

## 🌐 Dominio de red

Principales decisiones de diseño (ver detalle en `redes-conectividad.md`):

- VNet única por ambiente con espacio de direcciones `10.122.0.0/18` en DEV/QA/PRD.  
- Subnets separadas por función (AKS, APIM, DB, Redis, Endpoints, Functions) para facilitar políticas y segmentación.  
- Rutas UDR hacia el firewall Fortigate (`next_hop_fortigate_mercantil`) para todo el tráfico saliente de subnets críticas.  
- NSG específico para APIM y posibilidad de NSG adicionales por subnet.

## 🧩 Cómputo (AKS, Functions, ACR)

- **AKS**:  
  - Clúster privado (`private_cluster_enabled = true`) con red tipo `azure` y `network_plugin_mode = overlay`.  
  - `default_node_pool` de sistema y `user_node_pool` de usuario, ambos parametrizados por ambiente.  
  - Auto-escalado habilitado mediante `auto_scaler_profile` y configuración de `min_count`, `max_count` por pool.

- **ACR**:  
  - Registro privado con SKU `Premium` y geo-replicación `eastus2`.  
  - Integración con identidades gestionadas para pull seguro desde AKS.  
  - Endpoints públicos deshabilitados y soporte de Private Endpoint cuando `enable_private_endpoints = true`.

- **Azure Functions**:  
  - Plan elástico Linux (Flex Consumption) con memoria y número máximo de instancias parametrizable.  
  - Acceso a Storage mediante identidad gestionada (sin claves de cuenta en código).  
  - IP Restrictions: solo se permite tráfico desde subnet interna; el resto se deniega (`DenyAll`).

## 🔐 Seguridad y secretos

- **Key Vault**:  
  - Acceso restringido por red mediante Private Endpoint.  
  - Políticas de acceso para el cliente actual (`azurerm_client_config`) y para APIM (vía Managed Identity).  
  - Uso previsto para almacenar secretos de APIM, cadenas de conexión, certificados, etc.

- **Managed Identities**:  
  - Conjunto de identidades por dominio: AKS, ACR, APIM, bases de datos, Cosmos, Functions, Storage.  
  - Utilizadas para autenticación sin credenciales en Key Vault, Storage, ACR, etc.

- **Azure Policy – Resource Locks**:  
  - `resource_lock_policy.json` define una política `deployIfNotExists` que aplica locks `CanNotDelete` sobre recursos críticos.  
  - El módulo Terraform asociado está preparado en `main.tf` (bloque comentado) y puede activarse según lineamientos de seguridad corporativos.

## 💾 Datos y mensajería

- **SQL Server + Databases**:  
  - SQL Server único por ambiente con TLS mínimo 1.2 y autenticación via Entra ID (`azuread_authentication_only = true`).  
  - Bases de datos lógicas definidas desde `locals_sql_database.tf` con SKU basado en DTUs.

- **Cosmos DB (Mongo)**:  
  - Modo MongoDB con política de consistencia `Session`.  
  - Geo-replicación en `eastus` (primario) y `eastus2` (secundario).  
  - Private Endpoint activable para exponer solo dentro de la VNet.

- **Redis**:  
  - Instancia Premium con TLS 1.2 y posibilidad de Private Endpoint (según SKU).  
  - Pensado para caching de baja latencia para microservicios y/o Functions.

- **Service Bus**:  
  - Namespace con SKU `Standard` y capacidad parametrizable.  
  - Tópico principal de eventos transversales y suscripciones configurables vía variables.

## 📈 Observabilidad

- **Log Analytics Workspace** dedicado a la capa BackEnd (`<project>-<layer>-<env>-LAW`).  
- Envío de logs y métricas desde: VNet, AKS, APIM, SQL, Cosmos, Redis, ACR, Storage, Functions, entre otros.  
- Retención de datos controlada por ambiente mediante variables (`log_retention_days`).

## 🔗 Relación con Azure Well-Architected Framework

- **Excelencia Operacional**: separación por dominios (red, cómputo, datos, seguridad, observabilidad), uso de módulos reutilizables corporativos y parametrización por ambiente.  
- **Seguridad**: red segmentada, NSG, UDR hacia firewall, Private Endpoints, Key Vault, Managed Identities y Azure Policy para locks.  
- **Confiabilidad**: geo-replicación en ACR/Cosmos, redundancia en almacenamiento, escalado automático en AKS y límites claros para cada servicio.  
- **Eficiencia de Rendimiento**: selección explícita de SKUs y tamaños, pools separados para sistema/usuario, configuración de autoscaling.  
- **Optimización de Costos**: uso de SKUs adecuados por ambiente, separación de recursos por RG y control de costos por tags.
