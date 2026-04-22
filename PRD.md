# Vehicle Configurator Prototype

## Overview

A vehicle configurator (web application) is to be developed that allows the configuration of a car with the following options:

- Engine power
- Paint finish
- Wheels/Rims
- Special equipment (max. 5 items, e.g., air conditioning, sound system, driver safety systems, etc.)

## Functional Requirements

Any change to the configuration should immediately reflect in the displayed price without requiring a page refresh.

At the end of the configuration, a summary should be displayed and the order should be submittable.

Additionally, a URL should be generated that allows the user to access the selected configuration at any time.

Both the configuration properties and the orders are to be stored in a database.

As guidance for design and user experience, the numerous configurators available on the market can serve as reference.

Implementation of authentication or authorization logic for users is not required.

## Technical Framework

- **Frontend:** Vue.js, React, or Angular
- **Backend (Services):** Java
- **Operations:** Docker Compose

## Expected Project Structure

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
## Tasks

- Task-1: Implement the project with frontend in Vue.js and database MySQL and do a minimal version first
- Task-2: Can you integrate Three.js to render the car and get a nice model (e.g. the Ferrari) for this pupose 
- Task-3: The repo is moved to github (c.f. "git remote -v") - Can you add a Github Actions based workflow for CI/CD integration ?