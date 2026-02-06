# 🏗️ IaC BackEnd - Nova Digital

Este repositorio contiene la infraestructura como código (IaC) de la capa **BackEnd** de **Nova Digital**, desplegada en Microsoft Azure mediante **Terraform** y **Azure DevOps Pipelines**, siguiendo los lineamientos de seguridad corporativos del banco y el Azure Well-Architected Framework.

## 📚 Documentación

- **[📖 Índice general](docs/index.md)** – Navegación completa de la documentación.
- **[📂 Estructura de directorios](docs/estructura-directorios.md)** – Organización del repositorio y ambientes.
- **[🏗️ Arquitectura BackEnd](docs/arquitectura-backend.md)** – Componentes y dominios de la solución.
- **[🧰 Tecnologías y componentes](docs/tecnologias.md)** – Stack técnico y módulos corporativos.- [♻️ Guía de Reutilización de IaC](docs/guia-reutilizacion.md) – Guía para adaptar esta plantilla a nuevos proyectos.- **[🚀 Despliegue CI/CD](docs/despliegue-ci-cd.md)** – Flujo de pipeline y gobierno de despliegues.
- **[🔐 Seguridad y cumplimiento](docs/seguridad.md)** – Controles de seguridad y alineamiento corporativo.
- **[🌐 Redes y conectividad](docs/redes-conectividad.md)** – VNet, subredes, NSG, UDR y DNS privado.
- **[💾 Datos y almacenamiento](docs/datos-almacenamiento.md)** – SQL, Cosmos, Redis, Storage y Service Bus.
- **[📈 Observabilidad y operación](docs/observabilidad-operacion.md)** – Log Analytics y diagnósticos.
- **[📊 Parámetros de la IaC](docs/parametros-iac.md)** – Tablas de parámetros por componente.
- **[🧪 Pruebas y validaciones](docs/tests.md)** – Validaciones de Terraform, seguridad y costos.
- **[💡 Consideraciones de diseño](docs/consideraciones.md)** – Decisiones de arquitectura y relación con WAF.
- **[❓ Preguntas frecuentes](docs/faq.md)** – Uso diario, buenas prácticas y troubleshooting.
- **[📄 Licencia](docs/licencia.md)** – Uso interno y restricciones.

## 🚀 Flujo de despliegue (resumen)

```bash
terraform init
terraform plan
terraform apply
