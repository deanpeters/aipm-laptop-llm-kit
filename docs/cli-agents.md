# CLI Agents - Run n8n & LangFlow Workflows from Command Line

> **Transform your n8n workflows and LangFlow flows into standalone CLI agents that work with local LLMs**

## 🎯 Overview

The AIPM CLI Agent system lets you run any n8n workflow or LangFlow flow as a standalone command-line tool. Perfect for:

- **Automated PM tasks** (daily standups, user story generation, competitive analysis)
- **Background agents** that run on schedule or on-demand  
- **Local LLM integration** with both LM Studio and Ollama
- **Cross-platform support** (macOS, Linux, Windows PowerShell)

## 🚀 Quick Start

### 1. Find Your Workflow/Flow ID

**n8n Workflows:**
1. Open your workflow in n8n UI
2. Copy the workflow ID from the URL: `http://localhost:5678/workflow/YOUR-WORKFLOW-ID`
3. Or find it in **Settings** → **Workflow Settings**

**LangFlow Flows:**
1. Open your flow in LangFlow UI
2. Click **Share** → **API access** 
3. Copy the Flow ID from the generated code

### 2. Run Your Agents

**n8n Workflows (macOS/Linux):**
```bash
# Run once with LM Studio (default)
./scripts/run-agent.sh YOUR-WORKFLOW-ID

# Run in background with Ollama
./scripts/run-agent.sh YOUR-WORKFLOW-ID --background --provider ollama

# List all workflows
./scripts/run-agent.sh list
```

**n8n Workflows (Windows PowerShell):**
```powershell
# Run once with LM Studio (default)  
.\scripts\run-agent.ps1 YOUR-WORKFLOW-ID

# Run in background with Ollama
.\scripts\run-agent.ps1 YOUR-WORKFLOW-ID -Background -Provider ollama

# List all workflows
.\scripts\run-agent.ps1 list
```

**LangFlow Flows (macOS/Linux):**
```bash
# Run once with custom input
./scripts/run-langflow-agent.sh YOUR-FLOW-ID --input "Generate a user story for mobile checkout"

# Run in background with Ollama
./scripts/run-langflow-agent.sh YOUR-FLOW-ID --background --provider ollama

# Check LangFlow status
./scripts/run-langflow-agent.sh status
```

**LangFlow Flows (Windows PowerShell):**
```powershell
# Run once with custom input
.\scripts\run-langflow-agent.ps1 YOUR-FLOW-ID -Input "Generate a user story for mobile checkout"

# Run in background with Ollama
.\scripts\run-langflow-agent.ps1 YOUR-FLOW-ID -Background -Provider ollama

# Check LangFlow status
.\scripts\run-langflow-agent.ps1 status
```

## 📋 Command Reference

### macOS/Linux (`run-agent.sh`)

```bash
./run-agent.sh <WORKFLOW_ID>                    # Run once and exit
./run-agent.sh <WORKFLOW_ID> --background       # Run in background
./run-agent.sh <WORKFLOW_ID> --provider ollama  # Use Ollama instead of LM Studio
./run-agent.sh <WORKFLOW_ID> --log <file>       # Save output to specific log file
./run-agent.sh list                             # List available workflows
./run-agent.sh status                           # Show running background agents
```

### Windows PowerShell (`run-agent.ps1`)

```powershell
.\run-agent.ps1 <WORKFLOW_ID>                    # Run once and exit
.\run-agent.ps1 <WORKFLOW_ID> -Background       # Run in background
.\run-agent.ps1 <WORKFLOW_ID> -Provider ollama  # Use Ollama instead of LM Studio
.\run-agent.ps1 <WORKFLOW_ID> -LogFile <file>   # Save output to specific log file
.\run-agent.ps1 list                            # List available workflows
.\run-agent.ps1 status                          # Show running background agents
```

### macOS/Linux LangFlow (`run-langflow-agent.sh`)

```bash
./run-langflow-agent.sh <FLOW_ID>                       # Run once and exit
./run-langflow-agent.sh <FLOW_ID> --background          # Run in background
./run-langflow-agent.sh <FLOW_ID> --provider ollama     # Use Ollama instead of LM Studio
./run-langflow-agent.sh <FLOW_ID> --input "text"        # Custom input text for the flow
./run-langflow-agent.sh <FLOW_ID> --tweaks '{"key":"val"}' # Custom component tweaks
./run-langflow-agent.sh <FLOW_ID> --log <file>          # Save output to specific log file
./run-langflow-agent.sh status                          # Show LangFlow server status
```

### Windows PowerShell LangFlow (`run-langflow-agent.ps1`)

```powershell
.\run-langflow-agent.ps1 <FLOW_ID>                      # Run once and exit
.\run-langflow-agent.ps1 <FLOW_ID> -Background         # Run in background
.\run-langflow-agent.ps1 <FLOW_ID> -Provider ollama    # Use Ollama instead of LM Studio
.\run-langflow-agent.ps1 <FLOW_ID> -Input "text"       # Custom input text for the flow
.\run-langflow-agent.ps1 <FLOW_ID> -Tweaks '{"key":"val"}' # Custom component tweaks
.\run-langflow-agent.ps1 <FLOW_ID> -LogFile <file>     # Save output to specific log file
.\run-langflow-agent.ps1 status                        # Show LangFlow server status
```

