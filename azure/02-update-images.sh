#!/usr/bin/env bash
# Fast redeploy: rolls each app forward to IMAGE_TAG (default: latest).
# Used by the azure-deploy.yml GitHub Actions workflow on every push to
# main, but also runnable locally.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=config.env
source "$HERE/config.env"

for pair in \
  "$APP_DATABASE $IMAGE_DATABASE" \
  "$APP_BACKEND  $IMAGE_BACKEND"  \
  "$APP_FRONTEND $IMAGE_FRONTEND" ; do
  # shellcheck disable=SC2086
  set -- $pair
  APP="$1"; IMG="$2"
  echo ">>> $APP -> $IMG"
  az containerapp update \
    --name "$APP" \
    --resource-group "$AZ_RESOURCE_GROUP" \
    --image "$IMG" \
    --output none
done

FQDN=$(az containerapp show \
  --name "$APP_FRONTEND" \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn -o tsv)
echo ">>> Deploy complete: https://$FQDN"
