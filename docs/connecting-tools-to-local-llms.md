# Connecting n8n & LangFlow to Local LLMs

> **Simple guide to connect n8n workflows and LangFlow flows to your local LM Studio or Ollama setup**

## 🎯 Quick Start

**The key insight:** Both n8n and LangFlow use **"OpenAI API"** credential/component types to connect to ANY OpenAI-compatible API, including your local LLMs.

### Environment Variables (Already Set Up)

Our installer automatically configures these for you:

```bash
# LM Studio (default)
LLM_BASE_URL=http://localhost:1234/v1
LLM_API_KEY=local-lmstudio-key
LLM_MODEL_NAME=phi-3-mini-4k-instruct
LLM_DOCKER_URL=http://host.docker.internal:1234/v1

# Ollama (alternative)
OLLAMA_BASE_URL=http://localhost:11434/v1
OLLAMA_API_KEY=local-ollama-key
OLLAMA_MODEL_NAME=phi4-mini:latest
OLLAMA_DOCKER_URL=http://host.docker.internal:11434/v1
```

## 🔧 n8n Integration

### Step 1: Create OpenAI API Credential

**There is NO "LM Studio" credential type in n8n. Always use "OpenAI API".**

1. **n8n UI** → **Settings** → **Credentials** → **Add Credential**
2. **Search for "OpenAI"** → Select **"OpenAI API"**
3. **Configure:**
   - **Name:** "Local LM Studio" (or "Local Ollama")
   - **API Key:** `={{$env.LLM_API_KEY}}` (references environment variable)
   - **Base URL:** `={{$env.LLM_DOCKER_URL}}` (for Docker n8n) or `={{$env.LLM_BASE_URL}}` (for CLI n8n)

### Step 2: Use in Workflows

1. **Add OpenAI node** to your workflow
2. **Credential:** Select your "Local LM Studio" credential
3. **Model:** `={{$env.LLM_MODEL_NAME}}`
4. **Configure your prompt and parameters**

### Example n8n Workflow Node

```json
{
  "parameters": {
    "resource": "chat",
    "model": "={{$env.LLM_MODEL_NAME}}",
    "messages": {
      "messageValues": [
        {
          "role": "system",
          "content": "You are a product manager assistant."
        },
        {
          "role": "user", 
          "content": "Create a user story for mobile login"
        }
      ]
    },
    "temperature": 0.3,
    "maxTokens": 500
  },
  "id": "openai-node",
  "name": "Generate User Story",
  "type": "n8n-nodes-base.openAi",
  "credentials": {
    "openAiApi": {
      "id": "local-lm-studio",
      "name": "Local LM Studio"
    }
  }
}
```

### Multiple Provider Setup

Create separate credentials for different providers:

**LM Studio Credential:**
- Name: "Local LM Studio"
- API Key: `={{$env.LLM_API_KEY}}`
- Base URL: `={{$env.LLM_DOCKER_URL}}`

**Ollama Credential:**
- Name: "Local Ollama"
- API Key: `={{$env.OLLAMA_API_KEY}}`
- Base URL: `={{$env.OLLAMA_DOCKER_URL}}`

## 🌊 LangFlow Integration

### Step 1: Configure OpenAI Component

**LangFlow also uses "OpenAI" components for local LLMs.**

1. **Add OpenAI component** to your flow
2. **Configure:**
   - **Base URL:** `{LLM_DOCKER_URL}` (for Docker) or `{LLM_BASE_URL}` (for CLI)
   - **API Key:** `{LLM_API_KEY}`
   - **Model:** `{LLM_MODEL_NAME}`
   - **Temperature:** 0.3 (or your preference)

### Environment Variable Reference

LangFlow uses `{VARIABLE_NAME}` syntax to reference environment variables:

```json
{
  "base_url": "{LLM_BASE_URL}",
  "api_key": "{LLM_API_KEY}",
  "model_name": "{LLM_MODEL_NAME}",
  "temperature": 0.3,
  "max_tokens": 1000
}
```

### Multiple Provider Configuration

**LM Studio OpenAI Component:**
- Base URL: `{LLM_BASE_URL}` or `{LLM_DOCKER_URL}`
- API Key: `{LLM_API_KEY}`
- Model: `{LLM_MODEL_NAME}`

**Ollama OpenAI Component:**
- Base URL: `{OLLAMA_BASE_URL}` or `{OLLAMA_DOCKER_URL}`
- API Key: `{OLLAMA_API_KEY}`
- Model: `{OLLAMA_MODEL_NAME}`

## 🔄 Docker vs CLI URLs

### The URL Rule

Our scripts automatically handle this, but here's the logic:

