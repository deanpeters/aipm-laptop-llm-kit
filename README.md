# AIPM Laptop LLM Kit 🤖

[![CI](https://github.com/deanpeters/aipm-laptop-llm-kit/workflows/CI/badge.svg)](https://github.com/deanpeters/aipm-laptop-llm-kit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

> **One-command setup for a 100% local, private AI stack for Product Managers**

Transform your laptop into a powerful AI workstation with local models, document chat, workflow automation, and AI-powered coding assistance - all running privately on your machine.

## 📑 Table of Contents

- **[🚀 Quick Start](#-quick-start)** - One-command installation
- **[📚 Complete Documentation](#-complete-documentation)** - All guides and resources  
- **[🔒 Why Offline-First?](#-offline-first-architecture)** - Cost, security, and customization benefits
- **[🏗️ What Gets Installed](#️-what-gets-installed)** - Core and optional services
- **[🎮 Usage Examples](#-usage-examples)** - Chat, code, automate, fine-tune
- **[🔧 Advanced Configuration](#-advanced-configuration)** - Customization options
- **[🩺 Troubleshooting](#-troubleshooting)** - Common issues and solutions

**🎯 New to AI fine-tuning?** Jump to [Creating Training Data](docs/creating-training-data.md) and [Training Models](docs/training-models.md)!

**🔌 Tools pre-configured!** v1.05 includes automatic credential setup + early service launch - see [Connecting Tools](docs/connecting-tools.md) for details!

## 🚀 Quick Start

### macOS / Linux

```bash
git clone https://github.com/deanpeters/aipm-laptop-llm-kit.git
cd aipm-laptop-llm-kit
./install.sh
```

### Windows

```powershell
git clone https://github.com/deanpeters/aipm-laptop-llm-kit.git
cd aipm-laptop-llm-kit
.\install.ps1
```

**That's it!** The installer will:

- ✅ **Detect your system** and install package managers (Homebrew/Chocolatey)
- ✅ **Update pip** and install essential Python packages
- ✅ **Install all dependencies** (Docker, VS Code, Ollama with model)
- ✅ **Configure everything** to work together seamlessly
- ✅ **Verify the installation** with comprehensive health checks

## 🎉 **NEW in v1.05: Early Service Launch + Pre-Configured Connections!**

**No more manual credential setup!** All tools now come with pre-configured connections to your local Ollama server:

```bash
# One command configures everything
./scripts/setup-all-credentials.sh
```

**What you get:**
- ✅ **n8n**: "Local Ollama (Pre-configured)" credential ready to use
- ✅ **AnythingLLM**: "Product Management Hub" workspace pre-loaded
- ✅ **LangFlow**: Global Variables `{OLLAMA_BASE_URL}`, `{OLLAMA_MODEL}` available
- ✅ **Continue.dev**: Already configured for Ollama
- ✅ **Cline**: VS Code workspace settings with PM-optimized prompts

**Perfect for low-tech Product Managers** - just open any tool and start working with AI immediately!

## 🚀 Quick Start - Test Drive Everything

### **Step 0: Start Docker Services**

**macOS/Linux:**

1. Open Terminal in this folder
2. Start Docker Desktop (Spotlight search "Docker" or from Applications)
3. Wait for Docker whale icon in menu bar to show "Docker Desktop is running"
4. Run: `docker compose up -d anythingllm n8n`

**Windows:**

1. Open PowerShell as Administrator in this folder  
2. Start Docker Desktop (Start menu → Docker Desktop)
3. Wait for Docker system tray icon to show "Docker Desktop is running"
4. Run: `docker compose up -d anythingllm n8n`

### 1. **Ollama** (2 minutes)

1. **Start:** Ollama should start automatically, or run: `ollama serve`
2. **Download Model:** Run `ollama pull phi3:mini` (should happen automatically during install)
3. **Verify:** Run `ollama list` to see installed models
4. **Test:** Run `curl http://localhost:11434/api/tags` to check the API

### 2. **AnythingLLM** (1 minute)

1. **Open:** Go to http://localhost:3001 (wait ~60 seconds for startup)
2. **Pre-configured workspace:** Look for "Product Management Hub" - ready to use!
3. **Upload:** Drag & drop PM documents (PRDs, user stories, research) into the workspace
4. **Chat:** Ask "What is this document about?" - powered by local Ollama!
5. **Optional setup:** Run `./scripts/setup-all-credentials.sh` if workspace isn't pre-configured

### 3. **n8n Workflows** (30 seconds)

1. **Open:** Go to http://localhost:5678
2. **Create account:** Quick local setup (no email needed)
3. **Pre-configured credentials:** Look for "Local Ollama (Pre-configured)" - ready to use!
4. **Quick test:** Create workflow → Add "OpenAI Chat Model" → Select pre-configured credential → Test!

### 4. **VS Code AI Coding** (30 seconds)

1. **Open:** Run `code .` in Terminal/PowerShell (or open VS Code manually)
2. **Start Cline:** Press `Ctrl+Shift+P` → Type "Cline: Start Cline" → Press Enter
3. **Ask:** Type "Create a simple hello world Python script" 
4. **Watch:** AI writes and explains the code for you!

### 5. **Optional Services** (Try these alternatives!)

**PrivateGPT** - Alternative document chat:

```bash
docker compose --profile optional up -d privategpt
# Wait 2 minutes, then open: http://localhost:8001
# Upload a document and chat with it
```

**LangFlow** - Visual workflow builder:

```bash
docker compose --profile optional up -d langflow  
# Wait 1 minute, then open: http://localhost:7860
# Drag and drop components to build AI workflows
```

**Ollama Web UI** - Alternative LLM interface:

```bash
# First install Ollama separately: https://ollama.ai/download
# Then start the web UI:
docker compose --profile optional up -d ollama-webui
# Wait 1 minute, then open: http://localhost:8080
```

## 🎯 What You Get

### 🧠 Local AI Brain

- **Ollama**: Run models locally with optimized performance
- **Continue.dev**: AI coding assistant in VS Code
- **Cline**: Advanced AI development workflows

### 📚 Smart Document Chat

- **AnythingLLM**: Chat with your PDFs, docs, and knowledge base
- **Private RAG**: Your documents never leave your machine
- **Multiple file formats**: PDF, DOCX, TXT, Markdown, and more

### ⚡ Workflow Automation

- **n8n**: Visual workflow builder for AI-powered automation
- **Monitor stack updates**: Get notified when tools have new releases
- **Custom workflows**: Build your own AI-powered processes

### 🔧 Development Tools

- **VS Code**: Fully configured with AI extensions
- **Docker services**: Everything runs in containers for easy management
- **Environment management**: Automatic setup of all configuration

## 📚 Complete Documentation

This kit includes comprehensive guides for every aspect of local AI setup and customization:

### 📖 Core Documentation

- **[README.md](README.md)** - This file: Complete setup and usage guide
- **[Offline-First Architecture](docs/offline-first-architecture.md)** - Why local AI is the future: cost analysis, security benefits, and 2026 trends
- **[CLAUDE.md](CLAUDE.md)** - Development context, commands, and technical details

### 🎯 Model Training & Customization

- **[Creating Training Data](docs/creating-training-data.md)** - Complete guide to preparing PM-specific training datasets
- **[Training Models](docs/training-models.md)** - Step-by-step fine-tuning walkthrough with Ollama
- **[Example Dataset](examples/dataset.jsonl)** - 19 ready-to-use PM training examples

### 🔌 Tool Integration

- **[Connecting Tools](docs/connecting-tools.md)** - Complete guide to connecting VS Code, n8n, LangFlow, and all tools to your local LLM
- **[Terminology Guide](docs/terminology-guide.md)** - Understand API keys, credentials, environment variables, and tool-specific terms

### ⚙️ Configuration & Setup

- **[Environment Variables](config/env.example)** - All customizable settings and ports
- **[Continue.dev Config](config/continue.json)** - VS Code AI assistant configuration
- **[n8n Workflows](config/workflows/)** - Pre-built automation templates

### 📋 Additional Resources

- **[Installation Scripts](scripts/)** - Individual component installers and utilities
- **[Verification Tools](scripts/verify.sh)** - Health checks and troubleshooting
- **[Uninstall Guide](uninstall.sh)** - Clean removal with confirmation prompts

**💡 New to AI fine-tuning?** Start with the [Training Data Guide](docs/creating-training-data.md) to create your first specialized PM assistant!

## 🏗️ What Gets Installed

### Core Stack (Always Installed)

| Component              | Purpose                          | Access                 |
| ---------------------- | -------------------------------- | ---------------------- |
| **Ollama**             | Local model server               | `ollama serve`         |
| **AnythingLLM**        | Document chat & RAG              | http://localhost:3001  |
| **n8n**                | Workflow automation              | http://localhost:5678  |
| **Continue.dev**       | VS Code AI assistant             | Ctrl+I in VS Code      |
| **Cline**              | Advanced AI workflows            | Ctrl+Shift+P > "Cline" |
| **Python AI Packages** | OpenAI, LangChain, NumPy, Pandas | Command line           |
| **Docker**             | Container management             | Command line           |

### Optional Services (Available on demand)

| Component         | Purpose                     | Access                | Start Command                                          |
| ----------------- | --------------------------- | --------------------- | ------------------------------------------------------ |
| **PrivateGPT**    | Alternative document chat   | http://localhost:8001 | `docker compose --profile optional up -d privategpt`   |
| **LangFlow**      | Visual LLM workflow builder | http://localhost:7860 | `docker compose --profile optional up -d langflow`     |
| **Ollama Web UI** | Web interface for Ollama    | http://localhost:8080 | `docker compose --profile optional up -d ollama-webui` |

## 📋 System Requirements

- **macOS 10.15+** / **Windows 10+** / **Ubuntu 18.04+**
- **8GB RAM minimum** (16GB recommended for larger models)
- **10GB free disk space**
- **Internet connection** for initial setup
- **Admin/sudo access** for package manager setup

**Everything else is auto-installed:**

- Package managers (Homebrew/Chocolatey)
- Python with pip updates
- Docker Desktop
- VS Code with extensions
- Ollama with Phi-3 Mini model

## 🔐 Privacy First

- ✅ **100% local processing** - your data stays on your machine
- ✅ **No cloud dependencies** - works completely offline
- ✅ **Private models** - run your own fine-tuned models
- ✅ **Encrypted storage** - all data stored locally and securely
- ✅ **Automatic model download** - Phi-3 Mini included out-of-the-box
- ❌ **No telemetry** - anonymous telemetry disabled by default

## 🎮 Usage Examples

### Chat with Documents

1. Open AnythingLLM: http://localhost:3001
2. Create a new workspace
3. Upload your PDFs, docs, or folders
4. Ask questions about your content

### AI-Powered Coding

1. Open VS Code: `code .`
2. Press `Ctrl+I` (Continue.dev) or `Ctrl+Shift+P` > "Cline"
3. Describe what you want to build
4. Watch AI write and explain code

### Workflow Automation

1. Open n8n: http://localhost:5678
2. Import pre-built workflows from [`config/workflows/`](config/workflows/)
3. Create custom AI-powered automations
4. Monitor your tools for updates

### Fine-tune Models

1. **Read the comprehensive guides:**
   - **[Creating Training Data](docs/creating-training-data.md)** - How to prepare high-quality training data
   - **[Training Models](docs/training-models.md)** - Complete fine-tuning walkthrough
2. **Start with examples:** Review **[examples/dataset.jsonl](examples/dataset.jsonl)** for 19 PM-focused examples
3. **Create your dataset:** Build training data for your specific PM tasks
4. **Train with Ollama:** Use Ollama's Modelfile system for custom models
5. **Test and iterate:** Continuously improve your specialized PM assistant

## 🔧 Advanced Configuration

### Environment Variables

Customize ports and settings in `.env`:

```bash
LLM_BASE_URL=http://localhost:1234/v1
ANYTHINGLLM_PORT=3001
N8N_PORT=5678
```

**📄 See all variables:** Check [`config/env.example`](config/env.example) for complete list of customizable settings, including local LLM API keys and specialized model configurations.

### Managing Optional Services

Start and manage additional tools:

```bash
# Start individual optional services
docker compose --profile optional up -d privategpt    # Alternative doc chat
docker compose --profile optional up -d langflow      # Visual LLM workflows  
docker compose --profile optional up -d ollama-webui  # Web UI for Ollama

# Start all optional services at once
docker compose --profile optional up -d

# Check status of all services (core + optional)
docker compose ps

# View logs for optional services
docker compose logs -f privategpt
docker compose logs -f langflow
docker compose logs -f ollama-webui

# Stop optional services
docker compose --profile optional stop
docker compose --profile optional down  # Stop and remove containers
```

### VS Code Configuration

Continue.dev config is at [`config/continue.json`](config/continue.json) - automatically points to your local Ollama server.

### Testing Installation

Before running the full installer, test in dry-run mode:

```bash
# Test full installation without making changes
./install.sh --dry-run           # macOS/Linux
./install.ps1 -DryRun            # Windows

# Test individual components  
./scripts/install-ollama.sh --help           # See all Ollama options
./scripts/install-ollama.sh --dry-run        # Test Ollama install
./scripts/setup-env.sh                        # Test environment setup
./scripts/verify.sh                           # Test system health

# Test optional services configuration
docker compose --profile optional config      # Validate optional services
docker compose config                         # Validate core services

# Test individual optional service startup (quick test)
docker compose --profile optional up -d langflow && sleep 30 && curl -f http://localhost:7860 && docker compose stop langflow
```

**💡 For detailed testing procedures:** See [CLAUDE.md](CLAUDE.md) for comprehensive testing commands and development workflows.

## 🩺 Troubleshooting

### Pre-Configuration Issues (v1.05)

**Pre-configured credentials not appearing?**

```bash
# Run the master setup script to configure all tools
./scripts/setup-all-credentials.sh

# Or configure individual tools:
./scripts/setup-n8n-credentials.sh          # n8n credentials
./scripts/setup-anythingllm-config.sh       # AnythingLLM workspace  
./scripts/setup-langflow-variables.sh       # LangFlow global variables
./scripts/setup-cline-config.sh            # Cline VS Code settings
```

**Can't see "Local Ollama (Pre-configured)" in n8n?**

```bash
# Check if n8n is running
curl http://localhost:5678/healthz

# Verify credential was created
./scripts/setup-n8n-credentials.sh
```

**AnythingLLM "Product Management Hub" workspace missing?**

```bash
# Check if AnythingLLM is running  
curl http://localhost:3001/api/ping

# Reconfigure workspace
./scripts/setup-anythingllm-config.sh
```

**LangFlow Global Variables not available?**

```bash
# Check if LangFlow is running
curl http://localhost:7860/health

# Setup global variables
./scripts/setup-langflow-variables.sh
```

### Common Issues

**Services not starting?**

```bash
# Check Docker is running
docker info

# Restart services
docker compose down && docker compose up -d
```

**Ollama not connecting?**

```bash
# Check if Ollama server is running
curl http://localhost:11434/api/tags

# Start Ollama server manually
ollama serve

# Or re-run Ollama installer with dry-run first to test
./scripts/install-ollama.sh --dry-run
./scripts/install-ollama.sh
```

**VS Code extensions not working?**

```bash
# Reinstall extensions
code --install-extension saoudrizwan.claude-dev
code --install-extension Continue.continue
```

**Port conflicts?**
Edit `.env` file to change ports, then restart:

```bash
docker compose down && docker compose up -d
```

**Installer hanging or timing out?**

```bash
# Test installer in dry-run mode first
./install.sh --dry-run           # macOS/Linux
./install.ps1 -DryRun            # Windows

# Test Ollama installer separately
./scripts/install-ollama.sh --dry-run     # macOS/Linux
./scripts/install-ollama.ps1 -DryRun      # Windows
```

**Package manager issues?**

```bash
# macOS: Update Homebrew
brew update && brew doctor

# Windows: Try different package managers
winget --version    # Check if winget available
choco --version     # Check if Chocolatey available

# Update pip for Python packages
pip3 install --upgrade pip
```

**Model fine-tuning issues?**

- **Read the complete guides:**
  - `docs/creating-training-data.md` - Fix data format and quality issues
  - `docs/training-models.md` - Troubleshoot training parameters and performance
- **Check training data:** Validate JSONL format and example quality
- **Adjust parameters:** Lower learning rate or reduce batch size for stability

**Tools not connecting to local LLM?**

- **Complete integration guide:** [Connecting Tools](docs/connecting-tools.md) - Step-by-step setup for VS Code, n8n, LangFlow, and more
- **Terminology help:** [Terminology Guide](docs/terminology-guide.md) - Understand credentials, API keys, and environment variables
- **Quick fixes:** Check Ollama server running on port 11434, use correct model name, verify API endpoints

### Health Check

Run the verification script to check everything:

```bash
./scripts/verify.sh  # macOS/Linux
.\scripts\verify.ps1  # Windows
```

### Get Help

- **Documentation:** See [Complete Documentation](#-complete-documentation) section above for all guides
- **Training Issues:** Check [Creating Training Data](docs/creating-training-data.md) and [Training Models](docs/training-models.md)
- **Technical Details:** Review [CLAUDE.md](CLAUDE.md) for development context and commands
- **Check logs:** `docker compose logs -f`
- **Verify setup:** `./scripts/verify.sh`
- **Reset environment:** `./uninstall.sh && ./install.sh`

## 🗑️ Uninstalling

### Quick Removal

```bash
./uninstall.sh     # macOS/Linux
.\uninstall.ps1    # Windows
```

### Manual Cleanup

```bash
# Stop and remove containers
docker compose down -v

# Remove Docker images (optional)
docker rmi $(docker images -q mintplexlabs/anythingllm n8nio/n8n)

# Remove VS Code extensions (optional)
code --uninstall-extension saoudrizwan.claude-dev
code --uninstall-extension Continue.continue
```

## 🤝 Contributing

This toolkit is designed for simplicity and reliability. When contributing:

1. **Keep it simple** - PMs need low-touch solutions
2. **Test across platforms** - macOS, Windows, Linux
3. **Document everything** - clear instructions and examples
4. **Privacy first** - no cloud dependencies or telemetry

## 📖 Learn More

### Platform Documentation

- **Ollama**: [ollama.ai](https://ollama.ai/) - Local model inference and management
- **AnythingLLM**: [docs.anythingllm.com](https://docs.anythingllm.com) - Document chat and RAG
- **n8n**: [docs.n8n.io](https://docs.n8n.io) - Workflow automation
- **Continue.dev**: [docs.continue.dev](https://docs.continue.dev) - AI coding assistant

### Training & Customization

- **[Creating Training Data](docs/creating-training-data.md)** - Complete guide to preparing PM-specific datasets  
- **[Training Models](docs/training-models.md)** - Step-by-step fine-tuning walkthrough with Ollama
- **[Example Dataset](examples/dataset.jsonl)** - 19 ready-to-use PM training examples

### Integration & Configuration

- **[Connecting Tools to Local LLMs](docs/connecting-tools-to-local-llms.md)** - Essential guide for connecting n8n and LangFlow to Ollama
- **[Connecting All Tools](docs/connecting-tools.md)** - Connect VS Code, n8n, LangFlow, and all tools to your local LLM
- **[CLI Agents](docs/cli-agents.md)** - Run n8n workflows and LangFlow flows as standalone command-line agents
- **[Terminology Guide](docs/terminology-guide.md)** - Understand API keys, credentials, environment variables, and tool concepts
- **[Configuration Files](config/)** - Environment variables, VS Code settings, and workflow templates

## 🔄 Updates & Re-Installation

### ✅ Safe to Re-Run Installation

**The installer is designed to be run multiple times safely.** It checks for existing installations and only updates what's needed:

```bash
# Get latest version
git pull origin main

# Re-run installer (safe to run multiple times)
./install.sh
```

### 🛡️ Safety Features

The installer includes comprehensive safety checks:

- **Idempotent operations**: Won't reinstall existing packages
- **Environment preservation**: Updates `.env` only if missing
- **Guarded shell configs**: Uses markers to prevent duplicate entries  
- **Docker safety**: Uses `docker compose up -d` which safely updates running containers
- **Dependency checking**: Verifies existing installations before proceeding

### 📈 Recommended for Growing Toolkit

As this toolkit expands (especially for webinar distribution), regular re-installation ensures:

- Latest configuration templates
- New tool integrations
- Updated documentation
- Fresh Docker images and models

### 🚨 What Gets Updated vs. Preserved

**Updated on each run:**

- Package managers (Homebrew/apt) and packages
- Docker images and container configurations
- VS Code extensions
- Documentation and example files

**Preserved across runs:**

- Your `.env` file (only created if missing)
- Docker volumes and data
- Your shell configuration (guarded blocks prevent duplicates)
- Custom workflows and configurations

Monitor your AI tools for updates using the included n8n workflow at http://localhost:5678

## 🔒 Offline-First Architecture

**Why local AI matters in 2026**: Rising subscription costs, enterprise security requirements, and the need for customized domain models are driving the shift to local-first AI infrastructure.

### Key Benefits:

- **💰 Cost Control**: Eliminate recurring AI subscriptions ($1,680+/year → $0 after hardware)
- **🛡️ Complete Privacy**: All data stays on your machine, no external API calls
- **🎨 Full Customization**: Fine-tune models for your specific PM domain and methodology
- **⚡ No Limits**: Unlimited inference, parallel agents, rapid prototyping

### Technical Approach:

- **100% Local Inference**: All models run on your hardware via Ollama
- **OpenAI-Compatible Protocol**: Tools connect to local endpoints, not cloud APIs
- **Container Isolation**: Docker services communicate internally only
- **Environment Variable Control**: All configurations point to local resources

**[→ Read the full analysis](docs/offline-first-architecture.md)** covering cost comparisons, security benefits, and migration strategies for the local AI future.

## ⭐ Why Local AI?

- **Privacy**: Your data, your control
- **Speed**: No API rate limits or network delays  
- **Cost**: No per-token charges, unlimited usage
- **Reliability**: Works offline, no service outages
- **Customization**: Fine-tune models for your specific needs

## 🤝 Contributing

Contributions are welcome! This toolkit is designed to grow with the community's needs.

- **Bug reports & feature requests**: [Open an issue](https://github.com/deanpeters/aipm-laptop-llm-kit/issues)
- **Code contributions**: See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines
- **Documentation improvements**: Help make setup even easier for newcomers
- **Testing**: Try the installer on different systems and report issues

### Contributors

Thanks to everyone who has contributed to making local AI accessible to Product Managers and professionals worldwide! 🙏

---

**Ready to supercharge your productivity with local AI? Run the installer and start building! 🚀**