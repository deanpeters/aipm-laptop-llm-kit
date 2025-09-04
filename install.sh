#!/bin/bash
# Note: We don't use `set -e` here to allow graceful handling of non-critical failures

# AIPM Laptop LLM Kit Installer
# One-command setup for local AI stack

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/install.log"
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "AIPM Laptop LLM Kit Installer"
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

# Logging function
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Progress indicator
progress() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

# Success indicator
success() {
    echo -e "${GREEN}✓ $1${NC}" | tee -a "$LOG_FILE"
}

# Warning indicator
warning() {
    echo -e "${YELLOW}⚠ $1${NC}" | tee -a "$LOG_FILE"
}

# Error indicator
error() {
    echo -e "${RED}✗ $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        PKG_MGR="brew"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            OS="linux"
            PKG_MGR="apt"
        elif command -v yum >/dev/null 2>&1; then
            OS="linux"
            PKG_MGR="yum"
        else
            error "Unsupported Linux distribution. Please install Docker manually and re-run."
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        error "Please use install.ps1 on Windows instead of this script."
    else
        error "Unsupported operating system: $OSTYPE"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install and update package managers
install_package_manager() {
    case $OS in
        macos)
            if ! command_exists brew; then
                progress "Installing Homebrew..."
                if [[ "$DRY_RUN" == "true" ]]; then
                    log "[DRY RUN] Would install Homebrew"
                else
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    success "Homebrew installed"
                fi
            else
                success "Homebrew already installed"
            fi
            
            # Update Homebrew for consistency
            if [[ "$DRY_RUN" != "true" ]] && command_exists brew; then
                progress "Updating Homebrew..."
                brew update || warning "Homebrew update failed (continuing anyway)"
            fi
            ;;
            
        linux)
            success "Using system package manager: $PKG_MGR"
            
            # Update package lists
            if [[ "$DRY_RUN" != "true" ]]; then
                progress "Updating package lists..."
                case $PKG_MGR in
                    apt)
                        sudo apt-get update || warning "apt update failed (continuing anyway)"
                        ;;
                    yum)
                        sudo yum makecache || warning "yum update failed (continuing anyway)"
                        ;;
                esac
            fi
            ;;
    esac
    
    # Update pip for Python package consistency
    update_pip
}

# Update pip for consistency
update_pip() {
    progress "Updating pip for Python package consistency..."
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY RUN] Would update pip to latest version"
        return
    fi
    
    # Try different Python/pip combinations
    local pip_updated=false
    
    # Try pip3 first (most common)
    if command_exists pip3; then
        pip3 install --upgrade pip >/dev/null 2>&1 && pip_updated=true
    fi
    
    # Try pip if pip3 failed
    if [[ "$pip_updated" == "false" ]] && command_exists pip; then
        pip install --upgrade pip >/dev/null 2>&1 && pip_updated=true
    fi
    
    # Try python -m pip as fallback
    if [[ "$pip_updated" == "false" ]] && command_exists python3; then
        python3 -m pip install --upgrade pip >/dev/null 2>&1 && pip_updated=true
    fi
    
    if [[ "$pip_updated" == "true" ]]; then
        success "pip updated to latest version"
    else
        warning "Could not update pip (this may not affect installation)"
    fi
}

# Install Python dependencies
install_python_deps() {
    progress "Installing Python packages for AI/ML workflows..."
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY RUN] Would install Python packages (requests, numpy, pandas, openai, etc.)"
        return
    fi
    
    "$SCRIPT_DIR/scripts/install-python-deps.sh"
}

# Install Docker
install_docker() {
    if ! command_exists docker; then
        progress "Installing Docker..."
        if [[ "$DRY_RUN" == "true" ]]; then
            log "[DRY RUN] Would install Docker via package manager"
            return
        fi
        
        case $OS in
            macos)
                if command_exists brew; then
                    brew install --cask docker
                    success "Docker installed. Please start Docker Desktop."
                else
                    error "Homebrew not found - this should have been installed earlier"
                fi
                ;;
            linux)
                case $PKG_MGR in
                    apt)
                        # Use official Docker convenience script for reliability
                        curl -fsSL https://get.docker.com -o get-docker.sh
                        sudo sh get-docker.sh
                        sudo usermod -aG docker "$USER"
                        rm get-docker.sh
                        success "Docker installed. Please log out and back in to use Docker without sudo."
                        ;;
                    yum)
                        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
                        sudo systemctl start docker
                        sudo usermod -aG docker "$USER"
                        success "Docker installed and started."
                        ;;
                    *)
                        warning "Unsupported package manager for Docker installation"
                        ;;
                esac
                ;;
        esac
    else
        success "Docker already installed"
    fi
}