| Your Setup | LM Studio URL to Use |
|------------|---------------------|
| **CLI n8n** → **Local LM Studio** | `http://localhost:1234/v1` |
| **Docker n8n** → **Local LM Studio** | `http://host.docker.internal:1234/v1` |
| **CLI LangFlow** → **Local LM Studio** | `http://localhost:1234/v1` |
| **Docker LangFlow** → **Local LM Studio** | `http://host.docker.internal:1234/v1` |

**Why the difference?**
- Docker containers run in isolation and need `host.docker.internal` to reach your Mac
- CLI applications run directly on your machine and use `localhost`

### Environment Variable Mapping

| Environment Variable | When to Use |
|---------------------|-------------|
| `LLM_BASE_URL` | CLI n8n, CLI LangFlow |
| `LLM_DOCKER_URL` | Docker n8n, Docker LangFlow |
| `OLLAMA_BASE_URL` | CLI n8n, CLI LangFlow |
| `OLLAMA_DOCKER_URL` | Docker n8n, Docker LangFlow |

## 🛠️ Troubleshooting

### Connection Issues

**"Connection refused" errors:**

1. **Check if LM Studio is running:**
   ```bash
   curl http://localhost:1234/v1/models
   ```

2. **Ensure LM Studio accepts network connections:**
   ```bash
   lsof -iTCP:1234 -sTCP:LISTEN
   ```
   Should show `0.0.0.0:1234`, not `127.0.0.1:1234`

3. **Verify Docker networking:**
   ```bash
   # From inside n8n container
   docker exec -u node n8n curl http://host.docker.internal:1234/v1/models
   ```

### Credential Issues

**n8n "Cannot find LM Studio credential":**
- Use **"OpenAI API"** credential type, NOT "LM Studio"
- There is no "LM Studio" credential type in n8n

**Environment variables not working:**
- Check Docker container environment: `docker exec n8n env | grep LLM`
- Restart containers after updating `.env`: `docker compose restart n8n langflow`

### Model Name Issues

**"Model not found" errors:**

1. **Get exact model name from LM Studio:**
   ```bash
   curl http://localhost:1234/v1/models | jq '.data[].id'
   ```

2. **Use exact model ID in configuration:**
   - n8n: `={{$env.LLM_MODEL_NAME}}`
   - LangFlow: `{LLM_MODEL_NAME}`

### Provider Switching

**Switch between LM Studio and Ollama:**

```bash
# Use the provider switching script
./scripts/switch-provider.sh ollama

# Or manually update .env file
DEFAULT_LLM_PROVIDER=ollama
```

## 🎛️ Advanced Configuration

### Custom Models

Add specialized models to your `.env`:

```bash
# PM-specific model
PM_SPECIALIST_URL=http://localhost:1234/v1
PM_SPECIALIST_KEY=local-pm-specialist-key
PM_SPECIALIST_MODEL=pm-assistant-v2

# Code-specific model  
CODE_SPECIALIST_URL=http://localhost:1235/v1
CODE_SPECIALIST_KEY=local-code-specialist-key
CODE_SPECIALIST_MODEL=deepseek-coder-v2
```

### External API Fallback

Configure cloud APIs as backup:

```bash
# External API keys for hybrid workflows
OPENAI_API_KEY=sk-your-openai-key-here
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key-here
```

### Security Best Practices

1. **Environment Variables:** Store non-secrets (URLs, model names) as environment variables
2. **n8n Credentials:** Store API keys in encrypted n8n credentials
3. **Encryption Key:** Set `N8N_ENCRYPTION_KEY` for credential encryption
4. **No Hardcoding:** Never hardcode URLs or keys in workflows/flows

## 📋 Quick Reference

### n8n Credential Setup
1. **OpenAI API** credential type (not "LM Studio")
2. **API Key:** `={{$env.LLM_API_KEY}}`
3. **Base URL:** `={{$env.LLM_DOCKER_URL}}`
4. **Model:** `={{$env.LLM_MODEL_NAME}}`

### LangFlow Component Setup
1. **OpenAI** component type (not "LM Studio")
2. **API Key:** `{LLM_API_KEY}`
3. **Base URL:** `{LLM_DOCKER_URL}`
4. **Model:** `{LLM_MODEL_NAME}`

### Environment Variables
```bash
# Check current setup
cat .env | grep LLM

# Test local LLM connection
curl http://localhost:1234/v1/models

# Switch providers
./scripts/switch-provider.sh [lmstudio|ollama]
```

---

**💡 Key Takeaway:** Both n8n and LangFlow connect to local LLMs using "OpenAI API" credential/component types. The magic is in the environment variables that automatically configure the correct URLs for your setup.