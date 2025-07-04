#!/bin/bash

# Pre-launch configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_DIRECTORY="$SCRIPT_DIR/../models"
COMPOSE_FILE="$SCRIPT_DIR/../docker-compose.yml"
LLAMA_SERVER_BIN="$SCRIPT_DIR/../dependency/build/bin/llama-server"
LLAMA_PORT="10000"
CHAT_TEMPLATE="llama2"

# Load any overriding environment variables
source $SCRIPT_DIR/../.env

# Fetch dependency build
OS_NAME="macos"
HARDWARE_NAME="arm64"
DEPENDENCY_VERSION="b5760"

DEPENDENCY_URL="https://github.com/ggml-org/llama.cpp/releases/download/$DEPENDENCY_VERSION/llama-$DEPENDENCY_VERSION-bin-$OS_NAME-$HARDWARE_NAME.zip"

# Check if dependency folder exists
if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
    echo "Directory "
fi


curl -L "$DEPENDENCY_URL" | tar -xz -C ./dependency
chmod +x $LLAMA_SERVER_BIN

LLAMA_SERVER_CMD=(
	"$LLAMA_SERVER_BIN"
	-m $MODEL_DIRECTORY/$MODEL_FILENAME
	--chat-template $CHAT_TEMPLATE
	--port $LLAMA_PORT
	${CTX_SIZE:+--ctx-size $CTX_SIZE}
	${GPU_LAYERS:+--gpu-layers $GPU_LAYERS}
	${BATCH_SIZE:+--batch-size $BATCH_SIZE}
	${N_PREDICT:+--n-predict $N_PREDICT}
)

echo ${LLAMA_SERVER_CMD[@]}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Starting LLAMA services..."

# Function to check if a port is in use
is_port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# Function to stop llama-server process
stop_llama_server() {
    echo -e "${YELLOW}Stopping existing llama-server processes...${NC}"
    pkill -f "llama-server.*port $LLAMA_PORT" 2>/dev/null || true
    sleep 2
}

# Function to stop docker-compose services
stop_docker_compose() {
    if [ -f "$COMPOSE_FILE" ]; then
        echo -e "${YELLOW}Stopping docker-compose services...${NC}"
        docker-compose down 2>/dev/null || true
        sleep 2
    fi
}

# Check if llama-server is already running on port 10000
if is_port_in_use $LLAMA_PORT; then
    echo -e "${YELLOW}Port $LLAMA_PORT is already in use. Stopping existing services...${NC}"
    stop_llama_server
fi

# Check if docker-compose services are running
if docker-compose ps -q 2>/dev/null | grep -q .; then
    echo -e "${YELLOW}Docker-compose services are already running. Restarting...${NC}"
    stop_docker_compose
fi

# Start docker-compose services
if [ -f "$COMPOSE_FILE" ]; then
    echo -e "${GREEN}Starting docker-compose services...${NC}"
    docker-compose up -d
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to start docker-compose services${NC}"
        exit 1
    fi
    echo -e "${GREEN}Docker-compose services started successfully${NC}"
else
    echo -e "${YELLOW}No docker-compose.yml found, skipping docker services${NC}"
fi

# Start llama-server in background
echo -e "${GREEN}Starting llama-server on port $LLAMA_PORT...${NC}"
nohup ${LLAMA_SERVER_CMD[@]} > llama-server.log 2>&1 &
LLAMA_PID=$!

# Wait a moment and check if llama-server started successfully
sleep 3
if kill -0 $LLAMA_PID 2>/dev/null; then
    echo -e "${GREEN}✅ llama-server started successfully (PID: $LLAMA_PID)${NC}"
    echo -e "${GREEN}Log file: llama-server.log${NC}"
else
    echo -e "${RED}❌ Failed to start llama-server${NC}"
    stop_docker_compose
    exit 1
fi

# Show status
echo -e "\n${GREEN}📊 Service Status:${NC}"
echo "🔹 llama-server: http://localhost:$LLAMA_PORT (PID: $LLAMA_PID)"

if [ -f "$COMPOSE_FILE" ]; then
    echo "🔹 Docker services:"
    docker-compose ps
fi

echo -e "\n${GREEN}✨ All services are running!${NC}"
echo -e "${YELLOW}To stop llama-server: kill $LLAMA_PID${NC}"
echo -e "${YELLOW}To stop docker services: docker-compose down${NC}"
echo -e "${YELLOW}View llama-server logs: tail -f llama-server.log${NC}"