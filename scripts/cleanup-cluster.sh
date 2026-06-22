#!/bin/bash
set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo -e "${RED}       ⚠️  DESTRUIR CLUSTER EKS - OPERACIÓN IRREVERSIBLE${NC}"
echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}❌ Esta acción DESTRUIRÁ:${NC}"
echo "   • Cluster EKS"
echo "   • Todos los Pods y Servicios"
echo "   • Nodos EC2 asociados"
echo "   • Load Balancers"
echo ""
echo -e "${YELLOW}⚠️  NO destruirá:${NC}"
echo "   • Imágenes en ECR (reutilizables)"
echo ""

read -p "¿Estás seguro? Escribe 'SI' para confirmar: " CONFIRM

if [ "$CONFIRM" != "SI" ]; then
    echo -e "${YELLOW}❌ Operación cancelada${NC}"
    exit 0
fi

CLUSTER_NAME="innovatech-eks-cluster"
REGION="us-east-1"
NAMESPACE="innovatech"

echo ""
echo -e "${YELLOW}🔧 Configuración:${NC}"
echo "   Cluster: $CLUSTER_NAME"
echo "   Región: $REGION"
echo ""

# Eliminar aplicación del namespace
echo -e "${YELLOW}🗑️  Eliminando aplicación del cluster...${NC}"

aws eks update-kubeconfig \
    --region $REGION \
    --name $CLUSTER_NAME 2>/dev/null || true

if kubectl get namespace $NAMESPACE &>/dev/null; then
    echo "   Eliminando namespace $NAMESPACE..."
    kubectl delete namespace $NAMESPACE --ignore-not-found || true
    
    echo "   ⏳ Esperando eliminación..."
    sleep 10
fi

echo -e "${GREEN}✅ Aplicación eliminada${NC}"
echo ""

# Destruir cluster
echo -e "${RED}💣 DESTRUYENDO CLUSTER EKS...${NC}"
echo "   ⏳ Esto puede tomar 10-15 minutos..."
echo ""

eksctl delete cluster \
    --name $CLUSTER_NAME \
    --region $REGION \
    --force

echo ""
echo -e "${GREEN}✅ Cluster destruido${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ CLUSTER DESTRUIDO EXITOSAMENTE${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${GREEN}💰 COSTOS AHORRADOS:${NC}"
echo "   • EKS Control Plane: \$0.10/hora ✓"
echo "   • 2× nodos t3.small: \$0.03/hora × 2 ✓"
echo ""
echo "   Total ahorrado: ~\$3.84/día de uptime"
echo ""

echo -e "${YELLOW}📝 Imágenes en ECR aún disponibles para reutilizar${NC}"