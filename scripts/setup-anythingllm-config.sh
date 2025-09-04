#!/bin/bash
set -e

# AnythingLLM Configuration Setup Script for Product Managers
# Pre-configures Ollama connection and PM-optimized settings

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ANYTHINGLLM_DB="${PROJECT_ROOT}/storage/anythingllm/anythingllm.db"
ANYTHINGLLM_URL="http://localhost:3001"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[anythingllm-setup]${NC} $1"
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

# Check if AnythingLLM is running
check_anythingllm_running() {
    if ! curl -s "${ANYTHINGLLM_URL}/api/ping" > /dev/null 2>&1; then
        error "AnythingLLM is not running or not accessible at ${ANYTHINGLLM_URL}"
        log "Please start AnythingLLM first: docker compose up -d anythingllm"
        exit 1
    fi
}

# Wait for AnythingLLM database to be created
wait_for_database() {
    log "Waiting for AnythingLLM database..."
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if [[ -f "$ANYTHINGLLM_DB" ]]; then
            log "Database found at $ANYTHINGLLM_DB"
            return 0
        fi
        sleep 2
        ((attempt++))
    done
    
    error "AnythingLLM database not found after ${max_attempts} attempts"
    return 1
}

# Check if configuration already exists
config_exists() {
    if [[ ! -f "$ANYTHINGLLM_DB" ]]; then
        return 1
    fi
    
    local count=$(sqlite3 "$ANYTHINGLLM_DB" "SELECT COUNT(*) FROM system_settings WHERE label='llm_provider'" 2>/dev/null || echo "0")
    [[ "$count" -gt 0 ]]
}

# Configure Ollama as LLM provider
configure_ollama_provider() {
    log "Configuring Ollama as LLM provider..."
    
    if [[ ! -f "$ANYTHINGLLM_DB" ]]; then
        error "AnythingLLM database not found"
        return 1
    fi
    
    # Configure LLM provider settings
    sqlite3 "$ANYTHINGLLM_DB" << 'EOF'
-- Configure Ollama as the LLM provider
INSERT OR REPLACE INTO system_settings (label, value, createdAt, updatedAt) VALUES
('llm_provider', 'custom-openai', datetime('now'), datetime('now')),
('open_ai_base_path', 'http://ollama:11434/v1', datetime('now'), datetime('now')), 
('open_ai_api_key', 'local-ollama-key', datetime('now'), datetime('now')),
('open_ai_model_pref', 'phi3:mini', datetime('now'), datetime('now')),
('open_ai_temp', '0.7', datetime('now'), datetime('now')),
('open_ai_max_tokens', '4096', datetime('now'), datetime('now'));

-- Configure embedding provider (use Ollama embeddings)
INSERT OR REPLACE INTO system_settings (label, value, createdAt, updatedAt) VALUES
('embedding_engine', 'ollama', datetime('now'), datetime('now')),
('embedding_base_path', 'http://ollama:11434', datetime('now'), datetime('now')),
('embedding_model_pref', 'nomic-embed-text', datetime('now'), datetime('now'));

-- Configure vector database settings optimized for PM documents
INSERT OR REPLACE INTO system_settings (label, value, createdAt, updatedAt) VALUES
('vector_db', 'lancedb', datetime('now'), datetime('now')),
('text_splitter_chunk_size', '1000', datetime('now'), datetime('now')),
('text_splitter_chunk_overlap', '200', datetime('now'), datetime('now'));

-- Set system message optimized for Product Management
INSERT OR REPLACE INTO system_settings (label, value, createdAt, updatedAt) VALUES
('system_customization_messages', '[{"role":"system","content":"You are an AI assistant specialized in Product Management. Help users with user stories, product requirements, market analysis, roadmap planning, and agile workflows. Always provide structured, actionable responses suitable for PM documentation."}]', datetime('now'), datetime('now'));
EOF
    
    success "Configured Ollama as LLM provider"
    log "  Base URL: http://ollama:11434/v1"
    log "  Model: phi3:mini"
    log "  Embeddings: nomic-embed-text"
}

# Create default workspace for PM documents
create_pm_workspace() {
    log "Creating default PM workspace..."
    
    # Create a workspace optimized for PM documents
    sqlite3 "$ANYTHINGLLM_DB" << 'EOF'
INSERT OR REPLACE INTO workspaces (id, name, slug, vectorTag, createdAt, lastUpdatedAt) VALUES
(1, 'Product Management Hub', 'pm-hub', 'pm-documents', datetime('now'), datetime('now'));

-- Configure workspace settings
INSERT OR REPLACE INTO workspace_settings (workspaceId, label, value, createdAt, updatedAt) VALUES
(1, 'system_prompt', 'You are a Product Manager AI assistant. Help analyze documents, generate user stories, create PRDs, and provide strategic product insights. Focus on actionable recommendations and structured PM deliverables.', datetime('now'), datetime('now')),
(1, 'openAiTemp', '0.7', datetime('now'), datetime('now')),
(1, 'openAiHistory', '10', datetime('now'), datetime('now')),
(1, 'openAiPrompt', 'You are a helpful Product Manager assistant focused on creating clear, actionable product documentation and insights.', datetime('now'), datetime('now'));
EOF
    
    success "Created 'Product Management Hub' workspace"
    log "  Workspace optimized for PM document analysis"
    log "  Pre-configured with PM-focused prompts"
}

# Main setup function
main() {
    log "Setting up AnythingLLM configuration for Product Managers..."
    
    # Check prerequisites
    if ! command -v sqlite3 >/dev/null 2>&1; then
        error "sqlite3 is required but not installed"
        exit 1
    fi
    
    # Check if AnythingLLM is running
    check_anythingllm_running
    
    # Wait for database to be created
    if ! wait_for_database; then
        error "Could not set up configuration - AnythingLLM database not ready"
        exit 1
    fi
    
    # Skip if already configured
    if config_exists; then
        success "AnythingLLM already configured"
        exit 0
    fi
    
    # Configure Ollama provider
    configure_ollama_provider
    
    # Create PM workspace
    create_pm_workspace
    
    success "AnythingLLM configuration complete!"
    log ""
    log "🎯 Product Managers can now:"
    log "   1. Open AnythingLLM at ${ANYTHINGLLM_URL}"
    log "   2. Use the 'Product Management Hub' workspace"
    log "   3. Upload PM documents (PRDs, user stories, market research)"
    log "   4. Chat with documents using Ollama phi3:mini model"
    log ""
    log "📚 Configuration automatically uses local Ollama server"
    log "⚡ No manual LLM setup required - ready to use immediately!"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "AnythingLLM Configuration Setup for AIPM Laptop LLM Kit"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo ""
        echo "This script pre-configures AnythingLLM with Ollama connection"
        echo "and creates a PM-optimized workspace."
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac