# 🏗️ IaC BackEnd - Nova Digital (Wiki Azure DevOps)

> Documentación ejecutiva para la wiki de Azure DevOps sobre la infraestructura como código (IaC) de la capa **BackEnd** de **Nova Digital**, desplegada en Azure con **Terraform** y **Azure DevOps Pipelines**.

---

| Fecha | Descripción | Realizado por | Validado por | Fecha de Validación |
|:-:|:-:|:-:|:-:|:-:|
|19/01/2026|Creación del Documento Wiki IaC BackEnd Nova|Cesar Alexis Arango / IA Asistida|Pendiente|Pendiente|

---

[[_TOC_]]

---

# 🎯 Descripción del Proyecto

La capa **BackEnd** de Nova Digital se implementa completamente mediante **infraestructura como código (IaC)** usando **Terraform** y se despliega a través de **Azure DevOps Pipelines**, extendiendo la plantilla corporativa `mercantil-pipeline-template-IAC`.

## Propósito

Estandarizar y automatizar la provisión de la infraestructura BackEnd en Azure, garantizando:

- ✅ **Consistencia** entre ambientes (DEV, QA, PRD) mediante código versionado.
- 🔒 **Seguridad** alineada a lineamientos corporativos y al Azure Well-Architected Framework.
- 🔄 **Ciclo de cambios controlado** mediante pipelines con aprobaciones.
- 📊 **Trazabilidad** de cambios, parámetros y componentes desplegados.

## Alcance

- Capa **BackEnd** del ecosistema Nova Digital.
- Entornos: **DEV**, **QA** y **PRD** (carpeta `envs/`).
- Uso de módulos Terraform corporativos alojados en el repositorio `nova-digital-infraestructure-core-tf` en Azure DevOps.
- Despliegues controlados exclusivamente por pipelines YAML (`azure-pipelines.yml`).

---

# 🏛️ Arquitectura de la Solución

## Visión General

A alto nivel, la capa BackEnd se compone de los siguientes dominios:

1. **Red y conectividad**
   - VNet dedicada por ambiente.
   - Subredes para AKS, APIM, bases de datos, Redis, endpoints privados y Functions.
   - NSG por dominio (por ejemplo, NSG específico para APIM).
   - Tablas de rutas (UDR) hacia el firewall corporativo Fortigate.
   - DNS privado opcional para servicios con Private Endpoint.

2. **Plataforma de ejecución**
   - **Azure Kubernetes Service (AKS)** para microservicios contenedorizados.
   - **Azure Functions (Flex Consumption)** para cargas serverless.
   - **Azure Container Registry (ACR)** como registro privado de imágenes.

3. **Exposición de APIs**
   - **Azure API Management (APIM)** como fachada única para APIs.
   - **Policy fragments** versionados en el repositorio y desplegados con Terraform.

4. **Datos y mensajería**
   - **Azure SQL Database** para datos relacionales.
   - **Azure Cosmos DB (Mongo)** para datos NoSQL geo-replicados.
   - **Azure Cache for Redis** para caching distribuido.
   - **Azure Service Bus** (namespace, topics, subscriptions) para mensajería y eventos.

5. **Seguridad y gestión de secretos**
   - **Azure Key Vault** para secretos, certificados y claves.
   - **User Assigned Managed Identities** para AKS, ACR, APIM, SQL/Cosmos, Functions y Storage.
   - **Azure Policy (Resource Locks)** preparada para proteger recursos críticos.
   - Uso extensivo de **Private Endpoints** en la subnet de endpoints.

6. **Observabilidad**
   - **Log Analytics Workspace** dedicado por capa/ambiente.
   - **Diagnostic Settings** habilitables en VNet, AKS, APIM, SQL, Cosmos, Redis, Storage, Functions, etc.

---

# 📂 Estructura de la IaC

## Árbol de Directorios (simplificado)

```text
nova-digital-back-tf/
├── azure-pipelines.yml
├── README.md
├── resource_lock_policy.json
├── docs/                   # Documentación técnica detallada
└── envs/
    ├── dev/
    ├── qa/
    └── prod/
```

### Carpeta `envs/`

Cada subcarpeta define la infraestructura completa de un ambiente:

