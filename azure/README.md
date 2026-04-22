# Azure deployment scripts

Deploys the Vehicle Configurator stack to **Azure Container Apps (ACA)**
using the public Docker images built by the `Publish Docker images`
GitHub Actions workflow. Authentication from GitHub to Azure uses
**OIDC federation** (no long-lived secrets).

## What gets created

| Azure resource | Name (default) | Purpose |
|---|---|---|
| Resource group | `rg-vehicle-configurator` | Container for everything else |
| Log Analytics workspace | `vc-logs` | Required by ACA for container logs |
| Container Apps environment | `vc-env` | Network + DNS boundary for the three apps |
| Container app | `database` | `mysql:8.4` with seed SQL baked in, internal TCP ingress on :3306, `minReplicas=1` |
| Container app | `backend` | Spring Boot, internal HTTP on :8080, scales to zero |
| Container app | `frontend` | nginx serving the Vue build, **external HTTPS** on :80, scales to zero |

App names deliberately match the local compose service names so the
frontend's nginx can keep proxying to `http://backend:8080` and the
backend can keep using `jdbc:mysql://database:3306/...` — the same
images run locally, in Codespaces, and in Azure with no config
changes.

## One-time setup

Prerequisites:

- `az login` to the personal subscription you want to use (confirm with `az account show`).
- `gh auth login` (the `00-bootstrap-oidc.sh` script writes the three GitHub secrets via the `gh` CLI).
- Permission to create AAD app registrations in your tenant (standard on a pay-as-you-go subscription).

Steps:

```bash
./azure/00-bootstrap-oidc.sh     # creates AAD app, grants Contributor on the RG,
                                 # writes AZURE_CLIENT_ID / AZURE_TENANT_ID /
                                 # AZURE_SUBSCRIPTION_ID to GitHub repo secrets.
./azure/01-setup.sh              # creates the RG, Log Analytics, ACA env, 3 apps.
                                 # Prints the public URL at the end.
```

From this point on, every push to `main`:

1. Triggers `Publish Docker images` — builds backend, frontend, database images and pushes them to GHCR.
2. On success, triggers `Deploy to Azure` — runs `02-update-images.sh`, which rolls each container app forward to `:latest`.

## Day-to-day commands

```bash
./azure/02-update-images.sh      # force a redeploy from local shell
./azure/03-teardown.sh           # delete the RG (stops all billing)
```

You can also trigger the deploy workflow manually from the GitHub Actions tab ("Deploy to Azure" → **Run workflow**), which is useful after a teardown + setup when you want to redeploy without pushing a commit.

## Overriding defaults

All tunables live in [`config.env`](./config.env). Override per-run by
exporting variables first, e.g. to deploy to Frankfurt instead:

```bash
AZ_LOCATION=germanywestcentral ./azure/01-setup.sh
```

## Cost

- `frontend` and `backend` scale to zero — ~$0 while idle.
- `database` runs with `minReplicas=1` (MySQL has no HTTP traffic for ACA to use as a scale trigger). 0.5 vCPU + 1 GiB memory running 24/7 costs roughly €10–15 / month in West Europe at the time of writing.
- Log Analytics has a 5 GB / month free grant that this stack does not come close to consuming.

To spend ~zero: run `01-setup.sh` right before a demo, `03-teardown.sh` right after. Each takes 3–5 minutes.

## Debugging

```bash
az containerapp logs show -g rg-vehicle-configurator -n backend  --tail 100 --follow
az containerapp logs show -g rg-vehicle-configurator -n frontend --tail 100 --follow
az containerapp logs show -g rg-vehicle-configurator -n database --tail 100 --follow

az containerapp revision list -g rg-vehicle-configurator -n backend -o table
```

## What this setup does NOT do

- No custom domain / HTTPS certificate (uses the default `*.azurecontainerapps.io` FQDN).
- No persistent database — every cold start of `database` reseeds from `database/init/*.sql`. This is intentional per the demo requirements; swap the `database` app for **Azure Database for MySQL Flexible Server** when you want persistence.
- No network isolation — the environment uses the public profile. For enterprise deployments use `--internal-only` and VNet integration.
