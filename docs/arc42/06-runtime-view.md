# 6. Runtime View

This section shows the important runtime scenarios. Each scenario maps
to one of the quality goals or to a core business flow.

## 6.1 Scenario 1 – Opening the configurator

Covers: first visit, Quality Goal 1 (instant feedback after initial load).

```mermaid
sequenceDiagram
    autonumber
    participant B as Browser
    participant FE as Frontend (nginx/Vite)
    participant API as Backend /api
    participant DB as MySQL

    B->>FE: GET /
    FE-->>B: index.html + JS bundle + aventador.glb
    B->>FE: GET /api/options
    FE->>API: GET /api/options
    API->>DB: SELECT * FROM car_models, engine_options, paint_options, ...
    DB-->>API: catalog rows
    API-->>FE: JSON { carModels, engines, paints, wheelDesigns, wheelColors, caliperColors, equipment }
    FE-->>B: JSON
    B->>B: render Configurator.vue + CarPreview3D
```

Key points:

- A **single** catalog call (`/api/options`) powers the whole UI – no
  further round-trips are needed for paint/wheel/caliper selections.
- `CarPreview3D` loads the GLB and an HDR environment once; subsequent
  selections only mutate material/mesh properties.

## 6.2 Scenario 2 – User changes a property (live update)

Covers: Quality Goal 1 – price and 3D preview must update without a
network call.

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant Cfg as Configurator.vue
    participant P3D as CarPreview3D.vue
    U->>Cfg: click "Blu Cepheus" paint swatch
    Cfg->>Cfg: selected.paintId = 6
    Cfg->>Cfg: recompute totalPrice (sum of selected prices)
    Cfg->>P3D: prop paintColor = "#…"
    P3D->>P3D: updateBodyColor() (material.color.set)
    Cfg-->>U: price label + header CTA update
    P3D-->>U: canvas repaints next frame
```

Notes:

- **No** backend call happens on property changes – all catalog data and
  all prices are already in the Vue reactive state.
- The 3D preview mutates `THREE.Material` color properties in place; the
  scene is not rebuilt.
- Switching wheel **design** toggles the visibility of the two rim
  meshes (`Obj_Rim_T0A` ↔ `Obj_Rim_T0B`) that ship inside the GLB.

## 6.3 Scenario 3 – Saving a configuration ("Continue to Summary")

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant Cfg as Configurator.vue
    participant FE as Frontend proxy
    participant Ctl as ConfiguratorController
    participant Svc as ConfiguratorService
    participant DB as MySQL

    U->>Cfg: click "Continue to Summary"
    Cfg->>FE: POST /api/configurations { carModelId, engineId, paintId, ..., equipmentIds[] }
    FE->>Ctl: POST /api/configurations
    Ctl->>Svc: saveConfiguration(request)
    Svc->>Svc: build Configuration, id = UUID.randomUUID()
    Svc->>DB: INSERT INTO configurations
    Svc->>DB: INSERT INTO configuration_equipment (per selected eq.)
    DB-->>Svc: OK
    Svc-->>Ctl: { id, configuration, totalPrice }
    Ctl-->>FE: 200 JSON
    FE-->>Cfg: JSON
    Cfg->>Cfg: router.push("/summary/" + id)
```

Notes:

- The UUID is generated **server-side** and returned in the response;
  the frontend has no part in id creation, so the URL is guaranteed
  unique.
- `calculateTotalPrice` is computed on the server on save and on read –
  the client-side total is advisory and not trusted for storage.

## 6.4 Scenario 4 – Opening a shared configuration URL

```mermaid
sequenceDiagram
    autonumber
    participant B as Browser (opens /summary/<uuid>)
    participant FE as Frontend
    participant Ctl as ConfiguratorController
    participant DB as MySQL

    B->>FE: GET /summary/<uuid>
    FE-->>B: index.html + JS
    B->>FE: GET /api/configurations/<uuid>
    FE->>Ctl: GET /api/configurations/<uuid>
    Ctl->>DB: SELECT config + joined catalog rows + equipment
    DB-->>Ctl: rows
    Ctl-->>B: { configuration, totalPrice }
    B->>B: render Summary.vue + CarPreview3D with persisted selections
```

The `:id` route parameter is a UUID, so the URL is shareable and
bookmarkable (PRD requirement 3).

## 6.5 Scenario 5 – Submitting an order

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant Sum as Summary.vue
    participant Ctl as ConfiguratorController
    participant Svc as ConfiguratorService
    participant DB as MySQL

    U->>Sum: fill name + email, click "Submit Order"
    Sum->>Ctl: POST /api/orders { configurationId, customerName, customerEmail }
    Ctl->>Svc: createOrder(request)  [@Transactional]
    Svc->>DB: SELECT * FROM configurations WHERE id = ?
    alt configuration exists
        Svc->>Svc: total = calculateTotalPrice(config)
        Svc->>DB: INSERT INTO orders (configuration_id, customer_name, customer_email, total_price, created_at)
        DB-->>Svc: new id
        Svc-->>Ctl: Order entity
        Ctl-->>Sum: 200 JSON
        Sum-->>U: "Order submitted" confirmation
    else configuration missing
        Svc-->>Ctl: throw RuntimeException
        Ctl-->>Sum: 500
        Sum-->>U: error banner
    end
```

## 6.6 Scenario 6 – First-time container startup (init + schema)

```mermaid
sequenceDiagram
    autonumber
    participant BE as Backend container
    participant DB as MySQL container
    participant Init as init script 001-init.sql

    Note over DB: docker entrypoint
    DB->>DB: mysqld --initialize
    DB->>Init: run /docker-entrypoint-initdb.d/001-init.sql
    Init->>DB: CREATE TABLEs (catalog, configurations, orders, join table)
    Init->>DB: INSERT seed rows (1 car model, 4 engines, 8 paints, ...)
    DB-->>DB: healthcheck mysqladmin ping OK

    BE->>DB: JPA connect (spring.datasource.url)
    BE->>BE: Hibernate = map only (ddl-auto=none)
    BE-->>BE: Tomcat up on :8080
```

The backend `depends_on` the database with `service_healthy` in
`docker/compose.yml`, so the init script has always completed by the
time the backend starts.
