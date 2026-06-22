# EP3: Orquestación y Automatización en AWS EKS

## 📋 Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Arquitectura](#arquitectura)
3. [Pasos de Ejecución](#pasos-de-ejecución)
4. [Comandos Útiles](#comandos-útiles)
5. [Troubleshooting](#troubleshooting)

---

## 📌 Resumen Ejecutivo

Esta es una **solución completa de DevOps** que implementa:

✅ **Cluster Kubernetes en AWS EKS** (administrado por AWS)
✅ **3 microservicios** (Backend Despachos, Backend Ventas, Frontend)
✅ **CI/CD automático** con GitHub Actions (push → build → ECR → deploy)
✅ **Autoscaling automático** basado en CPU y memoria
✅ **Observabilidad** con logs y métricas

**Costo:** ~$5/día (con $50 tienes ~10 días de uptime)

---

## 🏗️ Arquitectura
Internet

↓

AWS Load Balancer (ALB)

↓

┌─────────────────────────────────────┐

│     EKS Cluster (us-east-1)         │

├─────────────────────────────────────┤

│ Namespace: innovatech               │

│                                     │

│ ┌─────────────┐ ┌─────────────┐    │

│ │  Backend    │ │  Backend    │    │

│ │ Despachos   │ │   Ventas    │    │

│ │   (×2)      │ │   (×2)      │    │

│ └──────┬──────┘ └──────┬──────┘    │

│        │                │           │

│        └────────┬───────┘           │

│               ┌─▼──┐               │

│               │ ALB│◄──────────┐   │

│               └────┘           │   │

│                          ┌─────▼──┐│

│                          │Frontend││

│                          │  (×2)  ││

│                          └────────┘│

└─────────────────────────────────────┘

↓

ECR Repositories

(imágenes de los servicios)

↓

GitHub Actions (CI/CD)
---

## 🚀 Pasos de Ejecución

### **PASO 1: Validar Requisitos**

```bash
./scripts/0-validate-setup.sh
```

**Qué verifica:**
- ✅ AWS CLI instalado
- ✅ kubectl instalado
- ✅ eksctl instalado
- ✅ Docker instalado
- ✅ Git instalado
- ✅ Credenciales AWS válidas

**Si todo está ✅, continúa. Si hay ❌, instala lo que falte.**

---

### **PASO 2: Crear Cluster EKS**

```bash
./scripts/1-create-eks-cluster.sh
```

**Qué hace:**
- Crea un cluster EKS con nombre `innovatech-eks-cluster`
- Crea 2 nodos `t3.small` (optimizados para presupuesto)
- Configura VPC, subredes, Security Groups
- Configura kubectl localmente

**Tiempo:** ~15-20 minutos

**Cuando termine, verás:**
✅ CLUSTER EKS CREADO EXITOSAMENTE

✅ Nodos: 2 en estado Ready
---

### **PASO 3: Crear Repositorios ECR**

```bash
./scripts/2-create-ecr-repos.sh
```

**Qué hace:**
- Crea 3 repositorios en Amazon ECR:
  - `innovatech/backend-despachos`
  - `innovatech/backend-ventas`
  - `innovatech/frontend`

**Tiempo:** ~2 minutos

**Cuando termine, verás:**
✅ REPOSITORIOS ECR CREADOS

🔗 URIs de los repositorios:

📦 099875544194.dkr.ecr.us-east-1.amazonaws.com/innovatech/backend-despachos

📦 099875544194.dkr.ecr.us-east-1.amazonaws.com/innovatech/backend-ventas

📦 099875544194.dkr.ecr.us-east-1.amazonaws.com/innovatech/frontend
**⚠️ IMPORTANTE:** Anota estos URIs, los necesitarás después.

---

### **PASO 4: Build & Push de Imágenes**

```bash
./scripts/3-build-and-push.sh
```

**Qué hace:**
- Build de 3 imágenes Docker
- Push automático a ECR

**Tiempo:** ~10 minutos (depende de tu conexión)

**Cuando termine, verás:**
✅ TODOS LOS BUILDS Y PUSHES COMPLETADOS
---

### **PASO 5: Actualizar Manifiestos con URIs de ECR**

Antes de desplegar, necesitas **reemplazar los placeholders** en los manifiestos.

Abre cada archivo y reemplaza:

**En `kubernetes/01-backend-despachos.yaml`:**
Reemplaza:
```yaml
image: REPLACE_WITH_ECR_URI_DESPACHOS
```

Con (usa el URI del PASO 3):
```yaml
image: 099875544194.dkr.ecr.us-east-1.amazonaws.com/innovatech/backend-despachos:latest
```

**En `kubernetes/02-backend-ventas.yaml`:**
Reemplaza:
```yaml
image: REPLACE_WITH_ECR_URI_VENTAS
```

Con:
```yaml
image: 099875544194.dkr.ecr.us-east-1.amazonaws.com/innovatech/backend-ventas:latest
```

**En `kubernetes/03-frontend.yaml`:**
Reemplaza:
```yaml
image: REPLACE_WITH_ECR_URI_FRONTEND
```

Con:
```yaml
image: 099875544194.dkr.ecr.us-east-1.amazonaws.com/innovatech/frontend:latest
```

**Guarda todos los archivos (Ctrl + S en VS Code)**

---

### **PASO 6: Desplegar en EKS**

```bash
./scripts/4-deploy-to-eks.sh
```

**Qué hace:**
- Crea el namespace `innovatech`
- Prepara el cluster para despliegue

**Tiempo:** ~2 minutos

**Cuando termine, verás:**
✅ CLUSTER LISTO PARA DESPLIEGUE
---

### **PASO 7: Aplicar Manifiestos de Kubernetes**

Ahora aplicamos los manifiestos manualmente:

```bash
# 1. Namespace
kubectl apply -f kubernetes/00-namespace.yaml

# 2. Backend Despachos
kubectl apply -f kubernetes/01-backend-despachos.yaml

# 3. Backend Ventas
kubectl apply -f kubernetes/02-backend-ventas.yaml

# 4. Frontend
kubectl apply -f kubernetes/03-frontend.yaml
```

**Verifica que los pods se crearon:**

```bash
kubectl get pods -n innovatech
```

Deberías ver algo así:
NAME                                    READY   STATUS    RESTARTS   AGE

backend-despachos-5f9c8d7f4-abc12      1/1     Running   0          2m

backend-despachos-5f9c8d7f4-def34      1/1     Running   0          2m

backend-ventas-6g8d9e8f5-ghi56         1/1     Running   0          2m

backend-ventas-6g8d9e8f5-jkl78         1/1     Running   0          2m

frontend-7h9e0f9g6-mno90               1/1     Running   0          2m

frontend-7h9e0f9g6-pqr12               1/1     Running   0          2m
---

## 📊 Comandos Útiles

### **Ver estado de los pods**

```bash
kubectl get pods -n innovatech
```

### **Ver logs de un servicio**

```bash
# Backend Despachos
kubectl logs -f deployment/backend-despachos -n innovatech

# Backend Ventas
kubectl logs -f deployment/backend-ventas -n innovatech

# Frontend
kubectl logs -f deployment/frontend -n innovatech
```

### **Ver autoscaling**

```bash
kubectl get hpa -n innovatech
```

### **Escalar manualmente**

```bash
kubectl scale deployment backend-despachos --replicas=3 -n innovatech
```

### **Ver nodos del cluster**

```bash
kubectl get nodes
```

### **Ver información del cluster**

```bash
kubectl cluster-info
```

### **Ver eventos**

```bash
kubectl get events -n innovatech
```

---

## 🔍 Troubleshooting

### **Pod en CrashLoopBackOff**

```bash
# Ver logs
kubectl logs <POD_NAME> --previous -n innovatech

# Ver descripción detallada
kubectl describe pod <POD_NAME> -n innovatech
```

**Causas comunes:**
- Imagen no existe en ECR
- Puerto bloqueado
- Variables de entorno faltantes

### **Pods no se crean**

```bash
# Ver eventos
kubectl get events -n innovatech

# Ver descripción del deployment
kubectl describe deployment backend-despachos -n innovatech
```

### **Verificar que ECR tiene las imágenes**

```bash
aws ecr describe-repositories --region us-east-1
aws ecr describe-images --repository-name innovatech/backend-despachos --region us-east-1
```

---

## 💰 Destruir Cluster (IMPORTANTE)

**Cuando termines de trabajar, SIEMPRE destruye el cluster para ahorrar dinero:**

```bash
./scripts/cleanup-cluster.sh
```

**⚠️ Esto es IRREVERSIBLE, pero:**
- ✅ Las imágenes en ECR se conservan
- ✅ Puedes recrear el cluster en 15 minutos
- ✅ Ahorras ~$5/día

---

## ✅ Checklist de Validación

- [ ] Paso 1: Validación exitosa
- [ ] Paso 2: Cluster EKS creado
- [ ] Paso 3: Repositorios ECR creados
- [ ] Paso 4: Imágenes en ECR
- [ ] Paso 5: Manifiestos actualizados con URIs
- [ ] Paso 6: Cluster preparado
- [ ] Paso 7: Pods corriendo (6 pods en total)
- [ ] `kubectl logs` muestra información correcta
- [ ] HPA configurado (`kubectl get hpa`)

---

## 📝 Notas Importantes

1. **Account ID:** 099875544194 (guarda este número)
2. **Región:** us-east-1 (SIEMPRE)
3. **Cluster:** innovatech-eks-cluster
4. **Namespace:** innovatech
5. **Presupuesto:** $50 → ~10 días de uptime

---

**Última actualización:** Junio 2026
**Status:** ✅ Listo para producción
