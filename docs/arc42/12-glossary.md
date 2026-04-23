# 12. Glossary

## Domain terms

| Term | Definition |
|------|------------|
| **Car model** | A catalog entry representing a vehicle (e.g. *Lamborghini Aventador LP700-4*). Has a base price, brand, display name, and a 3D `model_file` (GLB). The seed data currently contains one car model. |
| **Engine option** | A choice of power train, always tied to a specific car model via `car_model_id`. Described by name, horsepower, and an optional surcharge (the base engine is priced 0). |
| **Paint option** | Body color choice. Has a HTML `color_code` used both in the UI swatches and as the diffuse color of the body material in the 3D preview. |
| **Wheel design** | Rim *shape*. Identified by a `model_object` string that matches a mesh in the GLB (`Obj_Rim_T0A`, `Obj_Rim_T0B`). Changing the wheel design toggles mesh visibility rather than loading new geometry. |
| **Wheel color** | Independent of the wheel design. Applied as a material color to the selected rim mesh. |
| **Caliper color** | Color of the brake caliper part of the car model. |
| **Special equipment** | Optional extras (sound system, carbon trim, …). A configuration may include between **0 and 5** special equipment items (PRD constraint). |
| **Configuration** | The complete specification the user has assembled: one car model + one engine + one paint + one wheel design + one wheel color + one caliper color + 0..5 equipment items. Identified by a server-generated UUID that appears in the shareable URL. |
| **Order** | A configuration that has been submitted with a customer name and email. The total price is snapshotted at submission time. |
| **Total price** | `basePrice + engine.price + paint.price + wheelDesign.price + wheelColor.price + caliperColor.price + Σ equipment.price`. Computed live on the client for UI feedback and authoritatively on the backend at save and order time. |
| **Shareable URL** | The path `/summary/<configuration-uuid>` (or `/config/<configuration-uuid>` to re-enter the configurator with the same selections). The UUID makes it safe to share publicly. |

## Technical terms

| Term | Definition |
|------|------------|
| **SPA** | Single-Page Application. Here: the Vue 3 bundle served by nginx (prod) or Vite (dev). |
| **Vite** | Frontend build tool (dev server + Rollup-based production build). |
| **Vue Router** | Client-side router used to switch between `/`, `/config/:id`, `/summary/:id`. |
| **Teleport** | A Vue 3 feature allowing a child component to render its DOM inside a different DOM target (`<Teleport to="#header-actions">`). Used by both pages to inject controls into the sticky app header. |
| **three.js** | JavaScript 3D library used by `CarPreview3D.vue` (GLB loading, PBR materials, orbit controls, HDR environment). |
| **GLB / glTF** | Binary form of the glTF 3D asset format. The Aventador model is shipped as `frontend/public/models/aventador.glb`. |
| **DRACO** | Mesh compression format supported by `GLTFLoader` via `DRACOLoader`; used to keep the car model small. |
| **HDR / RGBE** | High-dynamic-range environment map used for PBR reflections on the car body. |
| **Spring Boot** | Java application framework providing the embedded Tomcat, JPA integration, REST controllers, and dependency injection in use here (version 4.0.x). |
| **JPA / Hibernate** | Standard Java persistence API; Hibernate is the implementation shipped with Spring Data JPA. In this project Hibernate is configured **not** to manage DDL (`ddl-auto=none`). |
| **Virtual threads** | JDK 21+ lightweight threads (JEP 444). Enabled in Spring via `spring.threads.virtual.enabled=true`; each HTTP request is handled on a virtual thread. |
| **UUID** | 128-bit universally unique identifier, here used as a 36-character string PK for `configurations`. |
| **Compose file** | YAML file describing a multi-container application. This repo uses `docker/compose.yml` (dev, builds from source) and `docker/compose.prod.yml` (pulls from GHCR). |
| **Multi-stage build** | Docker build with multiple `FROM` stages to produce a small final image. Used for both the backend (build + runtime) and frontend (deps + dev + build + prod/nginx). |
| **GHCR** | GitHub Container Registry – `ghcr.io`. Hosts the three component images of this project. |
| **Azure Container Apps (ACA)** | Managed serverless container platform on Azure. Runs all three containers of the production deployment. |
| **Container App environment** | The ACA construct grouping related container apps so they share a VNET, Log Analytics, and internal DNS. |
| **Internal / external ingress** | ACA ingress modes. "Internal" means the app is only reachable from other apps in the same environment; "external" exposes a public FQDN. The backend and database are *internal*; only the frontend is *external*. |
| **OIDC federation** | GitHub Actions ↔ Azure AD trust mechanism that trades a short-lived GitHub-issued token for an Azure access token, removing the need for stored service-principal secrets. |
| **Log Analytics** | Azure log store. The workspace `vc-logs` receives stdout from all three container apps. |
| **Dependabot** | GitHub service that opens PRs for outdated dependencies. Configured to update Maven, npm, Docker base images, and GitHub Actions weekly. |
| **arc42** | The architecture documentation template used for this document set. |
