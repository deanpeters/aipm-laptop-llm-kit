# Terminology Guide for AIPM Laptop LLM Kit

> **Understanding key terms and concepts for local AI tools and configurations**

## 🎯 Overview

This guide explains terminology you'll encounter when setting up and using your local AI stack. No need to guess what "credentials" or "API keys" mean in different tools - everything is explained here.

## 🔑 API Keys and Authentication

### What are API Keys?
**API Keys** are like passwords that tools use to connect to AI models. In cloud services like OpenAI, these are secret tokens that cost money per use. In our local setup, they're just identifiers.

#### Local vs. Cloud API Keys:
- **Local API Keys**: `local-lmstudio-key` - Just identifiers, no cost, no external connection
- **Cloud API Keys**: `sk-1234abcd...` - Real secrets that cost money per API call

### Why Use Local API Keys?
Even though our local models don't need authentication, tools like n8n and LangFlow expect API keys in their configuration. We use fake/local keys to satisfy the tool requirements.

## 🔌 Environment Variables

### What are Environment Variables?
**Environment Variables** are settings stored on your computer that applications can access. Think of them as a global settings file that all your tools can read.

#### Example:
~~~bash
# In your .env file:
LLM_API_KEY=local-lmstudio-key

# Tools can access this as:
# n8n: ={{$env.LLM_API_KEY}}
# LangFlow: {LLM_API_KEY}
# Python: os.getenv('LLM_API_KEY')
~~~

### Benefits of Environment Variables:
- **Security**: API keys aren't hardcoded in workflows
- **Flexibility**: Easy to switch between models or providers
- **Consistency**: Same settings across all tools
- **Team Sharing**: Share workflows without exposing secrets

## 🛠️ Tool-Specific Terminology

### n8n (Workflow Automation)

#### **Credentials**
In n8n, **credentials** are how you map environment variables to API connections. Think of them as "connection profiles."

**Creating n8n Credentials:**
1. **Go to**: Settings → Credentials → Add Credential
2. **Choose**: "OpenAI API" (even for local models)
3. **Configure**:
   - **Name**: "Local LM Studio" (your choice)
   - **API Key**: `={{$env.LLM_API_KEY}}` (references environment variable)
   - **Base URL**: `={{$env.LLM_DOCKER_URL}}`

**Using Credentials in Workflows:**
1. **Add OpenAI Node** to your workflow
2. **Select Credential**: Choose "Local LM Studio"
3. **Model Field**: Use `={{$env.LLM_MODEL_NAME}}`

#### **Workflow vs. Node vs. Credential**:
- **Workflow**: The entire automation (like "Daily Standup Generator")
- **Node**: Individual steps in workflow (like "OpenAI" or "Slack")
- **Credential**: Connection settings (like "Local LM Studio")

### LangFlow (Visual AI Workflows)

#### **Components**
In LangFlow, **components** are building blocks for AI workflows. Each component has configuration fields.

**Using Environment Variables in Components:**
1. **OpenAI Component**: 
   - **Base URL**: `{LLM_DOCKER_URL}` (references environment)
   - **API Key**: `{LLM_API_KEY}`
   - **Model**: `{LLM_MODEL_NAME}`

#### **Flow vs. Component**:
- **Flow**: Complete AI workflow (like "Document Analysis")
- **Component**: Individual building blocks (like "OpenAI" or "Text Input")

### VS Code (AI Coding Assistant)

#### **Configuration Files**
VS Code extensions use **configuration files** instead of environment variables.

**Continue.dev Configuration** (`config/continue.json`):
~~~json
{
  "models": [
    {
      "title": "Local Phi-3",
      "provider": "openai",
      "model": "microsoft-phi4-mini-4k-instruct-gguf",
      "apiBase": "http://localhost:1234/v1",
      "apiKey": "not-needed"
    }
  ]
}
~~~

### AnythingLLM (Document Chat)

#### **LLM Provider Settings**
AnythingLLM calls API configurations **LLM Provider Settings**.

**Configuration:**
- **Provider**: "Generic OpenAI" (even for local models)
- **Base URL**: `http://host.docker.internal:1234/v1`
- **API Key**: `local-api-key` (any text works)
- **Model**: `microsoft-phi4-mini-4k-instruct-gguf`

## 🌐 Network Terminology

### Local vs. Docker URLs

#### **Local URLs** (for desktop apps):
~~~
http://localhost:1234/v1
~~~
Use for: VS Code, desktop applications, command line tools

#### **Docker URLs** (for containerized apps):
~~~
http://host.docker.internal:1234/v1
~~~
Use for: n8n, LangFlow, AnythingLLM, any Docker containers

### Why the Difference?
- **Docker containers** run in isolation and can't access `localhost`
- **`host.docker.internal`** is Docker's way to reach your computer from inside containers
- **Desktop apps** run directly on your computer, so `localhost` works

## 🤖 AI Model Terminology

### Model Names and Identifiers

