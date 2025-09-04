#!/bin/bash
set -e

# AIPM Laptop LLM Kit Uninstaller
# Removes services, configurations, and optionally data

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD_MARKER="aipm-laptop-llm-kit"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "$1"
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

error() {
    echo -e "${RED}✗ $1${NC}"
}

# Confirmation prompt
confirm() {
    local message="$1"
    local default="$2"
    
    if [[ "$default" == "y" ]]; then
        prompt="$message [Y/n]: "
    else
        prompt="$message [y/N]: "
    fi
    
    read -p "$prompt" -n 1 -r
    echo
    
    if [[ "$default" == "y" ]]; then
        [[ $REPLY =~ ^[Nn]$ ]] && return 1 || return 0
    else
        [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
    fi
}

# Stop and remove Docker containers
remove_docker_services() {
    log "Stopping and removing Docker services..."
    
    cd "$SCRIPT_DIR"
    
    # Stop services
    if docker compose ps -q >/dev/null 2>&1; then
        docker compose down
        success "Docker services stopped"
    else
        log "No running Docker services found"
    fi
    
    # Remove volumes if confirmed
    if confirm "Remove Docker volumes (this will delete all data)?" "n"; then
        docker compose down -v 2>/dev/null || true
        success "Docker volumes removed"
    fi
    
    # Remove images if confirmed  
    if confirm "Remove Docker images?" "n"; then
        local images=(
            "mintplexlabs/anythingllm:latest"
            "n8nio/n8n:latest"
            "zylonai/privategpt:latest"
            "langflowai/langflow:latest"
            "ghcr.io/open-webui/open-webui:main"
        )
        
        for image in "${images[@]}"; do
            if docker images -q "$image" 2>/dev/null | grep -q .; then
                docker rmi "$image" 2>/dev/null || true
            fi
        done
        success "Docker images removed"
    fi
}

# Remove VS Code extensions
remove_vscode_extensions() {
    if command -v code >/dev/null 2>&1; then
        if confirm "Remove VS Code extensions (Cline, Continue.dev)?" "y"; then
            code --uninstall-extension saoudrizwan.claude-dev 2>/dev/null || true
            code --uninstall-extension Continue.continue 2>/dev/null || true
            success "VS Code extensions removed"
        fi
    else
        log "VS Code not found, skipping extension removal"
    fi
}

# Remove environment variables from shell configs
remove_shell_config() {
    local shell_configs=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
    )
    
    log "Removing environment variables from shell configurations..."
    
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            # Check if our block exists
            if grep -q "# >>> $GUARD_MARKER >>>" "$config"; then
                # Remove our block
                sed -i.backup "/# >>> $GUARD_MARKER >>>/,/# <<< $GUARD_MARKER <<</d" "$config"
                success "Removed environment block from $(basename "$config")"
            fi
        fi
    done
}

# Remove macOS GUI environment variables
remove_macos_gui_env() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log "Removing macOS GUI environment variables..."
        
        local vars=(
            "LLM_BASE_URL"
            "ANYTHINGLLM_PORT"
            "N8N_PORT"
            "SOV_STACK_HOME"
        )
        
        for var in "${vars[@]}"; do
            launchctl unsetenv "$var" 2>/dev/null || true
        done
        
        warning "macOS GUI environment will be cleared after logout/login"
    fi
}

# Remove storage directories
remove_storage() {
    if confirm "Remove storage directories (this will delete all data)?" "n"; then
        local storage_dir="$SCRIPT_DIR/storage"
        if [[ -d "$storage_dir" ]]; then
            rm -rf "$storage_dir"
            success "Storage directories removed"
        fi
    fi
}

# Remove project files
remove_project_files() {
    if confirm "Remove configuration files (.env, logs)?" "y"; then
        local files_to_remove=(
            "$SCRIPT_DIR/.env"
            "$SCRIPT_DIR/install.log"
        )
        
        for file in "${files_to_remove[@]}"; do
            if [[ -f "$file" ]]; then
                rm -f "$file"
                success "Removed $(basename "$file")"
            fi
        done
    fi
}

# Show manual cleanup steps
show_manual_steps() {
    log ""
    warning "Manual cleanup steps (if needed):"
    log ""
    log "1. LM Studio (if installed manually):"
    log "   - macOS: Drag LM Studio.app to Trash"
    log "   - Windows: Uninstall via Settings > Apps"
    log "   - Linux: Remove from /opt or ~/Applications"
    log ""
    log "2. Docker Desktop (if you want to remove it):"
    log "   - macOS: Drag Docker.app to Trash"
    log "   - Windows: Uninstall via Settings > Apps"  
    log "   - Linux: sudo apt remove docker-ce docker-ce-cli containerd.io"
    log ""
    log "3. VS Code (if you want to remove it):"
    log "   - macOS: Drag Visual Studio Code.app to Trash"
    log "   - Windows: Uninstall via Settings > Apps"
    log "   - Linux: sudo apt remove code"
    log ""
}

# Main uninstall function
main() {
    log "=== AIPM Laptop LLM Kit Uninstaller ==="
    log "This will remove services, configurations, and optionally data."
    log ""
    
    if ! confirm "Continue with uninstallation?" "n"; then
        log "Uninstallation cancelled."
        exit 0
    fi
    
    log ""
    remove_docker_services
    remove_vscode_extensions
    remove_shell_config
    remove_macos_gui_env
    remove_storage
    remove_project_files
    
    log ""
    success "=== Uninstallation Complete ==="
    log ""
    warning "Please restart your terminal to clear any remaining environment variables."
    log ""
    
    show_manual_steps
}

# Handle Ctrl+C
trap 'echo -e "\n${RED}Uninstallation interrupted${NC}"; exit 1' INT

# Run main function
main "$@"