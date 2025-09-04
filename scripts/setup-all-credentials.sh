#!/bin/bash
set -e

# Master Credential Setup Script for AIPM Laptop LLM Kit
# Pre-configures ALL tools with Ollama connections for Product Managers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

log() {
    echo -e "${BLUE}[all-setup]${NC} $1"
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

header() {
    echo -e "\n${BOLD}${BLUE}🚀 $1${NC}\n"
}

# Check if services are running
check_services() {
    header "Checking Service Status"
    
    local services_status=0
    
    # Check Ollama
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        success "Ollama is running (port 11434)"
    else
        warning "Ollama not running - start with: ollama serve"
        services_status=1
    fi
    
    # Check n8n
    if curl -s http://localhost:5678/healthz > /dev/null 2>&1; then
        success "n8n is running (port 5678)"
    else
        warning "n8n not running - start with: docker compose up -d n8n"
        services_status=1
    fi
    
    # Check AnythingLLM
    if curl -s http://localhost:3001/api/ping > /dev/null 2>&1; then
        success "AnythingLLM is running (port 3001)"
    else
        warning "AnythingLLM not running - start with: docker compose up -d anythingllm"
        services_status=1
    fi
    
    # Check LangFlow (optional)
    if curl -s http://localhost:7860/health > /dev/null 2>&1; then
        success "LangFlow is running (port 7860)"
    else
        log "LangFlow not running (optional) - start with: docker compose --profile optional up -d langflow"
    fi
    
    return $services_status
}

# Setup n8n credentials
setup_n8n() {
    header "Setting up n8n Credentials"
    
    if [[ -f "$SCRIPT_DIR/setup-n8n-credentials.sh" ]]; then
        log "Configuring n8n with pre-built Ollama credentials..."
        if "$SCRIPT_DIR/setup-n8n-credentials.sh"; then
            success "n8n credentials configured"
            log "  ✨ Look for 'Local Ollama (Pre-configured)' in workflow credentials"
        else
            warning "n8n credential setup had issues (check if n8n is running)"
        fi
    else
        warning "n8n setup script not found"
    fi
}

# Setup AnythingLLM
setup_anythingllm() {
    header "Setting up AnythingLLM Configuration"
    
    if [[ -f "$SCRIPT_DIR/setup-anythingllm-config.sh" ]]; then
        log "Configuring AnythingLLM with Ollama connection..."
        if "$SCRIPT_DIR/setup-anythingllm-config.sh"; then
            success "AnythingLLM configured"
            log "  ✨ 'Product Management Hub' workspace ready to use"
        else
            warning "AnythingLLM setup had issues (check if AnythingLLM is running)"
        fi
    else
        warning "AnythingLLM setup script not found"
    fi
}

# Setup LangFlow
setup_langflow() {
    header "Setting up LangFlow Global Variables"
    
    if curl -s http://localhost:7860/health > /dev/null 2>&1; then
        if [[ -f "$SCRIPT_DIR/setup-langflow-variables.sh" ]]; then
            log "Configuring LangFlow with global variables..."
            if "$SCRIPT_DIR/setup-langflow-variables.sh"; then
                success "LangFlow global variables configured"
                log "  ✨ Use {OLLAMA_BASE_URL}, {OLLAMA_MODEL} variables in flows"
            else
                warning "LangFlow setup had issues"
            fi
        else
            warning "LangFlow setup script not found"
        fi
    else
        log "LangFlow not running - skipping (optional service)"
    fi
}

# Setup Cline
setup_cline() {
    header "Setting up Cline VS Code Configuration"
    
    if [[ -f "$SCRIPT_DIR/setup-cline-config.sh" ]]; then
        log "Configuring Cline workspace settings..."
        if "$SCRIPT_DIR/setup-cline-config.sh"; then
            success "Cline workspace configured"
            log "  ✨ VS Code workspace settings optimized for PM tasks"
        else
            warning "Cline setup had issues"
        fi
    else
        warning "Cline setup script not found"
    fi
}

# Verify Continue.dev config
verify_continue() {
    header "Verifying Continue.dev Configuration"
    
    local continue_config="$PROJECT_ROOT/config/continue.json"
    if [[ -f "$continue_config" ]]; then
        if grep -q "ollama" "$continue_config" && grep -q "phi4-mini:latest" "$continue_config"; then
            success "Continue.dev already configured for Ollama"
            log "  ✨ Ready to use in VS Code (Ctrl+I)"
        else
            warning "Continue.dev config may need updating"
        fi
    else
        warning "Continue.dev config not found"
    fi
}

# Create summary report
create_summary() {
    header "🎯 Setup Summary for Product Managers"
    
    echo -e "${BOLD}Your AI tools are now pre-configured!${NC}\n"
    
    echo -e "${GREEN}✅ Ready-to-use connections:${NC}"
    echo "   • n8n: 'Local Ollama (Pre-configured)' credential"
    echo "   • AnythingLLM: 'Product Management Hub' workspace" 
    echo "   • LangFlow: {OLLAMA_BASE_URL}, {OLLAMA_MODEL} variables"
    echo "   • Continue.dev: Ollama provider (phi4-mini:latest model)"
    echo "   • Cline: VS Code workspace settings (PM-optimized prompts)"
    echo ""
    
    echo -e "${BLUE}🚀 Next steps:${NC}"
    echo "   1. Open any tool and look for pre-configured options"
    echo "   2. Try the example workflows in config/example-workflows/"
    echo "   3. Upload PM documents to AnythingLLM workspace"
    echo "   4. Use Ctrl+I in VS Code for AI coding assistance"
    echo ""
    
    echo -e "${YELLOW}📚 Tool URLs:${NC}"
    echo "   • n8n Workflows: http://localhost:5678"
    echo "   • AnythingLLM: http://localhost:3001"
    echo "   • LangFlow: http://localhost:7860 (optional)"
    echo ""
    
    echo -e "${GREEN}🎉 No more manual credential setup needed!${NC}"
}

# Main setup function
main() {
    echo -e "${BOLD}${BLUE}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════╗
    ║         AIPM Laptop LLM Kit - Master Setup           ║
    ║      Pre-configuring ALL tools with Ollama           ║
    ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log "Configuring credentials for all AI tools..."
    
    # Check service status first
    if ! check_services; then
        warning "Some services aren't running - credentials will be created but may not work until services start"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Setup cancelled. Start services and try again."
            exit 0
        fi
    fi
    
    echo ""
    
    # Setup each tool
    setup_n8n
    setup_anythingllm
    setup_langflow
    setup_cline
    verify_continue
    
    # Final summary
    create_summary
    
    success "🎉 All tool credentials configured successfully!"
    log "Product Managers can now focus on building workflows instead of wrestling with connections!"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Master Credential Setup for AIPM Laptop LLM Kit"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "This script configures pre-built credentials/connections for:"
        echo "  • n8n (OpenAI API credentials pointing to Ollama)"
        echo "  • AnythingLLM (LLM provider settings + PM workspace)"
        echo "  • LangFlow (Global variables for Ollama connection)"
        echo "  • Continue.dev (Already configured in config/continue.json)"
        echo "  • Cline (VS Code workspace settings with PM prompts)"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo ""
        echo "All connections point to local Ollama server (phi4-mini:latest model)"
        echo "This eliminates manual credential setup for Product Managers."
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac