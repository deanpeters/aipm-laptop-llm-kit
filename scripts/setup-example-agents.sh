#!/bin/bash
# Setup Example Agents - Import and configure example n8n workflows
# This script imports the example workflows and provides you with the workflow IDs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WORKFLOWS_DIR="$PROJECT_ROOT/config/example-workflows"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "$1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }

check_n8n() {
    if ! docker ps | grep -q n8n; then
        echo "❌ n8n container is not running!"
        echo "Start it with: docker compose up -d n8n"
        exit 1
    fi
    success "n8n container is running"
}

import_workflow() {
    local workflow_file="$1"
    local workflow_name="$2"
    
    if [[ ! -f "$workflow_file" ]]; then
        warning "Workflow file not found: $workflow_file"
        return 1
    fi
    
    info "Importing $workflow_name..."
    
    # Copy workflow to container and import
    docker cp "$workflow_file" n8n:/tmp/workflow.json
    local result=$(docker exec -u node n8n n8n import:workflow --input /tmp/workflow.json)
    
    if echo "$result" | grep -q "Successfully imported"; then
        # Extract the workflow ID from the result
        local workflow_id=$(echo "$result" | grep -o '[a-f0-9-]\{36\}' | head -1)
        if [[ -n "$workflow_id" ]]; then
            success "Imported $workflow_name"
            echo "   Workflow ID: $workflow_id"
            echo "   Run command: ./scripts/run-agent.sh $workflow_id"
            echo ""
            return 0
        fi
    fi
    
    warning "Failed to import $workflow_name"
    echo "$result"
    return 1
}

show_usage() {
    info "Setting up example PM agent workflows..."
    echo ""
    echo "After import, you can run agents with:"
    echo "  ./scripts/run-agent.sh <WORKFLOW_ID>         # Run once"
    echo "  ./scripts/run-agent.sh <WORKFLOW_ID> --background  # Run in background"
    echo "  ./scripts/run-agent.sh list                  # List all workflows"
    echo ""
}

create_agent_aliases() {
    local aliases_file="$PROJECT_ROOT/agent-aliases.sh"
    
    cat > "$aliases_file" << 'EOF'
#!/bin/bash
# AIPM Agent Aliases - Source this file to get quick agent commands
# Usage: source agent-aliases.sh

AIPM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Quick agent commands
alias aipm-standup='cd "$AIPM_ROOT" && ./scripts/run-agent.sh'
alias aipm-story='cd "$AIMP_ROOT" && ./scripts/run-agent.sh' 
alias aipm-agents='cd "$AIPM_ROOT" && ./scripts/run-agent.sh list'
alias aipm-status='cd "$AIPM_ROOT" && ./scripts/run-agent.sh status'

echo "🤖 AIPM Agent aliases loaded!"
echo "   aipm-standup <workflow-id>  # Run standup agent"
echo "   aimp-story <workflow-id>    # Run user story agent"
echo "   aipm-agents                 # List all agents"
echo "   aimp-status                 # Show agent status"
EOF
    
    chmod +x "$aliases_file"
    success "Created agent aliases file: $aliases_file"
    info "Source it with: source $aliases_file"
}

main() {
    show_usage
    check_n8n
    
    echo ""
    info "Importing example agent workflows..."
    echo ""
    
    # Import example workflows
    import_workflow "$WORKFLOWS_DIR/daily-standup-agent.json" "Daily Standup Agent"
    import_workflow "$WORKFLOWS_DIR/user-story-generator.json" "User Story Generator Agent"
    
    # Create convenience aliases
    create_agent_aliases
    
    echo ""
    success "Example agents setup complete!"
    echo ""
    info "Next steps:"
    echo "1. Note the Workflow IDs above"
    echo "2. Test an agent: ./scripts/run-agent.sh <WORKFLOW_ID>"
    echo "3. Configure environment variables in .env for external integrations"
    echo "4. Read docs/cli-agents.md for full documentation"
    echo ""
    warning "Remember: Webhook-triggered agents need to run in background mode to listen for requests"
}

main "$@"