#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}       📦 CREANDO REPOSITORIOS EN AMAZON ECR${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

REGION="us-east-1"
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO_DESPACHOS="innovatech/backend-despachos"
ECR_REPO_VENTAS="innovatech/backend-ventas"
ECR_REPO_FRONTEND="innovatech/frontend"

REPOS=($ECR_REPO_DESPACHOS $ECR_REPO_VENTAS $ECR_REPO_FRONTEND)

echo -e "${YELLOW}📍 Región: $REGION${NC}"
echo -e "${YELLOW}👤 Account: $AWS_ACCOUNT${NC}"
echo ""

echo -e "${YELLOW}⏳ Creando repositorios ECR...${NC}"

for REPO in "${REPOS[@]}"; do
    echo ""
    echo -e "${YELLOW}📦 Creando: $REPO${NC}"
    
    if aws ecr describe-repositories \
        --repository-names "$REPO" \
        --region $REGION &> /dev/null; then
        echo -e "${YELLOW}⚠️  Repositorio ya existe: $REPO${NC}"
    else
        aws ecr create-repository \
            --repository-name "$REPO" \
            --region $REGION \
            --image-tag-mutability IMMUTABLE \
            --image-scanning-configuration scanOnPush=true
        
        echo -e "${GREEN}✅ Repositorio creado: $REPO${NC}"
    fi
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ REPOSITORIOS ECR CREADOS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}🔗 URIs de los repositorios:${NC}"

for REPO in "${REPOS[@]}"; do
    ECR_URI="$AWS_ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$REPO"
    echo "   📦 $ECR_URI"
done

echo ""
echo -e "${YELLOW}🔐 Para hacer login en ECR desde Docker:${NC}"
echo ""
echo "   aws ecr get-login-password --region $REGION | \\"
echo "   docker login --username AWS --password-stdin $AWS_ACCOUNT.dkr.ecr.$REGION.amazonaws.com"
echo ""

echo -e "${YELLOW}✅ Próximo paso: ./scripts/3-build-and-push.sh${NC}"