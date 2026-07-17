# TechMarket Orders API - Advanced CI/CD Pipeline

## Overview
Este repositorio contiene la implementación de una arquitectura de microservicios de alta disponibilidad para **TechMarket Orders**. El proyecto se centra en la entrega continua (CD) mediante una estrategia de despliegue **Blue-Green**, diseñada para garantizar cero tiempo de inactividad (*zero-downtime*) y resiliencia ante fallos en el entorno de producción (AWS EKS).

---

## 🚀 Key Engineering Features

*   **Blue-Green Deployment Strategy:** Implementación de conmutación de tráfico dinámica mediante `kubectl patch`, permitiendo despliegues atómicos sin afectar la experiencia del usuario.
*   **Automated Quality Gates:** Implementación de *smoke tests* antes de la conmutación de tráfico. El pipeline valida la integridad del servicio (`/health`) mediante túneles temporales (`port-forwarding`) garantizando que solo versiones funcionales lleguen a producción.
*   **Self-Healing & Rollback:** Mecanismo de reversión automática. Ante cualquier fallo en la validación, el pipeline ejecuta un `rollout undo` inmediato para restaurar la versión estable anterior.
*   **Dynamic Configuration:** Gestión de variables de entorno inyectadas dinámicamente (`DEPLOY_COLOR`) permitiendo que la aplicación se identifique a sí misma según su entorno activo.
*   **Automated Versioning (Lifecycle Management):** Automatización total del ciclo de vida del software mediante *Auto-Tagging* y *Auto-Releases* en cada despliegue exitoso.

---

## 📊 Arquitectura del Despliegue
Este diagrama muestra cómo tu pipeline decide inteligentemente dónde desplegar:

graph TD
    A[Push a Main] --> B{Detectar Color}
    B -- Es Blue --> C[Desplegar en Green]
    B -- Es Green --> D[Desplegar en Blue]
    C --> E[Validacion de Salud]
    D --> E
    E -- Error --> F[Rollback Automatico]
    E -- OK --> G[Switch de Trafico]
    G --> H[Auto-Tag y Release]

---

## 🛠️ Tech Stack
*   **Infrastructure:** AWS EKS, ECR.
*   **Orchestration:** Kubernetes (Deployment, Service, Service-Preview).
*   **CI/CD:** GitHub Actions (Reusable Workflows).
*   **Development:** Node.js (Express.js).
*   **Infrastructure as Code:** YAML Manifests with dynamic templating.

---

## 📦 Versioning & Releases
Este proyecto utiliza un modelo de versionado semántico automatizado:
1.  **Auto-Tagging:** Cada `push` a `main` genera un nuevo tag (ej: `v1.0.X`).
2.  **Auto-Release:** La detección de un nuevo tag dispara la creación automática de una *GitHub Release* con el historial de cambios asociado.

---

## 🚀 Getting Started
Para desplegar este pipeline en tu propio clúster:
1. Configura tus secretos de AWS en GitHub (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, etc.).
2. Asegura que los archivos de `k8s/` tengan los selectores de `version` correctos.
3. El pipeline detectará automáticamente el estado del clúster e iniciará el ciclo Blue-Green.

---
*Developed by Bryan Painemilla | Duoc UC Academic Project 2026*