#### **Display Names** (human-readable):
- "Phi-3 Mini"
- "GPT-4"
- "Claude 3"

#### **Model IDs** (technical identifiers):
- `microsoft-phi4-mini-4k-instruct-gguf`
- `gpt-4-1106-preview`
- `claude-3-sonnet-20240229`

**Important**: Always use **Model IDs** in configurations, not display names.

### Model Types:
- **Base Models**: General-purpose (like Phi-3 Mini)
- **Fine-tuned Models**: Specialized for specific tasks (like your PM assistant)
- **Code Models**: Optimized for programming (like DeepSeek Coder)

## 📊 PM-Specific Terminology

### Workflow Patterns

#### **Task-Based Routing**
Using different models for different PM tasks:
- **User Stories**: PM specialist model
- **Technical Specs**: Code specialist model
- **Creative Content**: General model with high creativity

#### **Hybrid Workflows**
Combining local and cloud models:
- **Local First**: Use local models for privacy/cost
- **Cloud Fallback**: Use cloud models for complex tasks
- **Model Selection**: Choose based on task complexity

### Configuration Patterns

#### **Multi-Model Setup**
Environment variables for different purposes:
~~~bash
# General purpose
LLM_BASE_URL=http://localhost:1234/v1
LLM_MODEL_NAME=phi4-mini

# PM specialized
PM_SPECIALIST_URL=http://localhost:1234/v1
PM_SPECIALIST_MODEL=pm-assistant-v2

# External APIs
OPENAI_API_KEY=sk-your-key
~~~

## 🔧 Common Configurations Explained

### n8n Credential Example
**What you see**: "Add OpenAI Credential"
**What it means**: Create a connection profile for any OpenAI-compatible API
**For local LLM**: Use your local LM Studio endpoint

### LangFlow Component Example
**What you see**: "OpenAI Component"
**What it means**: A component that works with OpenAI-compatible APIs
**For local LLM**: Configure with your local endpoint

### Environment Variable Syntax
**What you see**: `={{$env.LLM_API_KEY}}`
**What it means**: Get the value of LLM_API_KEY from environment variables
**Tool-specific**:
- **n8n**: `={{$env.VARIABLE_NAME}}`
- **LangFlow**: `{VARIABLE_NAME}`
- **Shell**: `$VARIABLE_NAME` or `${VARIABLE_NAME}`

## ⚠️ Common Confusions Clarified

### "OpenAI" Doesn't Mean OpenAI
Many tools use "OpenAI" to mean "OpenAI-compatible API format." This includes:
- Local LM Studio
- Ollama
- Text Generation WebUI
- Many other local inference servers

### "No LM Studio/Ollama Credential in n8n"
**Problem**: Looking for "LM Studio" or "Ollama" in n8n credential types
**Solution**: Use **"OpenAI API"** credential type for BOTH providers
**Why**: n8n doesn't have specific credential types for local providers, but "OpenAI API" works with any OpenAI-compatible endpoint

**Works for:**
- LM Studio (http://localhost:1234/v1)
- Ollama (http://localhost:11434/v1)
- Any other OpenAI-compatible API

### "API Key Required" for Local Models
Some tools require an API key field even for local models. Common solutions:
- Use `not-needed` or `local-key`
- For strict validation: `sk-local-key` (starts with sk-)
- Environment variable: `local-lmstudio-key`

### Docker Networking Issues
**Problem**: "Connection refused" errors
**Cause**: Using `localhost` in Docker containers
**Solution**: Use `host.docker.internal` instead

### Model Name Mismatches
**Problem**: "Model not found" errors
**Cause**: Using display name instead of model ID
**Solution**: Get exact model ID from `curl http://localhost:1234/v1/models`

## 🎯 Quick Reference

### Essential Environment Variables
~~~bash
# Core local LLM setup
LLM_BASE_URL=http://localhost:1234/v1
LLM_API_KEY=local-lmstudio-key
LLM_MODEL_NAME=microsoft-phi4-mini-4k-instruct-gguf
LLM_DOCKER_URL=http://host.docker.internal:1234/v1
~~~

### Tool Integration Syntax
~~~bash
# n8n workflows
API Key: ={{$env.LLM_API_KEY}}
Base URL: ={{$env.LLM_DOCKER_URL}}

# LangFlow components  
API Key: {LLM_API_KEY}
Base URL: {LLM_DOCKER_URL}

# Command line
echo $LLM_BASE_URL
curl "$LLM_BASE_URL/models"
~~~

### Common URLs
~~~bash
# For desktop tools
http://localhost:1234/v1

# For Docker containers
http://host.docker.internal:1234/v1

# For Ollama (alternative)
http://localhost:11434/api
~~~

---

**💡 Still confused about a term?** Check the [Connecting Tools to Local LLMs](connecting-tools-to-local-llms.md) guide for specific examples, or the [Troubleshooting](#troubleshooting) section in the main README.