- `envs/dev/` – Desarrollo (DEV)
- `envs/qa/` – Quality Assurance (QA)
- `envs/prod/` – Producción (PRD)

Estructura típica en cada ambiente:

```text
env/
├── backend.tf          # Backend remoto de Terraform (azurerm)
├── provider.tf         # Proveedores azurerm / azuread
├── data.tf             # data.azurerm_client_config.current
├── variables.tf        # Variables de entrada (nombres, SKUs, flags, etc.)
├── locals_*.tf         # Convenciones de naming, red, RG, AKS, datos, etc.
├── main.tf             # Llamadas a módulos corporativos y recursos clave
└── <env>.tfvars        # Valores concretos por ambiente (DEV/QA/PRD)
```

### Locales (`locals_*.tf`)

- **locals_common.tf** – Prefijos, tags corporativos, nombres estándar (ACR, KV, Cosmos, Redis, Service Bus, LAW, etc.).
- **locals_resource_groups.tf** – Mapa de Resource Groups por dominio.
- **locals_network.tf** – VNet, subnets, NSG, rutas y UDR.
- **locals_aks.tf** – Naming y configuración de AKS (node pools, network profile, autoscaler).
- **locals_apim.tf** – Naming de APIM y policy fragments.
- **locals_function.tf** – Naming y configuración de Function App + App Service Plan.
- **locals_identity_management.tf** – Identidades gestionadas por dominio.
- **locals_key_vault.tf** – Access policies para Key Vault.
- **locals_sql_database.tf** – SQL Server y bases de datos lógicas.
- **locals_storage.tf** – Storage Account y metadatos (owner, cost center, etc.).

---

# 🧩 Módulos Terraform Principales

La IaC consume módulos corporativos desde `nova-digital-infraestructure-core-tf`. Algunos ejemplos clave (resumen):

| Dominio               | Módulo / Recurso          | Crea |
|-----------------------|---------------------------|------|
| Base                  | `resource_groups`         | Todos los RG por dominio (AKS, APIM, Databases, etc.). |
| Base / Observabilidad | `log_analytics_workspace` | Workspace de Log Analytics por capa/ambiente. |
| Identidad             | `user_identity`           | User Assigned Managed Identities para servicios principales. |
| Red                   | `vnet`, `subnets`, `route_table_fortigate`, `private_dns_zones`, `network_security_group_apim` | VNet, subnets, NSG, rutas UDR y DNS privado. |
| Cómputo               | `aks`, `userpool`, `function_app`, `azure_container_registry` | AKS, user node pool, Function App, ACR. |
| Datos                 | `sql_server`, `sql_database`, `cosmosdb`, `cosmosdb_mongo_database`, `redis_cache` | SQL, DBs lógicas, Cosmos (Mongo), Redis. |
| Mensajería            | `sb_namespace`, `sb_topics`, `sb_subscriptions` | Service Bus namespace + tópicos + suscripciones. |
| Seguridad             | `keyvault`, `keyvault_access_policy`, *(opcional)* `apply_resource_lock` | Key Vault, access policies y Resource Locks. |
| Almacenamiento        | `storage_account`         | Storage Account para datos y Functions. |

Para el detalle completo de módulos, ver `docs/modulos-backend.md` en el repositorio.

---

# � Listado de Recursos Desplegados

A continuación se detalla la lista de recursos y módulos incluidos en este repositorio (basado en el entorno Production).

> **Nota:** Algunos recursos pueden estar deshabilitados o no desplegados en entornos inferiores (DEV/QA) dependiendo de la configuración en `*.tfvars`.

## Infraestructura Base
- **Resource Groups**: Grupos de recursos segmentados por dominio (Network, Comms, Data, Ingress, Security, Monitor, Apps, Identity).
- **Log Analytics Workspace**: Espacio de trabajo centralizado para logs y diagnósticos.
- **User Assigned Managed Identities**: Identidades gestionadas para AKS, APIM, ACR, Bases de datos, Functions y Storage.

