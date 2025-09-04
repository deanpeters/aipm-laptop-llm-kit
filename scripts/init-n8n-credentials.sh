#!/bin/bash
set -e

# n8n Credential Initialization Script
# Pre-configures Ollama credentials for Product Managers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
N8N_DATA_DIR="${N8N_DATA_DIR:-/home/node/.n8n}"
DATABASE_FILE="$N8N_DATA_DIR/database.sqlite"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[n8n-init]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Wait for n8n to be ready
wait_for_n8n() {
    log "Waiting for n8n database to be initialized..."
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if [[ -f "$DATABASE_FILE" ]]; then
            log "Database found at $DATABASE_FILE"
            return 0
        fi
        sleep 2
        ((attempt++))
    done
    
    warning "n8n database not found after ${max_attempts} attempts"
    return 1
}

# Check if credentials already exist
credentials_exist() {
    if [[ ! -f "$DATABASE_FILE" ]]; then
        return 1
    fi
    
    local count=$(sqlite3 "$DATABASE_FILE" "SELECT COUNT(*) FROM credentials_entity WHERE name='Local Ollama (Pre-configured)'" 2>/dev/null || echo "0")
    [[ "$count" -gt 0 ]]
}

# Create Ollama credential
create_ollama_credential() {
    log "Creating pre-configured Ollama credential..."
    
    # Generate credential UUID
    local credential_id=$(openssl rand -hex 16 | sed 's/\(..\)/\1-/g; s/-$//' | sed 's/\(........\)-\(....\)-\(....\)-\(....\)-\(............\)/\1-\2-\3-\4-\5/')
    
    # Credential data (OpenAI API format for Ollama)
    local credential_data='{
        "apiKey": "local-ollama-key",
        "baseURL": "http://ollama:11434/v1"
    }'
    
    # Insert credential into database
    sqlite3 "$DATABASE_FILE" << EOF
INSERT OR REPLACE INTO credentials_entity (
    id, 
    name, 
    type, 
    data, 
    createdAt, 
    updatedAt
) VALUES (
    '$credential_id',
    'Local Ollama (Pre-configured)',
    'openAiApi',
    '$credential_data',
    datetime('now'),
    datetime('now')
);
EOF
    
    success "Created 'Local Ollama (Pre-configured)' credential"
    log "Credential ID: $credential_id"
}

# Main initialization function
main() {
    log "Initializing n8n with pre-configured Ollama credentials..."
    
    # Wait for n8n to create its database
    if ! wait_for_n8n; then
        warning "Could not initialize credentials - n8n database not ready"
        exit 0  # Don't fail the container startup
    fi
    
    # Check if we need to create credentials
    if credentials_exist; then
        success "Ollama credentials already configured"
        exit 0
    fi
    
    # Create the credential
    create_ollama_credential
    
    success "n8n credential initialization complete!"
    log "Product Managers can now use 'Local Ollama (Pre-configured)' in workflows"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi