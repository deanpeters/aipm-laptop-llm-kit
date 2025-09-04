#!/bin/bash
# Note: We don't use `set -e` here to allow graceful handling of LM Studio setup issues

# LM Studio Automated Installation Script
# Downloads, installs, and configures LM Studio with a default model

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
DEFAULT_MODEL="microsoft/Phi-3-mini-4k-instruct-gguf/Phi-3-mini-4k-instruct-q4.gguf"
LMS_PATH="$HOME/.lmstudio/bin/lms"
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "LM Studio Installation Script"
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

# Detect OS for download URL
detect_os_arch() {
    local os_type=""
    local arch=""
    
    case "$OSTYPE" in
        darwin*)
            os_type="darwin"
            ;;
        linux*)
            os_type="linux"
            ;;
        *)
            error "Unsupported OS: $OSTYPE"
            ;;
    esac
    
    arch=$(uname -m)
    case "$arch" in
        x86_64)
            arch="x64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        *)
            error "Unsupported architecture: $arch"
            ;;
    esac
    
    echo "${os_type}-${arch}"
}

# Get latest LM Studio download URL
get_download_url() {
    local platform="$1"
    
    case "$platform" in
        darwin-x64)
            echo "https://releases.lmstudio.ai/darwin/x86/latest/LM-Studio-darwin-x86-latest.dmg"
            ;;
        darwin-arm64)
            echo "https://releases.lmstudio.ai/darwin/arm64/latest/LM-Studio-darwin-arm64-latest.dmg"
            ;;
        linux-x64)
            echo "https://releases.lmstudio.ai/linux/x86/latest/LM-Studio-linux-x86-latest.AppImage"
            ;;
        linux-arm64)
            echo "https://releases.lmstudio.ai/linux/arm64/latest/LM-Studio-linux-arm64-latest.AppImage"
            ;;
        *)
            error "No download URL for platform: $platform"
            ;;
    esac
}

# Install LM Studio on macOS
install_lmstudio_macos() {
    # Try Homebrew Cask first (if available), fallback to manual download
    if command -v brew >/dev/null 2>&1; then
        progress "Checking for LM Studio in Homebrew..."
        if brew search --cask lm-studio >/dev/null 2>&1 && brew search --cask lm-studio | grep -q "lm-studio"; then
            progress "Installing LM Studio via Homebrew..."
            brew install --cask lm-studio
            success "LM Studio installed via Homebrew"
            return 0
        else
            warning "LM Studio not available in Homebrew, using direct download"
        fi
    fi
    
    # Fallback to manual installation
    local download_url="$1"
    local dmg_file="/tmp/LMStudio.dmg"
    
    progress "Downloading LM Studio for macOS..."
    curl -L -o "$dmg_file" "$download_url"
    
    progress "Installing LM Studio..."
    # Mount the DMG
    local mount_point=$(hdiutil attach "$dmg_file" | grep "/Volumes" | awk '{print $3}')
    
    # Copy to Applications
    cp -R "$mount_point/LM Studio.app" "/Applications/"
    
    # Unmount and cleanup
    hdiutil detach "$mount_point"
    rm -f "$dmg_file"
    
    success "LM Studio installed on macOS"
}

# Install LM Studio on Linux
install_lmstudio_linux() {
    local download_url="$1"
    local appimage_file="$HOME/.local/bin/LMStudio.AppImage"
    
    progress "Downloading LM Studio for Linux..."
    mkdir -p "$HOME/.local/bin"
    curl -L -o "$appimage_file" "$download_url"
    chmod +x "$appimage_file"
    
    # Create desktop entry
    local desktop_file="$HOME/.local/share/applications/lmstudio.desktop"
    mkdir -p "$HOME/.local/share/applications"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=LM Studio
Comment=Local LLM Inference
Exec=$appimage_file
Icon=lmstudio
Terminal=false
Type=Application
Categories=Development;Science;
EOF
    
    # Run LM Studio once to initialize (headless)
    progress "Initializing LM Studio..."
    timeout 30 "$appimage_file" --headless 2>/dev/null || true
    
    success "LM Studio installed on Linux"
}

# Setup LM Studio CLI
setup_lms_cli() {
    local dry_run="${1:-false}"
    
    progress "Setting up LM Studio CLI..."
    
    if [[ "$dry_run" == "true" ]]; then
        log "[DRY RUN] Would initialize LM Studio and set up CLI"
        return 0
    fi
    
    # First, run LM Studio once to initialize (this creates the CLI)
    if [[ "$OSTYPE" == "darwin"* ]] && [[ -d "/Applications/LM Studio.app" ]]; then
        progress "Initializing LM Studio (this creates the CLI)..."
        open "/Applications/LM Studio.app" &
        sleep 15  # Give it time to initialize
        osascript -e 'quit app "LM Studio"' 2>/dev/null || true
        sleep 5
    elif [[ "$OSTYPE" == "linux-gnu"* ]] && [[ -f "$HOME/.local/bin/LMStudio.AppImage" ]]; then
        progress "Initializing LM Studio..."
        timeout 30 "$HOME/.local/bin/LMStudio.AppImage" --headless 2>/dev/null || true
        sleep 5
    fi
    
    # Wait for lms to be available
    local max_attempts=20
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if [[ -f "$LMS_PATH" ]]; then
            break
        fi
        sleep 3
        ((attempt++))
    done
    
    if [[ ! -f "$LMS_PATH" ]]; then
        warning "LM Studio CLI not found - this is normal on first install"
        warning "The CLI will be available after running LM Studio once manually"
        return 0  # Don't fail the installation
    fi
    
    # Bootstrap the CLI
    "$LMS_PATH" bootstrap 2>/dev/null || warning "CLI bootstrap may have failed (this is sometimes normal)"
    
    success "LM Studio CLI ready"
}

