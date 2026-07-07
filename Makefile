.PHONY: dev dev-d prod down down-prod logs logs-api build build-prod \
        build-api build-admin build-vitrine \
        migrate-up migrate-down shell-api shell-db shell-redis clean restart

# ─────────────────────────────────────────────────────────────────────────────
# ⚠️  RÈGLE ABSOLUE : Toujours builder UN service à la fois (RAM limitée)
#     Ne jamais utiliser `docker compose build` sans spécifier un service.
#     Utiliser `make build` ou `make build-prod` qui buildet séquentiellement.
# ─────────────────────────────────────────────────────────────────────────────

# ── Build séquentiel DEV (un service à la fois) ───────────────────────────────
# Usage: make build
build:
	@echo "🔨 [1/3] Build API..."
	docker compose -f docker-compose.yml build --no-cache api
	@echo "🔨 [2/3] Build Admin..."
	docker compose -f docker-compose.yml build --no-cache admin
	@echo "🔨 [3/3] Build Vitrine..."
	docker compose -f docker-compose.yml build --no-cache vitrine
	@echo "✅ Build DEV terminé."

# ── Build séquentiel PROD (un service à la fois) ──────────────────────────────
# Usage: make build-prod
build-prod:
	@echo "🔨 [1/3] Build API (prod)..."
	docker compose -f docker-compose.prod.yml build --no-cache api
	@echo "🔨 [2/3] Build Admin (prod)..."
	docker compose -f docker-compose.prod.yml build --no-cache admin
	@echo "🔨 [3/3] Build Vitrine (prod)..."
	docker compose -f docker-compose.prod.yml build --no-cache vitrine
	@echo "✅ Build PROD terminé."

# ── Builds individuels (si besoin de rebuilder un seul service) ───────────────
build-api:
	@echo "🔨 Build API uniquement..."
	docker compose -f docker-compose.yml build --no-cache api

build-admin:
	@echo "🔨 Build Admin uniquement..."
	docker compose -f docker-compose.yml build --no-cache admin

build-vitrine:
	@echo "🔨 Build Vitrine uniquement..."
	docker compose -f docker-compose.yml build --no-cache vitrine

build-api-prod:
	@echo "🔨 Build API (prod) uniquement..."
	docker compose -f docker-compose.prod.yml build --no-cache api

build-admin-prod:
	@echo "🔨 Build Admin (prod) uniquement..."
	docker compose -f docker-compose.prod.yml build --no-cache admin

build-vitrine-prod:
	@echo "🔨 Build Vitrine (prod) uniquement..."
	docker compose -f docker-compose.prod.yml build --no-cache vitrine

# ── Development ───────────────────────────────────────────────────────────────
# ⚠️  dev et dev-d lancent les services SANS rebuild pour économiser la RAM.
#     Faire `make build` d'abord, puis `make dev-d`.

dev:
	docker compose -f docker-compose.yml up

dev-d:
	docker compose -f docker-compose.yml up -d

# ── Production ────────────────────────────────────────────────────────────────
# ⚠️  Faire `make build-prod` AVANT `make prod` pour ne pas builder en parallèle.

prod:
	docker compose -f docker-compose.prod.yml up -d

# ── Teardown ──────────────────────────────────────────────────────────────────

down:
	docker compose -f docker-compose.yml down

down-prod:
	docker compose -f docker-compose.prod.yml down

# ── Logs ──────────────────────────────────────────────────────────────────────

logs:
	docker compose -f docker-compose.yml logs -f

logs-prod:
	docker compose -f docker-compose.prod.yml logs -f

logs-api:
	docker compose -f docker-compose.yml logs -f api

logs-admin:
	docker compose -f docker-compose.yml logs -f admin

logs-vitrine:
	docker compose -f docker-compose.yml logs -f vitrine

# ── Migrations ────────────────────────────────────────────────────────────────

migrate-up:
	docker compose -f docker-compose.yml exec api ./migrate -path /app/migrations -database "$$DATABASE_URL" up

migrate-down:
	docker compose -f docker-compose.yml exec api ./migrate -path /app/migrations -database "$$DATABASE_URL" down 1

migrate-up-prod:
	docker compose -f docker-compose.prod.yml exec api ./migrate -path /app/migrations -database "$$DATABASE_URL" up

# ── Shells ────────────────────────────────────────────────────────────────────

shell-api:
	docker compose -f docker-compose.yml exec api sh

shell-db:
	docker compose -f docker-compose.yml exec postgres psql -U $${POSTGRES_USER:-zekdrive} -d $${POSTGRES_DB:-zekdrive}

shell-redis:
	docker compose -f docker-compose.yml exec redis redis-cli

# ── Cleanup ───────────────────────────────────────────────────────────────────

clean:
	docker compose -f docker-compose.yml down -v --remove-orphans

clean-prod:
	docker compose -f docker-compose.prod.yml down -v --remove-orphans

# ── Convenience ───────────────────────────────────────────────────────────────

# Rebuild + restart complet (séquentiel, safe pour RAM limitée)
restart: down build dev-d

# Restart prod complet (séquentiel)
restart-prod: down-prod build-prod prod
