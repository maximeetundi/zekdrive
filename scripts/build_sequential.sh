#!/bin/bash
# ════════════════════════════════════════════════════════════════
# ZekDrive — Build séquentiel (un service à la fois pour économiser la RAM)
# ════════════════════════════════════════════════════════════════
set -e
cd /root/zekdrive

echo ""
echo "════════════════════════════════════════════"
echo " ZekDrive — Build séquentiel"
echo "════════════════════════════════════════════"
echo ""

# 1. API (Go)
echo "▶ [1/3] Build API (Go)..."
docker compose build api
echo "✅ API buildée"
echo ""

# 2. Admin (Nuxt.js)
echo "▶ [2/3] Build Admin (Nuxt)..."
docker compose build admin
echo "✅ Admin buildé"
echo ""

# 3. Vitrine (Nginx/Static)
echo "▶ [3/3] Build Vitrine..."
docker compose build vitrine
echo "✅ Vitrine buildée"
echo ""

# Démarrage de tous les services
echo "▶ Démarrage de tous les services..."
docker compose up -d
echo ""

# Attendre que l'API soit healthy
echo "▶ Attente de l'API (migrations incluses)..."
for i in $(seq 1 30); do
  STATUS=$(docker compose ps api --format '{{.Health}}' 2>/dev/null || echo "starting")
  if [ "$STATUS" = "healthy" ]; then
    echo "✅ API opérationnelle !"
    break
  fi
  echo "  [$i/30] API status: $STATUS — attente 10s..."
  sleep 10
done

echo ""
echo "════════════════════════════════════════════"
echo " 📊 Statut des services :"
docker compose ps
echo ""
echo " 🔗 Accès :"
echo "   Panel Admin : http://localhost:3003"
echo "   API         : http://localhost:8082/api/v1/health"
echo "   PgAdmin     : http://localhost:5050 (si activé)"
echo ""
echo " 🔑 Credentials admin :"
echo "   Email  : admin@zekdrive.cm"
echo "   Pass   : admin123"
echo "════════════════════════════════════════════"
