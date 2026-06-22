#!/bin/bash
# Script de validación - verifica que tienes todo instalado

echo "🔍 Verificando requisitos para EP3..."
echo ""

# Verificar AWS CLI
if command -v aws &> /dev/null; then
    echo "✅ AWS CLI instalado"
else
    echo "❌ AWS CLI NO está instalado"
    exit 1
fi

# Verificar kubectl
if command -v kubectl &> /dev/null; then
    echo "✅ kubectl instalado"
else
    echo "❌ kubectl NO está instalado"
    exit 1
fi

# Verificar eksctl
if command -v eksctl &> /dev/null; then
    echo "✅ eksctl instalado"
else
    echo "❌ eksctl NO está instalado"
    exit 1
fi

# Verificar Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker instalado"
else
    echo "❌ Docker NO está instalado"
    exit 1
fi

# Verificar Git
if command -v git &> /dev/null; then
    echo "✅ Git instalado"
else
    echo "❌ Git NO está instalado"
    exit 1
fi

# Verificar credenciales AWS
echo ""
echo "🔐 Verificando credenciales AWS..."
if aws sts get-caller-identity &> /dev/null; then
    ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    echo "✅ Credenciales AWS válidas"
    echo "   Account ID: $ACCOUNT"
else
    echo "❌ Credenciales AWS no configuradas"
    exit 1
fi

echo ""
echo "✅ ¡TODOS LOS REQUISITOS OK!"