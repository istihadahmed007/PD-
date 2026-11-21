#!/bin/bash
set -e

PORT=${GAME_PORT:-7777}
MAX_PLAYERS=${MAX_PLAYERS:-16}
PROTOCOL=${PROTOCOL:-"websocket"} # "websocket" for browser clients or "enet" for raw UDP

echo "==============================================================================="
echo "       DTA: BANGLADESH OPEN-WORLD — AUTHORITATIVE DEDICATED SERVER            "
echo "==============================================================================="
echo "[SERVER] Port: $PORT"
echo "[SERVER] Protocol: $PROTOCOL"
echo "[SERVER] Max Players: $MAX_PLAYERS"
echo "[SERVER] Backend API URL: ${BACKEND_API_URL:-http://backend-api:4000}"

if [ "$PROTOCOL" = "websocket" ]; then
    echo "[SERVER] Launching Headless Godot 4 Dedicated Server with WebSocket..."
    exec godot --headless --path /server/project -- --server --websocket --port "$PORT" --max-players "$MAX_PLAYERS"
else
    echo "[SERVER] Launching Headless Godot 4 Dedicated Server with UDP/ENet..."
    exec godot --headless --path /server/project -- --server --port "$PORT" --max-players "$MAX_PLAYERS"
fi
