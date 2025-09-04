#!/bin/bash
set -e

# Cline Configuration Setup Script for Product Managers
# Pre-configures Cline VS Code extension for Ollama

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VSCODE_SETTINGS="${PROJECT_ROOT}/.vscode/settings.json"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[cline-setup]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if VS Code is installed
check_vscode() {
    if ! command -v code >/dev/null 2>&1; then
        warning "VS Code not detected - Cline configuration will be available when VS Code is installed"
        return 1
    fi
    return 0
}

# Check if Cline extension is installed
check_cline_extension() {
    if ! code --list-extensions | grep -q "saoudrizwan.claude-dev"; then
        log "Cline extension not detected - will be configured when installed"
        log "Install with: code --install-extension saoudrizwan.claude-dev"
        return 1
    fi
    return 0
}

# Ensure .vscode directory and settings exist
setup_workspace_settings() {
    log "Setting up VS Code workspace settings..."
    
    if [[ ! -d "${PROJECT_ROOT}/.vscode" ]]; then
        mkdir -p "${PROJECT_ROOT}/.vscode"
        log "Created .vscode directory"
    fi
    
    if [[ -f "$VSCODE_SETTINGS" ]]; then
        success "VS Code workspace settings already configured"
        log "  Cline pre-configured for Ollama (phi3:mini)"
        log "  PM-optimized system message included"
    else
        error "VS Code settings not found - should be created by installer"
        return 1
    fi
}

# Main setup function
main() {
    log "Setting up Cline configuration for Product Managers..."
    
    # Setup workspace settings
    setup_workspace_settings
    
    # Check VS Code installation
    if check_vscode; then
        success "VS Code detected"
        
        # Check Cline extension
        if check_cline_extension; then
            success "Cline extension detected"
        fi
    fi
    
    success "Cline workspace configuration complete!"
    log ""
    log "🎯 Product Managers can now:"
    log "   1. Open this project in VS Code: code ."
    log "   2. Install Cline if not already: Ctrl+Shift+P → Extensions: Install Extensions → Search 'Cline'"
    log "   3. Press Ctrl+Shift+P → 'Cline: Start Cline'"
    log "   4. Cline will automatically use phi3:mini model via Ollama"
    log ""
    log "📚 Cline is pre-configured with PM-focused system prompts"
    log "⚡ No manual model setup required - ready for PM tasks immediately!"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Cline Configuration Setup for AIPM Laptop LLM Kit"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo ""
        echo "This script ensures VS Code workspace settings are configured"
        echo "for optimal Cline experience with local Ollama."
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac