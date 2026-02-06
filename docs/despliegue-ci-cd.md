# 🚀 Despliegue CI/CD - Nova BackEnd

Este documento describe el flujo de CI/CD para la infraestructura BackEnd de Nova Digital utilizando **Azure DevOps Pipelines** y la plantilla corporativa de IAC.

## 🧩 Estructura del pipeline

- Archivo [azure-pipelines.yml](../azure-pipelines.yml):
  - Define el `trigger` sobre ramas `main`, `develop` y `release`.  
  - Extiende la plantilla corporativa `main.yml` desde el repositorio `mercantil-pipeline-template-IAC`:

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

- La lógica de etapas (build, validaciones, plan/apply) reside en la plantilla corporativa, lo que garantiza consistencia y cumplimiento en todos los proyectos de infraestructura del banco.

## 🔄 Flujo general CI/CD (alto nivel)

> Nota: el detalle exacto puede variar según la versión de la plantilla corporativa, pero usualmente incluye pasos como los siguientes.

### CI – Validación y plan

1. Checkout del código y limpieza del workspace.  
2. Obtención de secretos y parámetros desde Key Vault / grupos de variables.  
3. Instalación de herramientas de infraestructura (Terraform, linters, escáneres de seguridad).  
4. Validaciones de seguridad (por ejemplo, Checkov, TFLint, OPA baseline) siguiendo las políticas corporativas.  
5. `terraform init` contra el backend remoto configurado (Storage Account corporativa).  
6. `terraform validate` para validar sintaxis y tipos.  
7. `terraform plan` para generar el plan de cambios de infraestructura.  
8. Publicación del plan como artefacto y, opcionalmente, generación de reportes de costos (Infracost) y seguridad.

### CD – Aplicación de cambios

1. Espera de **aprobaciones manuales** según ambiente (por ejemplo, Arquitectura / Seguridad / Dueño de servicio).  
2. Descarga del artefacto con el `terraform plan` validado.  
3. `terraform init` en el contexto de ejecución de CD.  
4. Revisión del plan (opcional) en logs del pipeline.  
5. `terraform apply` utilizando el plan aprobado.  
6. Publicación de outputs relevantes (endpoints, nombres de recursos, etc.).

## 🔐 Gobierno de despliegues

- **Política corporativa**:  
  - Todas las ejecuciones de `terraform plan` / `terraform apply` deben realizarse **exclusivamente** a través del pipeline de Azure DevOps.  
  - No se permite la ejecución directa de `terraform apply` desde equipos locales contra entornos compartidos.

- **Aprobaciones**:  
  - El paso de QA y PRD debe estar protegido con aprobaciones manuales y, si aplica, gates automáticos de seguridad/costos.

- **Promoción de cambios**:  
  - Flujo recomendado: **DEV → QA → PRD**.  
  - Los cambios se validan primero en DEV; una vez aprobados, se promueven a QA y luego a PRD, reutilizando la misma base de código pero con distintos `*.tfvars`.

## 🧮 Relación con WAF

- **Excelencia Operacional**: uso de pipelines estandarizados, versionados y revisables.  
- **Seguridad**: integración con escáneres de seguridad y políticas corporativas, uso de Key Vault para secretos.  
- **Confiabilidad**: uso de `plan` + aprobaciones antes de `apply`.  
- **Optimización de Costos**: integración con herramientas de estimación de costos donde aplique.
