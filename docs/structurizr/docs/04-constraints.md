## Constraints

### From the PRD

- Frontend in **Vue.js, React, or Angular** — chose Vue 3 +
  Vite ([ADR-0001](#1-vue-3--vite-as-frontend-stack)).
- Backend services in **Java** — chose Spring Boot 4 on Java 25
  ([ADR-0002](#2-spring-boot-4-on-java-25)).
- Operated via **Docker Compose** — all runtime components (and this
  very documentation tool) are containerized.
- Data **persisted in a database** — MySQL 8.4 with DDL versioned as a
  SQL init script ([ADR-0004](#4-schema-in-sql-not-hibernate)).
- **No authentication / authorization** — zero security code.

### From the target environment

- **Monorepo** layout mandated in the PRD
  (`backend/`, `frontend/`, `database/`, `docker/`, `docs/`, `azure/`).
- **Cloud target: Azure (West Europe)** — resource group
  `rg-vehicle-configurator`, runtime Azure Container Apps
  ([ADR-0007](#7-azure-container-apps)).
- Deployment must be **scriptable** from a laptop with zero portal
  clicking — implemented via `azure/*.sh` + OIDC federation
  ([ADR-0009](#9-oidc-federation-from-github-to-azure)).
- Prototype budget: **cost-sensitive**, scale-to-zero wherever
  stateful-ness allows — MySQL stays at 1 replica.

### Conventions

- Every color/gradient is a CSS custom property on `:root` in
  `frontend/src/App.vue`; components reference them via `var(--token)`.
- API base path is always `/api`, called with relative URLs from the
  frontend (Vite dev proxy in dev, nginx in prod).
- Container images follow `ghcr.io/fbrase-itk/vehicle_configurator-<component>`.
