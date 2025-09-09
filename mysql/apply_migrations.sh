#!/bin/bash

set -e

DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-mysql}
DB_USER=${DB_USER:-root}
DB_PASS=${DB_PASS:-root}

MIGRATIONS=(
#    "01_create_schema.sql"
#    "02_fill_dictionaries.sql"
#    "03_create_fill_procedures.sql"
#    "04_create_users_and_roles.sql"
    "05_create_vpd.sql"
)

for migration in "${MIGRATIONS[@]}"; do
    echo "Applying migration: $migration"
    cat "$migration" | docker compose exec -T mysql mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" --default-character-set=utf8mb4 "$DB_NAME"
    echo ""
done