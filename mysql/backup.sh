#!/bin/bash

docker compose exec mysql mysqldump \
    --user=root \
    --password=root \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    --hex-blob \
    --complete-insert \
    --extended-insert \
    --add-drop-database \
    --add-drop-table \
    --databases library > backup_full_$(date +%Y%m%d_%H%M%S).sql
