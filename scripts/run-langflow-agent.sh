#!/bin/bash
# AIPM Laptop LLM Kit - LangFlow CLI Agent Runner for macOS/Linux
# Run LangFlow flows as standalone agents with local LLM support
#
# Usage: 
#   ./run-langflow-agent.sh <FLOW_ID>                    # Run once and exit
#   ./run-langflow-agent.sh <FLOW_ID> --background       # Run in background
#   ./run-langflow-agent.sh <FLOW_ID> --provider ollama  # Use Ollama instead of LM Studio
#   ./run-langflow-agent.sh <FLOW_ID> --input "prompt"   # Custom input text
#   ./run-langflow-agent.sh list                         # List available flows
#   ./run-langflow-agent.sh status                       # Check LangFlow status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/.env"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "$1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️ $1${NC}"; }

usage() {
    cat << EOF
${BLUE}AIPM LangFlow CLI Agent Runner${NC}
Run LangFlow flows as standalone agents with local LLM support

${YELLOW}Usage:${NC}
  $0 <FLOW_ID>                       Run flow once and exit
  $0 <FLOW_ID> --background          Run flow in background
  $0 <FLOW_ID> --provider ollama     Use Ollama instead of LM Studio
  $0 <FLOW_ID> --input "text"        Custom input text for the flow
  $0 <FLOW_ID> --tweaks '{"key":"val"}' Custom component tweaks
  $0 <FLOW_ID> --log <file>          Save output to specific log file
  $0 list                            List all available flows (if LangFlow supports it)
  $0 status                          Show LangFlow server status

${YELLOW}Examples:${NC}
  $0 123e4567-e89b-12d3-a456-426614174000
  $0 my-flow-id --background --provider ollama --input "Generate a user story"
  $0 my-flow-id --tweaks '{"temperature":0.8,"max_tokens":500}'

${YELLOW}Environment Variables (set automatically):${NC}
  LLM_BASE_URL, LLM_API_KEY, LLM_MODEL_NAME    (LM Studio)
  OLLAMA_BASE_URL, OLLAMA_API_KEY, OLLAMA_MODEL_NAME (Ollama)
  LANGFLOW_API_KEY (if API key authentication is enabled)

${YELLOW}Notes:${NC}
  - Flow ID can be found in LangFlow UI: Share → API access
  - Background agents log to ~/aipm-langflow-agents/<flow-id>.log
  - LangFlow must be running on http://localhost:7860 (default)
  - Use Docker networking URLs if LangFlow is containerized
EOF
}

load_environment() {
    if [[ -f "$ENV_FILE" ]]; then
        set -a  # automatically export all variables
        source "$ENV_FILE"
        set +a  # stop automatically exporting
        success "Loaded environment from .env"
    else
        warning "No .env file found, using defaults"
    fi
}

setup_provider() {
    local provider="${1:-lmstudio}"
    local execution_mode="$2"  # "docker" or "cli"
    
    case "$provider" in
        lmstudio|lm|studio)
            if [[ "$execution_mode" == "docker" ]]; then
                # Docker LangFlow -> use host.docker.internal
                export LLM_BASE_URL="${LLM_DOCKER_URL:-http://host.docker.internal:1234/v1}"
                info "Using LM Studio provider for Docker LangFlow (${LLM_BASE_URL})"
            else
                # CLI LangFlow -> use localhost
                export LLM_BASE_URL="${LLM_BASE_URL:-http://localhost:1234/v1}"
                info "Using LM Studio provider for CLI LangFlow (${LLM_BASE_URL})"
            fi
            export LLM_API_KEY="${LLM_API_KEY:-local-lmstudio-key}"
            export LLM_MODEL_NAME="${LLM_MODEL_NAME:-phi-3-mini-4k-instruct}"
            ;;
        ollama)
            if [[ "$execution_mode" == "docker" ]]; then
                # Docker LangFlow -> use host.docker.internal
                export OLLAMA_BASE_URL="${OLLAMA_DOCKER_URL:-http://host.docker.internal:11434/v1}"
                info "Using Ollama provider for Docker LangFlow (${OLLAMA_BASE_URL})"
            else
                # CLI LangFlow -> use localhost
                export OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-http://localhost:11434/v1}"
                info "Using Ollama provider for CLI LangFlow (${OLLAMA_BASE_URL})"
            fi
            export OLLAMA_API_KEY="${OLLAMA_API_KEY:-local-ollama-key}"
            export OLLAMA_MODEL_NAME="${OLLAMA_MODEL_NAME:-phi4-mini:latest}"
            ;;
        *)
            error "Unknown provider: $provider. Use 'lmstudio' or 'ollama'"
            exit 1
            ;;
    esac
}

check_langflow_installation() {
    # Check if LangFlow is available via Docker first (our default setup)
    if docker ps | grep -q langflow; then
        info "Found LangFlow running in Docker container"
        export LANGFLOW_EXECUTION_MODE="docker"
        export LANGFLOW_URL="http://localhost:7860/api"
        return 0
    fi
    
    # Check if LangFlow server is running locally
    if curl -s http://localhost:7860/health >/dev/null 2>&1; then
        info "Found LangFlow server running on localhost:7860"
        export LANGFLOW_EXECUTION_MODE="cli"
        export LANGFLOW_URL="http://localhost:7860/api"
        return 0
    fi
    
    # Check if langflow CLI is available
    if command -v langflow >/dev/null 2>&1; then
        warning "LangFlow CLI available but server not running"
        info "Start with: langflow run --host 0.0.0.0 --port 7860"
        export LANGFLOW_EXECUTION_MODE="cli"
        export LANGFLOW_URL="http://localhost:7860/api"
        return 1
    fi
    
    error "LangFlow not found or not running!"
    echo ""
    echo "To use with Docker (recommended):"
    echo "  docker compose --profile optional up -d langflow"
    echo ""
    echo "To install LangFlow CLI:"
    echo "  pip install langflow"
    echo "  langflow run --host 0.0.0.0 --port 7860"
    exit 1
}

