# 9. Architecture Decisions

Lightweight ADRs. Each decision is recorded with its context,
alternatives and consequences, in the spirit of Michael Nygard's ADR
template.

---

## ADR-001 – Vue 3 + Vite as the frontend stack

- **Status:** accepted
- **Context:** The PRD allows Vue.js, React, or Angular. We need a small
  SPA with two pages, a 3D preview, reactive price, and a
  teleport-capable header.
- **Decision:** Vue 3 with `<script>`-based SFCs, Vue Router 4, Vite as
  the dev server and build tool. No store library (Pinia/Vuex).
- **Alternatives considered:** React + Vite (equally viable; rejected
  for team familiarity). Angular (rejected as over-powered for two
  pages).
- **Consequences:**
  - Reactive price / 3D updates are one-liners with component state.
  - `<Teleport to="#header-actions">` gives us a clean way to inject
    per-page controls into the global header.
  - The dev server's proxy feature lets the same `/api` URL work in
    dev, compose-prod and Azure without code changes.

---

## ADR-002 – Spring Boot 4 on Java 25, single module

- **Status:** accepted
- **Context:** The PRD mandates Java. The catalog-and-order domain is
  small; we do not need microservices.
- **Decision:** One Spring Boot application with `spring-boot-starter-web`,
  `spring-boot-starter-data-jpa`, `spring-boot-starter-validation`, and
  MySQL Connector/J. Virtual threads enabled (`spring.threads.virtual.enabled=true`).
- **Alternatives considered:** Quarkus (rejected: less team familiarity);
  multi-module Maven (rejected: overkill).
- **Consequences:**
  - One fat-jar, one container, simple local run.
  - Virtual threads absorb burst traffic (every HTTP request gets its
    own carrier-free thread), which is free scalability for a
    mostly-DB-bound workload.

---

## ADR-003 – UUID-strings for Configuration IDs, auto-increment elsewhere

- **Status:** accepted
- **Context:** Configuration URLs must be shareable (PRD #3). Sharing a
  sequential integer would leak total count and invite easy enumeration.
- **Decision:** `Configuration.id` is a `VARCHAR(36)` UUID generated
  server-side (`UUID.randomUUID().toString()`). All catalog tables and
  `orders` keep `INT AUTO_INCREMENT`.
- **Alternatives considered:** `ULID` (rejected: no stdlib support in
  Java 25, negligible benefit for our volumes). Slug of car model +
  timestamp (rejected: collisions, guessability).
- **Consequences:**
  - `/summary/<uuid>` URLs are non-guessable and safe to paste in
    forums / chats.
  - No DB extension needed; strings serialise cleanly in JSON.

---

## ADR-004 – DDL lives in SQL, Hibernate does not manage schema

- **Status:** accepted
- **Context:** Hibernate's `ddl-auto=update` is convenient in dev but a
  liability in prod (surprise column drops, name-based collisions).
- **Decision:** `spring.jpa.hibernate.ddl-auto=none`; all DDL and seed
  data live in `database/init/001-init.sql`, executed by the MySQL
  entrypoint on first container start. Schema evolution happens by
  appending new `*.sql` files – or, later, adopting Flyway/Liquibase.
- **Consequences:**
  - The SQL file is the single reviewable source of truth for the schema.
  - Entity changes that contradict the schema fail fast at first JPA use.
  - Migrating existing data across versions is a manual exercise today
    (see technical debt D-01 in section 11).

---

## ADR-005 – Aggregated `GET /api/options` endpoint

- **Status:** accepted
- **Context:** The configurator needs all catalog data on first load; a
  single round-trip keeps the first-paint fast and avoids N+1 requests.
- **Decision:** Expose a single `GET /api/options` returning every
  catalog collection in one JSON response, in addition to the per-resource
  endpoints (which remain available for future admin tooling).
- **Alternatives considered:** GraphQL (rejected: too heavy for a
  prototype); client-side orchestration of 7 GETs (rejected: slower
  first render, harder to cache).
- **Consequences:**
  - One HTTP call powers the entire configurator's static data.
  - The response is cache-friendly – pure `GET`, no parameters, no auth.

---

## ADR-006 – three.js with in-place material updates

- **Status:** accepted
- **Context:** Quality Goal 1 demands instant (< 200 ms) visual
  feedback on paint/wheel/caliper changes. Re-loading the GLB on every
  change would be unacceptable.
- **Decision:** Load the car once on component mount; keep references
  to body / wheel / caliper materials (plus the two rim meshes) as
  non-reactive component fields; mutate `material.color` and mesh
  `visible` flags on prop changes. Vue `watch`ers call the matching
  update methods.
- **Alternatives considered:**
  - Rebuild the scene per change – rejected (slow, flashing).
  - Use a higher-level framework (e.g. Tres.js) – not needed for our
    scope, adds a dependency.
- **Consequences:**
  - UI feels as responsive as a native app.
  - `CarPreview3D.vue` is relatively long (~870 lines) because material
    lookup is done once and cached; mitigated by clear method names.

---

## ADR-007 – Azure Container Apps (not AKS, not App Service)

- **Status:** accepted
- **Context:** Target is cost-sensitive, container-native, low-ops.
- **Decision:** Use Azure Container Apps with the internal-envoy
  networking model. Frontend has **external** ingress, backend and
  database have **internal** ingress – the backend is only reachable
  through the frontend's nginx.
- **Alternatives considered:**
  - AKS – rejected: cluster management overhead for three containers.
  - Azure App Service – rejected: a single web-app slot doesn't match
    a 3-container deployment, and side-cars are clunky.
  - Azure Container Instances – rejected: no built-in ingress, no
    scale-to-zero.
- **Consequences:**
  - Scale-to-zero on frontend and backend ⇒ near-zero cost when idle.
  - MySQL replica must stay at 1 (stateful) – see risk R-03.

---

## ADR-008 – MySQL as a Container App, not Azure Database for MySQL

- **Status:** accepted, provisional
- **Context:** A managed database costs more and takes longer to
  provision than a prototype justifies.
- **Decision:** Run MySQL as an ACA app with `min=max=1 replica`.
- **Consequences:**
  - Persistence lives on the replica's ephemeral filesystem. On ACA
    replica recycling, data is **lost**. Acceptable for the prototype
    but must change before going to any real user. See risk R-03 and
    tech-debt D-02.

---

## ADR-009 – GitHub Actions + OIDC federation to Azure

- **Status:** accepted
- **Context:** Task-3 mandates GitHub Actions CI/CD; Task-4 target is
  Azure. Long-lived service principal secrets in `secrets.*` are a
  compliance risk.
- **Decision:** Use Azure AD workload identity federation. A single
  `gh-vehicle-configurator-deployer` app registration trusts
  `repo:fbrase-itk/vehicle_configurator:ref:refs/heads/main` via the
  GitHub OIDC issuer. `azure/login@v2` exchanges the ephemeral OIDC
  token for an Azure access token.
- **Consequences:**
  - No secret in the repo can deploy to Azure; only the configured ref
    can.
  - `00-bootstrap-oidc.sh` is the *only* script that needs Azure AD +
    GitHub repo admin rights – a one-off setup task.
