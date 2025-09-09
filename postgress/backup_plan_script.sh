#!/bin/bash

BACKUP_DIR="./backups"
RETENTION_DAYS=7

# Создаем директорию для резервных копий
mkdir -p "$BACKUP_DIR"

# Полное ежедневное резервное копирование
echo "=== Плановое резервное копирование $(date) ==="
docker compose exec postgres pg_dump \
    -U postgres \
    -h localhost \
    -p 5432 \
    --verbose \
    --clean \
    --create \
    --if-exists \
    --format=custom \
    --compress=9 \
    library > "$BACKUP_DIR/daily_backup_$(date +%Y%m%d_%H%M%S).dump"

# Инкрементальное копирование (WAL архивы) - упрощенная версия
echo "=== Создание инкрементальной копии ==="
docker compose exec postgres pg_dump \
    -U postgres \
    -h localhost \
    -p 5432 \
    --verbose \
    --data-only \
    --format=custom \
    --compress=9 \
    library > "$BACKUP_DIR/incremental_$(date +%Y%m%d_%H%M%S).dump"

# Очистка старых резервных копий
echo "=== Очистка резервных копий старше $RETENTION_DAYS дней ==="
find "$BACKUP_DIR" -name "*.dump" -type f -mtime +$RETENTION_DAYS -delete

echo "Плановое резервное копирование завершено"
echo "Доступные резервные копии:"
ls -la "$BACKUP_DIR"/*.dump