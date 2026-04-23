## Context

The **Vehicle Configurator** is a small web application that lets a
prospective buyer configure a car — engine, paint, wheels, brake
caliper color, and up to five special-equipment items — see the result
live in 3D, receive a shareable URL for the configuration, and submit
it as an order.

The prototype is the reference implementation of
[`PRD.md`](../../../PRD.md). It runs end-to-end on a laptop via Docker
Compose and is deployed to Azure Container Apps in West Europe.

### Actors and external systems

![](embed:SystemContext)

| Actor / system | Role |
|----------------|------|
| **End user** | The single human role. Browses the catalog, configures a car, optionally shares the URL, and submits an order. No authentication. |
| **Operator** | Developer/operator provisioning or updating the Azure deployment from their laptop via `azure/*.sh`. |
| **GitHub** | Hosts the source code and runs the three GitHub Actions workflows (CI, image publish, Azure deploy). |
| **GitHub Container Registry (GHCR)** | Stores the three component images (`vehicle_configurator-frontend`, `-backend`, `-database`). |
| **Azure Container Apps** | The production runtime. Consumes the GHCR images and exposes the public frontend FQDN. |

### What is explicitly *outside* the system

- No authentication / authorization / user accounts.
- No payment processing — "submit order" just persists `name + email + total`.
- No managed database (see [ADR-0008](#8-mysql-as-a-container-app)).
- No stock/inventory logic.
- No multi-currency or multi-language support.
