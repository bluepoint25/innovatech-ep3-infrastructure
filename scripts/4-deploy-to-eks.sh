#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}       🚀 DESPLEGAR APLICACIÓN EN EKS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

NAMESPACE="innovatech"
CLUSTER_NAME="innovatech-eks-cluster"
REGION="us-east-1"
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="$AWS_ACCOUNT.dkr.ecr.$REGION.amazonaws.com"

echo -e "${YELLOW}🔧 Configuración:${NC}"
echo "   Cluster: $CLUSTER_NAME"
echo "   Namespace: $NAMESPACE"
echo "   Registry: $ECR_REGISTRY"
echo ""

# Verificar que el cluster existe
echo -e "${YELLOW}🔍 Verificando cluster EKS...${NC}"

if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ No hay conexión a cluster EKS${NC}"
    echo "    Ejecuta primero: ./scripts/1-create-eks-cluster.sh"
    exit 1
fi

echo -e "${GREEN}✅ Cluster accesible${NC}"
echo ""

# Crear namespace
echo -e "${YELLOW}📦 Creando namespace...${NC}"

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✅ Namespace creado${NC}"
echo ""

# Crear ConfigMap para URLs de backends
echo -e "${YELLOW}🔧 Creando ConfigMap con URLs de servicios...${NC}"

kubectl create configmap backend-urls \
  --from-literal=DESPACHOS_URL="http://backend-despachos-service.innovatech.svc.cluster.local:8081" \
  --from-literal=VENTAS_URL="http://backend-ventas-service.innovatech.svc.cluster.local:8082" \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✅ ConfigMap creado${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ CLUSTER LISTO PARA DESPLIEGUE${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}📊 Estado del Cluster:${NC}"
kubectl get nodes
echo ""

echo -e "${YELLOW}📦 Namespaces:${NC}"
kubectl get namespaces
echo ""

echo -e "${YELLOW}⚠️  SIGUIENTE:${NC}"
echo "   Los manifiestos de Kubernetes están en ./kubernetes/"
echo "   Necesitas aplicarlos manualmente con:"
echo "   kubectl apply -f kubernetes/00-namespace.yaml"
echo "   kubectl apply -f kubernetes/01-backend-despachos.yaml"
echo "   kubectl apply -f kubernetes/02-backend-ventas.yaml"
echo "   kubectl apply -f kubernetes/03-frontend.yaml"
echo ""