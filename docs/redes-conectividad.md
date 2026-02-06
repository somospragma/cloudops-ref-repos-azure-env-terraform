# 🌐 Redes y Conectividad - Nova BackEnd

Este documento detalla el diseño de red de la capa BackEnd de , basado en la VNet, subredes, NSG y rutas UDR definidas en locals_network.tf y main.tf.

## VNet principal

- Nombre lógico: vnet_name = "${local.prefix}_VNET_${var.environment}" (por ejemplo, NOVA_BE_VNET_DEV).
- Espacio de direcciones: Configurado en los archivos `*.tfvars` (ej. `10.135.0.0/20` en DEV, `10.122.0.0/18` en QA/PRD).
- DNS: configurable mediante `dns_servers` (definidos en `locals_network.tf`).

## Subredes

Las subredes se definen en `locals_network.tf` usando un mapa `subnets`. Los rangos CIDR y nombres pueden variar entre ambientes (DEV vs QA/PRD).

| Subnet lógica      | Propósito                       | Comentario |
|--------------------|---------------------------------|------------|
| `subnet_aks`       | Nodos de AKS                    | Tráfico hacia servicios internos y externos vía UDR/Firewall |
| `subnet_databases` | SQL y otros motores de datos    | Segmentación de datos relacionales |
| `subnet_apim` (QA/PRD) / `subnet_web` (DEV) | API Management / Web | Service endpoints a KeyVault/Storage. En DEV se usa para propósitos web generales o APIM simulado. |
| `subnet_endpoint`  | Endpoints privados              | Private Endpoints de ACR, SQL, Cosmos, Redis, Storage, Functions, etc. |
| `subnet_redis`     | Redis / App Services            | Service endpoints y delegación a `Microsoft.Web/serverFarms` o `Microsoft.App/environments`. |
| `subnet_function`  | Function App (Flex Consumption) | Delegación a `Microsoft.App/environments` |
| `subnet_key_vault` | Key Vault (DEV)                 | Subnet específica para Key Vault presente en ambiente de desarrollo. |

## Network Security Groups

- NSG para APIM (`nsg_apim`):
  - Nombre: `${local.prefix}_APIM_NSG`.
  - Asociado a la subnet de APIM mediante `azurerm_subnet_network_security_group_association`.
  - Las reglas específicas se definen dentro del módulo corporativo de NSG.
  - *Nota: En ambiente DEV, este recurso puede estar deshabilitado si no se despliega APIM.*

## Rutas (UDR) y firewall

- Tabla de rutas route_table_fortigate:
  - Nombre: ${var.project_name}-${var.layer_name}-${var.environment}-UDR-FGT-RT.
  - Definida mediante el módulo azure_route.

- El mapa subnet_routes_map genera rutas por subnet que:
  - Tienen next_hop_type = "VirtualAppliance".
  - Apuntan al firewall Fortigate (next_hop_fortigate_mercantil = "10.105.1.4").

- all_routes combina:
  - Rutas automáticas por subnet (auto_routes).
  - Rutas manuales, por ejemplo route_out_internet (0.0.0.0/0).

## Private DNS

- Módulo private_dns_zones para creación de zonas DNS privadas y vínculos a la VNet.
- Control mediante la variable private_dns_create_vnet_links (en *.tfvars):
  - Si es true, se crean virtual_network_links entre las zonas privadas y la VNet.
  - Permite resolver nombres internos de servicios con Private Endpoint (SQL, Cosmos, Storage, etc.).

## Peerings opcionales

- Existe código comentado para azurerm_virtual_network_peering hacia una VNet corporativa (MBPFGTVNET).
- El peering puede habilitarse según la estrategia de conectividad (por ejemplo, integración on-premise u otros dominios del banco).
- Incluye configuración de permisos (allow_virtual_network_access, allow_forwarded_traffic, etc.).

## Relación con Well-Architected Framework

- Seguridad: segmentación de red por dominio y ambiente, uso de NSG, UDR y firewall como punto de control.
- Confiabilidad: rutas explícitas y nombres estandarizados facilitan operación y troubleshooting.
- Eficiencia de rendimiento: separación de subnets por carga (cómputo, datos, caché, endpoints) evita cuellos de botella.
- Optimización de costos: reutilización de una VNet por ambiente con subnets bien dimensionadas.
