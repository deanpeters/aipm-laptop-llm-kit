#!/bin/bash
# Setup LangFlow Example Agents - Import and configure example LangFlow flows
# This script imports the example flows and provides you with the flow IDs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FLOWS_DIR="$PROJECT_ROOT/config/example-langflow"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "$1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

check_langflow() {
    # Check if LangFlow is running
    if curl -s http://localhost:7860/health >/dev/null 2>&1; then
        success "LangFlow server is running on http://localhost:7860"
        return 0
    fi
    
    # Check Docker
    if docker ps | grep -q langflow; then
        success "LangFlow Docker container is running"
        return 0
    fi
    
    error "LangFlow is not running!"
    echo ""
    echo "Start with one of these options:"
    echo "  Docker: docker compose --profile optional up -d langflow"
    echo "  CLI:    langflow run --host 0.0.0.0 --port 7860"
    exit 1
}

import_flow() {
    local flow_file="$1"
    local flow_name="$2"
    
    if [[ ! -f "$flow_file" ]]; then
        warning "Flow file not found: $flow_file"
        return 1
    fi
    
    info "Importing $flow_name..."
    
    # Try to import via API
    local response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d @"$flow_file" \
        "http://localhost:7860/api/v1/flows/upload" 2>/dev/null)
    
    if [[ $? -eq 0 ]]; then
        # Try to extract flow ID from response
        local flow_id=$(echo "$response" | jq -r '.id // empty' 2>/dev/null)
        if [[ -n "$flow_id" ]]; then
            success "Imported $flow_name"
            echo "   Flow ID: $flow_id"
            echo "   Run command: ./scripts/run-langflow-agent.sh $flow_id"
            echo "   Test input: ./scripts/run-langflow-agent.sh $flow_id --input 'Your custom prompt'"
            echo ""
            return 0
        fi
    fi
    
    warning "API import failed for $flow_name"
    info "Manual import steps:"
    echo "1. Open LangFlow at http://localhost:7860"
    echo "2. Click 'New Flow' → 'Import'"
    echo "3. Upload: $flow_file"
    echo "4. After import, go to Share → API to get Flow ID"
    echo ""
    return 1
}

show_usage() {
    info "Setting up example LangFlow PM agent flows..."
    echo ""
    echo "After import, you can run agents with:"
    echo "  ./scripts/run-langflow-agent.sh <FLOW_ID>                    # Run once"
    echo "  ./scripts/run-langflow-agent.sh <FLOW_ID> --background       # Run in background"
    echo "  ./scripts/run-langflow-agent.sh <FLOW_ID> --input 'prompt'   # Custom input"
    echo "  ./scripts/run-langflow-agent.sh status                       # Show status"
    echo ""
}

create_flow_aliases() {
    local aliases_file="$PROJECT_ROOT/langflow-agent-aliases.sh"
    
    cat > "$aliases_file" << 'EOF'
#!/bin/bash
# LangFlow Agent Aliases - Source this file to get quick agent commands
# Usage: source langflow-agent-aliases.sh

AIPM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Quick LangFlow agent commands
alias lf-user-story='cd "$AIPM_ROOT" && ./scripts/run-langflow-agent.sh'
alias lf-competitive='cd "$AIPM_ROOT" && ./scripts/run-langflow-agent.sh'
alias lf-agents='cd "$AIPM_ROOT" && ./scripts/run-langflow-agent.sh status'
alias lf-list='cd "$AIPM_ROOT" && ./scripts/run-langflow-agent.sh list'

echo "🌊 LangFlow Agent aliases loaded!"
echo "   lf-user-story <flow-id>     # Run user story generator"  
echo "   lf-competitive <flow-id>    # Run competitive analysis"
echo "   lf-agents                   # Show agent status"
echo "   lf-list                     # List all flows"
EOF
    
    chmod +x "$aliases_file"
    success "Created LangFlow agent aliases file: $aliases_file"
    info "Source it with: source $aliases_file"
}

show_next_steps() {
    echo ""
    success "LangFlow example agents setup guide!"
    echo ""
    info "Import flows manually (recommended):"
    echo "1. Open LangFlow UI: http://localhost:7860"
    echo "2. Click 'New Flow' → 'Import'"
    echo "3. Import these files:"
    echo "   - $FLOWS_DIR/pm-user-story-flow.json"
    echo "   - $FLOWS_DIR/competitive-analysis-flow.json"
    echo "4. After import, click Share → API to get Flow ID"
    echo "5. Test with: ./scripts/run-langflow-agent.sh <FLOW_ID>"
    echo ""
    info "Environment variable usage:"
    echo "The flows use these variables (automatically set):"
    echo "  {LLM_BASE_URL}    - Your local LLM endpoint"
    echo "  {LLM_API_KEY}     - API key for local LLM"
    echo "  {LLM_MODEL_NAME}  - Model name (phi-3-mini-4k-instruct)"
    echo ""
    warning "Note: LangFlow flow import via API may not work in all versions"
    warning "Manual import through the UI is the most reliable method"
}

main() {
    show_usage
    check_langflow
    
    echo ""
    info "Attempting automatic import..."
    echo ""
    
    # Try to import example flows
    local imported_count=0
    
    if import_flow "$FLOWS_DIR/pm-user-story-flow.json" "PM User Story Generator"; then
        ((imported_count++))
    fi
    
    if import_flow "$FLOWS_DIR/competitive-analysis-flow.json" "Competitive Analysis Generator"; then
        ((imported_count++))
    fi
    
    # Create convenience aliases
    create_flow_aliases
    
    if [[ $imported_count -gt 0 ]]; then
        success "Successfully imported $imported_count flows automatically!"
    else
        warning "Automatic import failed - manual import required"
    fi
    
    show_next_steps
}

main "$@"