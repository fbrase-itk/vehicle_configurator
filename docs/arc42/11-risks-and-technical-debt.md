# 11. Risks and Technical Debt

Captured as of the current state of the prototype. Items are rated
**L** (low), **M** (medium), **H** (high) on *likelihood* and *impact*.

## 11.1 Risks

| ID | Risk | Likelihood | Impact | Mitigation / plan |
|----|------|-----------|--------|-------------------|
| R-01 | **CORS wide open** – `@CrossOrigin(origins = "*")` allows any origin to call `/api/*`. | H in dev / M in prod (backend has no public ingress in ACA, so reachability is limited anyway) | L in prod, M in dev | Replace with an explicit `CorsConfigurationSource` bean whitelisting the frontend origin before any real deployment to a public backend. |
| R-02 | **No input validation** on `ConfigurationRequest` / `OrderRequest` beyond what JPA does implicitly. A malformed request currently throws `500`. | M | M | Add `@NotNull / @Email / @Size` annotations + `@Valid`; add `@ControllerAdvice` for consistent 400 responses. |
| R-03 | **Single-replica MySQL on ephemeral storage** in ACA. Replica recycling wipes data. | H over time | H (data loss) | Move to Azure Database for MySQL Flexible Server, or mount persistent storage (Azure Files) to the DB container app. Track as D-02. |
| R-04 | **Hard-coded database password** (`configurator123`) identical across dev and prod env files. | H | M | Rotate via an ACA secret backed by an Azure Key Vault reference; remove from repo (add example files instead). |
| R-05 | **No rate limiting** on `POST /api/configurations` / `POST /api/orders`. | M | M | Add a reverse-proxy rate limit (nginx `limit_req_zone`) or front the backend with an APIM / Envoy rate-limit filter. |
| R-06 | **No metrics / tracing / alerting**. A silent backend error surfaces only as a user report. | M | M | Add `spring-boot-starter-actuator` + `micrometer-registry-azuremonitor`, export metrics and a minimum health endpoint; configure a Log Analytics alert on ERROR-level log lines. |
| R-07 | **No backend tests.** The `backend/src/test` tree is empty; integration coverage comes only from the CI smoke test. | H | M | Add unit tests for `ConfiguratorService.calculateTotalPrice` and `createOrder`; add `@SpringBootTest` slice tests for the controller. |
| R-08 | **No frontend tests.** There is no `vitest` / `playwright` setup. | H | M | Start with component tests for `Configurator.vue` state transitions (`vitest + @vue/test-utils`) and a Playwright smoke test for the happy path. |
| R-09 | **Configuration equipment cap (max 5)** is only enforced in the UI. A direct `POST /api/configurations` with 10 equipment IDs succeeds. | L | L | Validate in `ConfiguratorService.saveConfiguration`. |
| R-10 | **Auto-generated image tags vs. `:latest`** – `02-update-images.sh` pulls `:latest` with a revision suffix. Rolling back requires knowing the previous SHA tag and re-running with that. | M | M | Introduce explicit, immutable image refs (e.g. SHA digests) in deploy; keep `:latest` only for manual convenience. |
| R-11 | **Third-party asset dependency** – `aventador.glb` is shipped under `frontend/public/models/`. Licensing of the asset is not tracked in the repo. | M | L–M | Track asset provenance and license in `frontend/public/models/README.md`. |
| R-12 | **No authentication** (explicitly out of scope). Any visitor can submit orders as anyone. | L (prototype) | H if put in production as-is | Stop shipping this to real users without at least rate-limiting and captcha on the order endpoint. |

## 11.2 Technical Debt

| ID | Debt | Why it exists | Proposed fix |
|----|------|---------------|--------------|
| D-01 | Schema managed by **a single SQL file** (`001-init.sql`). MySQL only runs it on *first* start; updating the schema on an existing volume requires manual intervention. | Prototype simplicity. | Adopt **Flyway** or **Liquibase** in the backend; keep the init file as the baseline migration. |
| D-02 | MySQL as a Container App instead of managed PaaS. See R-03. | Cost + setup effort. | Provision **Azure Database for MySQL Flexible Server** in `01-setup.sh`; remove the `database` container app; keep the schema bootstrap via Flyway. |
| D-03 | `CarPreview.vue` (2D SVG fallback) is dead code – no page imports it. | Superseded by `CarPreview3D.vue`. | Delete or explicitly document as a no-WebGL fallback and wire it up. |
| D-04 | Environment files in `docker/env/*.env` are **committed with real values**. | Prototype convenience. | Commit `.env.example` files and `.gitignore` the real ones; document the required variables in README. |
| D-05 | The `integration` smoke test in `ci.yml` is inline bash. Growing it will make the workflow hard to read. | Written incrementally. | Move to a dedicated shell script under `scripts/smoke-test.sh` called from the workflow, also runnable locally. |
| D-06 | `ConfiguratorController` carries `@CrossOrigin` but no package-level CORS config exists. | Quick fix during dev. | Replace with a proper `WebMvcConfigurer` / `CorsConfigurationSource`. |
| D-07 | No `.editorconfig` / prettier / checkstyle. Code style is currently by convention. | Single-developer prototype. | Add `.editorconfig`, `prettier`, and `checkstyle` + wire into CI. |
| D-08 | Prices are seeded with a comment about USD→EUR conversion. There is no automated currency/rate source. | Static seed data. | Document as seed data only; any real pricing should come from an external system. |
| D-09 | No pagination on any `GET` endpoint. | Catalog is tiny (≤ 10 rows per table). | Add `Pageable` support before introducing any high-cardinality catalog. |