# Install VS Code
install_vscode() {
    if ! command_exists code; then
        progress "Installing VS Code..."
        if [[ "$DRY_RUN" == "true" ]]; then
            log "[DRY RUN] Would install VS Code via package manager"
            return
        fi
        
        case $OS in
            macos)
                if command_exists brew; then
                    brew install --cask visual-studio-code
                    success "VS Code installed"
                else
                    error "Homebrew not found - this should have been installed earlier"
                fi
                ;;
            linux)
                case $PKG_MGR in
                    apt)
                        # Use Microsoft's official repository
                        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
                        echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
                        sudo apt-get update
                        sudo apt-get install -y code
                        success "VS Code installed"
                        ;;
                    yum)
                        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
                        sudo yum install -y code
                        success "VS Code installed"
                        ;;
                    *)
                        warning "Unsupported package manager for VS Code installation"
                        ;;
                esac
                ;;
        esac
    else
        success "VS Code already installed"
    fi
}

# Install VS Code extensions
install_extensions() {
    if command_exists code; then
        progress "Installing VS Code extensions..."
        if [[ "$DRY_RUN" == "true" ]]; then
            log "[DRY RUN] Would install Cline and Continue.dev extensions"
            return
        fi
        
        code --install-extension saoudrizwan.claude-dev 2>/dev/null || warning "Failed to install Cline extension"
        code --install-extension Continue.continue 2>/dev/null || warning "Failed to install Continue extension"
        success "VS Code extensions installed"
    fi
}

# Setup environment
setup_environment() {
    progress "Setting up environment variables..."
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY RUN] Would setup environment variables"
        return
    fi
    
    "$SCRIPT_DIR/scripts/setup-env.sh"
    success "Environment configured"
}

# Start services
start_services() {
    progress "Starting Docker services..."
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY RUN] Would start AnythingLLM and n8n services"
        return
    fi
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        warning "Docker is not running. Please start Docker Desktop and run:"
        warning "docker compose up -d anythingllm n8n"
        return 1
    fi
    
    cd "$SCRIPT_DIR"
    if docker compose up -d anythingllm n8n; then
        success "Docker services started"
        log "AnythingLLM: http://localhost:3001 (starting up...)"
        log "n8n: http://localhost:5678"
    else
        warning "Failed to start Docker services. Try manually:"
        warning "docker compose up -d anythingllm n8n"
    fi
}

# Verify installation
verify_installation() {
    progress "Verifying installation..."
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY RUN] Would verify all services are working"
        return
    fi
    
    "$SCRIPT_DIR/scripts/verify.sh"
}

# Main installation flow
main() {
    log "=== AIPM Laptop LLM Kit Installation Started ==="
    log "Timestamp: $(date)"
    log "OS: $OSTYPE"
    log "Dry run: $DRY_RUN"
    log ""
    
    detect_os
    log "Detected OS: $OS with package manager: $PKG_MGR"
    
    # Install Ollama with automation
    progress "Installing Ollama with automated setup..."
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY RUN] Would install Ollama with default model and start server"
    else
        "$SCRIPT_DIR/scripts/install-ollama.sh"
    fi
    
    install_package_manager
    install_python_deps
    install_docker
    install_vscode
    install_extensions
    setup_environment
    start_services
    verify_installation
    
    log ""
    success "=== Installation Complete! ==="
    log ""
    log "Next steps:"
    if docker info >/dev/null 2>&1 && docker ps | grep -q "anythingllm.*n8n"; then
        log "1. Ollama service should be running with Phi-3 model"
        log "2. Access AnythingLLM: http://localhost:3001 (auto-connects to Ollama)"
        log "3. Access n8n: http://localhost:5678"
        log "4. Open VS Code: code ."
    else
        log "1. Start Docker Desktop"
        log "2. Run: docker compose up -d anythingllm n8n"
        log "3. Start Ollama service: ollama serve"
        log "4. Access AnythingLLM: http://localhost:3001"
        log "5. Access n8n: http://localhost:5678"
    fi
    log ""
    log "For help: see README.md or run: ./scripts/verify.sh"
}

# Handle Ctrl+C
trap 'echo -e "\n${RED}Installation interrupted${NC}"; exit 1' INT

# Run main function
main "$@"