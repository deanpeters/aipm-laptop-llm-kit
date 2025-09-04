#!/bin/bash
# Quick provider switching script for AIPM Laptop LLM Kit
# Usage: ./switch-provider.sh [lmstudio|ollama]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/.env"

usage() {
    echo "Usage: $0 [lmstudio|ollama]"
    echo ""
    echo "Switch between LM Studio and Ollama as your primary LLM provider"
    echo "This updates your .env file and restarts affected containers"
    echo ""
    echo "Examples:"
    echo "  $0 lmstudio    # Switch to LM Studio (port 1234)"
    echo "  $0 ollama      # Switch to Ollama (port 11434)"
    exit 1
}

switch_to_lmstudio() {
    echo "🔄 Switching to LM Studio as primary provider..."
    
    # Update .env file
    sed -i '' 's/^DEFAULT_LLM_PROVIDER=.*/DEFAULT_LLM_PROVIDER=lmstudio/' "$ENV_FILE" 2>/dev/null || \
    echo "DEFAULT_LLM_PROVIDER=lmstudio" >> "$ENV_FILE"
    
    # Set universal variables to LM Studio
    sed -i '' 's|^UNIVERSAL_LLM_URL=.*|UNIVERSAL_LLM_URL=${LLM_BASE_URL}|' "$ENV_FILE" 2>/dev/null || \
    echo 'UNIVERSAL_LLM_URL=${LLM_BASE_URL}' >> "$ENV_FILE"
    
    echo "✅ Switched to LM Studio"
    echo "   URL: http://localhost:1234/v1"
    echo "   Model: phi-3-mini-4k-instruct"
}

switch_to_ollama() {
    echo "🔄 Switching to Ollama as primary provider..."
    
    # Update .env file
    sed -i '' 's/^DEFAULT_LLM_PROVIDER=.*/DEFAULT_LLM_PROVIDER=ollama/' "$ENV_FILE" 2>/dev/null || \
    echo "DEFAULT_LLM_PROVIDER=ollama" >> "$ENV_FILE"
    
    # Set universal variables to Ollama
    sed -i '' 's|^UNIVERSAL_LLM_URL=.*|UNIVERSAL_LLM_URL=${OLLAMA_BASE_URL}|' "$ENV_FILE" 2>/dev/null || \
    echo 'UNIVERSAL_LLM_URL=${OLLAMA_BASE_URL}' >> "$ENV_FILE"
    
    echo "✅ Switched to Ollama"
    echo "   URL: http://localhost:11434/v1"
    echo "   Model: phi3:mini"
}

restart_containers() {
    echo ""
    echo "🔄 Restarting containers to pick up new configuration..."
    
    cd "$PROJECT_ROOT"
    if docker compose ps -q n8n >/dev/null 2>&1; then
        docker compose restart n8n
        echo "   ✅ Restarted n8n"
    fi
    
    if docker compose ps -q langflow >/dev/null 2>&1; then
        docker compose restart langflow
        echo "   ✅ Restarted LangFlow"
    fi
}

show_status() {
    echo ""
    echo "📊 Current Configuration:"
    if [[ -f "$ENV_FILE" ]]; then
        echo "   Provider: $(grep '^DEFAULT_LLM_PROVIDER=' "$ENV_FILE" | cut -d'=' -f2)"
        echo "   LM Studio: http://localhost:1234/v1"
        echo "   Ollama: http://localhost:11434/v1"
    else
        echo "   No .env file found - run setup-env.sh first"
    fi
    echo ""
    echo "💡 Test your connection:"
    echo "   LM Studio: curl http://localhost:1234/v1/models"
    echo "   Ollama: curl http://localhost:11434/v1/models"
}

# Main script
case "$1" in
    lmstudio)
        switch_to_lmstudio
        restart_containers
        show_status
        ;;
    ollama)
        switch_to_ollama
        restart_containers
        show_status
        ;;
    status|"")
        show_status
        ;;
    *)
        usage
        ;;
esac