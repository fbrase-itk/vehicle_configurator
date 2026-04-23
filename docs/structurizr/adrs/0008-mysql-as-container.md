# 8. MySQL as a Container App

Date: 2025-04-10

## Status

Accepted (provisional)

## Context

The prototype needs a relational database in Azure. A managed PaaS
option (Azure Database for MySQL Flexible Server) is the obviously
more durable choice, but:

- it costs roughly €15–25/month even at the smallest SKU (~200× what
  we're paying today for everything else), and
- it takes ~10 minutes to provision and requires VNET integration, SSL
  certs, and firewall rules to talk to ACA.

## Decision

Run MySQL 8.4 as an **Azure Container App** with `min=max=1` replica,
internal TCP ingress on port 3306. Persistence is the replica
filesystem.

## Consequences

- Setup fits in `azure/01-setup.sh` with no extra resources.
- **ACA replica recycling wipes the data.** This is explicitly
  acceptable for a prototype where no real users rely on
  persistence.
- Cannot go live with real users without replacing this. The fix is
  documented as tech-debt D-02 in the arc42 risk register: migrate to
  Azure Database for MySQL Flexible Server, keep DDL via Flyway (which
  also resolves D-01).
- Local development is unaffected — Docker Compose uses a named
  volume (`db-data`) that persists across container restarts.