# Download default model
download_default_model() {
    local dry_run="${1:-false}"
    
    if [[ "$dry_run" == "true" ]]; then
        log "[DRY RUN] Would download default model: $DEFAULT_MODEL"
        return 0
    fi
    
    if [[ ! -f "$LMS_PATH" ]]; then
        warning "LM Studio CLI not available - skipping model download"
        warning "You can download models manually from the LM Studio GUI"
        return 0
    fi
    
    progress "Downloading default model: $DEFAULT_MODEL"
    
    # Use lms to download the model
    if ! "$LMS_PATH" get "$DEFAULT_MODEL" 2>/dev/null; then
        warning "Failed to download default model, will try alternative"
        # Try a different small model
        if ! "$LMS_PATH" get "microsoft/Phi-3-mini-4k-instruct-gguf" 2>/dev/null; then
            warning "Model download failed - you can download manually from LM Studio GUI"
            return 0
        fi
    fi
    
    success "Default model downloaded"
}

# Start LM Studio server
start_lm_server() {
    local dry_run="${1:-false}"
    
    if [[ "$dry_run" == "true" ]]; then
        log "[DRY RUN] Would start LM Studio server on port 1234"
        return 0
    fi
    
    if [[ ! -f "$LMS_PATH" ]]; then
        warning "LM Studio CLI not available - skipping server startup"
        warning "You can start the server manually from LM Studio GUI"
        return 0
    fi
    
    progress "Starting LM Studio server..."
    
    # Load the default model and start server
    "$LMS_PATH" load "$DEFAULT_MODEL" 2>/dev/null || "$LMS_PATH" load --first-available 2>/dev/null || true
    "$LMS_PATH" server start --port 1234 2>/dev/null || true
    
    # Wait for server to start
    local max_attempts=15
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if curl -f -s http://localhost:1234/v1/models >/dev/null 2>&1; then
            success "LM Studio server running on port 1234"
            return 0
        fi
        sleep 2
        ((attempt++))
    done
    
    warning "LM Studio server may not have started automatically"
    warning "You can start it manually from LM Studio GUI (Local Server tab)"
}

# Check if LM Studio is already installed
check_existing_installation() {
    case "$OSTYPE" in
        darwin*)
            [[ -d "/Applications/LM Studio.app" ]]
            ;;
        linux*)
            [[ -f "$HOME/.local/bin/LMStudio.AppImage" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Main installation function
main() {
    local dry_run="$DRY_RUN"
    
    progress "Installing LM Studio with automation..."
    
    # Check if already installed
    if check_existing_installation; then
        success "LM Studio already installed"
        
        if [[ "$dry_run" == "true" ]]; then
            log "[DRY RUN] Would setup CLI, download model, and start server"
            return 0
        fi
        
        # Still setup CLI and server
        if [[ -f "$LMS_PATH" ]]; then
            setup_lms_cli "$dry_run"
            download_default_model "$dry_run"
            start_lm_server "$dry_run"
        else
            warning "LM Studio installed but CLI not found - may need manual setup"
        fi
        return 0
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        log "[DRY RUN] Would install LM Studio with default model and start server"
        return 0
    fi
    
    # Get platform and download URL
    local platform=$(detect_os_arch)
    local download_url=$(get_download_url "$platform")
    
    log "Platform: $platform"
    log "Download URL: $download_url"
    
    # Install based on OS
    case "$OSTYPE" in
        darwin*)
            install_lmstudio_macos "$download_url"
            ;;
        linux*)
            install_lmstudio_linux "$download_url"
            ;;
        *)
            error "Installation not supported for: $OSTYPE"
            ;;
    esac
    
    # Setup CLI and server
    setup_lms_cli "$dry_run"
    download_default_model "$dry_run"
    start_lm_server "$dry_run"
    
    success "LM Studio installation complete!"
    log ""
    log "Next steps:"
    log "1. Open LM Studio from Applications"
    log "2. Download a model (try Phi-3 Mini 4K Instruct)"
    log "3. Go to Local Server tab and start the server"
    log "4. Your local LLM will be at: http://localhost:1234/v1"
    log ""
    if [[ -f "$LMS_PATH" ]]; then
        log "CLI available: Use 'lms' command for automation"
    else
        log "CLI will be available after running LM Studio once"
    fi
}

main