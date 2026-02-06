# 🔐 Seguridad y Cumplimiento - Nova BackEnd

Este documento describe los controles de seguridad aplicados en la infraestructura BackEnd de , alineados con los lineamientos de seguridad corporativos del banco y el pilar de Seguridad del Azure Well-Architected Framework.

## Principios generales

- Seguridad por diseño: recursos en subredes dedicadas, con NSG, UDR y uso intensivo de endpoints privados.
- Acceso mínimo necesario: uso de identidades gestionadas y roles específicos por servicio.
- Separación por dominio: grupos de recursos independientes para red, seguridad, datos, mensajería, apps y monitoreo.
- Centralización de secretos: secretos, certificados y claves se almacenan en Azure Key Vault.

## Controles de red

- Espacio de direcciones único por ambiente (10.122.0.0/18 en DEV/QA/PRD).
- Subnets por dominio: AKS, APIM, bases de datos, Redis, endpoints, Functions.
- Tablas de rutas (route_table_fortigate) que envían el tráfico saliente de subnets críticas hacia el firewall Fortigate corporativo.
- Network Security Group para la subnet de APIM (nsg_apim) y posibilidad de NSG adicionales.

## Endpoints privados y exposición pública

- Azure Container Registry (ACR):
  - Acceso público deshabilitado.
  - Private Endpoint habilitable mediante la variable enable_private_endpoints.

- SQL Server, Cosmos DB, Redis, Storage, Function App, Key Vault:
  - Uso de Private Endpoints en la subnet de endpoints.
  - Subresource names específicos por servicio ("sqlServer", "MongoDB", "redisCache", "vault", "sites", etc.).

- API Management (APIM):
  - public_network_access_enabled = true solo para escenarios iniciales de configuración y pruebas.
  - Se espera su restricción posterior según la estrategia corporativa (por ejemplo, Private Endpoint + VPN / ExpressRoute).

## Azure Policy y Resource Locks

- El archivo resource_lock_policy.json define una política deployIfNotExists para aplicar Resource Locks de tipo CanNotDelete en:
  - Grupos de recursos.
  - Máquinas virtuales.
  - Cuentas de almacenamiento.
  - Servidores SQL.
  - Web Apps.

- El módulo asociado (apply_resource_lock) está preparado en main.tf (comentado) y puede habilitarse según lineamientos corporativos para impedir borrados accidentales de recursos críticos.

## Gestión de identidades y secretos

- Azure Key Vault:
  - Naming estándar basado en proyecto, capa y ambiente.
  - Acceso restringido por red (Private Endpoint) y mediante Access Policies.
  - Uso previsto para secretos de APIM, cadenas de conexión, certificados y claves de cifrado.

- Access Policies (locals_key_vault.tf):
  - Política para el cliente actual (identity del despliegue).
  - Política para el módulo de APIM utilizando la Managed Identity correspondiente.

- User Assigned Managed Identities (locals_identity_management.tf):
  - Identidades dedicadas para AKS, ACR, APIM, bases de datos, Cosmos, Functions y Storage.
  - Reemplazan credenciales en texto plano por autenticación basada en identidades.

## Bases de datos y cifrado

- SQL Server:
  - Versión 12.0 con TLS mínimo 1.2.
  - Autenticación mediante Entra ID (azuread_authentication_only = true).
  - Admin configurado con sql_admin_username y sql_admin_object_id (definidos en *.tfvars, no se documentan valores concretos).

- Cosmos DB (Mongo):
  - Consistencia Session y geo-replicación entre eastus y eastus2.
  - public_network_access_enabled = false para forzar acceso privado.

- Redis:
  - TLS 1.2 y configuración Premium.
  - Private Endpoint cuando la SKU lo permite.

- Storage Account:
  - public_network_access_enabled = false.
  - network_rules_default_action = "Deny" con bypass limitado a servicios de plataforma.
  - Soporte opcional de Customer Managed Keys (CMK) si se habilita en locals_storage.tf.

## Acceso a aplicaciones (APIM y Functions)

- APIM:
  - Preparado para integrarse con Key Vault para secretos de identity provider.
  - Uso de policy fragments para aplicar políticas de seguridad corporativas (headers, certificados, trazas, etc.).

- Function App:
  - https_only = true.
  - Acceso a Storage mediante identidad gestionada de usuario.
  - IP Restrictions que permiten únicamente la subnet interna de Functions.

## Alineamiento con los lineamientos corporativos

- Uso de tags obligatorios para trazabilidad y gobierno de recursos (Project, Layer, Environment, CostCenter, IaC, ManagedBy, Location).
- Aislamiento de redes por ambiente y dominio de aplicación.
- Preferencia por Private Endpoints y Managed Identities frente a exposición pública y secretos en código.
- Uso de Azure Policy y políticas APIM para reforzar estándares corporativos de seguridad.
