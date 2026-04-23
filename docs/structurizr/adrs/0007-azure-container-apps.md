# 7. Azure Container Apps

Date: 2025-04-10

## Status

Accepted

## Context

The cloud target is Azure. We have three long-running containers
(frontend, backend, database), low expected traffic, and a strong
cost-sensitivity requirement.

## Decision

Run all three components as **Azure Container Apps** inside one
environment (`vc-env`) in resource group `rg-vehicle-configurator`.

- `frontend` has **external** HTTP ingress (the only public entry point).
- `backend` and `database` have **internal** ingress — reachable only
  from inside the same ACA environment.
- `frontend` and `backend` are allowed to scale to zero (`min=0`,
  `max=2`).
- `database` is pinned at `min=max=1` replica because it is stateful.

## Alternatives considered

- **Azure Kubernetes Service (AKS)** — rejected: cluster management
  overhead is excessive for three containers.
- **Azure App Service** — rejected: one web-app slot doesn't map
  cleanly to three cooperating containers.
- **Azure Container Instances** — rejected: no scale-to-zero, no
  built-in ingress, no environment concept for internal DNS.

## Consequences

- Scale-to-zero ⇒ near-zero cost when idle for frontend and backend.
- Backend is reachable only via the frontend's nginx proxy — no
  public API surface by default.
- ACA's `--allow-insecure` flag is needed for internal HTTP ingress
  on the backend (Spring Boot does not terminate TLS itself); because
  traffic is already inside the ACA environment, this is acceptable.
- Stateful MySQL replica tied to this trade-off is handled separately
  in ADR-0008.