## Red y Conectividad
- **Virtual Network (VNet)**: Red virtual principal del entorno.
- **Subnets**: Subredes dedicadas para AKS, APIM, Data, Redis, Endpoints Privados y Functions.
- **Network Security Groups (NSG)**: Reglas de seguridad de red (ej. APIM).
- **Route Tables (UDR)**: Enrutamiento de tráfico hacia el firewall corporativo (Fortigate).
- **Private DNS Zones**: Zonas DNS privadas integradas para resolución de nombres de servicios PaaS (privatelink).
- **Private Endpoints**: Puntos de conexión privados para:
  - Azure Container Registry (ACR)
  - SQL Server
  - Cosmos DB (Mongo)
  - Redis Cache
  - Key Vault
  - Service Bus Namespace (deshabilitado temporalmente o requiere Premium)
  - Storage Account
  - Function App

## Cómputo
- **Azure Kubernetes Service (AKS)**: Clúster de Kubernetes gestionado (Private Cluster).
- **AKS Node Pools**:
  - `default_node_pool`: Pool de sistema.
  - `userpool`: Pool de nodos de usuario con autoscaling.
- **Azure Container Registry (ACR)**: Registro de contenedores privado con geo-replicación.
- **Azure Functions (Flex Consumption)**: Function App Linux en plan flexible.
- **App Service Plan**: Plan de hospedaje para las Functions.

## Datos y Almacenamiento
- **Azure SQL Server**: Servidor de base de datos lógica.
- **Azure SQL Database**: Bases de datos SQL desplegadas.
- **Azure Cosmos DB**: Cuenta de base de datos NoSQL (API MongoDB) con geo-replicación.
- **Cosmos DB Mongo Database**: Base de datos dentro de la cuenta Cosmos.
- **Azure Cache for Redis**: Instancia de Redis para caché distribuido.
- **Storage Account**: Cuenta de almacenamiento para uso general y soporte de Functions.
- **Storage Container**: Contenedor para despliegue de paquetes de Functions.

## Integración y Mensajería
- **API Management (APIM)**: Gateway de APIs (interno/externo).
- **APIM Policy Fragments**: Fragmentos de políticas XML reutilizables.
- **Service Bus Namespace**: Espacio de nombres de mensajería.
- **Service Bus Topics**: Tópicos para publicación/suscripción.
- **Service Bus Subscriptions**: Suscripciones a tópicos.

## Seguridad
- **Azure Key Vault**: Bóveda de claves para gestión de secretos y certificados.
- **Key Vault Access Policies**: Políticas de acceso para identidades gestionadas.
- **Azure Policy (Resource Locks)**: (Opcional) Bloqueos de recursos contra borrado accidental.

---

# �🚀 Flujo de Despliegue CI/CD

## Resumen General

El archivo `azure-pipelines.yml` en la raíz del repositorio **extiende** la plantilla corporativa:

```yaml
resources:
  repositories:
    - repository: mercantil-pipeline-template-IAC
      type: git
      ref: main
      name: mercantil-pipeline-template-IAC

extends:
  template: main.yml@mercantil-pipeline-template-IAC
```

La lógica detallada de CI/CD (stages, jobs, tareas) vive en `mercantil-pipeline-template-IAC`. Este repositorio únicamente establece la referencia y el contexto (código Terraform + estructura de ambientes).

## Flujo típico por ambiente

1. **Desarrollo (DEV)**
   - Ramas: `develop` / `feature/*` (según política del equipo).
   - Objetivo: validar cambios de infraestructura sin impacto en QA/PRD.

2. **QA (Quality Assurance)**
   - Ramas: `release/*` (por ejemplo).
   - Objetivo: pruebas integradas y validación pre-producción.

3. **Producción (PRD)**
   - Rama: `main`.
   - Objetivo: despliegue final, protegido con aprobaciones manuales.

## Pasos clave (alto nivel)

- **CI** (Continuous Integration):
  - Checkout del repositorio.
  - Obtención de secretos desde Azure Key Vault.
  - Configuración de Git para módulos corporativos.
  - Instalación de Terraform y herramientas de análisis.
  - `terraform init`, `terraform validate`, `terraform plan`.
  - Escáneres de seguridad (Checkov, TFLint, OPA/policy-as-code según plantilla).
  - Estimación de costos (Infracost) donde aplique.

- **CD** (Continuous Deployment):
  - Aprobación manual obligatoria antes de aplicar cambios.
  - Descarga del plan aprobado.
  - `terraform apply` utilizando el plan generado en CI.
  - Publicación de outputs.

