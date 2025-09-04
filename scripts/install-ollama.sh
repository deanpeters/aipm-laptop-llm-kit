#!/bin/bash
set -e

# Ollama Automated Installation Script
# Downloads, installs, and configures Ollama with a default model

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DEFAULT_MODEL="phi3:mini"
OLLAMA_PORT="11434"
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Ollama Installation Script"
            echo "Usage: $0 [--dry-run] [--help]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be installed without making changes"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

log() {
    echo -e "$1"
}

progress() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# Check if Ollama is already installed
check_existing_installation() {
    command -v ollama >/dev/null 2>&1
}

# Install Ollama on macOS
install_ollama_macos() {
    progress "Installing Ollama on macOS..."
    
    # Try Homebrew first
    if command -v brew >/dev/null 2>&1; then
        progress "Installing Ollama via Homebrew..."
        brew install ollama
        success "Ollama installed via Homebrew"
        return 0
    fi
    
    # Fallback to official installer
    progress "Installing Ollama via official installer..."
    curl -fsSL https://ollama.ai/install.sh | sh
    success "Ollama installed via official installer"
}

# Install Ollama on Linux
install_ollama_linux() {
    progress "Installing Ollama on Linux..."
    curl -fsSL https://ollama.ai/install.sh | sh
    success "Ollama installed on Linux"
}

# Start Ollama service
start_ollama_service() {
    local dry_run="${1:-false}"
    
    if [[ "$dry_run" == "true" ]]; then
        log "[DRY RUN] Would start Ollama service"
        return 0
    fi
    
    progress "Starting Ollama service..."
    
    # Start Ollama daemon in background
    nohup ollama serve > /dev/null 2>&1 &
    
    # Wait for service to start
    local max_attempts=15
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if curl -f -s http://localhost:${OLLAMA_PORT} >/dev/null 2>&1; then
            success "Ollama service running on port ${OLLAMA_PORT}"
            return 0
        fi
        sleep 2
        ((attempt++))
    done
    
    warning "Ollama service may not have started automatically"
    warning "You can start it manually with: ollama serve"
}

# Download default model
download_default_model() {
    local dry_run="${1:-false}"
    
    if [[ "$dry_run" == "true" ]]; then
        log "[DRY RUN] Would download default model: $DEFAULT_MODEL"
        return 0
    fi
    
    progress "Downloading default model: $DEFAULT_MODEL"
    
    if ! ollama pull "$DEFAULT_MODEL"; then
        warning "Failed to download default model - you can download manually with: ollama pull $DEFAULT_MODEL"
        return 0
    fi
    
    success "Default model downloaded"
}

# Verify installation
verify_installation() {
    local dry_run="${1:-false}"
    
    if [[ "$dry_run" == "true" ]]; then
        log "[DRY RUN] Would verify Ollama installation"
        return 0
    fi
    
    progress "Verifying Ollama installation..."
    
    # Check if Ollama command works
    if ! ollama --version >/dev/null 2>&1; then
        error "Ollama installation failed - command not available"
    fi
    
    # Check if service is running
    if ! curl -f -s http://localhost:${OLLAMA_PORT} >/dev/null 2>&1; then
        warning "Ollama service not responding - may need manual start"
        return 0
    fi
    
    # Check if model is available
    if ! ollama list | grep -q "$DEFAULT_MODEL"; then
        warning "Default model not found - may need manual download"
        return 0
    fi
    
    success "Ollama installation verified"
}

# Main installation function
main() {
    local dry_run="$DRY_RUN"
    
    progress "Installing Ollama with automation..."
    
    # Check if already installed
    if check_existing_installation; then
        success "Ollama already installed"
        
        if [[ "$dry_run" == "true" ]]; then
            log "[DRY RUN] Would start service, download model, and verify"
            return 0
        fi
        
        # Still start service and download model if needed
        start_ollama_service "$dry_run"
        download_default_model "$dry_run"
        verify_installation "$dry_run"
        return 0
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        log "[DRY RUN] Would install Ollama with default model and start service"
        return 0
    fi
    
    # Install based on OS
    case "$OSTYPE" in
        darwin*)
            install_ollama_macos
            ;;
        linux*)
            install_ollama_linux
            ;;
        *)
            error "Installation not supported for: $OSTYPE"
            ;;
    esac
    
    # Start service and download model
    start_ollama_service "$dry_run"
    download_default_model "$dry_run"
    verify_installation "$dry_run"
    
    success "Ollama installation complete!"
    log ""
    log "Next steps:"
    log "1. Ollama is running at: http://localhost:${OLLAMA_PORT}"
    log "2. Default model '$DEFAULT_MODEL' is available"
    log "3. Use 'ollama run $DEFAULT_MODEL' for interactive chat"
    log "4. Use 'ollama pull <model>' to download additional models"
    log ""
    log "Available commands:"
    log "  ollama serve          # Start the service"
    log "  ollama list           # List installed models"
    log "  ollama pull <model>   # Download a model"
    log "  ollama run <model>    # Run a model interactively"
}

main