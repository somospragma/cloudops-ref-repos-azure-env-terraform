# ⚙️ Instalación y Prerequisitos - Nova BackEnd

Este documento describe los prerequisitos para trabajar con la IaC de Nova BackEnd. La ejecución oficial de despliegues se realiza siempre mediante pipelines de Azure DevOps.

## Prerequisitos para trabajo local (solo lectura y validación)

- Acceso a la suscripción de Azure correspondiente (lectura al menos).
- `az` CLI instalado y autenticado (az login) si se requiere consulta de recursos.
- Terraform instalado (versión >= 1.14.0).
- Acceso al repositorio de módulos corporativos en Azure DevOps.

> Importante: la ejecución de terraform apply hacia entornos compartidos (DEV/QA/PRD) debe hacerse exclusivamente a través de los pipelines corporativos.

## Estructura mínima para comandos locales

Para inspección y validaciones puntuales (por ejemplo terraform validate) se recomienda:

1. Clonar el repositorio.
2. Posicionarse en la carpeta del ambiente deseado, por ejemplo envs/dev.
3. Verificar que el backend remoto esté correctamente configurado por variables de entorno o configuración corporativa.

Ejemplo de comandos locales seguros (solo validación):

```bash
# Desde envs/dev
terraform init -backend=false
terraform validate
```

No ejecutar terraform plan / terraform apply contra el backend real fuera del pipeline.

## Variables sensibles

- No se deben versionar secretos en los archivos *.tfvars.
- Los secretos (passwords, connection strings, certificados) deben obtenerse desde Azure Key Vault o grupos de variables seguros en Azure DevOps.

## Integración con pipelines

- El archivo azure-pipelines.yml en la raíz del repositorio referencia la plantilla corporativa mercantil-pipeline-template-IAC.
- Los parámetros de entorno (dev/qa/prod) se pasan al pipeline mediante variables y/o plantillas definidas a nivel organizacional.

Para más detalles, consultar despliegue-ci-cd.md.