## 🤖 Example Agent Workflows

The kit includes ready-to-use agent templates:

### n8n Agent Templates

### Daily Standup Agent
**File:** `config/example-workflows/daily-standup-agent.json`

**What it does:**
- Generates daily standup content using local LLM
- Posts to Slack webhook at 9 AM daily
- Includes accomplishments, priorities, blockers, metrics

**Import and run:**
```bash
# Import the workflow
docker exec -u node n8n n8n import:workflow --input /home/node/.n8n/workflows/daily-standup-agent.json

# Run once to test
./scripts/run-agent.sh YOUR-NEW-WORKFLOW-ID

# Or let it run on schedule (starts the cron trigger)
./scripts/run-agent.sh YOUR-NEW-WORKFLOW-ID --background
```

### User Story Generator Agent  
**File:** `config/example-workflows/user-story-generator.json`

**What it does:**
- Webhook-triggered agent for generating user stories
- Accepts feature descriptions via HTTP POST
- Creates detailed user stories with acceptance criteria
- Optionally saves to Notion database

**Import and test:**
```bash
# Import the workflow
docker exec -u node n8n n8n import:workflow --input /home/node/.n8n/workflows/user-story-generator.json

# Start the webhook listener
./scripts/run-agent.sh YOUR-NEW-WORKFLOW-ID --background

# Test with curl
curl -X POST http://localhost:5678/webhook/generate-story \
  -H "Content-Type: application/json" \
  -d '{
    "feature_description": "User login with social media accounts",
    "target_user": "end user",
    "priority": "high",
    "save_to_notion": "true"
  }'
```

### LangFlow Agent Templates

#### PM User Story Generator Flow
**File:** `config/example-langflow/pm-user-story-flow.json`

**What it does:**
- Takes feature descriptions as input
- Generates comprehensive user stories with acceptance criteria
- Includes story points estimation and edge cases
- Uses professional PM formatting

**Import and run:**
```bash
# Manual import (recommended)
# 1. Open LangFlow UI at http://localhost:7860
# 2. Click "New Flow" → "Import" 
# 3. Upload: config/example-langflow/pm-user-story-flow.json
# 4. Get Flow ID from Share → API access

# Run with custom input
./scripts/run-langflow-agent.sh YOUR-FLOW-ID \
  --input "Feature: Mobile app offline mode for task management"
```

#### Competitive Analysis Generator Flow
**File:** `config/example-langflow/competitive-analysis-flow.json`

**What it does:**
- Analyzes competitive landscape and market positioning
- Generates strategic recommendations
- Identifies threats and opportunities
- Creates actionable product insights

**Import and run:**
```bash
# Manual import through LangFlow UI (see above)

# Run competitive analysis
./scripts/run-langflow-agent.sh YOUR-FLOW-ID \
  --input "Product: AI-powered project management tool. Competitors: Linear, ClickUp, Notion"
```

#### Quick Setup
```bash
# Setup LangFlow agents (provides import guidance)
./scripts/setup-langflow-agents.sh
```

## 🔧 Environment Configuration

### Automatic Environment Setup

Both scripts automatically configure environment variables for your chosen provider and execution mode:

**LM Studio:**
- **Docker n8n**: `LLM_BASE_URL=http://host.docker.internal:1234/v1`
- **CLI n8n**: `LLM_BASE_URL=http://localhost:1234/v1`
- `LLM_API_KEY=local-lmstudio-key`
- `LLM_MODEL_NAME=phi-3-mini-4k-instruct`

**Ollama:**
- **Docker n8n**: `OLLAMA_BASE_URL=http://host.docker.internal:11434/v1`
- **CLI n8n**: `OLLAMA_BASE_URL=http://localhost:11434/v1`
- `OLLAMA_API_KEY=local-ollama-key`
- `OLLAMA_MODEL_NAME=phi4-mini:latest`

> **🔧 Smart URL Detection:** The scripts automatically detect whether you're using Docker n8n or CLI n8n and set the correct URLs. Docker containers need `host.docker.internal` to reach your Mac, while CLI n8n uses `localhost`.

### Custom Environment Variables

Add custom variables to your `.env` file:
```bash
# Custom model configurations
PM_SPECIALIST_MODEL=custom-pm-model
NOTION_DATABASE_ID=your-notion-database-id
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Encryption key for encrypted credentials
N8N_ENCRYPTION_KEY=your-long-random-key-here
```

## 📝 Creating Agent Workflows

### Best Practices for CLI Agents

1. **Use Environment Variables in n8n:**
   ```
   Model: ={{$env.LLM_MODEL_NAME}}
   API Key: ={{$env.LLM_API_KEY}}
   Base URL: ={{$env.LLM_DOCKER_URL}}
   ```

