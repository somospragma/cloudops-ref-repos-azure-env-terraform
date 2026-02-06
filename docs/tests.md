# 🧪 Pruebas y Validaciones - Nova BackEnd

La validación de la IaC de Nova BackEnd se realiza principalmente a través de la plantilla corporativa de pipeline mercantil-pipeline-template-IAC.

## Validaciones de Terraform

- terraform init: validación de backend y proveedores.
- terraform validate: validación de sintaxis, tipos y dependencias básicas.
- terraform plan: evaluación de cambios propuestos antes de aplicar.

Estas acciones se ejecutan en el pipeline, no manualmente en entornos compartidos.

## Validaciones de seguridad y cumplimiento

Dependiendo de la configuración de la plantilla corporativa, se incluyen pasos como:

- Escaneo de seguridad de IaC (por ejemplo, herramientas tipo Checkov).
- Linter de Terraform (TFLint) para buenas prácticas y estilo.
- Validaciones OPA / Policy-as-Code para cumplimiento de lineamientos internos.

## Validaciones de costos

- Estimaciones de costos mediante herramientas como Infracost (según configuración del pipeline corporativo).
- Revisión de impacto económico antes de aprobar despliegues a QA/PRD.

## Aprobaciones manuales

- Los despliegues a QA y PRD deben contar con aprobación manual previa.
- Se recomienda que las aprobaciones incluyan áreas de Arquitectura, Seguridad y Dueños de Servicio.

## Buenas prácticas adicionales

- Probar primero cualquier cambio en DEV antes de promoverlo a QA/PRD.
- Mantener los archives *.tfvars bajo control de versión y revisados por pares.
- Evitar cambios manuales en el portal de Azure que rompan el estado de Terraform.
