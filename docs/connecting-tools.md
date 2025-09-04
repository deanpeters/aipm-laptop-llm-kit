# Connecting All Tools to Your Local LLM

> **Complete integration guide with pre-configured connections: VS Code, n8n, LangFlow, and other tools to your local Phi-3 Mini model**

## 🎯 Overview

This guide shows you exactly how to connect every tool in the AIPM Laptop LLM Kit to your local Phi-3 Mini model running in Ollama. 

**🎉 New in v1.05:** Most connections are now **pre-configured automatically** and services launch early during installation! This guide shows you how to use the pre-configured connections and how to customize them if needed.

## 🚀 Pre-Configured Connections (Recommended for PMs)

The AIPM Laptop LLM Kit now comes with **pre-built connections** to eliminate setup complexity for Product Managers:

### Automatic Setup
Run this single command to configure all tool connections:
```bash
./scripts/setup-all-credentials.sh
```

This script automatically configures:
- ✅ **n8n**: "Local Ollama (Pre-configured)" credential
- ✅ **AnythingLLM**: "Product Management Hub" workspace  
- ✅ **LangFlow**: Global variables `{OLLAMA_BASE_URL}`, `{OLLAMA_MODEL}`
- ✅ **Continue.dev**: Ollama provider configuration
- ✅ **Cline**: VS Code workspace settings with PM prompts

### What This Means for You
- **No manual credential setup needed** - everything works immediately
- **Learning by example** - see working configurations to understand how connections work
- **PM-optimized settings** - system prompts and templates focused on Product Management tasks
- **One-click workflows** - start using AI tools for PM tasks right away

### If Pre-Configuration Doesn't Work
If you don't see pre-configured options in your tools, or want to customize connections manually, continue reading the detailed setup sections below.

## 🔧 Prerequisites

Before connecting tools, ensure:
- ✅ **Ollama is running** with Phi-3 Mini model loaded
- ✅ **Local server is active** on port 11434
- ✅ **Environment variables configured** (copy `config/env.example` to `.env`)
- ✅ **Model is responding** (test with: `curl http://localhost:11434/api/tags`)

### Environment Variables Setup
1. **Copy template:** `cp config/env.example .env`
2. **Edit `.env` file** with your preferred settings:
   ~~~bash
   # Primary Local LLM Configuration (Ollama)
   OLLAMA_BASE_URL=http://localhost:11434/v1
   OLLAMA_API_KEY=local-ollama-key
   OLLAMA_MODEL_NAME=phi4-mini:latest
   OLLAMA_DOCKER_URL=http://ollama:11434/v1
   ~~~
3. **Load environment:** `source .env` (or restart your terminal)

### Quick Ollama Setup
1. **Start Ollama:** `ollama serve` (or it may auto-start)
2. **Download model:** `ollama pull phi4-mini:latest` (done automatically during install)
3. **Verify service:** Should be running on port 11434
4. **Test connection:** `curl http://localhost:11434/api/tags`

**Expected response:**
~~~json
{
  "models": [
    {
      "name": "phi4-mini:latest",
      "size": "2300000000",
      "digest": "...",
      "modified_at": "2024-01-01T00:00:00Z"
    }
  ]
}
~~~

## 🔌 VS Code Integration

### Continue.dev Setup (AI Coding Assistant) ✅ PRE-CONFIGURED

The Continue.dev extension is **already pre-configured** to work with your local Ollama model! Here's how to verify and customize:

#### 1. Verify Configuration
1. **Open VS Code** in your project directory: `code .`
2. **Press Ctrl+Shift+P** → Type "Continue: Open config.json"
3. **Check configuration** (should already be set up):

~~~json
{
  "models": [
    {
      "title": "Phi-4 Mini (Local)",
      "provider": "ollama",
      "model": "phi4-mini:latest",
      "apiBase": "http://localhost:11434"
    }
  ],
  "customCommands": [
    {
      "name": "test",
      "prompt": "Write a simple test for the following code:\n\n{{{ input }}}"
    }
  ]
}
~~~

#### 2. Test Continue.dev
1. **Open any code file** (or create `test.py`)
2. **Press Ctrl+I** → Type: "Write a hello world function"
3. **AI should respond** with code suggestions using your local model

#### 3. Custom Configuration Options
Add these to your `config.json` for PM-specific tasks:

