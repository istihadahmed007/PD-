#!/bin/bash
# ==============================================================================
# AUTOMATED PRODUCTION DEPLOYMENT SCRIPT FOR LINUX VPS
# Target: Ubuntu 22.04 / Debian 12
# Project: Bangladesh Open-World (DTA)
# ==============================================================================
set -e

DOMAIN=${1:-"bc.vartualtutor.com"}
EMAIL=${2:-"admin@vartualtutor.com"}

echo "==============================================================================="
echo "       DTA: BANGLADESH OPEN-WORLD — PRODUCTION DEPLOYMENT SCRIPT              "
echo "==============================================================================="
echo "Target Domain: $DOMAIN"
echo "Admin Email:   $EMAIL"
echo "==============================================================================="

# 1. Install Docker & Docker Compose if missing
if ! command -v docker &> /dev/null; then
    echo "[SETUP] Installing Docker Engine..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable --now docker
    rm get-docker.sh
fi

if ! docker compose version &> /dev/null; then
    echo "[SETUP] Installing Docker Compose plugin..."
    apt-get update && apt-get install -y docker-compose-plugin
fi

# 2. Prepare Environment
cd "$(dirname "$0")"

if [ ! -f .env.production ]; then
    echo "[CONFIG] Generating .env.production from template..."
    cp .env.example .env.production
    sed -i "s/YOUR-DOMAIN.com/$DOMAIN/g" .env.production
    
    # Generate cryptographically secure random secrets
    DB_PASS=$(openssl rand -hex 16)
    JWT_SEC=$(openssl rand -hex 32)
    SRV_KEY=$(openssl rand -hex 24)
    
    sed -i "s/CHANGE_ME_STRONG_DATABASE_PASSWORD_2026/$DB_PASS/g" .env.production
    sed -i "s/GENERATE_A_64_CHARACTER_RANDOM_SECRET_FOR_JWT_TOKENS/$JWT_SEC/g" .env.production
    sed -i "s/GENERATE_A_SECRET_KEY_FOR_GODOT_TO_BACKEND_SYNC/$SRV_KEY/g" .env.production
fi

# 3. Ensure web build directory exists
mkdir -p ../builds/web

# 4. Pull/Build and start containers
echo "[DOCKER] Building and launching multi-container application stack..."
docker compose --env-file .env.production up -d --build

# 5. Health Check
echo "[VERIFY] Waiting for service health checks..."
sleep 10

if curl -s http://localhost:4000/health | grep -q "HEALTHY"; then
    echo "[SUCCESS] Backend API is HEALTHY!"
else
    echo "[WARN] Backend API is starting up; check logs with: docker compose logs backend-api"
fi

echo "==============================================================================="
echo "DEPLOYMENT COMPLETE!"
echo "Game Web Client: http://play.$DOMAIN (or https://play.$DOMAIN with SSL)"
echo "Backend REST:    http://api.$DOMAIN/health"
echo "Multiplayer WSS: ws://api.$DOMAIN/game (or wss://api.$DOMAIN/game with SSL)"
echo "==============================================================================="
