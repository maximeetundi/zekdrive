#!/usr/bin/env bash
# =============================================================
# ZekDrive - Script de développement
# Usage:
#   ./dev.sh          → rebuild complet + up (reset BDD)
#   ./dev.sh up       → juste docker compose up (sans reset)
#   ./dev.sh down     → arrêt propre (sans supprimer volumes)
#   ./dev.sh reset    → down -v + rebuild + up (reset BDD total)
#   ./dev.sh logs     → suivre les logs en temps réel
#   ./dev.sh migrate  → afficher les migrations appliquées
# =============================================================

set -e
cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

ACTION=${1:-reset}

log() { echo -e "${CYAN}[ZekDrive]${NC} $1"; }
ok()  { echo -e "${GREEN}✔${NC} $1"; }
warn(){ echo -e "${YELLOW}⚠${NC} $1"; }
err() { echo -e "${RED}✘${NC} $1"; }

banner() {
  echo -e "${BOLD}"
  echo "  ╔══════════════════════════════════╗"
  echo "  ║   🚗  ZekDrive Dev Script        ║"
  echo "  ╚══════════════════════════════════╝"
  echo -e "${NC}"
}

case "$ACTION" in

  # ── RESET COMPLET (défaut) ─────────────────────────────────────────────────
  reset|"")
    banner
    warn "Reset complet : suppression des volumes + rebuild + remigration"
    echo ""

    log "Arrêt + suppression des conteneurs et volumes..."
    docker compose down -v --remove-orphans 2>&1 | tail -5
    ok "Environnement nettoyé"

    log "Rebuild des images (api, admin, vitrine)..."
    docker compose build --no-cache api admin vitrine
    ok "Images reconstruites"

    log "Démarrage des services..."
    docker compose up -d
    ok "Services démarrés"

    log "Attente que la BDD soit prête..."
    sleep 5
    for i in {1..20}; do
      if docker compose exec -T postgres pg_isready -U "${POSTGRES_USER:-zekdrive}" -q 2>/dev/null; then
        ok "PostgreSQL est prêt"
        break
      fi
      sleep 2
      echo -n "."
    done

    echo ""
    log "Migrations auto-appliquées au démarrage de l'API (golang-migrate)"
    sleep 3
    docker compose logs --tail=20 api 2>&1 | grep -i "migrat\|RBAC\|seeded\|error\|start" || true

    echo ""
    log "État BDD après migrations :"
    docker compose exec -T postgres psql -U "${POSTGRES_USER:-zekdrive}" -d "${POSTGRES_DB:-zekdrive}" -t -c "
      SELECT '  Migration version : ' || version || ' (dirty=' || dirty || ')' FROM schema_migrations
      UNION ALL
      SELECT '  Rôles admin       : ' || COUNT(*) || ' rôles' FROM admin_roles
      UNION ALL
      SELECT '  Permissions       : ' || COUNT(*) || ' permissions' FROM admin_permissions
      UNION ALL
      SELECT '  Admins panel      : ' || COUNT(*) || ' comptes' FROM admin_users;
    " 2>/dev/null | grep -v "^$" || warn "BDD pas encore prête, relance: ./dev.sh migrate"

    echo ""
    ok "${BOLD}✨ ZekDrive est opérationnel !${NC}"
    echo ""
    echo -e "  ${BOLD}Services :${NC}"
    echo -e "  • API         → ${CYAN}http://localhost:8088${NC}"
    echo -e "  • Admin Panel → ${CYAN}http://localhost:3003${NC}"
    echo -e "  • Vitrine     → ${CYAN}http://localhost:3000${NC}"
    echo -e "  • Nginx       → ${CYAN}http://localhost:8082${NC}"
    echo ""
    echo -e "  ${BOLD}Admin par défaut :${NC}"
    echo -e "  • Email    : admin@zekdrive.com"
    echo -e "  • Password : admin123"
    echo ""
    ;;

  # ── UP SANS RESET ──────────────────────────────────────────────────────────
  up)
    banner
    log "Démarrage des services (sans reset des volumes)..."
    docker compose up -d
    ok "Services démarrés"
    docker compose ps
    ;;

  # ── DOWN ───────────────────────────────────────────────────────────────────
  down)
    banner
    log "Arrêt des services..."
    docker compose down
    ok "Services arrêtés (volumes préservés)"
    ;;

  # ── LOGS ───────────────────────────────────────────────────────────────────
  logs)
    log "Suivi des logs (Ctrl+C pour quitter)..."
    docker compose logs -f --tail=50 api admin
    ;;

  # ── MIGRATE : vérifier l'état ─────────────────────────────────────────────
  migrate)
    banner
    log "Migrations appliquées sur la BDD :"
    docker compose exec -T postgres psql -U "${POSTGRES_USER:-zekdrive}" -d "${POSTGRES_DB:-zekdrive}" \
      -c "SELECT version, dirty FROM schema_migrations ORDER BY version;" 2>/dev/null || \
      warn "BDD non accessible. Lance d'abord : ./dev.sh up"
    ;;

  # ── STATUS ─────────────────────────────────────────────────────────────────
  status)
    docker compose ps
    ;;

  *)
    err "Action inconnue: $ACTION"
    echo "Usage: ./dev.sh [reset|up|down|logs|migrate|status]"
    exit 1
    ;;
esac
