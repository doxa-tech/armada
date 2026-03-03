# Chatwoot

## Prerequisites

### PostgreSQL extensions

Before deploying, ensure the following extensions are enabled on the `chatwoot` database:

- **`vector`** (pgvector) — required for AI/embedding features. Needs the `postgresql-15-pgvector` package installed first:
  ```bash
  ansible-playbook install_pg_vector.yml
  ansible-playbook enable_postgres_extension.yml
  # database: chatwoot, extension: vector
  ```

- **`pg_stat_statements`**:
  ```bash
  ansible-playbook enable_postgres_extension.yml
  # database: chatwoot, extension: pg_stat_statements
  ```
