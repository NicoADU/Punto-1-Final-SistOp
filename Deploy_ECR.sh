#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────
# CONFIGURACIÓN — edita estas variables
# ─────────────────────────────────────────────
AWS_REGION="us-east-2"                   # Región de AWS
AWS_ACCOUNT_ID="724822233655"            # Tu Account ID de AWS
ECR_REPOSITORY="lambda-final"         # Nombre del repositorio en ECR
IMAGE_TAG="latest"
DOCKERFILE_PATH="."                      # Directorio donde está el Dockerfile
# ─────────────────────────────────────────────

ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_IMAGE_NAME="${ECR_URI}/${ECR_REPOSITORY}:${IMAGE_TAG}"

echo "==========================================="
echo " Deploy a Amazon ECR"
echo "==========================================="
echo "  Región      : ${AWS_REGION}"
echo "  Account ID  : ${AWS_ACCOUNT_ID}"
echo "  Repositorio : ${ECR_REPOSITORY}"
echo "  Imagen      : ${FULL_IMAGE_NAME}"
echo "==========================================="

# 1. Autenticación en ECR
echo ""
echo "[1/4] Autenticando en Amazon ECR..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${ECR_URI}"
echo "      ✔ Autenticación exitosa"

# 2. Crear el repositorio si no existe
echo ""
echo "[2/4] Verificando repositorio ECR..."
aws ecr describe-repositories \
  --repository-names "${ECR_REPOSITORY}" \
  --region "${AWS_REGION}" > /dev/null 2>&1 \
|| aws ecr create-repository \
  --repository-name "${ECR_REPOSITORY}" \
  --region "${AWS_REGION}" > /dev/null
echo "      ✔ Repositorio listo: ${ECR_REPOSITORY}"

# 3. Build de la imagen
echo ""
echo "[3/4] Construyendo la imagen Docker..."
docker build \
  --platform linux/amd64 \
  -t "${ECR_REPOSITORY}:${IMAGE_TAG}" \
  "${DOCKERFILE_PATH}"
echo "      ✔ Imagen construida: ${ECR_REPOSITORY}:${IMAGE_TAG}"

# 4. Tag y Push
echo ""
echo "[4/4] Etiquetando y subiendo imagen a ECR..."
docker tag "${ECR_REPOSITORY}:${IMAGE_TAG}" "${FULL_IMAGE_NAME}"
docker push "${FULL_IMAGE_NAME}"
echo "      ✔ Imagen publicada: ${FULL_IMAGE_NAME}"

echo ""
echo "==========================================="
echo " ✅ Deploy completado exitosamente"
echo "==========================================="