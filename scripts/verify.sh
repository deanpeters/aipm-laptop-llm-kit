#!/bin/bash
set -e

# Verification Script for AIPM Laptop LLM Kit
# Checks that all services are running and accessible

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
TOTAL_CHECKS=0

log() {
    echo -e "$1"
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((CHECKS_PASSED++))
}

failure() {
    echo -e "${RED}✗ $1${NC}"
    ((CHECKS_FAILED++))
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Test if a URL is accessible
test_url() {
    local url="$1"
    local service="$2"
    local timeout="${3:-10}"
    
    ((TOTAL_CHECKS++))
    if curl -f -s -m "$timeout" "$url" > /dev/null 2>&1; then
        success "$service is accessible at $url"
        return 0
    else
        failure "$service is not accessible at $url"
        return 1
    fi
}

# Test if a port is listening
test_port() {
    local port="$1"
    local service="$2"
    
    ((TOTAL_CHECKS++))
    if command -v nc >/dev/null 2>&1; then
        if nc -z localhost "$port" 2>/dev/null; then
            success "$service is listening on port $port"
            return 0
        else
            failure "$service is not listening on port $port"
            return 1
        fi
    elif command -v telnet >/dev/null 2>&1; then
        if timeout 5 telnet localhost "$port" </dev/null 2>/dev/null | grep -q "Connected"; then
            success "$service is listening on port $port"
            return 0
        else
            failure "$service is not listening on port $port"
            return 1
        fi
    else
        warning "Neither nc nor telnet available, skipping port check for $service"
        return 1
    fi
}

# Check command availability
check_command() {
    local cmd="$1"
    local description="$2"
    
    ((TOTAL_CHECKS++))
    if command -v "$cmd" >/dev/null 2>&1; then
        success "$description is installed"
        return 0
    else
        failure "$description is not installed"
        return 1
    fi
}

# Check Docker service
check_docker_service() {
    local service="$1"
    local container_name="$2"
    
    ((TOTAL_CHECKS++))
    if docker ps --format "table {{.Names}}" | grep -q "^$container_name$"; then
        success "Docker container '$container_name' is running"
        return 0
    else
        failure "Docker container '$container_name' is not running"
        return 1
    fi
}

# Check VS Code extension
check_vscode_extension() {
    local extension_id="$1"
    local extension_name="$2"
    
    ((TOTAL_CHECKS++))
    if command -v code >/dev/null 2>&1; then
        if code --list-extensions | grep -q "$extension_id"; then
            success "VS Code extension '$extension_name' is installed"
            return 0
        else
            failure "VS Code extension '$extension_name' is not installed"
            return 1
        fi
    else
        failure "VS Code is not available to check extensions"
        return 1
    fi
}

# Load environment variables
load_environment() {
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        set -a
        source "$PROJECT_ROOT/.env"
        set +a
        info "Loaded environment from .env"
    fi
    
    # Set defaults
    LLM_BASE_URL="${LLM_BASE_URL:-http://localhost:1234/v1}"
    ANYTHINGLLM_PORT="${ANYTHINGLLM_PORT:-3001}"
    N8N_PORT="${N8N_PORT:-5678}"
}

# Print environment info
print_environment() {
    log ""
    log "=== Environment Configuration ==="
    log "LLM_BASE_URL: $LLM_BASE_URL"
    log "ANYTHINGLLM_PORT: $ANYTHINGLLM_PORT"
    log "N8N_PORT: $N8N_PORT"
    log "SOV_STACK_HOME: ${SOV_STACK_HOME:-$PROJECT_ROOT}"
    log ""
}

# Check basic tools
check_basic_tools() {
    log "=== Checking Basic Tools ==="
    check_command "docker" "Docker"
    check_command "docker-compose" "Docker Compose" || check_command "docker" "Docker (with compose plugin)"
    check_command "code" "VS Code CLI"
    log ""
}

# Check LM Studio
check_lm_studio() {
    log "=== Checking LM Studio ==="
    
    # Check installation
    ((TOTAL_CHECKS++))
    local lm_studio_found=false
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [ -d "/Applications/LM Studio.app" ]; then
            success "LM Studio is installed"
            lm_studio_found=true
        else
            failure "LM Studio not found in /Applications/"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f "$HOME/.local/bin/LMStudio.AppImage" ]]; then
            success "LM Studio is installed"
            lm_studio_found=true
        else
            failure "LM Studio not found in ~/.local/bin/"
        fi
    else
        warning "LM Studio check not implemented for this OS"
    fi
    
    # Check CLI
    ((TOTAL_CHECKS++))
    if [[ -f "$HOME/.lmstudio/bin/lms" ]]; then
        success "LM Studio CLI (lms) is available"
    else
        failure "LM Studio CLI (lms) not found"
    fi
    
    # Test LM Studio API with better error handling
    ((TOTAL_CHECKS++))
    if curl -f -s -m 10 "$LLM_BASE_URL/models" >/dev/null 2>&1; then
        success "LM Studio API is responding"
        
        # Check if models are loaded
        local models_response=$(curl -s "$LLM_BASE_URL/models" 2>/dev/null)
        if echo "$models_response" | grep -q '"object".*"list"'; then
            local model_count=$(echo "$models_response" | grep -o '"id"' | wc -l | tr -d ' ')
            if [[ "$model_count" -gt 0 ]]; then
                success "LM Studio has $model_count model(s) available"
            else
                warning "LM Studio API responding but no models loaded"
            fi
        fi
    else
        failure "LM Studio API not responding at $LLM_BASE_URL"
        if [[ "$lm_studio_found" == "true" ]]; then
            warning "LM Studio is installed but server may not be running"
            warning "Try: ~/.lmstudio/bin/lms server start"
        fi
    fi
    
    log ""
}

