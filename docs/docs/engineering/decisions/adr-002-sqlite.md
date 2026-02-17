# ADR-002: SQLite

## Status

**Accepted**

## Context

CalcTek Calculator needs a database to persist user accounts and calculation history. The database must be simple to set up locally, require no additional Docker service, and support the small-to-moderate data volumes expected from a calculator application.

Options considered:

1. **PostgreSQL** -- Full-featured relational database.
2. **MySQL/MariaDB** -- Popular relational database with strong Laravel support.
3. **SQLite** -- Embedded, file-based relational database.

## Decision

Use **SQLite** as the sole database for both local development and production.

## Rationale

- **Zero infrastructure**: SQLite requires no separate database service, container, or network configuration. The database is a single file (`database/database.sqlite`).
- **Simplified Docker Compose**: Eliminates a database container, reducing resource usage and startup time. The backend container is self-contained.
- **Sufficient for the workload**: A calculator app has low concurrent-write requirements. Each user performs sequential calculations, and SQLite handles this pattern well with WAL mode.
- **Laravel native support**: Laravel's Eloquent ORM and migration system support SQLite out of the box with `DB_CONNECTION=sqlite`.
- **Portable**: The entire database can be backed up, restored, or inspected by copying a single file.

## Consequences

- SQLite does not support high-concurrency writes. If the application scales to many simultaneous users, migration to PostgreSQL may be necessary.
- In production (GKE), the SQLite file must live on a Persistent Volume Claim (PVC) to survive pod restarts.
- Some SQL features available in PostgreSQL/MySQL (e.g., `JSON` column operations, `UPSERT` syntax) may differ or be unavailable in SQLite.
