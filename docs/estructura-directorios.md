# 📂 Estructura de Directorios - Nova Digital BackEnd

Esta sección describe la estructura del repositorio de IaC para la capa **BackEnd** de Nova Digital.

```text
.
├── azure-pipelines.yml
├── README.md
├── README-EXAMPLE.md
├── resource_lock_policy.json
└── envs/
    ├── dev/
    ├── qa/
    └── prod/
```

## 🧱 Raíz del repositorio

- `azure-pipelines.yml`  
  Define el pipeline de Azure DevOps que **extiende** la plantilla corporativa `main.yml` del repositorio `mercantil-pipeline-template-IAC`. Aquí se controla el flujo de CI/CD, validaciones, gates de seguridad y aprobaciones.

- `README.md`  
  Documentación principal del proyecto (visión general, flujo de despliegue, enlaces a documentación detallada).

- `README-EXAMPLE.md`  
  Ejemplo de documentación de la plantilla corporativa de pipelines (referencia, no se modifica en el flujo normal del proyecto).

- `resource_lock_policy.json`  
  Definición de una política de Azure Policy de tipo `deployIfNotExists` para aplicar **Resource Locks (CanNotDelete)** sobre recursos críticos (grupos de recursos, máquinas virtuales, cuentas de almacenamiento, SQL, App Service). El módulo de Terraform asociado está referenciado pero actualmente comentado en `main.tf`.

## 🌍 Carpeta envs/

La carpeta `envs/` contiene la definición principal de la infraestructura (Root Module). En este repositorio de referencia, la estructura es plana para facilitar la reutilización, donde los valores específicos de cada ambiente se inyectan a través de archivos de variables (`.tfvars`) o variables de pipeline.

```text
envs/
├── backend.tf               # Configuración del backend remoto (debe ajustarse por proyecto)
├── data.tf                  # Data sources para consultas de recursos existentes
├── locals_*.tf              # Variables locales organizadas por componente (AKS, Network, SQL, etc.)
├── main.tf                  # Orquestador principal de módulos
├── policies/                # Definiciones de políticas (Azure Policy)
├── provider.tf              # Configuración de proveedores (AzureRM, etc.)
├── terraform.tfvars         # Valores de variables por defecto (Ejemplo: configuración de DEV)
└── variables.tf             # Declaración de variables de entrada
```

Para aplicar esta estructura a múltiples ambientes (DEV, QA, PROD), se recomienda:
1. Mantener este código base único.
2. Crear archivos específicos por ambiente: `dev.tfvars`, `qa.tfvars`, `prod.tfvars`.
3. Seleccionar el archivo correspondiente en el pipeline de despliegue.

### Archivos comunes por ambiente

- `backend.tf`  
  Configuración del **backend remotos** de Terraform en Azure (`azurerm`). El detalle del storage account / container se suministra fuera del código y se gestiona de acuerdo con lineamientos corporativos.

- `provider.tf`  
  Define los proveedores de Terraform:
  - `azurerm` (infraestructura en Azure)  
  - `azuread` (identidades y objetos en Entra ID)

- `data.tf`  
  Obtiene el contexto del cliente mediante `data "azurerm_client_config" "current" {}`, utilizado para asociar Tenant, Subscription y Object IDs a recursos como Key Vault, identidades gestionadas y políticas.

- `variables.tf`  
  Declara las variables de entrada parametrizables del módulo por ambiente (naming, redes, SKUs, configuraciones de AKS, SQL, Cosmos DB, Redis, Service Bus, Function App, Storage, diagnósticos, etc.).

- `<env>.tfvars` (`dev.tfvars`, `qa.tfvars`, `prod.tfvars`)  
  Valores concretos para cada ambiente (por ejemplo: `environment = "DEV|QA|PRD"`, SKUs, tamaños, parámetros de escalado, flags de seguridad). Estos archivos **no deben contener secretos**; credenciales y secretos van en Key Vault.

### Archivos locals_*.tf

Los archivos `locals_*.tf` encapsulan las **convenciones de nombres**, estructura de red y configuración estándar corporativa para los recursos de la capa BackEnd:

- `locals_common.tf`  
  - Prefijos estándar (`prefix`, `prefix_lower`).  
  - Tags corporativos obligatorios (Project, Layer, Environment, CostCenter, IaC, ManagedBy, Location).  
  - Naming de ACR, Storage, Key Vault, Cosmos DB, Redis, Service Bus y Log Analytics.

- `locals_resource_groups.tf`  
  - Nombres y mapa de **Resource Groups** por dominio: AKS, APIM, APPS, Container, Databases, Messaging, Monitoring, Network, Security, Storage, User Identity.

- `locals_network.tf`  
  - Definición de la VNet y subnets (AKS, APIM, Databases, Redis, Endpoints, Functions).  
  - Naming y configuración de `Network Security Groups` y **rutas** (UDR) hacia el firewall corporativo (Fortigate).  
  - Lógica para componer rutas automáticas y manuales (`all_routes`).

- `locals_aks.tf`  
  - Naming del clúster AKS y `dns_prefix`.  
  - Construcción de `default_node_pool`, `user_node_pool`, `network_profile` y `auto_scaler_profile` a partir de variables.

- `locals_apim.tf`  
  - Naming de APIM.  
  - Definición de **policy fragments** referenciando archivos XML en `envs/<env>/policies/apim/`.

- `locals_function.tf`  
  - Naming de App Service Plan y Function App.  
  - Configuración por defecto del plan (tier `FC1`, Linux, Elastic).  
  - IP Restrictions por defecto (permitir solo subnet interna y denegar todo el resto).

- `locals_identity_management.tf`  
  - Nombres y mapa de **User Assigned Managed Identities** específicos para: AKS, ACR, APIM, Bases de datos, Cosmos, Functions y Storage.

- `locals_key_vault.tf`  
  - Mapa de Access Policies para Key Vault (cliente actual y módulo de APIM), basados en `data.azurerm_client_config` y en las identidades gestionadas.

- `locals_sql_database.tf`  
  - Naming del SQL Server.  
  - Mapa de bases de datos lógicas (ej. `SQL_NOVA`) con collation, SKU y tamaño máximo.

- `locals_storage.tf`  
  - Naming de la cuenta de almacenamiento.  
  - Configuración de red y seguridad (network rules, CMK opcional) y metadatos (`owner`, `cost_center`, `department`).

## 🔁 Relación con los pilares WAF

- **Excelencia Operacional**: separación estricta por ambiente (`dev/qa/prod`), uso de módulos reutilizables y parametrización por `*.tfvars`.
- **Seguridad**: convenciones de naming, tags para trazabilidad, subnets dedicadas, NSG, rutas hacia firewall, private endpoints y uso de Key Vault.
- **Confiabilidad**: separación de Resource Groups por dominio, geo-replicación en ACR/Cosmos, configuración de escalado en AKS.
- **Eficiencia de Rendimiento**: definición explícita de SKUs y tamaños por entorno, auto-scaling en AKS y bases de datos dimensionadas.
- **Optimización de Costos**: uso de SKUs ajustados por ambiente (Developer para APIM en no-prod, Premium donde aplica) y control por tags de CostCenter.
