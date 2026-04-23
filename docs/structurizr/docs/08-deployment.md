## Deployment

The system has two deployment environments with the same container
topology. Both are modelled explicitly in `workspace.dsl`.

### Local — Docker Compose

![](embed:LocalDeployment)

Started by:

```bash
cd docker
docker compose up --build
```

| Container | Image / build | Host port | Notes |
|-----------|---------------|-----------|-------|
| `configurator-db` | `mysql:8.4` | 3306 | Bind-mounts `database/init/`, healthcheck `mysqladmin ping`, named volume `db-data`. |
| `configurator-backend` | `docker/backend/Dockerfile` (multi-stage Maven → JRE 25) | 8080 | Waits for `database:service_healthy`. |
| `configurator-frontend` | `docker/frontend/Dockerfile` (stage `dev`) | 5173 | Bind-mounts `../frontend:/app`; Vite dev proxy `/api → backend:8080`. |
| `configurator-structurizr` | `structurizr/lite:latest` | 8000 | Renders this very documentation — see `docs/structurizr/README.md`. |

A second compose file, `docker/compose.prod.yml`, pulls the production
images from GHCR and runs the frontend via the nginx build stage —
useful for smoke-testing the production artefacts locally without
changing the Azure deployment.

### Azure — Container Apps

![](embed:AzureDeployment)

| Azure resource | Name | Purpose |
|----------------|------|---------|
| Resource group | `rg-vehicle-configurator` | Scope for all resources. Lifecycle owned by `azure/01-setup.sh` and `azure/03-teardown.sh`. |
| Log Analytics workspace | `vc-logs` | Collects stdout/stderr from all container apps. |
| Container Apps environment | `vc-env` | Shared VNET + internal DNS (`<app>.internal.<envDefaultDomain>`). |
| Container App `frontend` | External HTTP ingress :80, 0–2 replicas, 0.25 CPU / 0.5 GiB. | nginx + SPA. `BACKEND_UPSTREAM` points at `backend.internal.<envDefaultDomain>`. |
| Container App `backend` | Internal HTTP ingress :8080 (`--allow-insecure`), 0–2 replicas, 0.5 CPU / 1 GiB. | Spring Boot. Not reachable from the public internet. |
| Container App `database` | Internal TCP ingress :3306, **min=max=1** replica, 0.5 CPU / 1 GiB. | Stateful. Persistence is on the replica filesystem — see [ADR-0008](#8-mysql-as-a-container-app). |

Provisioning is driven by four idempotent shell scripts in `azure/`,
configured from `azure/config.env`:

| Script | What it does |
|--------|--------------|
| `00-bootstrap-oidc.sh` | One-off: create the Azure AD app, assign Contributor on the RG, add a GitHub federated credential, push `AZURE_CLIENT_ID/TENANT_ID/SUBSCRIPTION_ID` as repo secrets. |
| `01-setup.sh` | Ensure RG, Log Analytics, environment, and the three container apps (idempotent). |
| `02-update-images.sh` | Force a new revision per app using `az containerapp update --image … --revision-suffix`. Used by CI and locally. |
| `03-teardown.sh` | Prompt to retype the RG name, then `az group delete --no-wait`. Leaves the AAD app + GitHub secrets in place for a future setup. |

### CI/CD

Three workflows in `.github/workflows/`:

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| `ci.yml` | every push / PR to `main` | Maven `verify`, `npm run build`, integration smoke test (compose up `database + backend`, exercise every REST endpoint including `POST /api/configurations → GET → POST /api/orders`). |
| `docker-publish.yml` | push to `main`, tags `v*.*.*`, manual | Matrix build of `backend / frontend / database` images, push to GHCR with `latest`, short SHA, branch, and semver tags. |
| `azure-deploy.yml` | successful `docker-publish` on `main` (or manual) | `azure/login@v2` via **OIDC**, then `bash azure/02-update-images.sh`. Emits the frontend FQDN as a GitHub Actions notice. |
