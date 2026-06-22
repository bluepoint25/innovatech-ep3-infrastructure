#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}       🐳 BUILD & PUSH MANUAL A ECR${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

REGION="us-east-1"
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="$AWS_ACCOUNT.dkr.ecr.$REGION.amazonaws.com"

echo -e "${YELLOW}🔧 Configuración:${NC}"
echo "   Region: $REGION"
echo "   Account: $AWS_ACCOUNT"
echo "   Registry: $ECR_REGISTRY"
echo ""

echo -e "${YELLOW}🔐 Login en ECR...${NC}"

aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $ECR_REGISTRY

echo -e "${GREEN}✅ Login exitoso${NC}"
echo ""

# Verificar que los repositorios existen localmente
echo -e "${YELLOW}🔍 Buscando repositorios locales...${NC}"

# Cambia estas rutas si tus repos están en otro lugar
REPO_BACK_DESPACHOS="../../back-despachos"
REPO_BACK_VENTAS="../../back-Ventas"
REPO_FRONT="../../front_despacho"

if [ ! -d "$REPO_BACK_DESPACHOS" ]; then
    echo -e "${RED}❌ No encontrado: $REPO_BACK_DESPACHOS${NC}"
    echo "   Verifica la ruta o clona: git clone https://github.com/bluepoint25/back-despachos.git"
    exit 1
fi

if [ ! -d "$REPO_BACK_VENTAS" ]; then
    echo -e "${RED}❌ No encontrado: $REPO_BACK_VENTAS${NC}"
    echo "   Verifica la ruta o clona: git clone https://github.com/bluepoint25/back-Ventas.git"
    exit 1
fi

if [ ! -d "$REPO_FRONT" ]; then
    echo -e "${RED}❌ No encontrado: $REPO_FRONT${NC}"
    echo "   Verifica la ruta o clona: git clone https://github.com/bluepoint25/front_despacho.git"
    exit 1
fi

echo -e "${GREEN}✅ Todos los repositorios encontrados${NC}"
echo ""

# Build Backend Despachos
echo -e "${YELLOW}⏳ Build: Backend Despachos${NC}"

cd "$REPO_BACK_DESPACHOS"

docker build \
  -t innovatech/backend-despachos:latest \
  -f Dockerfile .

echo -e "${GREEN}✅ Build completado: Backend Despachos${NC}"

# Push Backend Despachos
echo -e "${YELLOW}📤 Push: Backend Despachos${NC}"

docker tag innovatech/backend-despachos:latest \
  $ECR_REGISTRY/innovatech/backend-despachos:latest

docker push $ECR_REGISTRY/innovatech/backend-despachos:latest

echo -e "${GREEN}✅ Push completado${NC}"
echo ""

# Build Backend Ventas
echo -e "${YELLOW}⏳ Build: Backend Ventas${NC}"

cd "$REPO_BACK_VENTAS"

docker build \
  -t innovatech/backend-ventas:latest \
  -f Dockerfile .

echo -e "${GREEN}✅ Build completado: Backend Ventas${NC}"

# Push Backend Ventas
echo -e "${YELLOW}📤 Push: Backend Ventas${NC}"

docker tag innovatech/backend-ventas:latest \
  $ECR_REGISTRY/innovatech/backend-ventas:latest

docker push $ECR_REGISTRY/innovatech/backend-ventas:latest

echo -e "${GREEN}✅ Push completado${NC}"
echo ""

# Build Frontend
echo -e "${YELLOW}⏳ Build: Frontend${NC}"

cd "$REPO_FRONT"

docker build \
  -t innovatech/frontend:latest \
  -f Dockerfile \
  --build-arg VITE_API_DESPACHOS_URL="http://backend-despachos-service.innovatech.svc.cluster.local:8081" \
  --build-arg VITE_API_VENTAS_URL="http://backend-ventas-service.innovatech.svc.cluster.local:8082" \
  .

echo -e "${GREEN}✅ Build completado: Frontend${NC}"

# Push Frontend
echo -e "${YELLOW}📤 Push: Frontend${NC}"

docker tag innovatech/frontend:latest \
  $ECR_REGISTRY/innovatech/frontend:latest

docker push $ECR_REGISTRY/innovatech/frontend:latest

echo -e "${GREEN}✅ Push completado${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ TODOS LOS BUILDS Y PUSHES COMPLETADOS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}✅ Próximo paso: ./scripts/4-deploy-to-eks.sh${NC}"