~~~json
{
  "models": [
    {
      "title": "Phi-4 Mini (Local)",
      "provider": "ollama",
      "model": "phi4-mini:latest",
      "apiBase": "http://localhost:11434",
      "requestOptions": {
        "temperature": 0.7,
        "maxTokens": 2048
      }
    }
  ],
  "customCommands": [
    {
      "name": "prd",
      "prompt": "Create a Product Requirements Document for:\n\n{{{ input }}}"
    },
    {
      "name": "user-story", 
      "prompt": "Write a user story with acceptance criteria for:\n\n{{{ input }}}"
    },
    {
      "name": "stakeholder-update",
      "prompt": "Write a stakeholder update email about:\n\n{{{ input }}}"
    }
  ]
}
~~~

#### 4. Using Custom Commands
1. **Select text** describing a feature
2. **Right-click** → "Continue" → "user-story"
3. **AI generates** a properly formatted user story

### Cline Setup (Advanced AI Workflows) ✅ PRE-CONFIGURED

Cline is **already pre-configured** with PM-optimized workspace settings! Here's how to use it:

#### 1. Start Cline
1. **Press Ctrl+Shift+P** → Type "Cline: Start Cline"
2. **Select your model:** Should show "Phi-4 Mini (Local)"
3. **Start chatting:** Ask Cline to help with PM tasks

#### 2. PM-Optimized Prompts for Cline
~~~
"Create a PRD for a user authentication feature including success metrics and technical requirements"

"Generate a competitive analysis comparing 3 project management tools with pros/cons and recommendations" 

"Write a stakeholder update about a 2-week delay in the mobile app release, including mitigation plan"

"Create user stories with acceptance criteria for an e-commerce checkout flow"
~~~

## 🚀 AnythingLLM Integration ✅ PRE-CONFIGURED

AnythingLLM is **already pre-configured** with a PM-optimized workspace! Here's how to use it:

### 1. Access AnythingLLM
1. **Open browser:** http://localhost:3001
2. **Create account** (local only, no external signup)
3. **Create workspace:** Name it something like "PM Documents"

### 2. Verify LLM Connection
1. **Go to Settings** → "LLM Preference"
2. **Should show:**
   - Provider: Generic OpenAI
   - Base URL: `http://ollama:11434/v1`
   - API Key: `local-api-key`
   - Model: `phi4-mini:latest`

### 3. If Connection Fails
Update settings manually:
1. **LLM Provider:** Generic OpenAI
2. **Base URL:** `http://ollama:11434/v1`
3. **API Key:** `not-needed` (or any text)
4. **Chat Model:** `phi4-mini:latest`
5. **Click "Update"** and test with a message

### 4. Upload PM Documents
1. **Click "Upload Document"** or drag & drop
2. **Supported formats:** PDF, DOCX, TXT, MD, CSV
3. **Wait for processing** (watch progress bar)
4. **Start chatting** with your documents

### 5. PM-Specific Chat Examples
~~~
"Summarize the key requirements from this PRD"
"What are the main user pain points mentioned in this research report?"
"Extract all the acceptance criteria from these user stories"
"Create a feature comparison table from these competitive analysis documents"
~~~

## 🔄 n8n Integration (Workflow Automation) ✅ PRE-CONFIGURED

Connect n8n to your local LLM for automated PM workflows - **credentials are already set up for you!**

### 1. Access n8n
1. **Open browser:** http://localhost:5678
2. **Create account** (local instance)
3. **Skip onboarding** or complete setup

### 2. Use Pre-Configured Credentials (Recommended for PMs)

🎉 **Good news!** Your n8n instance comes with pre-configured Ollama credentials to make setup easier.

#### Option A: Use Pre-Configured Credential (Easiest)
1. **Open n8n:** http://localhost:5678
2. **Create a workflow** → Add any LLM node (like "OpenAI")
3. **Select credential:** Look for **"Local Ollama (Pre-configured)"**
4. **That's it!** No configuration needed - it's ready to use

If you don't see the pre-configured credential, run this setup command:
```bash
./scripts/setup-n8n-credentials.sh
```

#### Option B: Manual Credential Creation

> **⚠️ IMPORTANT:** There is no "Ollama" credential type in n8n. You MUST use the **"OpenAI API"** credential type instead. This works with any OpenAI-compatible API, including Ollama.

**Steps:**
1. **Settings** → **Credentials** → **Add Credential**
2. **Search for "OpenAI"** → Select **"OpenAI API"** (NOT Ollama)
3. **Configure:**
   - **Name:** "My Local Ollama"
   - **API Key:** `local-ollama-key`
   - **Base URL:** `http://ollama:11434/v1`
