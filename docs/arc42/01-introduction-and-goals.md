# 1. Introduction and Goals

## 1.1 Requirements Overview

The **Vehicle Configurator** is a web application that lets a user
configure a car interactively and submit the resulting specification as
an order. The prototype is derived from the Product Requirements
Document ([PRD.md](../../PRD.md)).

Configurable properties:

- **Engine power** (model-dependent list)
- **Paint finish**
- **Wheels / rims** (design + color)
- **Brake caliper color**
- **Special equipment** – up to five items

Functional requirements from the PRD:

1. Any change to the configuration must update the displayed **total
   price** immediately, without a page refresh.
2. At the end of the flow the user sees a **summary** and can submit an
   **order**.
3. A **shareable URL** must be generated so the configuration can be
   re-opened at any time.
4. Both configurations and orders must be **persisted** in a database.
5. Authentication / authorization is **out of scope** for the prototype.

## 1.2 Quality Goals

The three top quality goals that drive architectural decisions:

| Priority | Quality goal | Motivation / scenario |
|----------|--------------|-----------------------|
| 1 | **Usability** – "feel like a real-car configurator" | A 3D live preview updates in < 200 ms when the user switches paint/wheel/caliper. The total price updates synchronously on every selection. |
| 2 | **Deployability / Portability** | The entire stack runs on a laptop with a single `docker compose up` and can be lifted to Azure Container Apps via idempotent shell scripts, without rewriting code. |
| 3 | **Evolvability** | New option categories (e.g. interior trims) must be addable by extending one entity + one repository + one page step, without reshaping the API contract. |

Secondary quality goals: maintainability (single design-token block for
theming), observability (Azure Log Analytics), and reproducibility
(pinned Docker tags, Maven/npm lockfiles checked in).

## 1.3 Stakeholders

| Role | Expectations |
|------|--------------|
| **Product owner** (ITK) | A working prototype that demonstrates the full configurator flow (browse → configure → share → order) and looks like a premium OEM site. |
| **End user** (prospective buyer) | Fast, visual feedback, transparent pricing, bookmarkable configuration URL. |
| **Developer** | Clear module boundaries, local one-command dev loop, green CI on every push. |
| **Operator** | Deterministic deployment to Azure, no manual clicking in the portal, disposable environments (`03-teardown.sh`). |
| **Reviewer / architect** | A concise architecture description (this document) to judge the design and its trade-offs. |
