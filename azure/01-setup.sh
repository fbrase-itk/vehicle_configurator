#!/usr/bin/env bash
# Creates / updates the full ACA stack: resource group, Log Analytics,
# Container Apps environment, and three container apps (database,
# backend, frontend) that pull from the public GHCR images.
#
# Idempotent: re-running will update existing resources.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=config.env
source "$HERE/config.env"

echo ">>> Ensuring az CLI has the containerapp extension"
az extension add --name containerapp --upgrade --only-show-errors --output none

echo ">>> Registering providers (one-time, idempotent)"
for p in Microsoft.OperationalInsights Microsoft.App Microsoft.ContainerRegistry; do
  az provider register --namespace "$p" --only-show-errors --output none || true
done

echo ">>> Resource group: $AZ_RESOURCE_GROUP ($AZ_LOCATION)"
az group create --name "$AZ_RESOURCE_GROUP" --location "$AZ_LOCATION" --output none

echo ">>> Log Analytics workspace: $AZ_LOG_ANALYTICS"
az monitor log-analytics workspace create \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --workspace-name "$AZ_LOG_ANALYTICS" \
  --location "$AZ_LOCATION" \
  --output none 2>/dev/null || echo "    (already exists)"

LAW_ID=$(az monitor log-analytics workspace show \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --workspace-name "$AZ_LOG_ANALYTICS" \
  --query customerId -o tsv)
LAW_KEY=$(az monitor log-analytics workspace get-shared-keys \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --workspace-name "$AZ_LOG_ANALYTICS" \
  --query primarySharedKey -o tsv)

echo ">>> Container Apps environment: $AZ_ENVIRONMENT"
az containerapp env create \
  --name "$AZ_ENVIRONMENT" \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --location "$AZ_LOCATION" \
  --logs-workspace-id "$LAW_ID" \
  --logs-workspace-key "$LAW_KEY" \
  --output none 2>/dev/null || echo "    (already exists)"

# ---------------------------------------------------------------------
# database (internal TCP ingress on :3306, minReplicas=1)
# ---------------------------------------------------------------------
echo ">>> App: $APP_DATABASE"
if ! az containerapp show -g "$AZ_RESOURCE_GROUP" -n "$APP_DATABASE" >/dev/null 2>&1; then
  az containerapp create \
    --name "$APP_DATABASE" \
    --resource-group "$AZ_RESOURCE_GROUP" \
    --environment "$AZ_ENVIRONMENT" \
    --image "$IMAGE_DATABASE" \
    --transport tcp \
    --ingress internal \
    --target-port 3306 \
    --exposed-port 3306 \
    --cpu 0.5 --memory 1.0Gi \
    --min-replicas 1 --max-replicas 1 \
    --secrets \
        mysql-root-password="$MYSQL_ROOT_PASSWORD" \
        mysql-password="$MYSQL_PASSWORD" \
    --env-vars \
        MYSQL_ROOT_PASSWORD=secretref:mysql-root-password \
        MYSQL_DATABASE="$MYSQL_DATABASE" \
        MYSQL_USER="$MYSQL_USER" \
        MYSQL_PASSWORD=secretref:mysql-password \
    --output none
else
  az containerapp update \
    --name "$APP_DATABASE" \
    --resource-group "$AZ_RESOURCE_GROUP" \
    --image "$IMAGE_DATABASE" \
    --output none
fi

# ---------------------------------------------------------------------
# backend (internal HTTP ingress on :8080, scale to zero)
# ---------------------------------------------------------------------
# --allow-insecure: internal ACA traffic stays inside the env, so
# HTTP on :80 is fine. Without this, ACA ingress 301-redirects HTTP
# to HTTPS, which breaks the frontend's nginx reverse proxy.
echo ">>> App: $APP_BACKEND"
if ! az containerapp show -g "$AZ_RESOURCE_GROUP" -n "$APP_BACKEND" >/dev/null 2>&1; then
  az containerapp create \
    --name "$APP_BACKEND" \
    --resource-group "$AZ_RESOURCE_GROUP" \
    --environment "$AZ_ENVIRONMENT" \
    --image "$IMAGE_BACKEND" \
    --transport http \
    --ingress internal \
    --allow-insecure \
    --target-port 8080 \
    --cpu 0.5 --memory 1.0Gi \
    --min-replicas 0 --max-replicas 2 \
    --secrets \
        spring-datasource-password="$MYSQL_PASSWORD" \
    --env-vars \
        SPRING_PROFILES_ACTIVE=docker \
        SERVER_PORT=8080 \
        SPRING_DATASOURCE_URL="jdbc:mysql://${APP_DATABASE}:3306/${MYSQL_DATABASE}?allowPublicKeyRetrieval=true&useSSL=false" \
        SPRING_DATASOURCE_USERNAME="$MYSQL_USER" \
        SPRING_DATASOURCE_PASSWORD=secretref:spring-datasource-password \
    --output none
else
  az containerapp update \
    --name "$APP_BACKEND" \
    --resource-group "$AZ_RESOURCE_GROUP" \
    --image "$IMAGE_BACKEND" \
    --output none
  # Reassert ingress setting on re-runs (idempotent).
  az containerapp ingress update \
    --name "$APP_BACKEND" \
    --resource-group "$AZ_RESOURCE_GROUP" \
    --type internal \
    --allow-insecure \
    --output none
fi

# ---------------------------------------------------------------------
# frontend (EXTERNAL HTTP ingress on :80, scale to zero)
# ---------------------------------------------------------------------
# BACKEND_UPSTREAM is consumed by nginx envsubst inside the frontend
# image. Within an ACA environment, app-to-app HTTP traffic goes
# through the env's ingress on port 80 (NOT the container's target
# port). We use the *full internal FQDN* of the backend app so that
# the nginx-generated Host header (proxy_set_header Host $proxy_host)
# matches what the ACA ingress expects to route to the backend. A
# short name would get 404 "App Unavailable".
ENV_DOMAIN=$(az containerapp env show \
  --name "$AZ_ENVIRONMENT" \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --query properties.defaultDomain -o tsv)
BACKEND_INTERNAL_FQDN="${APP_BACKEND}.internal.${ENV_DOMAIN}"
FRONTEND_ENV_VARS=(
  "BACKEND_UPSTREAM=${BACKEND_INTERNAL_FQDN}"
)

echo ">>> App: $APP_FRONTEND"
if ! az containerapp show -g "$AZ_RESOURCE_GROUP" -n "$APP_FRONTEND" >/dev/null 2>&1; then
  az containerapp create \
    --name "$APP_FRONTEND" \
    --resource-group "$AZ_RESOURCE_GROUP" \
    --environment "$AZ_ENVIRONMENT" \
    --image "$IMAGE_FRONTEND" \
    --transport http \
    --ingress external \
    --target-port 80 \
    --cpu 0.25 --memory 0.5Gi \
    --min-replicas 0 --max-replicas 2 \
    --env-vars "${FRONTEND_ENV_VARS[@]}" \
    --output none
else
  az containerapp update \
    --name "$APP_FRONTEND" \
    --resource-group "$AZ_RESOURCE_GROUP" \
    --image "$IMAGE_FRONTEND" \
    --set-env-vars "${FRONTEND_ENV_VARS[@]}" \
    --output none
fi

FQDN=$(az containerapp show \
  --name "$APP_FRONTEND" \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn -o tsv)

cat <<EOF

>>> Setup complete.

    Public URL:  https://$FQDN

First request may take 10-30 seconds (frontend + backend cold start).
Database stays warm (minReplicas=1) because MySQL cannot scale to zero.

To tear everything down: ./azure/03-teardown.sh
EOF
