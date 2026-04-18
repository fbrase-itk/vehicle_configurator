# Vehicle Configurator

A web application for configuring vehicles with engine, paint, wheels, and special equipment options.

## Tech Stack

- **Frontend:** Vue.js 3 with Vite
- **Backend:** Java 17 with Spring Boot 3.2
- **Database:** MySQL 8.0
- **Infrastructure:** Docker Compose

## Quick Start

```bash
cd docker
docker compose up --build
```

The application will be available at:
- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8080/api

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/options` | Get all configuration options |
| GET | `/api/engines` | Get engine options |
| GET | `/api/paints` | Get paint options |
| GET | `/api/wheels` | Get wheel options |
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

## Project Structure

```
docker/
├── compose.yml          # Docker Compose configuration
├── .env                 # Environment variables
├── frontend/            # Vue.js application
├── backend/             # Spring Boot application
└── database/            # MySQL initialization scripts
```
