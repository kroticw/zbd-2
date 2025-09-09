#!/bin/bash

set -e

DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-postgres}
DB_USER=${DB_USER:-postgres}
DB_PASS=${DB_PASS:-postgres}

MIGRATIONS=(
    "01_create_schema.sql"
    "02_fill_dictionaries.sql"
    "03_create_fill_procedures.sql"
    "04_create_users_and_roles.sql"
)

for migration in "${MIGRATIONS[@]}"; do
    echo "Applying migration: $migration"
    cat "$migration" | docker compose exec -T postgres psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME"
    echo ""
done