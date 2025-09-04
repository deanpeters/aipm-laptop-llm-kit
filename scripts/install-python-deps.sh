#!/bin/bash
set -e

# Python Dependencies Installer for AIPM Laptop LLM Kit
# Installs commonly needed Python packages for AI/ML workflows

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PYTHON_PACKAGES=(
    "requests>=2.25.0"
    "numpy>=1.21.0"
    "pandas>=1.3.0"
    "openai>=1.0.0"
    "langchain>=0.1.0"
    "streamlit>=1.28.0"
    "fastapi>=0.68.0"
    "uvicorn>=0.15.0"
)

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

# Find the best Python/pip combination
find_python_pip() {
    local python_cmd=""
    local pip_cmd=""
    
    # Try different Python versions
    if command -v python3 >/dev/null 2>&1; then
        python_cmd="python3"
        if command -v pip3 >/dev/null 2>&1; then
            pip_cmd="pip3"
        else
            pip_cmd="python3 -m pip"
        fi
    elif command -v python >/dev/null 2>&1; then
        python_cmd="python"
        if command -v pip >/dev/null 2>&1; then
            pip_cmd="pip"
        else
            pip_cmd="python -m pip"
        fi
    fi
    
    echo "$python_cmd|$pip_cmd"
}

# Install Python packages
install_python_packages() {
    local dry_run="${1:-false}"
    
    progress "Installing Python packages for AI/ML workflows..."
    
    if [[ "$dry_run" == "true" ]]; then
        log "[DRY RUN] Would install Python packages:"
        for package in "${PYTHON_PACKAGES[@]}"; do
            log "  - $package"
        done
        return 0
    fi
    
    # Find Python/pip commands
    local python_pip=$(find_python_pip)
    local python_cmd=$(echo "$python_pip" | cut -d'|' -f1)
    local pip_cmd=$(echo "$python_pip" | cut -d'|' -f2)
    
    if [[ -z "$python_cmd" || -z "$pip_cmd" ]]; then
        warning "Python/pip not found - skipping Python package installation"
        warning "Install Python 3.8+ to enable additional AI tools"
        return 1
    fi
    
    log "Using Python: $python_cmd"
    log "Using pip: $pip_cmd"
    
    # Install packages
    local failed_packages=()
    for package in "${PYTHON_PACKAGES[@]}"; do
        progress "Installing $package..."
        if $pip_cmd install "$package" --user --quiet >/dev/null 2>&1; then
            success "Installed $package"
        else
            warning "Failed to install $package"
            failed_packages+=("$package")
        fi
    done
    
    if [[ ${#failed_packages[@]} -eq 0 ]]; then
        success "All Python packages installed successfully"
    else
        warning "Some packages failed to install: ${failed_packages[*]}"
        log "These packages can be installed manually later if needed"
    fi
}

# Main function
main() {
    local dry_run="${1:-false}"
    install_python_packages "$dry_run"
}

main "$@"