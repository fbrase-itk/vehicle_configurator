#!/usr/bin/env bash
# Fast redeploy: rolls each app forward to IMAGE_TAG (default: latest).
# Used by the azure-deploy.yml GitHub Actions workflow on every push to
# main, but also runnable locally.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=config.env
source "$HERE/config.env"

# Compute the backend's full internal FQDN for the frontend's
# BACKEND_UPSTREAM env var. We reassert this on every deploy so the
# value is self-healing in case someone pokes at it manually.
ENV_DOMAIN=$(az containerapp env show \
  --name "$AZ_ENVIRONMENT" \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --query properties.defaultDomain -o tsv)
BACKEND_INTERNAL_FQDN="${APP_BACKEND}.internal.${ENV_DOMAIN}"

for pair in \
  "$APP_DATABASE $IMAGE_DATABASE" \
  "$APP_BACKEND  $IMAGE_BACKEND"  \
  "$APP_FRONTEND $IMAGE_FRONTEND" ; do
  # shellcheck disable=SC2086
  set -- $pair
  APP="$1"; IMG="$2"
  echo ">>> $APP -> $IMG"
  if [ "$APP" = "$APP_FRONTEND" ]; then
    az containerapp update \
      --name "$APP" \
      --resource-group "$AZ_RESOURCE_GROUP" \
      --image "$IMG" \
      --set-env-vars "BACKEND_UPSTREAM=${BACKEND_INTERNAL_FQDN}" \
      --output none
  else
    az containerapp update \
      --name "$APP" \
      --resource-group "$AZ_RESOURCE_GROUP" \
      --image "$IMG" \
      --output none
  fi
done

FQDN=$(az containerapp show \
  --name "$APP_FRONTEND" \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn -o tsv)
echo ">>> Deploy complete: https://$FQDN"
