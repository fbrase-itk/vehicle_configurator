# C4 Architecture Model (Structurizr DSL)

This folder contains the architecture of the **Vehicle Configurator**
expressed in [Structurizr DSL](https://docs.structurizr.com/dsl), which
is the machine-readable form of the [C4 model](https://c4model.com).

The DSL is the single source of truth; all diagrams are **generated**
from it and therefore always consistent.

## Files

| Path | Purpose |
|------|---------|
| `workspace.dsl` | The complete Structurizr workspace — people, software systems, the Vehicle Configurator's containers and components, two deployment environments (local Compose + Azure Container Apps), views and styles. |
| `docs/` | Narrative Markdown sections (Context, Functional Overview, Quality Attributes, Constraints, Principles, Software Architecture with embedded diagrams, Data, Deployment, Development Environment, Operation). Loaded into the workspace via `!docs docs`; shown in the "Documentation" tab of Structurizr Lite. |
| `adrs/` | Architecture Decision Records (0001–0009). Loaded via `!adrs adrs`; shown in the "Decisions" tab. |

## What's in the workspace

Three tabs appear in the Structurizr Lite sidebar:

- **Diagrams** — the C4 views listed below.
- **Documentation** — the Markdown sections in `docs/`, each with the
  relevant view embedded inline via `![](embed:ViewKey)` references.
- **Decisions** — the ADRs in `adrs/`.

### Diagrams

All views are defined in `workspace.dsl` under the `views { … }` block.

| View key | C4 level | Scope |
|----------|----------|-------|
| `SystemContext` | Level 1 – System Context | The Vehicle Configurator in its environment (end user, operator, GitHub, GHCR, Azure Container Apps). |
| `Containers` | Level 2 – Containers | The three runtime containers: Frontend (Vue + nginx), Backend (Spring Boot), Database (MySQL). |
| `FrontendComponents` | Level 3 – Components | Internal decomposition of the Frontend container (App shell, Configurator page, Summary page, CarPreview3D, API client, nginx ingress). |
| `BackendComponents` | Level 3 – Components | Internal decomposition of the Backend container (Controller, Service, Repositories, JPA entities, Application). |
| `DatabaseComponents` | Level 3 – Components | Logical grouping of MySQL tables (catalog / configuration / orders). |
| `LocalDeployment` | Deployment | Docker Compose stack on a developer laptop. |
| `AzureDeployment` | Deployment | Azure Container Apps environment `vc-env` in resource group `rg-vehicle-configurator` (West Europe), backed by GHCR. |

## Rendering the diagrams

A `structurizr` service is wired into [`docker/compose.yml`](../../docker/compose.yml)
alongside the application stack. Start it together with everything
else, or on its own:

```bash
cd docker
docker compose up -d structurizr
```

Then open <http://localhost:8000/> in a browser. Each view from the
table above appears in the left-hand menu. You can pan/zoom, toggle
auto-layout, and export any diagram as PNG/SVG/PlantUML/Mermaid.

Structurizr Lite watches the mounted folder, so saving
`docs/structurizr/workspace.dsl` reloads the diagrams immediately – no
container restart needed.

## Editing tips

- The DSL is plain text – any editor will do. VS Code has a
  [Structurizr DSL](https://marketplace.visualstudio.com/items?itemName=systemticks.c4-dsl-extension)
  extension that provides syntax highlighting, completion, and live
  preview.
- `!identifiers hierarchical` is set, so components are addressed as
  `vc.frontend.fe_cfg`, `vc.backend.be_svc`, etc.
- Adding a new container: declare it inside the `vc` software system
  block, then add the relationships. No view changes are required –
  `include *` picks it up automatically.
- Adding a new deployment view: add a `deployment vc <envName> <key> {
  include * … }` stanza under `views`.

## Relationship to the arc42 documentation

The arc42 documentation in [`../arc42/`](../arc42/README.md) is the
**narrative** description (prose, quality goals, ADRs, risks). This
folder is the **model** description (a single executable source of
truth for the C4 diagrams).

Whenever the architecture changes:

1. Update `workspace.dsl` (here) so the diagrams stay consistent.
2. Update the relevant arc42 section (`../arc42/05-building-block-view.md`,
   `../arc42/07-deployment-view.md`, …) with the accompanying prose.
3. Both should go in the same PR.
