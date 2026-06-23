.PHONY: dev dev-d prod down down-prod logs logs-api build \
        migrate-up migrate-down shell-api shell-db shell-redis clean restart

# ── Development ───────────────────────────────────────────────────────────────

dev:
	docker compose -f docker-compose.yml up --build

dev-d:
	docker compose -f docker-compose.yml up --build -d

# ── Production ────────────────────────────────────────────────────────────────

prod:
	docker compose -f docker-compose.prod.yml up --build -d

# ── Teardown ──────────────────────────────────────────────────────────────────

down:
	docker compose down

down-prod:
	docker compose -f docker-compose.prod.yml down

# ── Logs ──────────────────────────────────────────────────────────────────────

logs:
	docker compose logs -f

logs-api:
	docker compose logs -f api

# ── Build ─────────────────────────────────────────────────────────────────────

build:
	docker compose build --no-cache

# ── Migrations ────────────────────────────────────────────────────────────────

migrate-up:
	docker compose exec api ./migrate -path /app/migrations -database "$$DATABASE_URL" up

migrate-down:
	docker compose exec api ./migrate -path /app/migrations -database "$$DATABASE_URL" down 1

# ── Shells ────────────────────────────────────────────────────────────────────

shell-api:
	docker compose exec api sh

shell-db:
	docker compose exec postgres psql -U $${POSTGRES_USER:-zekdrive} -d $${POSTGRES_DB:-zekdrive}

shell-redis:
	docker compose exec redis redis-cli

# ── Cleanup ───────────────────────────────────────────────────────────────────

clean:
	docker compose down -v --remove-orphans

# ── Convenience ───────────────────────────────────────────────────────────────

restart: down dev
