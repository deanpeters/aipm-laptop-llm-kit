#!/bin/bash
set -e

# Custom n8n entrypoint with credential initialization
# This script runs before n8n starts to pre-configure Ollama credentials

echo "🚀 AIPM n8n Initialization Starting..."

# Start n8n in the background to initialize database
echo "📦 Starting n8n to initialize database..."
n8n start &
N8N_PID=$!

# Wait for n8n to create its database
echo "⏳ Waiting for n8n database initialization..."
sleep 10

# Check if credential initialization is enabled
if [[ "${N8N_INIT_CREDENTIALS:-false}" == "true" ]]; then
    echo "🔐 Initializing pre-configured credentials..."
    
    # Run the credential initialization script
    if [[ -f "/home/node/.n8n/init-credentials.sh" ]]; then
        bash /home/node/.n8n/init-credentials.sh
    else
        echo "⚠️ Credential initialization script not found, skipping..."
    fi
else
    echo "⏭️ Credential initialization disabled"
fi

# Stop the background n8n process
echo "🔄 Restarting n8n with credentials configured..."
kill $N8N_PID || true
wait $N8N_PID 2>/dev/null || true

echo "✅ AIPM n8n initialization complete!"
echo "🎯 Product Managers can now use 'Local Ollama (Pre-configured)' credentials"

# Start n8n normally
echo "🌟 Starting n8n..."
exec n8n start