4. **Save** the credential

### 3. Create Your First PM Workflow

Let's test the pre-configured credentials with a simple user story generator:

#### Quick Test Workflow
1. **New Workflow:** Click "+" → "Blank workflow"
2. **Add Trigger:** Search "Manual" → Add "Manual Trigger"
3. **Add LLM Node:** Search "OpenAI" → Add "OpenAI Chat Model"
4. **Configure LLM Node:**
   - **Credential:** Select "Local Ollama (Pre-configured)"
   - **Model:** `phi4-mini:latest`
   - **Messages:** User Message
   - **User Message:** `Create a user story for user login functionality`
5. **Test:** Click "Test workflow" → Should get PM-formatted response!

**PM Specialist Model:**
- **Name:** "PM Specialist"
- **API Key:** `={{$env.PM_SPECIALIST_KEY}}`
- **Base URL:** `={{$env.PM_SPECIALIST_URL}}`

**General Purpose Model:**
- **Name:** "General LLM"
- **API Key:** `={{$env.OPENAI_API_KEY}}` (if using OpenAI as backup)
- **Base URL:** `https://api.openai.com/v1`

### 3. Test Connection with Simple Workflow

#### Test Ollama Connection:
1. **Add "Manual Trigger"** node
2. **Add "OpenAI" node** → Connect to trigger
3. **Configure OpenAI node:**
   - **Credential:** Select "Local Ollama"
   - **Resource:** "Text"  
   - **Operation:** "Complete"
   - **Model:** `={{$env.LLM_MODEL_NAME}}` (uses environment variable)
   - **Prompt:** `Write a brief product update for a team meeting`
4. **Execute workflow** → Should get AI-generated response

#### Test Ollama Connection:
1. **Add "Manual Trigger"** node
2. **Add "OpenAI" node** → Connect to trigger
3. **Configure OpenAI node:**
   - **Credential:** Select "Local Ollama"
   - **Resource:** "Text"
   - **Operation:** "Complete"  
   - **Model:** `={{$env.OLLAMA_MODEL_NAME}}` (e.g., `phi4-mini:latest`)
   - **Prompt:** `Write a brief product update for a team meeting`
4. **Execute workflow** → Should get AI-generated response

#### Test Both Providers (Advanced):
Create a workflow that tries Ollama first, then falls back to Ollama:
1. **Manual Trigger** → **OpenAI (Ollama)** → **IF Node**
2. **IF condition:** Check if Ollama response succeeded
3. **True branch:** Use Ollama response
4. **False branch:** **OpenAI (Ollama)** as backup

#### Advanced Model Selection
For dynamic model selection based on task type:

**Expression Node Example:**
~~~javascript
// Choose model based on task type
const taskType = $input.first().json.taskType;
const modelMap = {
  'technical': $env.LLM_MODEL_NAME,
  'creative': $env.PM_SPECIALIST_MODEL,
  'analysis': $env.OPENAI_API_KEY ? 'gpt-4' : $env.LLM_MODEL_NAME
};

return [{
  json: {
    selectedModel: modelMap[taskType] || $env.LLM_MODEL_NAME,
    selectedCredential: taskType === 'analysis' && $env.OPENAI_API_KEY ? 'General LLM' : 'Local Ollama'
  }
}];
~~~

### 4. PM Workflow Examples

#### A. Daily Standup Generator
**Trigger:** Schedule (daily 9 AM)
**Nodes:** 
- HTTP Request (fetch Jira tickets)
- OpenAI (summarize progress)
- Slack (post to team channel)

#### B. Competitive Analysis Monitor
**Trigger:** Webhook (when competitor releases feature)
**Nodes:**
- HTTP Request (fetch product data)
- OpenAI (generate competitive analysis)
- Email (send to stakeholders)

#### C. User Feedback Analyzer
**Trigger:** New support ticket
**Nodes:**
- Extract ticket content
- OpenAI (categorize and prioritize)
- Notion (add to product backlog)

### 5. Advanced n8n + LLM Patterns

#### Custom Functions for PM Tasks
Add this JavaScript function node for reusable prompts:

~~~javascript
// PM Prompt Templates
const templates = {
  prd: "Create a Product Requirements Document for: ",
  userStory: "Write a user story with acceptance criteria for: ",
  stakeholderUpdate: "Write a stakeholder update about: ",
  competitive: "Create a competitive analysis comparing: "
};

