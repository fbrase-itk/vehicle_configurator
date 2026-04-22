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
