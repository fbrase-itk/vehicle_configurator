## Functional Overview

The system supports a single end-to-end user flow:

1. **Open** `/` — the configurator loads the full option catalog in one
   request (`GET /api/options`) and renders a live 3D preview of the car.
2. **Configure** — the user picks a car model, engine, paint, wheel
   design + color, caliper color, and up to five special-equipment
   items. Every change:
    * updates the running **total price** inline (no network call), and
    * updates the **3D preview** in place (no scene rebuild).
3. **Continue to Summary** — `POST /api/configurations` persists the
   selection with a server-generated UUID and redirects the browser to
   `/summary/<uuid>`.
4. **Share** — the `/summary/<uuid>` URL is a public, bookmarkable
   reference to the exact configuration (including the 3D preview).
5. **Submit order** — the user enters name + email and `POST /api/orders`
   stores the order (transactionally) together with the snapshot price.

### Feature inventory

| Feature | Where implemented | Notes |
|---------|-------------------|-------|
| Real-time price | `Configurator.vue` computed total; authoritative total recomputed server-side in `ConfiguratorService.calculateTotalPrice`. | No currency handling — EUR only. |
| Live 3D preview | `CarPreview3D.vue` (three.js, GLB + HDR + DRACO). | Mutates material colors and toggles rim meshes; scene loaded once. |
| Shareable URL | `GET /api/configurations/{id}` + Vue Router route `/summary/:id`. | UUID for non-guessability. |
| Order submission | `POST /api/orders` (`@Transactional`). | Name + email only. |
| Max 5 equipment items | UI constraint in `Configurator.vue`. | Not enforced at DB/API today — see risk R-09 in `../arc42/11-risks-and-technical-debt.md`. |
| Multi-step flow | `Configurator.vue` with teleported step navigation in the app header. | Each step can be revisited. |
