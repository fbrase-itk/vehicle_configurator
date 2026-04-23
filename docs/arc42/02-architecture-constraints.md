# 2. Architecture Constraints

Constraints are boundary conditions the architecture **must** respect.
They come from the PRD, from the operating environment, and from
decisions already made upstream.

## 2.1 Technical Constraints

| # | Constraint | Source | Consequence |
|---|------------|--------|-------------|
| T1 | Frontend must be implemented in **Vue.js, React, or Angular**. | PRD | We picked Vue 3 + Vite. |
| T2 | Backend services must be written in **Java**. | PRD | We use Spring Boot 4.0 on Java 25. |
| T3 | Operations via **Docker Compose**. | PRD | One `compose.yml` for dev, one `compose.prod.yml` for GHCR-backed deployment; all services containerized. |
| T4 | All project data (configurations + orders) **persisted in a database**. | PRD | MySQL 8.4 with a SQL init script; JPA from the backend. |
| T5 | **Authentication / authorization** is explicitly out of scope. | PRD | No Spring Security, no login UI, no session handling. |
| T6 | **CORS** must be permissive so the Vite dev server (`:5173`) can call the backend (`:8080`). | Dev environment | Controller-level `@CrossOrigin(origins = "*")`. In prod, same-origin via nginx proxy, no CORS required. |
| T7 | Hibernate **must not** manage schema (`spring.jpa.hibernate.ddl-auto=none`). | Review decision | Schema lives in `database/init/001-init.sql` and is the single source of truth. |

## 2.2 Organizational Constraints

| # | Constraint | Source | Consequence |
|---|------------|--------|-------------|
| O1 | Code hosted on **GitHub**, repo `fbrase-itk/vehicle_configurator`. | Task-3 | CI/CD via GitHub Actions, images on GHCR, OIDC federation to Azure. |
| O2 | Target cloud is **Azure** (West Europe). | Task-4 | Resource group `rg-vehicle-configurator`; Azure Container Apps as runtime. |
| O3 | Prototype scope – no SLAs, no 24/7 availability, cost-sensitive. | Task-1 "minimal version first" | Single replica per service, scale-to-zero for stateless apps, MySQL as a container (no managed PaaS database). |
| O4 | Deployment must be **automatable and tear-down-able** from a laptop. | Task-4 | `azure/00..03-*.sh` shell scripts, idempotent, driven by `config.env`. |

## 2.3 Conventions

- **Monorepo layout** mandated in the PRD:
  `backend/`, `frontend/`, `database/`, `docker/`, `docs/`, `azure/` at the root.
- **Design tokens** (colors, gradients) are defined **once** in the
  `:root` block of `frontend/src/App.vue` and referenced via
  `var(--token-name)` everywhere else (see README §*Theme & Design Tokens*).
- **API base path** is `/api`; the frontend always calls relative URLs
  and relies on a proxy (Vite dev proxy in dev, nginx `/api/` location
  in prod) to reach the backend.
- Docker image names are lowercased and follow
  `ghcr.io/fbrase-itk/vehicle_configurator-<component>`.
