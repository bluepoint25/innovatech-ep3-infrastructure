# innovatech-ep3-infrastructure
EP3 DevOps - Orquestación con AWS EKS
# EP3 DevOps: Orquestación y Automatización en AWS EKS

**Evaluación Parcial N°3 - Introducción a Herramientas DevOps**  
**DuocUC - Ingeniería en Informática**

## 📌 Quick Start (5 minutos)

```bash
# 1. Validar que todo está listo
chmod +x scripts/*.sh
./scripts/0-validate-setup.sh

# 2. Crear cluster EKS (15-20 minutos)
./scripts/1-create-eks-cluster.sh

# 3. Crear repositorios ECR (2 minutos)
./scripts/2-create-ecr-repos.sh

# 4. Build & Push de imágenes (10 minutos)
./scripts/3-build-and-push.sh

# 5. Desplegar en EKS (5 minutos)
./scripts/4-deploy-to-eks.sh

# 6. Obtener URL pública
kubectl get ingress -n innovatech
```

**Tiempo total: ~45 minutos** ⏱️

## 🏗️ Requisitos

- AWS Academy Learner Lab activo
- AWS CLI configurado
- kubectl instalado
- eksctl instalado
- Docker instalado
- Git

## 🚀 Estructura
scripts/           → Automatización

kubernetes/        → Manifiestos K8s

github-workflows/  → CI/CD

docs/             → Documentación
## 📝 Documentación

Ver `docs/README-EP3.md` para guía completa.