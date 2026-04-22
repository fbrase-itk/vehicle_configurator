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

The frontend uses a light-blue theme derived from the palette in [PRD.md → Prefered Colors](PRD.md#prefered-colors). All colors are defined once as CSS custom properties in the `:root` block of `frontend/src/App.vue` and consumed everywhere else via `var(--token-name)`. To retheme the app, edit that one block.

**Raw palette** (named after the PRD wishes)

```css
--color-app-bg:      #DDF3FE;  /* light blue page background         */
--color-app-bg-2:    #A7E2FF;  /* darker light blue, accent tint     */
--color-menu-bg:     #000233;  /* dark navy header / menu            */
--color-button-blue: #0049B0;  /* deep blue CTA                      */
--color-white:       #FFFFFF;
--color-icon-active: #2980b9;  /* active/icon blue                   */
--color-status-ok:   #00FF01;  /* bright green status dot            */
--color-green-dark:  #27ae60;  /* success UI (checkmarks, success h) */
--color-red:         #e74c3c;  /* error / destructive                */
--color-lila:        #7c3aed;  /* gradient companion for button-blue */
```

**Semantic tokens** (derived — what component styles actually reference)

```css
--color-text:              #0F172A;   /* body text on light surfaces */
--color-text-muted:        #475569;   /* secondary text, hints       */
--color-text-on-dark:      #FFFFFF;
--color-text-on-dark-mute: rgba(255, 255, 255, 0.72);

--surface-card:            #FFFFFF;   /* option cards, summary panel */
--surface-card-hover:      #F1F9FF;
--surface-selected:        #A7E2FF;
--surface-selected-soft:   rgba(167, 226, 255, 0.45);

--border-subtle:           rgba(0, 36, 80, 0.10);
--border-strong:           rgba(0, 36, 80, 0.22);
--border-selected:         #0049B0;
--border-on-dark:          rgba(255, 255, 255, 0.12);

--shadow-card:             0 2px 8px rgba(0, 36, 80, 0.08);
--shadow-card-hover:       0 6px 20px rgba(0, 36, 80, 0.15);
--shadow-header:           0 2px 14px rgba(0, 2, 51, 0.35);
```

**Gradients**

```css
/* deep-blue → lila, for light surfaces (cards, page body) */
--gradient-primary:         linear-gradient(90deg, #0049B0, #7c3aed);
--gradient-primary-soft:    linear-gradient(90deg,
                              rgba(0, 73, 176, 0.18),
                              rgba(124, 58, 237, 0.18));

/* lighter variant for elements on the dark navy header,
   where the deep blue would otherwise blend into the background */
--gradient-primary-on-dark: linear-gradient(90deg, #A7E2FF, #B79CFF);
```

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
