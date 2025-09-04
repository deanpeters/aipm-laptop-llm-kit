#!/bin/bash
# AIPM Laptop LLM Kit - CLI Agent Runner for macOS/Linux
# Run n8n workflows as standalone agents with local LLM support
#
# Usage: 
#   ./run-agent.sh <WORKFLOW_ID>                    # Run once and exit
#   ./run-agent.sh <WORKFLOW_ID> --background       # Run in background
#   ./run-agent.sh <WORKFLOW_ID> --provider ollama  # Use Ollama instead of LM Studio
#   ./run-agent.sh list                             # List available workflows

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
${BLUE}AIPM CLI Agent Runner${NC}
Run n8n workflows as standalone agents with local LLM support

${YELLOW}Usage:${NC}
  $0 <WORKFLOW_ID>                    Run workflow once and exit
  $0 <WORKFLOW_ID> --background       Run workflow in background
  $0 <WORKFLOW_ID> --provider ollama  Use Ollama instead of LM Studio
  $0 <WORKFLOW_ID> --log <file>       Save output to specific log file
  $0 list                             List all available workflows
  $0 status                           Show running background agents

${YELLOW}Examples:${NC}
  $0 123e4567-e89b-12d3-a456-426614174000
  $0 my-workflow-id --background --provider ollama
  $0 list

${YELLOW}Environment Variables (set automatically):${NC}
  LLM_BASE_URL, LLM_API_KEY, LLM_MODEL_NAME    (LM Studio)
  OLLAMA_BASE_URL, OLLAMA_API_KEY, OLLAMA_MODEL_NAME (Ollama)
  N8N_ENCRYPTION_KEY (if needed for encrypted credentials)

${YELLOW}Notes:${NC}
  - Workflow ID can be found in n8n UI URL or workflow settings
  - Background agents log to ~/aipm-agents/<workflow-id>.log
  - Use 'docker logs -f n8n' to see container output if using Docker setup
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
                # Docker n8n -> use host.docker.internal
                export LLM_BASE_URL="${LLM_DOCKER_URL:-http://host.docker.internal:1234/v1}"
                info "Using LM Studio provider for Docker n8n (${LLM_BASE_URL})"
            else
                # CLI n8n -> use localhost
                export LLM_BASE_URL="${LLM_BASE_URL:-http://localhost:1234/v1}"
                info "Using LM Studio provider for CLI n8n (${LLM_BASE_URL})"
            fi
            export LLM_API_KEY="${LLM_API_KEY:-local-lmstudio-key}"
            export LLM_MODEL_NAME="${LLM_MODEL_NAME:-phi-3-mini-4k-instruct}"
            ;;
        ollama)
            if [[ "$execution_mode" == "docker" ]]; then
                # Docker n8n -> use host.docker.internal
                export OLLAMA_BASE_URL="${OLLAMA_DOCKER_URL:-http://host.docker.internal:11434/v1}"
                info "Using Ollama provider for Docker n8n (${OLLAMA_BASE_URL})"
            else
                # CLI n8n -> use localhost
                export OLLAMA_BASE_URL="${OLLAMA_BASE_URL:-http://localhost:11434/v1}"
                info "Using Ollama provider for CLI n8n (${OLLAMA_BASE_URL})"
            fi
            export OLLAMA_API_KEY="${OLLAMA_API_KEY:-local-ollama-key}"
            export OLLAMA_MODEL_NAME="${OLLAMA_MODEL_NAME:-phi3:mini}"
            ;;
        *)
            error "Unknown provider: $provider. Use 'lmstudio' or 'ollama'"
            exit 1
            ;;
    esac
}

check_n8n_installation() {
    # Check if n8n is available via Docker first (our default setup)
    if docker ps | grep -q n8n; then
        info "Found n8n running in Docker container"
        export N8N_EXECUTION_MODE="docker"
        return 0
    fi
    
    # Check if n8n CLI is available globally
    if command -v n8n >/dev/null 2>&1; then
        info "Found n8n CLI installation"
        export N8N_EXECUTION_MODE="cli"
        return 0
    fi
    
    error "n8n not found! Please ensure n8n is running via Docker or install n8n CLI globally"
    echo ""
    echo "To use with Docker (recommended):"
    echo "  docker compose up -d n8n"
    echo ""
    echo "To install n8n CLI globally:"
    echo "  npm install -g n8n"
    exit 1
}

run_n8n_command() {
    local cmd="$1"
    
    # Try Docker first (our default setup)
    if docker ps | grep -q n8n; then
        docker exec -u node n8n $cmd
    # Fall back to global CLI
    elif command -v n8n >/dev/null 2>&1; then
        n8n $cmd
    else
        error "Cannot execute n8n command: $cmd"
        exit 1
    fi
}

list_workflows() {
    info "Listing available workflows..."
    run_n8n_command "list:workflow"
}

show_status() {
    info "Checking running background agents..."
    
    # Check for background processes
    local log_dir="$HOME/aipm-agents"
    if [[ -d "$log_dir" ]]; then
        local count=$(find "$log_dir" -name "*.log" -newer "$log_dir/.last-cleanup" 2>/dev/null | wc -l | tr -d ' ')
        if [[ $count -gt 0 ]]; then
            info "Found $count recent agent log files in $log_dir"
            ls -la "$log_dir"/*.log 2>/dev/null || true
        else
            info "No recent background agent activity found"
        fi
    else
        info "No background agents directory found"
    fi
    
    # Show Docker container status
    if docker ps | grep -q n8n; then
        info "n8n Docker container is running"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep n8n
    fi
}

execute_workflow() {
    local workflow_id="$1"
    local background="$2"
    local log_file="$3"
    
    if [[ -z "$workflow_id" ]]; then
        error "Workflow ID is required"
        usage
        exit 1
    fi
    
    # Set up logging
    local log_dir="$HOME/aipm-agents"
    if [[ -n "$background" || -n "$log_file" ]]; then
        mkdir -p "$log_dir"
        touch "$log_dir/.last-cleanup"  # Marker for status checking
        if [[ -z "$log_file" ]]; then
            log_file="$log_dir/${workflow_id}.log"
        fi
    fi
    
    # Execute command
    local cmd="execute --id $workflow_id"
    
    if [[ -n "$background" ]]; then
        info "Running workflow $workflow_id in background..."
        info "Log file: $log_file"
        
        if docker ps | grep -q n8n; then
            docker exec -u node -d n8n bash -c "$cmd > /tmp/${workflow_id}.log 2>&1 && docker cp n8n:/tmp/${workflow_id}.log $log_file"
        else
            nohup n8n $cmd > "$log_file" 2>&1 &
        fi
        
        success "Background agent started"
        info "Monitor with: tail -f $log_file"
    else
        info "Running workflow $workflow_id..."
        
        if [[ -n "$log_file" ]]; then
            run_n8n_command "$cmd" | tee "$log_file"
        else
            run_n8n_command "$cmd"
        fi
        
        success "Workflow execution completed"
    fi
}

# Main script
main() {
    local workflow_id=""
    local background=""
    local provider="lmstudio"
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
            --log|-l)
                log_file="$2"
                shift 2
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            list)
                check_n8n_installation
                list_workflows
                exit 0
                ;;
            status)
                show_status
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                workflow_id="$1"
                shift
                ;;
        esac
    done
    
    if [[ -z "$workflow_id" ]]; then
        usage
        exit 1
    fi
    
    # Execute workflow
    load_environment
    check_n8n_installation
    setup_provider "$provider" "$N8N_EXECUTION_MODE"
    execute_workflow "$workflow_id" "$background" "$log_file"
}

main "$@"