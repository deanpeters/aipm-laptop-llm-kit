#!/bin/bash
set -e

# LangFlow Global Variables Setup Script for Product Managers
# Pre-configures Ollama connection and PM-specific templates

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LANGFLOW_STORAGE="${PROJECT_ROOT}/storage/langflow"
LANGFLOW_URL="http://localhost:7860"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[langflow-setup]${NC} $1"
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

# Check if LangFlow is running
check_langflow_running() {
    if ! curl -s "${LANGFLOW_URL}/health" > /dev/null 2>&1; then
        error "LangFlow is not running or not accessible at ${LANGFLOW_URL}"
        log "Please start LangFlow first: docker compose --profile optional up -d langflow"
        exit 1
    fi
}

# Wait for LangFlow to be fully ready
wait_for_langflow() {
    log "Waiting for LangFlow to be fully ready..."
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if curl -s "${LANGFLOW_URL}/api/v1/flows" > /dev/null 2>&1; then
            log "LangFlow API is responding"
            return 0
        fi
        sleep 3
        ((attempt++))
    done
    
    error "LangFlow API not ready after ${max_attempts} attempts"
    return 1
}

# Create global variables via API
create_global_variables() {
    log "Creating global variables for Ollama connection..."
    
    # Read the global variables template
    local vars_file="${PROJECT_ROOT}/config/langflow-init/global_variables.json"
    if [[ ! -f "$vars_file" ]]; then
        error "Global variables template not found at $vars_file"
        return 1
    fi
    
    # Create each variable via LangFlow API
    local variables=(
        "OLLAMA_BASE_URL:http://ollama:11434/v1:Base URL for local Ollama server"
        "OLLAMA_API_KEY:local-ollama-key:API key for local Ollama server"
        "OLLAMA_MODEL:phi3:mini:Default Ollama model for PM tasks"
        "PM_SYSTEM_PROMPT:You are a Product Manager AI assistant specialized in writing user stories, creating PRDs, analyzing market trends, and facilitating agile workflows.:System prompt for PM tasks"
        "USER_STORY_TEMPLATE:As a [user], I want [goal] so that [benefit]. Acceptance Criteria: [testable conditions].:Template for user stories"
    )
    
    for var_def in "${variables[@]}"; do
        IFS=':' read -r name value description <<< "$var_def"
        
        log "Creating variable: $name"
        
        # Create variable via API call
        local response=$(curl -s -X POST "${LANGFLOW_URL}/api/v1/variables" \
            -H "Content-Type: application/json" \
            -d "{
                \"name\": \"$name\",
                \"value\": \"$value\",
                \"type\": \"str\",
                \"description\": \"$description\"
            }" 2>/dev/null)
        
        if [[ $? -eq 0 ]]; then
            success "Created global variable: $name"
        else
            warning "Could not create variable $name (may already exist)"
        fi
        
        sleep 1  # Rate limiting
    done
}

# Create example PM flow with pre-configured variables
create_example_flow() {
    log "Creating example PM workflow with pre-configured Ollama..."
    
    local flow_json='{
        "name": "PM User Story Generator (Pre-configured)",
        "description": "Generate user stories using pre-configured Ollama connection",
        "data": {
            "nodes": [
                {
                    "id": "chat-input",
                    "type": "ChatInput",
                    "data": {
                        "node": {
                            "base_classes": ["Message"],
                            "display_name": "Feature Description",
                            "description": "Describe the feature you want a user story for"
                        }
                    }
                },
                {
                    "id": "ollama-llm", 
                    "type": "ChatOllama",
                    "data": {
                        "node": {
                            "base_classes": ["BaseLanguageModel"],
                            "display_name": "Ollama PM Assistant",
                            "description": "Pre-configured Ollama for PM tasks"
                        },
                        "base_url": "{OLLAMA_BASE_URL}",
                        "model": "{OLLAMA_MODEL}",
                        "system_message": "{PM_SYSTEM_PROMPT}"
                    }
                },
                {
                    "id": "chat-output",
                    "type": "ChatOutput", 
                    "data": {
                        "node": {
                            "base_classes": ["Message"],
                            "display_name": "Generated User Story",
                            "description": "Your formatted user story with acceptance criteria"
                        }
                    }
                }
            ],
            "edges": [
                {
                    "source": "chat-input",
                    "target": "ollama-llm"
                },
                {
                    "source": "ollama-llm", 
                    "target": "chat-output"
                }
            ]
        }
    }'
    
    # Create the flow
    local response=$(curl -s -X POST "${LANGFLOW_URL}/api/v1/flows" \
        -H "Content-Type: application/json" \
        -d "$flow_json" 2>/dev/null)
    
    if [[ $? -eq 0 ]]; then
        success "Created example PM workflow"
        log "Flow uses global variables: {OLLAMA_BASE_URL}, {OLLAMA_MODEL}, {PM_SYSTEM_PROMPT}"
    else
        warning "Could not create example flow (LangFlow may need manual setup)"
    fi
}

# Main setup function
main() {
    log "Setting up LangFlow global variables for Product Managers..."
    
    # Check if LangFlow is running
    check_langflow_running
    
    # Wait for LangFlow to be ready
    if ! wait_for_langflow; then
        error "Could not set up global variables - LangFlow not ready"
        exit 1
    fi
    
    # Create global variables
    create_global_variables
    
    # Create example flow
    create_example_flow
    
    success "LangFlow global variables setup complete!"
    log ""
    log "🎯 Product Managers can now:"
    log "   1. Open LangFlow at ${LANGFLOW_URL}"
    log "   2. Use global variables in flows: {OLLAMA_BASE_URL}, {OLLAMA_MODEL}" 
    log "   3. Reference PM templates: {PM_SYSTEM_PROMPT}, {USER_STORY_TEMPLATE}"
    log "   4. Try the pre-configured 'PM User Story Generator' flow"
    log ""
    log "📚 Variables are automatically substituted in LangFlow components"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "LangFlow Global Variables Setup for AIPM Laptop LLM Kit"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo ""
        echo "This script creates pre-configured global variables in LangFlow"
        echo "for seamless Ollama integration and PM-specific templates."
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac