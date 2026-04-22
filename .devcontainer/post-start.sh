#!/usr/bin/env bash
# Boots the Vehicle Configurator stack from the published GHCR images and
# waits until the backend is responding before returning. Runs on every
# Codespace start (postStartCommand), so it is safe to re-run.
set -euo pipefail

COMPOSE_FILE="docker/compose.prod.yml"

echo ">>> Pulling latest images (fast if already cached)"
docker compose -f "$COMPOSE_FILE" pull --quiet || true

echo ">>> Starting database, backend, frontend"
docker compose -f "$COMPOSE_FILE" up -d

echo ">>> Waiting for backend to become ready on :8080 ..."
for i in $(seq 1 30); do
  if curl -sf http://localhost:8080/api/options > /dev/null; then
    echo ">>> Backend is ready."
    break
  fi
  sleep 3
  if [ "$i" -eq 30 ]; then
    echo ">>> Backend did not become ready in 90s. Recent logs:"
    docker compose -f "$COMPOSE_FILE" logs --tail=50 backend || true
  fi
done

echo ">>> Stack status:"
docker compose -f "$COMPOSE_FILE" ps

cat <<'EOF'

-------------------------------------------------------------------
Vehicle Configurator is up. In the "Ports" tab of VS Code, open the
forwarded URL for port 5173 ("Frontend (Vue + nginx)") in a browser.

Port 5173 is configured as PUBLIC so you can share that URL with an
external reviewer. If your organisation restricts public ports, the
visibility will silently fall back to "private" (GitHub login required
to open the URL).

Useful commands:
  docker compose -f docker/compose.prod.yml ps      # status
  docker compose -f docker/compose.prod.yml logs -f # tail logs
  docker compose -f docker/compose.prod.yml down    # stop stack
-------------------------------------------------------------------
EOF
