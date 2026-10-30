#!/bin/bash

# Pre-launch configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/../docker-compose.yml"
OLLAMA_PORT="${OLLAMA_PORT:-11434}"

# Load any overriding environment variables
source $SCRIPT_DIR/../.env

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🦙 Starting local LLM services..."

# Function to check if a port is in use
is_port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# Check Ollama is installed
if ! command -v ollama >/dev/null 2>&1; then
    echo -e "${RED}❌ Ollama is not installed. Install it with: brew install ollama${NC}"
    echo -e "${RED}   or download it from https://ollama.com${NC}"
    exit 1
fi

# Check a model has been configured
if [ -z "$OLLAMA_MODEL" ]; then
    echo -e "${RED}❌ OLLAMA_MODEL is not set. Assign it in your .env file (e.g. OLLAMA_MODEL=llama3.2:3b)${NC}"
    exit 1
fi

# Start the Ollama server natively (keeps Apple Silicon GPU acceleration;
# Docker has no Metal GPU passthrough)
if is_port_in_use $OLLAMA_PORT; then
    echo -e "${YELLOW}Ollama already appears to be running on port $OLLAMA_PORT, reusing it...${NC}"
else
    echo -e "${GREEN}Starting ollama serve on port $OLLAMA_PORT...${NC}"
    OLLAMA_HOST="127.0.0.1:$OLLAMA_PORT" nohup ollama serve > ollama.log 2>&1 &
    OLLAMA_PID=$!

    # Wait a moment and check if ollama started successfully
    sleep 3
    if kill -0 $OLLAMA_PID 2>/dev/null; then
        echo -e "${GREEN}✅ ollama serve started successfully (PID: $OLLAMA_PID)${NC}"
        echo -e "${GREEN}Log file: ollama.log${NC}"
    else
        echo -e "${RED}❌ Failed to start ollama serve${NC}"
        exit 1
    fi
fi

# Pull the configured model (no-op if already present locally)
echo -e "${GREEN}Pulling model ${OLLAMA_MODEL}...${NC}"
OLLAMA_HOST="127.0.0.1:$OLLAMA_PORT" ollama pull "$OLLAMA_MODEL"
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to pull model ${OLLAMA_MODEL}${NC}"
    exit 1
fi

# Start docker-compose services (open-webui + kokoro-tts)
if [ -f "$COMPOSE_FILE" ]; then
    echo -e "${GREEN}Starting docker-compose services...${NC}"
    docker compose -f "$COMPOSE_FILE" up -d
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to start docker-compose services${NC}"
        exit 1
    fi
    echo -e "${GREEN}Docker-compose services started successfully${NC}"
else
    echo -e "${YELLOW}No docker-compose.yml found, skipping docker services${NC}"
fi

# Show status
echo -e "\n${GREEN}📊 Service Status:${NC}"
echo "🔹 ollama: http://localhost:$OLLAMA_PORT (model: $OLLAMA_MODEL)"

if [ -f "$COMPOSE_FILE" ]; then
    echo "🔹 Docker services:"
    docker compose -f "$COMPOSE_FILE" ps
fi

echo -e "\n${GREEN}✨ All services are running!${NC}"
echo -e "${YELLOW}Open the chat UI at: http://localhost:3000${NC}"
echo -e "${YELLOW}To stop Ollama: pkill -f 'ollama serve'${NC}"
echo -e "${YELLOW}To stop docker services: docker compose -f $COMPOSE_FILE down${NC}"
echo -e "${YELLOW}View ollama logs: tail -f ollama.log${NC}"
