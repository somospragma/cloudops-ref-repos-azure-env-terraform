# 🎯 Tópicos Principales - IaC Nova BackEnd

Este documento resume los principales tópicos de la solución de infraestructura como código para la capa BackEnd de Nova Digital.

## 📌 Tópicos

- **Arquitectura general**  
  Visión de alto nivel de la solución, dominios de red, cómputo, datos, seguridad y observabilidad.  
  Ver: [Arquitectura BackEnd](arquitectura-backend.md).

- **Estructura de repositorio y entornos**  
  Organización de carpetas, archivos `locals_*.tf`, `variables.tf`, `*.tfvars` y relación entre `dev`, `qa`, `prod`.  
  Ver: [Estructura de directorios](estructura-directorios.md).

- **Red y conectividad segura**  
  VNet, subnets, NSG, rutas UDR hacia firewall, endpoints privados y DNS privados.  
  Ver: [Redes y conectividad](redes-conectividad.md).

- **Plataforma de ejecución (AKS, Functions, ACR)**  
  Clúster AKS, pools de nodos, Function App en Flex Consumption, integración con ACR y políticas de acceso.  
  Ver: [Arquitectura BackEnd](arquitectura-backend.md) y [Parámetros de la IaC](parametros-iac.md).

- **Servicios de datos y mensajería**  
  SQL Database, Cosmos DB (Mongo), Redis Cache y Azure Service Bus (topics/subscriptions).  
  Ver: [Datos y almacenamiento](datos-almacenamiento.md).

- **Seguridad y cumplimiento corporativo**  
  Key Vault, identities, Resource Locks, reglas de red, policy fragments en APIM y alineamiento con lineamientos corporativos.  
  Ver: [Seguridad y cumplimiento](seguridad.md).

- **Observabilidad y diagnósticos**  
  Log Analytics, Diagnostic Settings, retención, estructura de logs clave.  
  Ver: [Observabilidad y operación](observabilidad-operacion.md).

- **CI/CD y gobierno de despliegues**  
  Pipeline de Azure DevOps, relación con la plantilla corporativa de IAC, gates de seguridad, aprobaciones y flujo dev→qa→prod.  
  Ver: [Despliegue CI/CD](despliegue-ci-cd.md).

- **Parámetros y convenciones de naming**  
  Variables de Terraform, archivos `*.tfvars` por ambiente, formatos de nombres y tags corporativos.  
  Ver: [Parámetros de la IaC](parametros-iac.md).

- **Preguntas frecuentes y troubleshooting**  
  Dudas recurrentes sobre uso de Terraform, errores comunes de despliegue y buenas prácticas.  
  Ver: [FAQ](faq.md).