const promptType = $input.first().json.promptType;
const content = $input.first().json.content;

return [{
  json: {
    prompt: templates[promptType] + content
  }
}];
~~~

## 🌊 LangFlow Integration ✅ PRE-CONFIGURED

LangFlow provides a visual interface for building LLM workflows - **Global Variables are already set up for you!**

### 1. Start LangFlow
~~~bash
docker compose --profile optional up -d langflow
# Wait 1-2 minutes for startup
~~~

### 2. Access LangFlow
1. **Open browser:** http://localhost:7860
2. **Create account** (local instance)
3. **Skip tutorials** or explore interface

### 3. Use Pre-Configured Global Variables (Recommended)

🎉 **Global Variables are already set up!** Use these pre-configured variables in any component:

- `{OLLAMA_BASE_URL}` → `http://ollama:11434/v1`
- `{OLLAMA_MODEL}` → `phi4-mini:latest`  
- `{PM_SYSTEM_PROMPT}` → PM-optimized system message
- `{USER_STORY_TEMPLATE}` → Template for consistent user story formatting

#### How to Use Pre-Configured Variables:
1. **Create new flow** → Start with blank canvas
2. **Add "OpenAI" component** from left sidebar  
3. **Configure OpenAI component using variables:**
   - **Base URL:** `{OLLAMA_BASE_URL}` 
   - **Model:** `{OLLAMA_MODEL}`
   - **System Message:** `{PM_SYSTEM_PROMPT}`
4. **Variables are automatically substituted** at runtime

#### Manual Configuration (Alternative)

> **⚠️ NOTE:** LangFlow uses "OpenAI" components for ALL OpenAI-compatible APIs, including Ollama.

#### Option A: Ollama Configuration
**Using Environment Variables:**
1. **Create new flow** → Start with blank canvas
2. **Add "OpenAI" component** from left sidebar  
3. **Configure OpenAI component:**
   - **Base URL:** `{LLM_DOCKER_URL}` (references environment)
   - **API Key:** `{LLM_API_KEY}` 
   - **Model:** `{LLM_MODEL_NAME}`
   - **Temperature:** 0.7

**Direct Configuration:**
- **Base URL:** `http://ollama:11434/v1`
- **API Key:** `local-ollama-key`
- **Model:** `phi-3-mini-4k-instruct`
- **Temperature:** 0.7

#### Option B: Ollama Configuration
**Using Environment Variables:**
1. **Create new flow** → Start with blank canvas
2. **Add "OpenAI" component** from left sidebar
3. **Configure OpenAI component:**
   - **Base URL:** `{OLLAMA_DOCKER_URL}` (references environment)
   - **API Key:** `{OLLAMA_API_KEY}`
   - **Model:** `{OLLAMA_MODEL_NAME}`
   - **Temperature:** 0.7

**Direct Configuration:**
- **Base URL:** `http://host.docker.internal:11434/v1`
- **API Key:** `local-ollama-key`
- **Model:** `phi4-mini:latest` (or any Ollama model)
- **Temperature:** 0.7

#### Option C: Multiple Provider Setup
Create different flows for different providers:
1. **Ollama Flow:** For general tasks (faster startup)
2. **Ollama Flow:** For specific models (more model variety)
3. **Hybrid Flow:** Try one provider, fallback to another

#### Setting Up Environment Variables in LangFlow
LangFlow can access environment variables from your `.env` file:
1. **Create environment variables** in your `.env`:
   ~~~bash
   LANGFLOW_LLM_URL=http://ollama:11434/v1
   LANGFLOW_LLM_KEY=sk-local-key
   LANGFLOW_LLM_MODEL=phi4-mini:latest
   ~~~
2. **Reference in components** using `{VARIABLE_NAME}` syntax

### 4. Build PM-Specific Flows

#### Simple Text Generation Flow
1. **Text Input** → **OpenAI** → **Text Output**
2. **Configure Text Input:** "Write a user story for login functionality"
3. **Run flow** → Get generated user story

#### Document Analysis Flow
1. **File Upload** → **Text Splitter** → **OpenAI** → **Text Output**
2. **Configure OpenAI:** "Summarize this document from a PM perspective"
3. **Upload PRD** → Get executive summary

