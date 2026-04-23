## Quality Attributes

The top three qualities driving the design, in priority order:

### 1. Usability — "feels like a real-car configurator"

- **Scenario:** user clicks a paint swatch; the 3D body color and the
  total price update within 200 ms, measured in the browser
  performance timeline.
- **How it's achieved:**
    * One-shot catalog load via `GET /api/options` — no subsequent
      network calls for property changes.
    * In-place three.js material updates
      ([ADR-0006](#6-threejs-with-in-place-material-updates)).
    * Vue reactivity re-renders only the price label and the relevant
      option card.

### 2. Deployability / Portability

- **Local:** `docker compose up --build` in `docker/` yields the full
  stack (frontend, backend, database, plus a Structurizr Lite service
  for these docs) in under three minutes on a cold build.
- **Cloud:** `azure/00-bootstrap-oidc.sh` (one-off) +
  `azure/01-setup.sh` stands up the Azure Container Apps environment
  idempotently in roughly ten minutes. A second run is a no-op.

### 3. Evolvability

- Adding a new option category (e.g. *interior trim*) is a recipe:
  one new table in `001-init.sql`, one JPA entity, one repository, one
  reference in `Configuration`, one step section in `Configurator.vue`,
  and extend `ConfiguratorService.getAllOptions()`. See
  [ADR-0005](#5-aggregated-api-options-endpoint) for why this does not
  break existing clients.
- Re-theming the UI is a single-file edit inside the `:root` block of
  `frontend/src/App.vue`.

### Non-goals (explicit)

- High availability / multi-region — single replica per service.
- Formal throughput/load SLA — prototype.
- Production-grade backup & restore — MySQL runs as a container
  ([ADR-0008](#8-mysql-as-a-container-app)).
- WCAG / GDPR / PCI compliance — out of scope.
