# Vehicle Configurator – Architecture Documentation (arc42)

This folder contains the architecture documentation of the **Vehicle Configurator** prototype, structured along the [arc42](https://arc42.org/overview) template (version 8.2).

arc42 provides a proven, domain-independent template for the documentation
of software and system architectures. The twelve sections below cover
*what* the system does, *why* it was built this way, *how* it is structured,
and *under which conditions* it operates.

## Sections

| # | Section | Purpose |
|---|---------|---------|
| 1 | [Introduction and Goals](01-introduction-and-goals.md) | Business context, top quality goals, main stakeholders |
| 2 | [Architecture Constraints](02-architecture-constraints.md) | Technical and organizational constraints the design has to live with |
| 3 | [System Scope and Context](03-context-and-scope.md) | External interfaces, neighbouring systems, users |
| 4 | [Solution Strategy](04-solution-strategy.md) | Fundamental decisions that shape the architecture |
| 5 | [Building Block View](05-building-block-view.md) | Static decomposition into modules / components |
| 6 | [Runtime View](06-runtime-view.md) | Important runtime scenarios (configure, save, order) |
| 7 | [Deployment View](07-deployment-view.md) | Local Docker Compose stack and Azure Container Apps target |
| 8 | [Cross-cutting Concepts](08-crosscutting-concepts.md) | Theming, persistence, pricing, 3D preview, CORS, logging |
| 9 | [Architecture Decisions](09-architecture-decisions.md) | Key ADRs captured in short form |
| 10 | [Quality Requirements](10-quality-requirements.md) | Quality tree and measurable scenarios |
| 11 | [Risks and Technical Debt](11-risks-and-technical-debt.md) | Known risks, compromises, backlog items |
| 12 | [Glossary](12-glossary.md) | Domain and technical terminology |

## How to read this

- Start with **Section 1** for the business goal and **Section 3** for the
  system boundary.
- If you want to understand *how* the system is built, read sections
  **4 → 5 → 6** in order.
- If you want to understand *where* it runs, read section **7**.
- Diagrams are embedded as [Mermaid](https://mermaid.js.org/) code fences
  and render directly on GitHub and in most IDEs.

## Keeping this documentation in sync

The source of truth for APIs, tables and deployment details remains the
code:

- Backend REST surface → `backend/src/main/java/com/configurator/controller/ConfiguratorController.java`
- Persistence model → `backend/src/main/java/com/configurator/model/*.java` and `database/init/001-init.sql`
- Frontend entry → `frontend/src/main.js`, `frontend/src/pages/*.vue`
- Local deployment → `docker/compose.yml`, `docker/compose.prod.yml`
- Cloud deployment → `azure/*.sh`, `.github/workflows/azure-deploy.yml`

When any of the above changes in a way that affects the architecture,
update the corresponding arc42 section in the same PR.
