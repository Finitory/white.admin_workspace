#!/usr/bin/env bash
set -euo pipefail

# Only executed during initial PostgreSQL data initialization.

migration_password="$(
  cat /run/secrets/admin_auth_migration_password
)"
runtime_password="$(
  cat /run/secrets/admin_auth_runtime_password
)"

psql \
  -v ON_ERROR_STOP=1 \
  -v migration_password="$migration_password" \
  -v runtime_password="$runtime_password" \
  --username "$POSTGRES_USER" \
  --dbname postgres <<'SQL'

CREATE ROLE admin_auth_migration
    LOGIN
    NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
    PASSWORD :'migration_password';

CREATE ROLE admin_auth_runtime
    LOGIN
    NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION
    PASSWORD :'runtime_password';

CREATE DATABASE admin_auth_db OWNER postgres;

\connect admin_auth_db

REVOKE ALL ON DATABASE admin_auth_db FROM PUBLIC;

GRANT CONNECT ON DATABASE admin_auth_db
    TO admin_auth_migration, admin_auth_runtime;

REVOKE ALL ON SCHEMA public FROM PUBLIC;

GRANT USAGE, CREATE ON SCHEMA public
    TO admin_auth_migration;

GRANT USAGE ON SCHEMA public
    TO admin_auth_runtime;

ALTER DEFAULT PRIVILEGES
FOR ROLE admin_auth_migration
IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLES TO admin_auth_runtime;

SQL

unset migration_password runtime_password
