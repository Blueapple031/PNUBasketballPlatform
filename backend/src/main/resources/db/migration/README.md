# Versioned database migrations

The existing production database is adopted at Flyway baseline version `100`.
New migrations start at `V101` and must remain backward-compatible with both
Blue and Green application versions during the rollback window.

Use names such as `V101__add_example_column.sql`. Automatic deploys permit only
backward-compatible expansion. Destructive changes (`DROP`, `TRUNCATE`, rename,
type/`NOT NULL` changes, bulk delete, immediate constraints, and unique indexes)
require a separately reviewed contract release after all application versions
have stopped using the old schema. The CI policy intentionally fails closed.
