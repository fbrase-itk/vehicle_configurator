# 3. UUID strings for Configuration IDs

Date: 2025-03-20

## Status

Accepted

## Context

Configurations must have a **shareable URL** (PRD requirement). Using
a sequential integer PK would leak total configuration count and make
enumeration trivial.

## Decision

`configurations.id` is a `VARCHAR(36)` UUID generated server-side via
`UUID.randomUUID().toString()` in `ConfiguratorService.saveConfiguration`.
All other entities keep `INT AUTO_INCREMENT`.

## Consequences

- `/summary/<uuid>` URLs are safe to paste anywhere.
- No DB extension needed; UUIDs serialise cleanly in JSON.
- Minor index overhead versus an integer PK — irrelevant at our scale.
- Tooling that expects numeric IDs (e.g. naive URL scraping) won't
  work — acceptable trade-off.
