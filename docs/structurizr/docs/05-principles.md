## Principles

The handful of recurring design rules that explain *why* the code looks
the way it does.

### Dev/prod parity through containers

All three runtime services — frontend, backend, database — run as
containers locally (`docker/compose.yml`) and in Azure
(`docker/compose.prod.yml` pulls the same GHCR images; ACA runs them
directly). The *only* thing that changes between environments is a
single env var: the frontend's `BACKEND_UPSTREAM` (pointing at
`backend:8080` locally, `backend.internal.<envDefaultDomain>` on ACA).

### Single aggregated catalog endpoint

`GET /api/options` returns the full option catalog in one response.
Property changes in the UI are then pure in-memory operations against
that reactive state. This is the cheapest way to hit the "live feel"
quality goal. See [ADR-0005](#5-aggregated-api-options-endpoint).

### Server-authoritative pricing

`ConfiguratorService.calculateTotalPrice()` is the single source of
truth. The client-side running total is for *display*; the persisted
`orders.total_price` is re-computed server-side at submission time, so
a tampered client cannot store a fake total.

### Schema lives in SQL, not in code

Hibernate is configured with `spring.jpa.hibernate.ddl-auto=none`.
All DDL and seed data live in `database/init/001-init.sql`, are
reviewable as SQL, and are re-applied predictably on every fresh
database container. See [ADR-0004](#4-schema-in-sql-not-hibernate).

### Three.js scene is built once, mutated always

`CarPreview3D.vue` loads the GLB and HDR environment on mount and
*never* reloads them. Subsequent prop changes mutate materials or
toggle mesh `visible` flags. This is what keeps option changes snappy.
See [ADR-0006](#6-threejs-with-in-place-material-updates).

### One theme file

Every color / gradient is declared in the `:root` block of
`frontend/src/App.vue`. No component stylesheet contains a hex code.
Rebranding is therefore a one-file edit.

### No secrets in the repo

The only credentials needed by CI/CD are Azure client / tenant /
subscription **IDs** (non-secret identifiers). Actual access is via
OIDC federation scoped to `refs/heads/main`. See
[ADR-0009](#9-oidc-federation-from-github-to-azure).