#### Multi-Step Analysis Flow
1. **Text Input** (competitor info)
2. **OpenAI** (analyze strengths/weaknesses)  
3. **OpenAI** (generate recommendations)
4. **Text Output** (final report)

### 5. Multi-Model Flow Example
Create a flow that uses different models for different tasks:

#### Model Selection Flow
1. **Text Input** (task description)
2. **Code Node** (model selector):
   ~~~python
   # Model selection based on task type
   task_text = input_value.lower()
   
   if 'code' in task_text or 'technical' in task_text:
       model_config = {
           'url': os.getenv('LLM_DOCKER_URL'),
           'key': os.getenv('LLM_API_KEY'),
           'model': os.getenv('LLM_MODEL_NAME')
       }
   elif 'creative' in task_text or 'marketing' in task_text:
       model_config = {
           'url': os.getenv('PM_SPECIALIST_URL'),
           'key': os.getenv('PM_SPECIALIST_KEY'),
           'model': os.getenv('PM_SPECIALIST_MODEL')
       }
   else:
       # Default to general model
       model_config = {
           'url': os.getenv('LLM_DOCKER_URL'),
           'key': os.getenv('LLM_API_KEY'),
           'model': os.getenv('LLM_MODEL_NAME')
       }
   
   return model_config
   ~~~
3. **OpenAI Component** (configured dynamically from code node)
4. **Text Output**

### 6. Save and Share Flows
1. **Click "Save"** → Name your flow
2. **Export flow** → Download JSON file
3. **Share with team** → Import JSON in their LangFlow

## 🐙 Ollama Web UI Integration (Optional)

If you're using Ollama as an alternative to Ollama:

### 1. Install Ollama
~~~bash
# macOS
brew install ollama

# Linux
curl -fsSL https://ollama.ai/install.sh | sh

# Windows - download from https://ollama.ai/download
~~~

### 2. Pull Phi-3 Mini
~~~bash
ollama pull phi4-mini:latest
ollama serve  # Start Ollama server
~~~

### 3. Start Ollama Web UI
~~~bash
docker compose --profile optional up -d ollama-webui
~~~

### 4. Access Web UI
1. **Open browser:** http://localhost:8080
2. **Should auto-detect** Ollama server
3. **Select phi4-mini:latest** model
4. **Start chatting**

### 5. Configure Other Tools for Ollama
If using Ollama instead of Ollama, update URLs:
- **Base URL:** `http://host.docker.internal:11434/api`
- **Model:** `phi4-mini:latest`

## ⚠️ Troubleshooting Connections

### Common Issues and Solutions

#### "Connection Refused" Errors
**Problem:** Tools can't reach Ollama
**Solutions:**
1. **Check Ollama server:** Is it running on port 11434?
2. **Test locally:** `curl http://localhost:11434/v1/models`
3. **For Docker containers:** Use `http://ollama:11434/v1`
4. **For local tools:** Use `http://localhost:11434/v1`

#### "Model Not Found" Errors
**Problem:** Wrong model name in configuration
**Solutions:**
1. **Get exact model name:** `curl http://localhost:11434/v1/models`
2. **Copy the "id" field** exactly
3. **Update tool configurations** with correct name

#### "API Key Invalid" Errors
**Problem:** Tool requires API key format
**Solutions:**
1. **For most tools:** Use `not-needed` or `local-api-key`
2. **For OpenAI-strict tools:** Use `sk-not-needed`
3. **Never leave blank** - always enter something

#### Slow Responses
**Problem:** Local model responding slowly
**Solutions:**
1. **Check CPU/RAM usage** - close other applications
2. **Reduce max tokens** in tool configurations
3. **Lower temperature** for more predictable responses
4. **Upgrade RAM** if consistently slow

### Tool-Specific Debugging

#### VS Code/Continue.dev Issues
1. **Check extension logs:** View → Output → Continue
2. **Reload window:** Ctrl+Shift+P → "Reload Window"
3. **Reset config:** Delete `~/.continue/config.json`

#### AnythingLLM Issues  
1. **Check Docker logs:** `docker compose logs -f anythingllm`
2. **Reset database:** Stop container, delete `storage/anythingllm`
3. **Update LLM settings** in AnythingLLM admin panel

#### n8n Issues

**"Connection refused" or "Cannot find Ollama/Ollama credential":**
1. **Use "OpenAI API" credential type** (not Ollama or Ollama)
2. **Check Docker networking** - ensure `docker-compose.yml` has:
   ```yaml
   n8n:
     extra_hosts:
       - "host.docker.internal:host-gateway"
   ```
