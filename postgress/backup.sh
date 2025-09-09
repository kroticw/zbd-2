#!/bin/bash

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
    library > backup_full_$(date +%Y%m%d_%H%M%S).dump
