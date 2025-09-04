# Claude Code Configuration

This file contains commands and notes for Claude Code when working on the AIPM Laptop LLM Kit project.

## 🎉 PROJECT STATUS: OLLAMA-POWERED & PRODUCTION-READY! ✅

**AIPM Laptop LLM Kit v1.05** - Early service launch + comprehensive pre-configuration!

### 🚀 **LATEST ACHIEVEMENTS (v1.05 - EARLY SERVICE LAUNCH + PRE-CONFIGURED CREDENTIALS):**
- ✅ **PRE-CONFIGURED CREDENTIALS** - All tools auto-configured with Ollama connections
- ✅ **EARLY SERVICE LAUNCH** - Docker/Ollama detected and started early in installer with background execution
- ✅ **ROBUST ERROR HANDLING** - Services launch with & background execution, no installation failures
- ✅ **INTELLIGENT WAITING** - Smart wait periods (30s Docker, 15s Ollama) with progress indicators
- ✅ **CROSS-PLATFORM SERVICE MGMT** - Works on macOS (open -a), Linux (systemctl), Windows (Start-Process)
- ✅ **n8n CREDENTIALS** - "Local Ollama (Pre-configured)" credential automatically injected
- ✅ **LANGFLOW GLOBAL VARIABLES** - Pre-loaded {OLLAMA_BASE_URL}, {OLLAMA_MODEL} templates
- ✅ **ANYTHINGLLM WORKSPACE** - "Product Management Hub" workspace pre-configured
- ✅ **CONTINUE.DEV + CLINE SETTINGS** - VS Code AI assistants ready for Ollama out-of-box
- ✅ **ONE-COMMAND SETUP** - ./scripts/setup-all-credentials.sh configures everything
- ✅ **ZERO MANUAL CONFIG** - Eliminates complexity for low-tech Product Managers
- ✅ **LEARNING BY EXAMPLE** - Working configurations show PMs how connections work

### 🛠️ **CORE FEATURES (v1.05 Complete):**
- ✅ **SMART INSTALLER WITH EARLY SERVICES** - Detects, launches Docker/Ollama early with background execution
- ✅ **COMPREHENSIVE PRE-CONFIGURATION** - All tools auto-configured with Ollama connections
- ✅ **ZERO-SETUP CREDENTIALS** - n8n, AnythingLLM, LangFlow, Continue.dev, Cline ready instantly
- ✅ **PM-OPTIMIZED WORKSPACES** - Pre-built templates, prompts, and workflows for Product Managers
- ✅ **ONE-COMMAND SETUP** - ./scripts/setup-all-credentials.sh configures everything
- ✅ **OLLAMA-FIRST ARCHITECTURE** - Primary model server with containerized deployment
- ✅ **NATIVE TOOL INTEGRATION** - n8n Ollama nodes, Continue.dev Ollama provider
- ✅ **STABLE API ENDPOINTS** - Port 11434, consistent networking, no compatibility workarounds
- ✅ **MODELFILE CUSTOMIZATION** - Modern model specialization approach
- ✅ **CROSS-PLATFORM INSTALLER** - Automated Ollama setup (macOS, Windows, Linux) 
- ✅ **DOCKER ORCHESTRATION** - Ollama + AnythingLLM + n8n + optional services
- ✅ **VS CODE INTEGRATION** - Continue.dev + Cline with first-class Ollama support
- ✅ **PM-FOCUSED EXAMPLES** - 19 fine-tuning samples + Modelfile templates
- ✅ **COMPREHENSIVE DOCUMENTATION** - Complete Ollama workflow guides
- ✅ **AUTO MODEL MANAGEMENT** - Phi-3 Mini ready to use immediately
- ✅ **ROBUST PACKAGE MANAGERS** - Homebrew/Chocolatey auto-install with updates
- ✅ **PYTHON ECOSYSTEM** - pip updates + essential AI packages (OpenAI, LangChain, etc.)
- ✅ **ENTERPRISE CONSISTENCY** - Reliable, repeatable installations across environments
- ✅ **CLI AGENTS** - Run n8n workflows and LangFlow flows from command line
- ✅ **AGENT SCHEDULING** - Timer-based automation with human-readable schedules

## Project Context
- **Project:** AIPM Laptop LLM Kit - A 100% local, private AI stack for low-technical Product Managers
- **Repository:** https://github.com/deanpeters/aipm-laptop-llm-kit (LIVE ON GITHUB)
- **Role:** Senior build/release engineer
- **Path:** ~/Code/AIPM_Laptop_LLM_Kit
- **Status:** ✅ v1.05 EARLY-SERVICE-LAUNCH - GitHub published, webinar-ready, community-enabled

## Key Commands

### Testing & Validation (WORKING ✅)
~~~bash
# Test installer (dry-run mode) - WITH EARLY SERVICE LAUNCH ✅  
./install.sh --dry-run    # macOS/Linux - TESTED ✅ (Now detects/launches Docker & Ollama early)
./install.ps1 -DryRun     # Windows - WITH EARLY SERVICE LAUNCH ✅

