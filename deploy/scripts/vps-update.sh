#!/bin/bash
# VPS'te proje klasöründen: bash deploy/scripts/vps-update.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

echo ">> git pull"
git pull origin main

echo ">> docker compose build & up"
cd deploy
docker compose -f docker-compose.prod.yml up -d --build

echo ">> health"
sleep 2
curl -sf http://127.0.0.1:3000/health && echo ""

echo ">> OK"
