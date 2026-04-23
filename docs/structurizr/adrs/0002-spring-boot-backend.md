# 2. Spring Boot 4 on Java 25

Date: 2025-03-15

## Status

Accepted

## Context

The PRD mandates Java for backend services. The domain (catalog +
configuration + orders) is small; we do not need microservices or
reactive streams.

## Decision

A single-module Spring Boot application, packaged as a fat-jar. Minimal
starters: `spring-boot-starter-web`, `spring-boot-starter-data-jpa`,
`spring-boot-starter-validation`, plus the MySQL Connector/J. Enable
virtual threads (`spring.threads.virtual.enabled=true`).

## Consequences

- One container, one port, one fat-jar — simplest possible deployment.
- Virtual threads handle concurrent HTTP requests without a tuned
  thread pool; adequate for a mostly-DB-bound workload.
- Using bleeding-edge Java 25 + Spring Boot 4 ties us to current
  Temurin images and Spring release cadence — acceptable for a
  prototype.