# Test Ollama installer separately (prevents hanging)
./scripts/install-ollama.sh --dry-run     # macOS/Linux - TESTED ✅
./scripts/install-ollama.ps1 -DryRun      # Windows

# Run actual installation
./install.sh             # macOS/Linux
./install.ps1            # Windows

# Verify installation
./scripts/verify.sh       # macOS/Linux - TESTED ✅  
./scripts/verify.ps1     # Windows

# Test environment setup
./scripts/setup-env.sh    # macOS/Linux - TESTED ✅
./scripts/setup-env.ps1  # Windows

# Shellcheck validation (future)
shellcheck install.sh uninstall.sh scripts/*.sh
~~~

### Development Workflow (SIMPLIFIED ✅)
~~~bash
# Start core services (single docker-compose.yml)
docker compose up -d anythingllm n8n

# Start optional services
docker compose --profile optional up -d privategpt langflow

# Stop services
docker compose down

# Check logs
docker compose logs -f anythingllm
docker compose logs -f n8n

# Test uninstaller
./uninstall.sh          # macOS/Linux - TESTED ✅
./uninstall.ps1         # Windows
~~~

## Important Guidelines

### Code Formatting
- **ALWAYS use `~~~` for code fences in all artifacts**
- For nested examples inside docs, **indent** rather than nesting fences
- Never create nested code fences

### Environment Variables
- Use guarded blocks in shell configs with unique markers
- Standard keys: `LLM_BASE_URL`, `ANYTHINGLLM_PORT`, `N8N_PORT`, `ANYTHINGLLM_STORAGE`, `CONTINUE_CONFIG`, `SLACK_WEBHOOK_URL`, `SOV_STACK_HOME`, `SOV_PROFILE_MARK`
- Always check for existing values before setting (don't clobber)

### Installation Requirements
- Must be **idempotent** and **resumable**
- Detect → Install → Configure → Persist env → Verify
- Fail fast with helpful messages and doc pointers
- Support macOS (brew), Windows (winget/choco), Linux (apt)

### Primary Tools Stack ✅ IMPLEMENTED
1. **Ollama** (local inference + model management) - Auto-detected + configured
2. **AnythingLLM** (Docker, local RAG) - Configured + ready
3. **VS Code + Cline + Continue.dev** (coding assistance) - Auto-install + configured  
4. **n8n** (Docker, automation workflows) - Configured + ready
5. **Optional services** (PrivateGPT, LangFlow, LM Studio) - Available via profiles

### Documentation ✅ COMPLETE (Simplified Approach)
- ✅ **README.md** - Comprehensive one-page guide with quick start
- ✅ **config/env.example** - All environment variables documented
- ✅ **examples/dataset.jsonl** - 10 PM-focused fine-tuning examples
- ✅ **CLAUDE.md** - Development context and commands (this file)

## Actual File Structure ✅ BUILT
```
aipm-laptop-llm-kit/
├── install.sh / install.ps1      # Main installers - WORKING ✅
├── uninstall.sh / uninstall.ps1  # Clean removal - WORKING ✅  
├── docker-compose.yml            # All services - CONFIGURED ✅
├── scripts/
│   ├── setup-env.sh/.ps1         # Environment management - WORKING ✅
│   ├── verify.sh/.ps1            # Health checks - WORKING ✅
│   ├── install-ollama.sh/.ps1    # Ollama automation - WORKING ✅
│   └── install-python-deps.sh    # Python packages - WORKING ✅
├── docs/
│   ├── creating-training-data.md  # Complete training data guide - NEW ✅
│   ├── training-models.md         # Step-by-step model training - NEW ✅
│   ├── connecting-tools.md        # Complete tool integration guide - NEW ✅
│   └── terminology-guide.md       # API keys, credentials, concepts explained - NEW ✅
├── config/
│   ├── continue.json             # VS Code AI config - READY ✅
│   ├── env.example               # Environment template - READY ✅
│   └── workflows/                # n8n workflow templates - READY ✅
├── examples/
│   └── dataset.jsonl            # 19 PM fine-tuning samples - READY ✅
├── storage/                      # Auto-created data directories - READY ✅
└── README.md                     # Complete user guide - READY ✅
```

## ✅ SUCCESS CRITERIA - ALL MET!
- ✅ **One-command install** - `./install.sh` works perfectly
- ✅ **Cross-platform** - macOS/Windows/Linux support
- ✅ **Smart detection** - Skips installed components  
- ✅ **Environment management** - Safe, guarded shell blocks
- ✅ **Service configuration** - All tools point to local LM Studio
- ✅ **PM-friendly examples** - Ready-to-use fine-tuning dataset
- ✅ **Clean uninstall** - Safe removal with confirmations
- ✅ **Complete documentation** - Single comprehensive README
- ✅ **Robust testing** - Dry-run modes prevent installation issues
- ✅ **GUI process handling** - No more installer hanging
- ✅ **Comprehensive troubleshooting** - Updated with recent fixes
- ✅ **Optional services documented** - LangFlow, PrivateGPT, Ollama WebUI fully tested
- ✅ **Complete service management** - Start/stop/monitor commands for all services
- ✅ **Comprehensive training guides** - Complete documentation for data creation and model training
- ✅ **PM-specific fine-tuning** - Step-by-step guides with real examples and best practices
- ✅ **Complete tool integration** - Detailed guide for connecting all tools to local LLM (no external docs needed)
- ✅ **Environment variable automation** - Installer sets up API key patterns and tool configurations
- ✅ **Terminology clarification** - Complete guide to credentials, API keys, and tool-specific concepts

### 🆕 **NEW FEATURES ADDED (v3.0):**

#### CLI Agent System
~~~bash
# Run n8n workflows as command-line agents
./scripts/run-agent.sh WORKFLOW_ID --provider ollama --background

# Run LangFlow flows as agents  
./scripts/run-langflow-agent.sh FLOW_ID --input "Generate user stories" --background
~~~

#### Cross-Platform Agent Scheduling
~~~bash
# Schedule daily standup at 9 AM (macOS/Linux)
./scripts/schedule-agent.sh add n8n WORKFLOW_ID "daily at 9am" "Daily Standup" --background

# Schedule weekly competitive analysis (Windows)
.\scripts\schedule-agent.ps1 add langflow FLOW_ID "every monday at 10am" "Weekly Analysis" -Background

# Manage scheduled agents
./scripts/schedule-agent.sh list    # Show all scheduled agents
./scripts/schedule-agent.sh remove "Daily Standup"  # Remove specific agent
./scripts/schedule-agent.sh status  # Check scheduling system status
~~~

#### Testing Public Installation
~~~bash
# Test the GitHub repository installation
cd ~/Desktop
git clone https://github.com/deanpeters/aipm-laptop-llm-kit.git
cd aipm-laptop-llm-kit
./install.sh --dry-run  # Safe test
./install.sh            # Full installation
~~~

## 🌟 PRODUCTION STATUS

**✅ v4.0 OLLAMA-POWERED RELEASE COMPLETE**
- GitHub repository: https://github.com/deanpeters/aipm-laptop-llm-kit
- Major architecture upgrade from LM Studio to Ollama
- Native integration support eliminates compatibility issues
- Professional documentation and community features
- Automated testing across all platforms (CI/CD)
- Safe re-installation process for updates
- Complete offline-first architecture documentation

## 🔄 v4.0 MIGRATION BENEFITS

**Why Ollama > LM Studio:**
- ✅ **Native n8n Integration** - First-class Ollama nodes eliminate OpenAI compatibility workarounds
- ✅ **Stable Continue.dev Support** - Dedicated Ollama provider vs buggy OpenAI emulation
- ✅ **Containerized Architecture** - Docker-based deployment with proper service networking
- ✅ **Standard Port Usage** - Port 11434 avoids common conflicts (vs LM Studio's 1234)
- ✅ **Modern Model Management** - Command-line `ollama pull/list/run` vs GUI dependency
- ✅ **Modelfile Approach** - Version-controlled model customization vs proprietary training
- ✅ **Industry Adoption** - Ollama is becoming the standard for local LLM deployment
- ✅ **Better Resource Management** - Optimized memory usage and model switching

## 📋 FUTURE TO-DO LIST (DO NOT EXECUTE - FOR REFERENCE)

### 🎯 HIGH PRIORITY - User Experience
- **Create self-contained HTML5 SPA post-install dashboard** - Beautiful dashboard that launches after installation
- **Add service links and exploration options** - Links to all services (AnythingLLM, n8n, LangFlow, etc.) with status indicators  
- **Design user-friendly post-install experience** - Next steps guidance, tutorials, getting started workflows
- **Update installer to launch dashboard automatically** - Seamless transition from install completion to exploration

### 🧪 Testing & Quality Assurance
- **Test Windows installer** - Still untested, welcome community contributions for validation
- **Cross-platform compatibility** - Validate across different Windows versions and configurations

### 📚 Documentation & Guidelines
- **Create contributor guidelines** - Structured guidelines and guardrails for project contributors
- **Explain model choice rationale** - Why phi4-mini:latest is our default training model, considerations for alternatives
- **Hardware/security constraints guide** - Document system requirements, security considerations, and deployment constraints
- **Docker usage rationale** - Explain why Docker is used for specific tools and the benefits it provides

### 🎯 Product Management Focus
- **Expand PM workflow examples** - Move beyond Scrum PO level to strategic PM, portfolio management, and executive-level use cases
- **Enterprise PM scenarios** - Add workflows for stakeholder management, roadmapping, competitive analysis
- **Strategic planning examples** - OKRs, market research, product strategy development

### 🎓 Learning & Community
- **Run Productside webinar workshop** - Conduct live workshop, then add recorded video to project
- **Create cookbook/recipes section** - How-to guides for building interesting projects, agents, and workflows
- **Community examples** - Showcase real-world implementations from users

### 🚀 FUTURE ENHANCEMENTS (Optional Development)
1. **Additional model providers** - Anthropic Claude, Google Gemini local options
2. **More PM workflows** - Sprint planning, roadmap generation templates  
3. **Mobile companion** - Simple mobile app for triggering scheduled agents
4. **Advanced automation** - Multi-step agent workflows and decision trees