#!/bin/bash

set -e

DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-mysql}
DB_USER=${DB_USER:-root}
DB_PASS=${DB_PASS:-root}

echo "Dropping database '$DB_NAME'..."
docker compose exec -it mysql mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -e "DROP DATABASE IF EXISTS \`$DB_NAME\`;"

echo "Creating database '$DB_NAME'..."
docker compose exec -it mysql mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE \`$DB_NAME\`"

echo "Database '$DB_NAME' has been reset successfully!"