3. **Use correct Base URL:**
   - Ollama: `http://ollama:11434/v1`
   - Ollama: `http://host.docker.internal:11434/v1`
4. **Check environment variables** - restart n8n after updating `.env`
5. **Test with direct values** if environment variables fail:
   - Ollama: API Key `local-ollama-key`, URL `http://ollama:11434/v1`
   - Ollama: API Key `local-ollama-key`, URL `http://host.docker.internal:11434/v1`

**Provider-specific troubleshooting:**
1. **Check if your provider is running:**
   - Ollama: `curl http://localhost:11434/v1/models`
   - Ollama: `curl http://localhost:11434/v1/models` or `ollama list`
2. **Switch providers:** `./scripts/switch-provider.sh [lmstudio|ollama]`
3. **Check Docker logs:** `docker compose logs -f n8n`
4. **Restart containers:** `docker compose restart n8n langflow`

**Model name issues:**
- Ollama: Use exact model ID from `curl http://localhost:11434/v1/models`
- Ollama: Use format like `phi4-mini:latest`, `llama3.2:3b`, `mistral:7b`

#### LangFlow Issues
1. **Clear browser cache** and refresh page
2. **Check console errors** in browser developer tools  
3. **Restart container:** `docker compose restart langflow`

## 🎯 Managing Multiple Specialized Models

### Setting Up Model Specialization
Use environment variables to manage different models for different PM tasks:

#### Example .env Configuration
~~~bash
# General Purpose Model (Ollama default)
LLM_BASE_URL=http://localhost:11434/v1
LLM_API_KEY=local-ollama-key
LLM_MODEL_NAME=phi4-mini:latest

# PM-Specialized Fine-tuned Model (same Ollama, different model)
PM_SPECIALIST_URL=http://localhost:11434/v1
PM_SPECIALIST_KEY=local-pm-specialist-key
PM_SPECIALIST_MODEL=pm-assistant-v2-finetuned

# Code-Specialized Model (separate Ollama instance or different port)
CODE_SPECIALIST_URL=http://localhost:1235/v1  
CODE_SPECIALIST_KEY=local-code-specialist-key
CODE_SPECIALIST_MODEL=deepseek-coder-v2

# Ollama Alternative Models
OLLAMA_BASE_URL=http://localhost:11434/api
OLLAMA_API_KEY=local-ollama-key
OLLAMA_MODEL_CREATIVE=llama3:70b
OLLAMA_MODEL_ANALYSIS=mixtral:8x7b

# External API Fallbacks
OPENAI_API_KEY=sk-your-openai-key
ANTHROPIC_API_KEY=sk-ant-your-key
GOOGLE_API_KEY=your-google-key
~~~

### Tool-Specific Model Selection Strategies

#### n8n: Task-Based Model Routing
Create a workflow that routes different PM tasks to specialized models:

**Expression Node - Model Router:**
~~~javascript
// Route PM tasks to appropriate models
const task = $input.first().json.task_type;
const content = $input.first().json.content;

const modelConfig = {
  'user_story': {
    credential: 'PM Specialist',
    model: $env.PM_SPECIALIST_MODEL,
    temperature: 0.3
  },
  'creative_brief': {
    credential: 'General LLM',
    model: 'gpt-4',
    temperature: 0.8
  },
  'technical_spec': {
    credential: 'Code Specialist', 
    model: $env.CODE_SPECIALIST_MODEL,
    temperature: 0.1
  },
  'competitive_analysis': {
    credential: 'Analysis Model',
    model: $env.OLLAMA_MODEL_ANALYSIS,
    temperature: 0.2
  }
};

return [{
  json: {
    ...modelConfig[task] || modelConfig['user_story'],
    prompt: content,
    task_type: task
  }
}];
~~~

#### LangFlow: Dynamic Model Components
Create reusable components that select models based on environment variables:

**Python Component - Dynamic Model Selector:**
~~~python
import os