> Política: **no** ejecutar `terraform apply` desde estaciones locales contra DEV/QA/PRD. Toda aplicación de cambios debe hacerse vía pipeline.

---

# 🔐 Seguridad y Cumplimiento

## Controles principales

- **Segmentación de red** por ambiente y dominio (subnets dedicadas para AKS, APIM, DB, Redis, Endpoints, Functions).
- **NSG** específicos (por ejemplo para APIM) y posibilidad de NSG adicionales via módulos corporativos.
- **UDR** que enrutan tráfico hacia el firewall Fortigate corporativo.
- **Private Endpoints** para SQL Server, Cosmos DB, Redis, Storage, Functions, Key Vault, ACR y otros servicios PaaS.
- **Key Vault** como almacén único de secretos, certificados y claves.
- **Managed Identities** para autenticación de servicios sin credenciales en texto plano.
- **Azure Policy + Resource Locks** (preparado) para proteger recursos críticos de borrados accidentales.
- **Tags corporativos** obligatorios: `Project`, `Layer`, `Environment`, `CostCenter`, `IaC`, `ManagedBy`, `Location`.

## Relación con Azure Well-Architected Framework

| Pilar                         | Cómo se aborda en la IaC BackEnd |
|------------------------------|-----------------------------------|
| Excelencia Operacional       | Separación por ambientes y dominios, módulos corporativos, pipelines YAML y control de cambios centralizado. |
| Seguridad                    | Segmentación de red, NSG, UDR, firewall, Private Endpoints, Key Vault, identities y Azure Policy. |
| Confiabilidad                | Geo-replicación (Cosmos, ACR), separación de responsabilidades, uso de Service Bus para desacoplar componentes. |
| Eficiencia de rendimiento    | AKS con autoscaling, Redis para caching, selección explícita de SKUs y tamaños por ambiente. |
| Optimización de costos       | SKUs diferentes según ambiente, tags de CostCenter, integración con herramientas de estimación de costos. |

---

# 🧭 Guía para Nuevos Integrantes

## ¿Por dónde empezar?

1. **Leer este documento Wiki completo** para entender el contexto general.
2. Revisar en el repositorio los siguientes archivos en este orden:
   - `README.md` (resumen ejecutivo + enlaces a docs).
   - `docs/arquitectura-backend.md` (vista detallada de arquitectura).
   - `docs/estructura-directorios.md` (cómo está organizado el código Terraform).
   - `docs/modulos-backend.md` (qué módulo crea qué recurso).
3. Navegar a `envs/dev/` y revisar:
   - `main.tf` (llamadas a módulos).
   - `locals_*.tf` (nombres, red, RG, datos, etc.).
   - `dev.tfvars` (valores concretos de DEV).

## Buenas prácticas

- No modificar recursos directamente en el Portal de Azure; siempre vía Terraform.
- Probar primero en DEV cualquier cambio de módulo o parámetro.
- Mantener sincronía entre código y estado real (evitar cambios manuales no declarados).
- Actualizar la documentación en `docs/` y en esta Wiki cuando se introduzcan nuevos dominios o servicios.

---

# ❓ FAQ Rápido

- **¿Dónde está la documentación técnica detallada?**  
  En la carpeta `docs/` del repositorio (ver índice en `docs/index.md`).

- **¿Puedo ejecutar terraform apply desde mi máquina?**  
  No para DEV/QA/PRD. Solo se permiten applies a través de los pipelines de Azure DevOps.

- **¿Dónde se configuran los parámetros por ambiente?**  
  En `dev.tfvars`, `qa.tfvars` y `prod.tfvars` dentro de la carpeta de cada ambiente.

- **¿Dónde se almacenan los secretos?**  
  En Azure Key Vault y/o variable groups seguros de Azure DevOps; nunca en `*.tfvars` ni en código.

- **¿Qué hago si el plan muestra cambios inesperados?**  
  Revisar plan, verificar si hubo cambios manuales en Azure y corregir el código o revertir dichos cambios antes de aprobar.

---

**Documento Wiki generado para la IaC BackEnd de Nova Digital** | **CloudOps / Arquitectura de Nube** | **Enero 2026**
