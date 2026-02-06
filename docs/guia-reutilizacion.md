# ♻️ Guía de Reutilización de IaC - Plantilla Azure BackEnd

Este repositorio ha sido diseñado como una **plantilla de referencia** (Reference Architecture) para el despliegue de infraestructura BackEnd en Azure. Su estructura modular y parametrizada permite adaptarlo fácilmente para nuevos proyectos o microservicios que requieran una topología similar.

Esta guía detalla los pasos necesarios para reutilizar este código en un nuevo proyecto.

## 📋 Lista de verificación para la adaptación

Para instanciar un nuevo proyecto basado en esta plantilla, siga estos pasos:

1.  [ ] **Clonado del repositorio**: Importar o clonar este repositorio en el nuevo proyecto de Azure DevOps.
2.  [ ] **Limpieza de estado**: Eliminar la carpeta `.terraform` y cualquier archivo de estado local si existen.
3.  [ ] **Configuración del Backend**: Ajustar `envs/backend.tf` (o la configuración de init en pipeline) para apuntar a un nuevo Key para el estado remoto (ej. `nuevo-proyecto.tfstate`).
4.  [ ] **Renombrado de Variables**: Actualizar los valores base en `envs/*.tfvars` o variables de pipeline.
5.  [ ] **Selección de Módulos**: Comentar o eliminar módulos no requeridos en `envs/main.tf`.
6.  [ ] **Ajuste de Pipelines**: Configurar `azure-pipelines.yml` con las nuevas conexiones de servicio y variables.

## 🛠️ Personalización de Parámetros

La personalización principal se realiza a través de las variables definidas en `envs/variables.tf`.

### 1. Identificadores del Proyecto
Modifique las siguientes variables para reflejar la identidad del nuevo servicio:

-   `project_name`: Código corto del proyecto (ej. "CRM", "PAY").
-   `layer_name`: Capa funcional (ej. "BE", "DATA").
-   `environment`: Ambiente destino (se gestiona dinámicamente, pero verifique validaciones).

### 2. Ajuste de Recursos (`main.tf`)
El archivo `envs/main.tf` orquesta todos los módulos. Para personalizar la arquitectura:

-   **Habilitar/Deshabilitar servicios**: Si su proyecto no requiere, por ejemplo, Cosmos DB, simplemente comente o elimine el bloque `module "cosmos_db" { ... }` y sus referencias en `locals.tf`.
-   **Dimensionamiento**: Ajuste los SKUs y capacidades en los archivos de variables (`*.tfvars`) sin modificar el código fuente de los módulos siempre que sea posible.

## 🏗️ Extensión de la Funcionalidad

Si requiere servicios no incluidos en esta plantilla:

1.  Verifique si existe un módulo corporativo aprobado en el repositorio de módulos.
2.  Agregue la referencia al módulo en `envs/main.tf`.
3.  Defina las nuevas variables necesarias en `envs/variables.tf`.
4.  Incorpore los valores por defecto en `envs/terraform.tfvars`.

## 🔄 Integración Continua (CI/CD)

El archivo `azure-pipelines.yml` está preconfigurado para usar plantillas corporativas. Para reutilizarlo:

1.  Asegúrese de que el **Service Connection** de Azure DevOps tenga permisos sobre la suscripción destino del nuevo proyecto.
2.  Verifique que el **Resource Group** del backend de Terraform (donde se guarda el `.tfstate`) sea accesible por el pipeline.
3.  Actualice las variables de pipeline (Library Groups) si su proyecto usa un set diferente de secretos (ej. `kv-nuevo-proyecto-secrets`).

## ⚠️ Puntos de atención

-   **Redes**: Si despliega en una VNet compartida existente, asegúrese de cambiar el enfoque de creación de VNet a "Data Source" o importar la red existente, en lugar de intentar crearla de nuevo.
-   **Nombres globales**: Recursos como Azure Key Vault, ACR y Storage Accounts requieren nombres globalmente únicos. Asegúrese de que la combinación `project_name` + `environment` + sufijos genere nombres únicos.

---
> **Nota**: Mantenga este repositorio sincronizado con el repositorio "madre" de referencia para recibir parches de seguridad y mejoras en la arquitectura base.
