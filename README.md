# TechMarket Orders API - Advanced CI/CD Pipeline

## 📖 Overview
Arquitectura de microservicios con despliegue de alta disponibilidad en **AWS EKS**. Este proyecto implementa una estrategia de despliegue **Blue-Green** automatizada, diseñada para garantizar cero tiempo de inactividad, resiliencia ante fallos y trazabilidad completa del ciclo de vida del software mediante flujos de trabajo en GitHub Actions.

---

## ⚙️ CI/CD Architecture (Workflows)
Este repositorio gestiona su automatización a través de tres workflows estratégicos ubicados en `.github/workflows/`:

### 1. Reusable EKS Deployment (`eks-deployment.yaml`)
Es el motor de despliegue. Este flujo reutilizable orquesta:
*   **Construcción:** Compila la imagen y la publica en el registro ECR de AWS.
*   **Despliegue Dinámico:** Detecta el entorno activo (Blue o Green) y despliega la nueva versión en el inactivo.
*   **Validación de Salud (Smoke Test):** Ejecuta un túnel `port-forward` temporal desde el clúster hacia el pipeline, garantizando que el endpoint `/health` responde `{"status":"OK"}` antes de la conmutación.
*   **Conmutación y Resiliencia:** Realiza el `patch` del servicio en Kubernetes para redirigir el tráfico. Si la validación falla, ejecuta un `rollout undo` automático, garantizando la estabilidad del sistema.

### 2. Auto-Tagging (`auto-tag.yml`)
Automatiza el versionado semántico del código. Cada vez que se realiza un `push` a la rama `main`, este flujo:
*   Genera un tag único y cronológico basado en el número de ejecución (`v1.0.X`).
*   Asegura la trazabilidad absoluta de las versiones desplegadas en producción.

### 3. Auto-Release (`release.yml`)
Gestiona la publicación oficial. Al detectar un nuevo tag generado por el workflow anterior, este proceso:
*   Crea una GitHub Release automática.
*   Documenta el `sha` del commit y el contexto del despliegue, permitiendo una gestión de lanzamientos auditable y profesional.

---

## 📊 Pipeline Logic
La estrategia de despliegue sigue un flujo lógico de protección:
1. **Identificación:** Se detecta el entorno actual para desplegar en el inactivo.
2. **Despliegue:** Se actualiza la imagen en Kubernetes.
3. **Validación:** Se abre un canal seguro (`port-forward`) para verificar la API en vivo.
4. **Decisión:** 
   - **Éxito:** Se conmuta el tráfico al nuevo entorno.
   - **Fallo:** Se ejecuta un `rollback` inmediato, protegiendo a los usuarios finales.
5. **Cierre:** Se marca el hito con un tag y una release automática.

---

## 🛠️ Tech Stack & Requisitos
*   **Infraestructura:** AWS EKS, ECR.
*   **Orquestación:** Kubernetes (Blue/Green Manifests).
*   **CI/CD:** GitHub Actions (Reusable Workflows).
*   **Desarrollo:** Node.js (Express.js).
*   **Seguridad:** Validación de salud pre-switch con `port-forwarding`.

---
*Developed by [Bryan Painemilla] | Duoc UC Academic Project 2026*