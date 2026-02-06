# ❓ Preguntas Frecuentes (FAQ) - Nova BackEnd

## ¿Puedo ejecutar terraform apply desde mi máquina local?

No. Las ejecuciones oficiales de terraform plan y terraform apply deben hacerse exclusivamente a través de los pipelines de Azure DevOps que utilizan la plantilla corporativa de IAC.

## ¿Dónde defino los valores específicos por ambiente?

En los archivos dev.tfvars, qa.tfvars y prod.tfvars dentro de la carpeta envs. Estos archivos parametrizan SKUs, tamaños, flags de seguridad y otros detalles de configuración.

## ¿Dónde se deben almacenar los secretos?

Los secretos (passwords, connection strings, certificados, etc.) deben almacenarse en Azure Key Vault o en grupos de variables seguros de Azure DevOps. No deben guardarse en *.tfvars ni en el código Terraform.

## ¿Cómo se controla el acceso a la infraestructura?

El acceso se controla mediante permisos en Azure (RBAC) y en Azure DevOps, además de las policies de red (NSG, UDR, Private Endpoints). Las identidades gestionadas se usan para que los servicios accedan a recursos sin credenciales en texto plano.

## ¿Qué hago si el plan muestra cambios inesperados?

- Revisar cuidadosamente el dif del plan en el pipeline.
- Verificar si hubo cambios manuales en el portal que no estén reflejados en el código.
- Corregir el código o revertir cambios manuales antes de aprobar el apply.

## ¿Cómo agrego un nuevo recurso o módulo?

- Revisar primero si existe un módulo corporativo en nova-digital-infraestructure-core-tf que cubra la necesidad.
- Implementar la llamada al módulo en main.tf y, si aplica, agregar variables y locals asociados.
- Probar el cambio en DEV y seguir el flujo habitual de promoción.

## ¿Qué pasa si necesito cambiar el naming de un recurso?

Cambios de naming suelen implicar recreación de recursos. Se recomienda:

- Evaluar impacto (borrado de datos, downtime, etc.).
- Planear una estrategia de migración (por ejemplo, recursos paralelos y corte controlado).
- Coordinar con Arquitectura y Operaciones antes de aplicar en QA/PRD.
