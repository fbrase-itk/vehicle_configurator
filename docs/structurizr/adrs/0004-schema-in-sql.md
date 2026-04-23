# 4. Schema in SQL, not Hibernate

Date: 2025-03-22

## Status

Accepted

## Context

Hibernate's `ddl-auto=update` is convenient in development but
dangerous in production: surprise column drops on entity renames,
name-based column mapping collisions, no rollback story.

## Decision

Set `spring.jpa.hibernate.ddl-auto=none`. All DDL and seed data live
in `database/init/001-init.sql`, executed by the MySQL container's
entrypoint on first start. Hibernate only maps; it never creates,
drops, or mutates tables.

## Consequences

- The SQL file is the reviewable, versioned source of truth for the
  schema.
- Entity-schema mismatches fail fast at first JPA use (during startup
  or first query).
- Schema evolution is currently manual (edit `001-init.sql` on a fresh
  volume, or add `002-*.sql`). A proper migration tool (Flyway /
  Liquibase) should be adopted before the first real deployment —
  tracked as D-01 in the arc42 risk register.
