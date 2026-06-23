# ZekDrive 🚗

> Plateforme de mobilité urbaine premium — VTC, Moto-taxi, Vélo, Livraison

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                     NGINX (80/443)                  │
├──────────────┬──────────────┬───────────────────────┤
│  zekdrive.com│admin.zekdrive│     api.zekdrive.com   │
│   (Vitrine)  │    (Admin)   │      (Go API)          │
│  Nuxt 3 SSG  │  Nuxt 3 SSR  │    Fiber + PostGIS     │
└──────────────┴──────────────┴───────────────────────┘
                                        │
                          ┌─────────────┼─────────────┐
                          │             │             │
                     PostgreSQL       Redis      WebSocket
                    16 + PostGIS     7 Alpine      Hub
```

## Services

| Service    | Description                        | Dev Port |
|------------|------------------------------------|----------|
| `api`      | Go Fiber REST API + WebSocket      | 8080     |
| `admin`    | Nuxt 3 Admin Dashboard             | 3001     |
| `vitrine`  | Nuxt 3 Landing / Showcase          | 3000     |
| `postgres` | PostgreSQL 16 + PostGIS            | 5432     |
| `redis`    | Redis 7                            | 6379     |
| `nginx`    | Reverse Proxy                      | 80 / 443 |
| `pgadmin`  | DB Admin UI (dev only)             | 5050     |

---

## Quick Start

### Prerequisites

- Docker >= 24.0
- Docker Compose >= 2.0
- `make`

### Development

```bash
git clone https://github.com/your-org/zekdrive
cd zekdrive
cp .env.example .env
# Edit .env — at minimum change DB_PASSWORD and JWT secrets
make dev
```

**Access points (all through Nginx on port 80):**

| URL | Service |
|-----|---------|
| http://localhost | 🌐 Vitrine |
| http://localhost/admin/ | 🎛️ Admin Panel |
| http://localhost/api/v1/ | 🔌 REST API |
| ws://localhost/ws | ⚡ WebSocket |
| http://localhost:5050 | 📊 PgAdmin |

### Production

```bash
cp .env.example .env
# Set all production values — strong passwords, real secrets
make prod
```

Place TLS certificates at:
- `nginx/ssl/fullchain.pem`
- `nginx/ssl/privkey.pem`

---

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make dev` | Start all services with live reload (foreground) |
| `make dev-d` | Start all services in detached mode |
| `make prod` | Build and start production stack |
| `make down` | Stop dev stack |
| `make down-prod` | Stop production stack |
| `make logs` | Tail all logs |
| `make logs-api` | Tail API logs only |
| `make build` | Rebuild all images (no cache) |
| `make migrate-up` | Run database migrations up |
| `make migrate-down` | Roll back last migration |
| `make shell-api` | Open shell in API container |
| `make shell-db` | Open psql in PostgreSQL container |
| `make shell-redis` | Open redis-cli |
| `make clean` | Stop stack and remove all volumes |
| `make restart` | `down` then `dev` |

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_ENV` | Runtime environment (`development` / `production`) | `development` |
| `APP_PORT` | Go API listen port | `8080` |
| `DB_HOST` | PostgreSQL host | `postgres` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `DB_NAME` | Database name | `zekdrive` |
| `DB_USER` | Database user | `zekdrive` |
| `DB_PASSWORD` | Database password | *(set in .env)* |
| `DB_SSL_MODE` | SSL mode for DB connection | `disable` |
| `POSTGRES_DB` | PostgreSQL DB (docker image var) | `zekdrive` |
| `POSTGRES_USER` | PostgreSQL user (docker image var) | `zekdrive` |
| `POSTGRES_PASSWORD` | PostgreSQL password (docker image var) | *(set in .env)* |
| `REDIS_URL` | Full Redis URL | `redis://redis:6379` |
| `REDIS_PASSWORD` | Redis auth password | *(empty in dev)* |
| `JWT_ACCESS_SECRET` | HMAC secret for access tokens | *(set in .env)* |
| `JWT_REFRESH_SECRET` | HMAC secret for refresh tokens | *(set in .env)* |
| `JWT_ACCESS_EXPIRY` | Access token TTL | `15m` |
| `JWT_REFRESH_EXPIRY` | Refresh token TTL | `7d` |
| `NUXT_PUBLIC_API_URL` | Public API base URL for frontend | `http://localhost/api/v1` |
| `NUXT_PUBLIC_WS_URL` | Public WebSocket URL for frontend | `ws://localhost/ws` |
| `PGADMIN_EMAIL` | PgAdmin login email | `admin@zekdrive.com` |
| `PGADMIN_PASSWORD` | PgAdmin login password | *(set in .env)* |
| `FIREBASE_CREDENTIALS_FILE` | Path to Firebase service account JSON | *(optional)* |
| `SMS_PROVIDER` | SMS gateway provider name | *(optional)* |
| `SMS_API_KEY` | SMS gateway API key | *(optional)* |
| `SMS_SENDER_ID` | SMS sender identifier | `ZekDrive` |

---

## API Endpoints

| Group | Prefix |
|-------|--------|
| Authentication | `/api/v1/auth/*` |
| Users | `/api/v1/users/*` |
| Drivers | `/api/v1/drivers/*` |
| Trips | `/api/v1/trips/*` |
| Deliveries | `/api/v1/deliveries/*` |
| Vehicles | `/api/v1/vehicles/*` |
| Zones | `/api/v1/zones/*` |
| Pricing | `/api/v1/pricing/*` |
| Admin | `/api/v1/admin/*` |
| WebSocket | `ws://localhost/ws` |

---

## Features

- 🚗 **VTC** — voiture avec chauffeur
- 🏍️ **Moto-taxi** — livraison et transport rapide
- 🚲 **Vélo** — mobilité douce
- 📦 **Livraison de colis** — dernière mile delivery
- 📍 **Tracking GPS temps réel** — PostGIS spatial queries
- 💬 **Chat conducteur-client** — via WebSocket
- ⚡ **Notifications push** — Firebase FCM
- 🔐 **Auth JWT sécurisé** — access + refresh tokens
- 📊 **Dashboard admin complet** — Nuxt 3 SSR
- 🌐 **Site vitrine** — Nuxt 3 SSG

---

## Project Structure

```
zekdrive/
├── api/                   # Go Fiber backend
│   ├── Dockerfile
│   ├── .air.toml          # Live reload config
│   ├── go.mod
│   └── ...
├── admin/                 # Nuxt 3 admin panel
│   ├── Dockerfile
│   ├── nuxt.config.ts
│   └── ...
├── vitrine/               # Nuxt 3 showcase site
│   ├── Dockerfile
│   ├── nuxt.config.ts
│   └── ...
├── nginx/
│   ├── nginx.conf         # Production config (HTTPS)
│   └── nginx.dev.conf     # Development config (HTTP)
├── scripts/
│   └── init-db.sh         # PostgreSQL extension bootstrap
├── docker-compose.yml     # Development stack
├── docker-compose.prod.yml# Production stack
├── Makefile
├── .env.example
└── README.md
```

---

## License

MIT © ZekDrive
