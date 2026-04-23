# 1. Vue 3 + Vite as frontend stack

Date: 2025-03-15

## Status

Accepted

## Context

The PRD allows Vue.js, React, or Angular for the frontend. We need a
small SPA with two pages (configurator, summary), a live 3D preview, a
reactive total-price label, and a sticky app header that per-page
components can inject controls into.

## Decision

Use **Vue 3** with single-file components, **Vue Router 4** for
routing, and **Vite** as dev server and production bundler. No
additional state-management library (no Pinia / Vuex).

## Consequences

- Vue's built-in reactivity covers the app's state needs without an
  external store.
- `<Teleport to="#header-actions">` provides a clean way for pages to
  contribute controls to the global header.
- Vite's dev proxy makes the `/api/*` URL work identically in dev,
  compose-prod, and Azure with no code changes.
- Team must be comfortable with Vue 3 composition/options API — a
  known alternative (React) would have been equally viable.