2. **Choose the Right Trigger:**
   - **Cron Trigger**: For scheduled agents (daily reports, weekly summaries)
   - **Webhook Trigger**: For on-demand agents (user story generator, analysis tools)
   - **Manual Trigger**: For one-time execution agents

3. **Configure Credentials:**
   - Use "OpenAI API" credential type for both LM Studio and Ollama
   - Reference environment variables: `={{$env.LLM_API_KEY}}`
   - Set Base URL: `={{$env.LLM_DOCKER_URL}}`

4. **Handle Outputs:**
   - **Webhook Response**: Return JSON for API-style agents
   - **File Output**: Save results to shared directories
   - **External Integration**: Post to Slack, Notion, email, etc.

### Example Agent Patterns

#### 1. Scheduled Report Agent
```json
{
  "trigger": "Cron Trigger (daily at 9 AM)",
  "processing": "OpenAI Node (generate report)",
  "output": "HTTP Request (post to Slack)"
}
```

#### 2. On-Demand Analysis Agent  
```json
{
  "trigger": "Webhook Trigger",
  "input": "Extract data from webhook body", 
  "processing": "OpenAI Node (analyze data)",
  "output": "Respond to Webhook (return JSON)"
}
```

#### 3. File Processing Agent
```json
{
  "trigger": "Manual Trigger",
  "input": "Read Files Node (process documents)",
  "processing": "OpenAI Node (extract insights)",
  "output": "Write Files Node (save summary)"
}
```

## 🐛 Troubleshooting

### Common Issues

**"n8n not found"**
```bash
# Ensure n8n is running
docker compose up -d n8n

# Or install n8n CLI globally
npm install -g n8n
```

**"Workflow not found"**
```bash
# List available workflows
./scripts/run-agent.sh list

# Import a workflow first
docker exec -u node n8n n8n import:workflow --input /path/to/workflow.json
```

**"Connection refused" (LLM provider)**
```bash
# Check if your LLM provider is running
curl http://localhost:1234/v1/models  # LM Studio
curl http://localhost:11434/v1/models # Ollama

# Ensure LM Studio is bound to all interfaces (not just 127.0.0.1)
lsof -iTCP:1234 -sTCP:LISTEN  # Should show 0.0.0.0:1234, not 127.0.0.1:1234

# Switch providers
./scripts/run-agent.sh YOUR-ID --provider ollama
```

**"Connection refused" with Docker n8n**
This is usually a URL issue. The script automatically detects execution mode, but verify:
```bash
# Docker n8n should use host.docker.internal
docker exec -u node n8n curl http://host.docker.internal:1234/v1/models

# CLI n8n should use localhost  
curl http://localhost:1234/v1/models
```

**Background agents not working**
```bash
# Check agent status
./scripts/run-agent.sh status

# Check logs
tail -f ~/aipm-agents/YOUR-WORKFLOW-ID.log

# Check Docker logs
docker logs -f n8n
```

### Debug Mode

Run agents in foreground to see full output:
```bash
# Instead of --background, run directly to see errors
./scripts/run-agent.sh YOUR-WORKFLOW-ID --log debug.log
```

## 🔄 Integration with Existing Tools

### VS Code Integration

Create a VS Code task to run agents:

**`.vscode/tasks.json`:**
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run User Story Agent",
      "type": "shell",
      "command": "./scripts/run-agent.sh",
      "args": ["user-story-workflow-id"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    }
  ]
}
```

### Terminal Aliases

Add to your shell profile (`~/.zshrc`, `~/.bashrc`):
```bash
# Quick agent aliases
alias standup='cd /path/to/aipm-laptop-llm-kit && ./scripts/run-agent.sh standup-workflow-id'
alias user-story='cd /path/to/aipm-laptop-llm-kit && ./scripts/run-agent.sh story-workflow-id'
alias competitive='cd /path/to/aipm-laptop-llm-kit && ./scripts/run-agent.sh competitive-workflow-id'
```

### Scheduled Execution (Optional)

**macOS/Linux crontab:**
```bash
# Daily standup at 9 AM
0 9 * * * cd /path/to/aipm-laptop-llm-kit && ./scripts/run-agent.sh standup-id

# Weekly competitive analysis on Mondays at 10 AM  
0 10 * * 1 cd /path/to/aipm-laptop-llm-kit && ./scripts/run-agent.sh competitive-id
```

**Windows Task Scheduler:**
Create scheduled tasks that run:
```powershell
PowerShell.exe -ExecutionPolicy Bypass -File "C:\path\to\aipm-laptop-llm-kit\scripts\run-agent.ps1" "workflow-id"
```

## 🎯 Next Steps

1. **Import example workflows** to get started quickly
2. **Create custom agents** for your specific PM workflows
3. **Set up background agents** for recurring tasks
4. **Integrate with external tools** (Slack, Notion, GitHub, etc.)
5. **Build a library** of reusable agent patterns

---

**💡 Pro Tip:** Start with the example workflows, then modify them for your specific needs. Every n8n workflow can become a powerful CLI agent with local LLM capabilities!