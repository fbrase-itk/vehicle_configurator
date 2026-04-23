## Operation and Support

### Observability

- **Backend logs:** Spring Boot default logback pattern to stdout. In
  Azure, collected by Log Analytics workspace `vc-logs` attached to the
  `vc-env` container-apps environment.
- **Frontend / nginx logs:** nginx access + error logs to stdout;
  same Log Analytics sink.
- **Database logs:** MySQL error log to stdout.
- **No metrics / tracing / APM** today — see risk R-06 in
  [`../arc42/11-risks-and-technical-debt.md`](../../arc42/11-risks-and-technical-debt.md).

### Runbooks

#### Deploy a new version

Normally automatic:

1. Merge a PR to `main`.
2. `docker-publish.yml` builds and pushes `:latest` + `:sha-<short>`
   images to GHCR.
3. On success, `azure-deploy.yml` triggers and runs
   `azure/02-update-images.sh`, which calls `az containerapp update` on
   each of the three apps with a fresh `--revision-suffix`, forcing a
   pull and a new revision.

Manual (from a laptop):

```bash
cd azure
./02-update-images.sh
```

#### Roll back

`02-update-images.sh` pulls `:latest`. For a targeted rollback, deactivate
the bad revision in the Azure portal or via CLI, which will route traffic
back to the previous revision (ACA keeps a revision history).

A better long-term fix: pin `latest` only for convenience and always
deploy by explicit SHA tags (see risk R-10).

#### Database maintenance

Because MySQL runs as a container app on ephemeral storage
([ADR-0008](#8-mysql-as-a-container-app)), **replica recycling wipes
data**. For anything beyond the prototype, plan to migrate to Azure
Database for MySQL Flexible Server.

Backing up today means `mysqldump` against the internal FQDN from a
container in the same ACA environment, or accepting that data is
transient.

#### Tear everything down

```bash
cd azure
./03-teardown.sh
# (prompts for confirmation — retype the RG name)
```

This deletes the resource group entirely. The AAD app registration and
the GitHub repo secrets are deliberately kept so `01-setup.sh` can
recreate the environment later.

### Security posture (prototype level)

- Only the frontend has public ingress. Backend and database are
  internal-only on Azure.
- No stored long-lived Azure credentials — CI/CD authenticates via
  OIDC federation scoped to `refs/heads/main`
  ([ADR-0009](#9-oidc-federation-from-github-to-azure)).
- CORS is wide open (`@CrossOrigin(origins="*")`) for dev convenience;
  because the backend has no public ingress in Azure, the real attack
  surface is limited to local dev. See risk R-01.
- No authentication / authorization — do not ship to real users.