show_langflow_status() {
    info "Checking LangFlow server status..."
    
    # Check Docker container
    if docker ps | grep -q langflow; then
        info "LangFlow Docker container is running"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep langflow
    fi
    
    # Check local server
    if curl -s http://localhost:7860/health >/dev/null 2>&1; then
        local version=$(curl -s http://localhost:7860/api/v1/version 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        success "LangFlow server is running on http://localhost:7860"
        info "Version: ${version:-unknown}"
    else
        warning "LangFlow server not responding on http://localhost:7860"
    fi
    
    # Check for background agents
    local log_dir="$HOME/aipm-langflow-agents"
    if [[ -d "$log_dir" ]]; then
        local count=$(find "$log_dir" -name "*.log" -newer "$log_dir/.last-cleanup" 2>/dev/null | wc -l | tr -d ' ')
        if [[ $count -gt 0 ]]; then
            info "Found $count recent LangFlow agent log files in $log_dir"
            ls -la "$log_dir"/*.log 2>/dev/null || true
        else
            info "No recent background agent activity found"
        fi
    else
        info "No background agents directory found"
    fi
}

list_flows() {
    info "Attempting to list available flows..."
    
    # Try to get flows list (this endpoint may not exist in all LangFlow versions)
    local flows_response=$(curl -s "${LANGFLOW_URL}/v1/flows" 2>/dev/null)
    
    if [[ $? -eq 0 ]] && [[ -n "$flows_response" ]]; then
        echo "$flows_response" | jq -r '.flows[]? | "\(.id): \(.name)"' 2>/dev/null || echo "$flows_response"
    else
        warning "Unable to list flows via API"
        info "To find your Flow ID:"
        echo "1. Open LangFlow UI at http://localhost:7860"
        echo "2. Open your flow"
        echo "3. Click Share → API access"
        echo "4. Copy the Flow ID from the generated code"
    fi
}

execute_flow() {
    local flow_id="$1"
    local background="$2"
    local input_text="${3:-run agent}"
    local tweaks="${4:-{}}"
    local log_file="$5"
    
    if [[ -z "$flow_id" ]]; then
        error "Flow ID is required"
        usage
        exit 1
    fi
    
    # Set up logging
    local log_dir="$HOME/aipm-langflow-agents"
    if [[ -n "$background" || -n "$log_file" ]]; then
        mkdir -p "$log_dir"
        touch "$log_dir/.last-cleanup"  # Marker for status checking
        if [[ -z "$log_file" ]]; then
            log_file="$log_dir/${flow_id}.log"
        fi
    fi
    
    # Prepare API request
    local api_url="${LANGFLOW_URL}/v1/run/${flow_id}?stream=false"
    local api_key_header=""
    
    if [[ -n "$LANGFLOW_API_KEY" ]]; then
        api_key_header="-H \"x-api-key: $LANGFLOW_API_KEY\""
    fi
    
    # Prepare request body
    local request_body=$(cat << EOF
{
  "input_value": "$input_text",
  "input_type": "chat",
  "output_type": "chat",
  "tweaks": $tweaks
}
EOF
)
    
    if [[ -n "$background" ]]; then
        info "Running LangFlow agent $flow_id in background..."
        info "Input: $input_text"
        info "Log file: $log_file"
        
        # Run in background with logging
        (
            curl --request POST \
                --url "$api_url" \
                --header "Content-Type: application/json" \
                $api_key_header \
                --data "$request_body" \
                --silent --show-error 2>&1
        ) > "$log_file" &
        
        success "Background agent started (PID: $!)"
        info "Monitor with: tail -f $log_file"
    else
        info "Running LangFlow agent $flow_id..."
        info "Input: $input_text"
        
        local response
        if [[ -n "$log_file" ]]; then
            response=$(curl --request POST \
                --url "$api_url" \
                --header "Content-Type: application/json" \
                $api_key_header \
                --data "$request_body" \
                --silent --show-error 2>&1 | tee "$log_file")
        else
            response=$(curl --request POST \
                --url "$api_url" \
                --header "Content-Type: application/json" \
                $api_key_header \
                --data "$request_body" \
                --silent --show-error 2>&1)
        fi
        
        # Try to pretty print JSON response
        if echo "$response" | jq . >/dev/null 2>&1; then
            echo "$response" | jq .
        else
            echo "$response"
        fi
        
        success "Flow execution completed"
    fi
}

# Main script
main() {
    local flow_id=""
    local background=""
    local provider="lmstudio"
    local input_text="run agent"
    local tweaks="{}"
    local log_file=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --background|-b)
                background="true"
                shift
                ;;
            --provider|-p)
                provider="$2"
                shift 2
                ;;
            --input|-i)
                input_text="$2"
                shift 2
                ;;
            --tweaks|-t)
                tweaks="$2"
                shift 2
                ;;
            --log|-l)
                log_file="$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            list)
                check_langflow_installation
                list_flows
                exit 0
                ;;
            status)
                show_langflow_status
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                flow_id="$1"
                shift
                ;;
        esac
    done
    
    if [[ -z "$flow_id" ]]; then
        usage
        exit 1
    fi
    
    # Execute flow
    load_environment
    check_langflow_installation
    setup_provider "$provider" "$LANGFLOW_EXECUTION_MODE"
    execute_flow "$flow_id" "$background" "$input_text" "$tweaks" "$log_file"
}

main "$@"