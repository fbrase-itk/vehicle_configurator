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

# Force a new revision on every run.
#
# `az containerapp update --image ...:latest` is a no-op when every
# template field is textually identical to the current revision - even
# if the :latest tag on GHCR now points to a different image digest.
# ACA only re-pulls when *something* in the template changes. Without
# this, a rebuild that only changes the image contents (e.g. a CSS-only
# frontend change) silently fails to roll out.
#
# Passing a unique --revision-suffix guarantees a new revision name,
# which forces ACA to pull the current :latest. In CI we use the short
# commit SHA so the revision name is traceable back to a git commit;
# locally we fall back to a timestamp.
if [ -n "${GITHUB_SHA:-}" ]; then
  REV_SUFFIX="sha-${GITHUB_SHA:0:7}"
else
  REV_SUFFIX="r$(date +%Y%m%d-%H%M%S)"
fi
echo ">>> Revision suffix: $REV_SUFFIX"

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
      --revision-suffix "$REV_SUFFIX" \
      --set-env-vars "BACKEND_UPSTREAM=${BACKEND_INTERNAL_FQDN}" \
      --output none
  else
    az containerapp update \
      --name "$APP" \
      --resource-group "$AZ_RESOURCE_GROUP" \
      --image "$IMG" \
      --revision-suffix "$REV_SUFFIX" \
      --output none
  fi
done

FQDN=$(az containerapp show \
  --name "$APP_FRONTEND" \
  --resource-group "$AZ_RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn -o tsv)
echo ">>> Deploy complete: https://$FQDN"
