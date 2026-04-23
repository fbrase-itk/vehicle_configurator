# 5. Aggregated `/api/options` endpoint

Date: 2025-03-25

## Status

Accepted

## Context

The configurator UI needs all catalog data (car models, engines,
paints, wheel designs/colors, caliper colors, equipment) to render
its first meaningful paint. Issuing seven parallel GETs would:

- add HTTP/1.1 head-of-line latency,
- require client-side orchestration code, and
- complicate caching (seven cache keys instead of one).

## Decision

Expose a single coarse-grained endpoint `GET /api/options` that
returns all catalog collections in one JSON response. Keep the
per-resource endpoints for potential future admin/CMS tooling.

## Consequences

- One HTTP round-trip powers the entire configurator's static data.
- After the initial load, property changes are purely in-memory
  operations (no further network calls) — enables the "instant
  feedback" quality goal.
- If the catalog grows beyond a few hundred KB, we'll need to revisit
  (paginated endpoints, selective field loading, or GraphQL).
