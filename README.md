# Vehicle Configurator

[![CI](https://github.com/fbrase-itk/vehicle_configurator/actions/workflows/ci.yml/badge.svg)](https://github.com/fbrase-itk/vehicle_configurator/actions/workflows/ci.yml)
[![Publish Docker images](https://github.com/fbrase-itk/vehicle_configurator/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/fbrase-itk/vehicle_configurator/actions/workflows/docker-publish.yml)

A web application for configuring vehicles with engine, paint, wheels, and special equipment options.

## Tech Stack

- **Frontend:** Vue.js 3 with Vite
- **Backend:** Java 25 with Spring Boot 4.0
- **Database:** MySQL 8.4
- **Infrastructure:** Docker Compose

## Quick Start

```bash
cd docker
docker compose up --build
```

The application will be available at:
- **Frontend:** http://localhost:5173
- **Backend API:** http://localhost:8080/api

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/options` | Get all configuration options |
| GET | `/api/car-models` | Get all car models |
| GET | `/api/car-models/{id}` | Get a specific car model |
| GET | `/api/car-models/{id}/engines` | Get engine options for a car model |
| GET | `/api/engines` | Get engine options |
| GET | `/api/paints` | Get paint options |
| GET | `/api/wheel-designs` | Get wheel design options |
| GET | `/api/wheel-colors` | Get wheel color options |
| GET | `/api/caliper-colors` | Get brake caliper color options |
| GET | `/api/equipment` | Get special equipment options |
| POST | `/api/configurations` | Save a configuration |
| GET | `/api/configurations/{id}` | Get a saved configuration |
| POST | `/api/orders` | Submit an order |

## Features

- Real-time price calculation without page refresh
- Shareable configuration URLs
- Order submission with customer details
- Responsive design
- Max 5 special equipment items per configuration

## Theme & Design Tokens

The frontend uses a light-green / dark-green theme. All colors are defined once as CSS custom properties in the `:root` block of `frontend/src/App.vue` and consumed everywhere else via `var(--token-name)`. To retheme the app, edit that one block.

**Raw palette**

```css
--color-app-bg:            #E3F9E5;  /* light green page background         */
--color-app-bg-2:          #B0EAB3;  /* darker light green, accent tint     */
--color-menu-bg:           #052E16;  /* dark forest header / menu           */
--color-button-primary:    #0F8A2B;  /* emerald CTA                         */
--color-white:             #FFFFFF;
--color-icon-active:       #2F9E44;  /* active/icon green                   */
--color-status-ok:         #00FF01;  /* bright lime status dot              */
--color-green-dark:        #27AE60;  /* success UI (checkmarks, success h)  */
--color-red:               #E74C3C;  /* error / destructive                 */
--color-accent-deep:       #14532D;  /* deep-forest gradient companion      */
```

**Semantic tokens** (derived — what component styles actually reference)

```css
--color-text:              #0F172A;   /* body text on light surfaces */
--color-text-muted:        #475569;   /* secondary text, hints       */
--color-text-on-dark:      #FFFFFF;
--color-text-on-dark-mute: rgba(255, 255, 255, 0.72);

--surface-card:            #FFFFFF;   /* option cards, summary panel */
--surface-card-hover:      #F1FBF2;
--surface-selected:        #B0EAB3;
--surface-selected-soft:   rgba(176, 234, 179, 0.45);

--border-subtle:           rgba(5, 46, 22, 0.10);
--border-strong:           rgba(5, 46, 22, 0.22);
--border-selected:         #0F8A2B;
--border-on-dark:          rgba(255, 255, 255, 0.12);

--shadow-card:             0 2px 8px rgba(5, 46, 22, 0.08);
--shadow-card-hover:       0 6px 20px rgba(5, 46, 22, 0.15);
--shadow-header:           0 2px 14px rgba(5, 46, 22, 0.35);
```

**Gradients**

```css
/* emerald → deep forest, for light surfaces (cards, page body) */
--gradient-primary:         linear-gradient(90deg, #0F8A2B, #14532D);
--gradient-primary-soft:    linear-gradient(90deg,
                              rgba(15, 138, 43, 0.18),
                              rgba(20, 83, 45, 0.18));

/* lighter variant for elements on the dark forest header,
   where the emerald would otherwise blend into the background */
--gradient-primary-on-dark: linear-gradient(90deg, #B0EAB3, #6EE7B7);
```

## Architecture Documentation

- [**ARCHITECTURE.md**](ARCHITECTURE.md) — short, diagram-first overview (context, component and deployment diagrams, CI/CD pipeline).
- [**docs/arc42/**](docs/arc42/README.md) — full architecture description following the [arc42](https://arc42.org) template (quality goals, building blocks, runtime scenarios, ADRs, quality scenarios, risks, glossary).
- [**docs/structurizr/**](docs/structurizr/README.md) — executable [C4 model](https://c4model.com) in [Structurizr DSL](https://docs.structurizr.com/dsl); renders to context, container, component and deployment diagrams via Structurizr Lite or the CLI.

## CI/CD

Automated pipelines run on GitHub Actions.

- **`ci.yml`** — on every push and pull request:
  - Backend: Java 25 (Temurin) + `mvn verify`
  - Frontend: Node 22 + `npm run build`
  - Integration: spins up `database` + `backend` via `docker compose`, smoke-tests every REST endpoint
- **`docker-publish.yml`** — on push to `main` and `v*.*.*` tags:
  - Builds and pushes both images to GitHub Container Registry:
    - `ghcr.io/fbrase-itk/vehicle_configurator-backend`
    - `ghcr.io/fbrase-itk/vehicle_configurator-frontend`
  - Tags: `latest` (main), short SHA, branch name, semver on tag pushes
- **`dependabot.yml`** — weekly updates for Maven, npm, Docker base images, and GitHub Actions

## Project Structure

```
vehicle-configurator/
│
├── backend/
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/example/configurator/
│       │   │   ├── controller/
│       │   │   ├── service/
│       │   │   ├── model/
│       │   │   └── repository/
│       │   └── resources/
│       └── test/
│           └── java/
│
├── frontend/
│   ├── public/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   └── services/
│   ├── package.json
│   └── vite.config.js / angular.json / webpack.config.js
│
├── database/
│   ├── init/
│   │   └── 001-init.sql
│   └── seeds/
│
├── docker/
│   ├── compose.yml
│   ├── env/
│   │   ├── backend.env
│   │   ├── frontend.env
│   │   └── database.env
│   ├── frontend/
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   └── backend/
│       ├── Dockerfile
│       └── .dockerignore
│
├── docs/
├── README.md
├── .gitignore
└── .env
```