def select_model_for_task(task_type: str, fallback_to_cloud: bool = False):
    """Select appropriate model based on task type"""
    
    model_configs = {
        'creative': {
            'url': os.getenv('PM_SPECIALIST_URL', os.getenv('LLM_BASE_URL')),
            'key': os.getenv('PM_SPECIALIST_KEY', os.getenv('LLM_API_KEY')),
            'model': os.getenv('PM_SPECIALIST_MODEL', os.getenv('LLM_MODEL_NAME')),
            'temperature': 0.8
        },
        'analytical': {
            'url': os.getenv('OLLAMA_BASE_URL', os.getenv('LLM_BASE_URL')),
            'key': os.getenv('OLLAMA_API_KEY', os.getenv('LLM_API_KEY')),
            'model': os.getenv('OLLAMA_MODEL_ANALYSIS', os.getenv('LLM_MODEL_NAME')),
            'temperature': 0.2
        },
        'technical': {
            'url': os.getenv('CODE_SPECIALIST_URL', os.getenv('LLM_BASE_URL')),
            'key': os.getenv('CODE_SPECIALIST_KEY', os.getenv('LLM_API_KEY')),
            'model': os.getenv('CODE_SPECIALIST_MODEL', os.getenv('LLM_MODEL_NAME')),
            'temperature': 0.1
        }
    }
    
    # Fallback to cloud if local unavailable and permitted
    if fallback_to_cloud and not test_local_connection():
        return {
            'url': 'https://api.openai.com/v1',
            'key': os.getenv('OPENAI_API_KEY'),
            'model': 'gpt-4',
            'temperature': 0.7
        }
    
    return model_configs.get(task_type, model_configs['creative'])

# Usage in flow
config = select_model_for_task(task_type)
return config
~~~

### Best Practices for Model Management

#### 1. Environment Variable Naming Convention
~~~bash
# Pattern: {PURPOSE}_{ATTRIBUTE}
GENERAL_LLM_URL=http://localhost:11434/v1
GENERAL_LLM_KEY=local-general-key
GENERAL_LLM_MODEL=phi4-mini

PM_SPECIALIST_URL=http://localhost:11434/v1  
PM_SPECIALIST_KEY=local-pm-key
PM_SPECIALIST_MODEL=pm-assistant-v2

CODE_ASSISTANT_URL=http://localhost:1235/v1
CODE_ASSISTANT_KEY=local-code-key
CODE_ASSISTANT_MODEL=deepseek-coder
~~~

#### 2. Model Testing and Validation
Add this to your `.env` for model health checking:
~~~bash
# Model Health Check Configuration
MODEL_HEALTH_CHECK_ENABLED=true
MODEL_HEALTH_CHECK_INTERVAL=300  # 5 minutes
MODEL_FALLBACK_ENABLED=true
~~~

#### 3. Cost and Performance Optimization
~~~bash
# Performance Settings
LOCAL_MODEL_MAX_CONCURRENT=3
CLOUD_MODEL_MAX_TOKENS=2048
LOCAL_MODEL_MAX_TOKENS=4096

# Cost Controls  
OPENAI_BUDGET_LIMIT=50.00  # Monthly limit in USD
ANTHROPIC_BUDGET_LIMIT=30.00
~~~

## 📊 Performance Optimization

### Model Settings for Different Use Cases

#### For Code Generation (VS Code)
~~~json
{
  "temperature": 0.3,
  "maxTokens": 1024,
  "topP": 0.9
}
~~~

#### For Creative Writing (Docs, Marketing)
~~~json
{
  "temperature": 0.8,
  "maxTokens": 2048,
  "topP": 0.95
}
~~~

#### For Analysis (Data, Research)
~~~json
{
  "temperature": 0.1,
  "maxTokens": 1024,
  "topP": 0.8
}
~~~

### Resource Management
- **Concurrent connections:** Ollama handles ~5 simultaneous requests well
- **Memory usage:** Monitor with Activity Monitor/Task Manager
- **Response time:** Typically 2-10 seconds depending on prompt complexity

## 🎯 Next Steps

### 1. Test All Connections
- [ ] VS Code Continue.dev working
- [ ] AnythingLLM responding to documents
- [ ] n8n executing AI workflows
- [ ] LangFlow building custom flows

### 2. Create Your First Workflows
- [ ] PM status update automation in n8n
- [ ] Document analysis flow in LangFlow
- [ ] Custom VS Code commands for PM tasks

### 3. Optimize for Your Use Case
- [ ] Fine-tune model with your PM data (see [Training Models](training-models.md))
- [ ] Create custom n8n workflow templates
- [ ] Build LangFlow components for your specific needs

---

**🎉 All Connected!** You now have a complete local AI ecosystem where every tool works together with your private Phi-3 Mini model. No external API calls, no data leaving your machine, and no subscription fees!