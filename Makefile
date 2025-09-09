# Database Management Makefile
# Commands for MySQL and PostgreSQL database operations

# Default database connection parameters
MYSQL_HOST ?= localhost
MYSQL_PORT ?= 3306
MYSQL_DB ?= library
MYSQL_USER ?= root
MYSQL_PASS ?= root

PG_HOST ?= localhost
PG_PORT ?= 5432
PG_DB ?= library
PG_USER ?= postgres
PG_PASS ?= postgres

.PHONY: mysql-connect
mysql-connect:
	@docker compose exec -it mysql mysql -h$(MYSQL_HOST) -P$(MYSQL_PORT) -u$(MYSQL_USER) -p$(MYSQL_PASS) --default-character-set=utf8mb4 $(MYSQL_DB)

.PHONY: mysql-migrate
mysql-migrate:
	@echo "Applying MySQL migrations..."
	@cd mysql && DB_HOST=$(MYSQL_HOST) DB_PORT=$(MYSQL_PORT) DB_NAME=$(MYSQL_DB) DB_USER=$(MYSQL_USER) DB_PASS=$(MYSQL_PASS) ./apply_migrations.sh

.PHONY: mysql-reset
mysql-reset:
	@echo "Resetting MySQL database..."
	@cd mysql && DB_HOST=$(MYSQL_HOST) DB_PORT=$(MYSQL_PORT) DB_NAME=$(MYSQL_DB) DB_USER=$(MYSQL_USER) DB_PASS=$(MYSQL_PASS) ./reset_db.sh

.PHONY: mysql-backup
mysql-backup:
	@echo "Start backup mysql db"
	@cd mysql && ./backup.sh

.PHONY: pg-connect
pg-connect:
	@PGPASSWORD=$(PG_PASS) docker compose exec -it postgres psql -h $(PG_HOST) -p $(PG_PORT) -U $(PG_USER) -d $(PG_DB)

.PHONY: pg-migrate
pg-migrate:
	@echo "Applying PostgreSQL migrations..."
	@cd postgress && DB_HOST=$(PG_HOST) DB_PORT=$(PG_PORT) DB_NAME=$(PG_DB) DB_USER=$(PG_USER) DB_PASS=$(PG_PASS) ./apply_migrations.sh

.PHONY: pg-reset
pg-reset:
	@echo "Resetting PostgreSQL database..."
	@cd postgress && DB_HOST=$(PG_HOST) DB_PORT=$(PG_PORT) DB_NAME=$(PG_DB) DB_USER=$(PG_USER) DB_PASS=$(PG_PASS) ./reset_db.sh

.PHONY: pg-backup
pg-backup:
	@echo "Start backup mysql db"
	@cd postgress && ./backup.sh
