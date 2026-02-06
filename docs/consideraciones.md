# 💡 Consideraciones de Diseño - Nova BackEnd

Este documento resume las principales decisiones de diseño de la IaC de Nova BackEnd y su relación con el Azure Well-Architected Framework.

## Separación por dominios y ambientes

- Separación por ambiente en carpetas envs/dev, envs/qa y envs/prod.
- Resource Groups separados por dominio (AKS, APIM, APPS, Container, Databases, Messaging, Monitoring, Network, Security, Storage, User Identity).
- Facilita gobierno, observabilidad y delegación de permisos específicos.

## Red y seguridad

- VNet única por ambiente con subnets dedicadas por tipo de carga (cómputo, datos, caché, endpoints, integración).
- Rutas UDR hacia el firewall Fortigate como punto central de inspección.
- Uso extensivo de Private Endpoints para exponer servicios PaaS solo dentro de la red privada.

## Identidad y secretos

- Uso de identidades gestionadas de usuario para AKS, ACR, APIM, SQL/Cosmos, Functions y Storage.
- Se minimiza el uso de claves y secretos embebidos; en su lugar se recurre a Key Vault.

## Escalabilidad y rendimiento

- AKS con pools separados para sistema y usuario, con soporte de auto-escalado.
- Capacidad de ajustar SKUs y tamaños de recursos (SQL, Cosmos, Redis, Service Bus, APIM) por ambiente a través de *.tfvars.

## Confiabilidad y resiliencia

- Geo-replicación en ACR y Cosmos DB.
- Separación de cargas de datos, cómputo y mensajería en dominios diferentes.
- Posibilidad de configurar alertas y dashboards sobre Log Analytics (fuera de este repo).

## Optimización de costos

- Uso de SKUs de desarrollo (por ejemplo Developer para APIM) en entornos no productivos.
- Capacidad de escalar vertical y horizontalmente los recursos según demanda y presupuesto.

## Relación con Azure Well-Architected Framework

- Excelencia operacional: uso de módulos corporativos estandarizados y pipelines centralizados.
- Seguridad: red segmentada, identities, Key Vault, Policy y controles de acceso.
- Confiabilidad: redundancia y separación de responsabilidades entre componentes.
- Eficiencia de rendimiento: diseño orientado a cargas distribuidas y autoscaling.
- Optimización de costos: configuración de SKUs por ambiente y visibilidad de costos vía tags.