# Check VS Code extensions
check_vscode_extensions() {
    log "=== Checking VS Code Extensions ==="
    check_vscode_extension "saoudrizwan.claude-dev" "Cline"
    check_vscode_extension "Continue.continue" "Continue.dev"
    log ""
}

# Check Docker services
check_docker_services() {
    log "=== Checking Docker Services ==="
    
    # Check if Docker is running
    ((TOTAL_CHECKS++))
    if docker info >/dev/null 2>&1; then
        success "Docker daemon is running"
    else
        failure "Docker daemon is not running"
        warning "Start Docker Desktop and try again"
        return 1
    fi
    
    check_docker_service "AnythingLLM" "anythingllm"
    check_docker_service "n8n" "n8n"
    log ""
}

# Check web services
check_web_services() {
    log "=== Checking Web Services ==="
    test_url "http://localhost:$ANYTHINGLLM_PORT" "AnythingLLM"
    test_url "http://localhost:$N8N_PORT" "n8n"
    log ""
}

# Check storage directories
check_storage() {
    log "=== Checking Storage Directories ==="
    local storage_dirs=(
        "$PROJECT_ROOT/storage/anythingllm"
        "$PROJECT_ROOT/storage/n8n"
    )
    
    for dir in "${storage_dirs[@]}"; do
        ((TOTAL_CHECKS++))
        if [[ -d "$dir" ]]; then
            success "Storage directory exists: $dir"
        else
            failure "Storage directory missing: $dir"
        fi
    done
    log ""
}

# Print next steps
print_next_steps() {
    log "=== Next Steps ==="
    log ""
    
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        success "All checks passed! Your AIPM Laptop LLM Kit is ready to use."
        log ""
        log "Quick start:"
        log "1. Open VS Code: code ."
        log "2. Press Ctrl+Shift+P (Cmd+Shift+P on Mac)"
        log "3. Type 'Cline: Start Cline' to begin coding with AI"
        log "4. Visit AnythingLLM: http://localhost:$ANYTHINGLLM_PORT"
        log "5. Visit n8n: http://localhost:$N8N_PORT"
    else
        warning "Some checks failed. Common fixes:"
        log ""
        
        if ! command -v docker >/dev/null 2>&1; then
            log "• Install Docker Desktop and start it"
        fi
        
        if ! docker info >/dev/null 2>&1; then
            log "• Start Docker Desktop"
        fi
        
        if ! docker ps | grep -q "anythingllm\|n8n"; then
            log "• Start services: docker compose up -d"
        fi
        
        if ! command -v code >/dev/null 2>&1; then
            log "• Install VS Code or add it to PATH"
        fi
        
        if ! curl -f -s "$LLM_BASE_URL/models" >/dev/null 2>&1; then
            log "• Start LM Studio server: ~/.lmstudio/bin/lms server start"
            log "• Or re-run installer: ./install.sh"
        fi
        
        log ""
        log "For more help, see README.md"
    fi
}

# Print summary
print_summary() {
    log ""
    log "=== Verification Summary ==="
    log "Total checks: $TOTAL_CHECKS"
    success "Passed: $CHECKS_PASSED"
    
    if [[ $CHECKS_FAILED -gt 0 ]]; then
        failure "Failed: $CHECKS_FAILED"
    fi
    
    log ""
}

# Main verification function
main() {
    log "=== AIPM Laptop LLM Kit Verification ==="
    log "Timestamp: $(date)"
    log ""
    
    load_environment
    print_environment
    check_basic_tools
    check_lm_studio
    check_vscode_extensions
    check_docker_services
    check_web_services
    check_storage
    print_next_steps
    print_summary
    
    # Exit with appropriate code
    if [[ $CHECKS_FAILED -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"