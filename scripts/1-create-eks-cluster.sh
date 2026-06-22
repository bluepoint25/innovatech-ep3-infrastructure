#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}       🚀 CREANDO CLUSTER EKS PARA EP3${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

# Variables
CLUSTER_NAME="innovatech-eks-cluster"
REGION="us-east-1"
NODEGROUP_NAME="innovatech-nodegroup"
NODE_TYPE="t3.small"
DESIRED_NODES=2
MIN_NODES=1
MAX_NODES=4

echo -e "${YELLOW}📋 CONFIGURACIÓN:${NC}"
echo "   Cluster: $CLUSTER_NAME"
echo "   Región: $REGION"
echo "   Node Type: $NODE_TYPE"
echo "   Nodos: $DESIRED_NODES"
echo ""

# Verificar credenciales AWS
echo -e "${YELLOW}🔐 Verificando credenciales AWS...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Credenciales AWS no válidas"
    exit 1
fi
echo -e "${GREEN}✅ Credenciales OK${NC}"
echo ""

# Crear cluster
echo -e "${YELLOW}⏳ Creando cluster EKS (esto toma ~15-20 minutos)...${NC}"

eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --nodegroup-name $NODEGROUP_NAME \
  --node-type $NODE_TYPE \
  --nodes $DESIRED_NODES \
  --nodes-min $MIN_NODES \
  --nodes-max $MAX_NODES \
  --with-oidc \
  --enable-ssm

# Configurar kubectl
echo -e "${YELLOW}🔧 Configurando kubectl...${NC}"
aws eks update-kubeconfig \
  --region $REGION \
  --name $CLUSTER_NAME

echo ""
echo -e "${GREEN}✅ CLUSTER EKS CREADO EXITOSAMENTE${NC}"
echo ""
echo -e "${YELLOW}Información del Cluster:${NC}"
kubectl cluster-info
echo ""
echo -e "${YELLOW}Nodos activos:${NC}"
kubectl get nodes
echo ""
echo -e "${YELLOW}✅ Próximo paso: ./scripts/2-create-ecr-repos.sh${NC}"