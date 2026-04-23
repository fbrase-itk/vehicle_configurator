## Software Architecture

The central chapter of the guidebook. It walks through the C4 model
levels from containers down to components, embedding each view inline.

### Containers (C4 Level 2)

![](embed:Containers)

Three runtime containers cooperate:

| Container | Technology | Responsibility |
|-----------|------------|----------------|
| **Frontend** | Vue 3 + Vite + three.js, served by nginx in prod | Serves static assets, proxies `/api/*` to the backend, provides the configurator + summary UIs including the live 3D preview. |
| **Backend** | Spring Boot 4, Java 25 (virtual threads), JPA/Hibernate | Stateless REST API. Reads the catalog, validates and persists configurations and orders, computes the authoritative total price. |
| **Database** | MySQL 8.4 | Stores the option catalog (seeded on first start), configurations, and orders. Schema applied by `database/init/001-init.sql`. |

Only the **Frontend** is exposed externally; the backend and database
have *internal-only* ingress in the Azure deployment. See the
[Deployment](#deployment) chapter.

### Frontend components (C4 Level 3)

![](embed:FrontendComponents)

| Component | Source file | Responsibility |
|-----------|-------------|----------------|
| **App shell** | `frontend/src/App.vue` | Sticky header with `#header-actions` teleport target, `:root` design-token block, `<router-view/>`. |
| **Configurator page** | `frontend/src/pages/Configurator.vue` | Multi-step configurator; live total price; teleports step navigation + "Continue to Summary" CTA into the header; on submit calls `saveConfiguration` and navigates to `/summary/:id`. |
| **Summary page** | `frontend/src/pages/Summary.vue` | Loads a persisted configuration, renders preview + detail table + order form; teleports a "Back" button. |
| **CarPreview3D** | `frontend/src/components/CarPreview3D.vue` | three.js scene. Loads `aventador.glb` + DRACO + HDR once; reactively mutates materials and toggles rim meshes on prop changes. |
| **API client** | `frontend/src/services/api.js` | Thin `fetch` wrapper around `/api`. |
| **nginx ingress (prod)** | `docker/frontend/Dockerfile` (nginx stage) | Serves the SPA bundle, SPA fallback (`try_files`), reverse-proxies `/api/` to `${BACKEND_UPSTREAM}:8080`. In dev, replaced by the Vite dev server. |

### Backend components (C4 Level 3)

![](embed:BackendComponents)

The backend is a classic controller → service → repository → entity
stack with no CQRS, no ports/adapters, no hexagonal gymnastics — the
domain is small enough that the simple layering is the right answer.

| Component | Source | Responsibility |
|-----------|--------|----------------|
| **Application** | `com.configurator.Application` | Spring Boot entry point. |
| **ConfiguratorController** | `com.configurator.controller.ConfiguratorController` | The **only** controller. Exposes `/api/*` (options, per-resource catalog endpoints, configurations, orders). Class-level `@CrossOrigin(origins="*")`. |
| **ConfiguratorService** | `com.configurator.service.ConfiguratorService` | The **only** service. Aggregates catalog for `/api/options`, assembles `Configuration`, generates UUID, computes `calculateTotalPrice`, creates orders `@Transactional`. |
| **Repositories** | `com.configurator.repository.*` | Nine Spring Data JPA interfaces (one per entity) extending `JpaRepository`. No custom queries. |
| **JPA entities** | `com.configurator.model.*` | `CarModel`, `EngineOption`, `PaintOption`, `WheelDesign`, `WheelColor`, `CaliperColor`, `SpecialEquipment`, `Configuration` (UUID PK), `Order`. `ddl-auto=none` — Hibernate only maps, never migrates. |

### Database components (logical view)

![](embed:DatabaseComponents)

The three logical groups inside the MySQL container are:

| Group | Tables | Purpose |
|-------|--------|---------|
| **Catalog** | `car_models`, `engine_options`, `paint_options`, `wheel_designs`, `wheel_colors`, `caliper_colors`, `special_equipment` | Read-only at runtime. Seeded on first start. |
| **Configurations** | `configurations` (UUID PK), `configuration_equipment` (join table, ≤ 5 rows per configuration) | Written by `POST /api/configurations`. |
| **Orders** | `orders` | Written by `POST /api/orders`; snapshot of `total_price` at submission time. |
