# Contributing to AIPM Laptop LLM Kit

Thank you for your interest in contributing! This document outlines how to contribute to the project.

## 🎯 Project Goals & Philosophy

This toolkit aims to provide a **one-command local AI stack** for Product Managers and professionals who want:
- Complete privacy and offline operation
- Zero recurring costs after hardware investment
- Easy setup without deep technical knowledge
- Integration between AI tools (LM Studio, n8n, LangFlow, VS Code)

### 💡 Our Philosophy
**"Amplify Human Insight, Don't Replace Human Judgment"**
- **Teach while doing**: Every feature should be a learning experience for PM professionals
- **Strategic AND tactical value**: Balance high-level thinking with practical execution
- **Cross-functional perspective**: Consider the broader product ecosystem
- **Collaboration over competition**: Build tools that enhance team dynamics

## 🔧 Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/yourusername/aipm-laptop-llm-kit.git
   cd aipm-laptop-llm-kit
   ```

2. **Test the installation**
   ```bash
   ./install.sh --dry-run    # Safe test without changes
   ./install.sh              # Full installation
   ```

## 📋 Contribution Guidelines

### Code Standards

**Shell Scripts (`.sh` files):**
- Must pass `shellcheck` linting
- Use `#!/bin/bash` shebang
- Include error handling with `set -e` where appropriate
- Use descriptive variable names
- Add comments for complex logic

**PowerShell Scripts (`.ps1` files):**
- Must pass `PSScriptAnalyzer` linting
- Use approved PowerShell verbs
- Include proper error handling
- Use descriptive parameter names

**Documentation:**
- Use `~~~` for code blocks (not ```)
- Keep language simple and beginner-friendly
- Include examples for each major feature
- Update relevant documentation when changing functionality

### Testing Requirements

Before submitting a PR:

1. **Lint your code:**
   ```bash
   # Shell scripts
   shellcheck install.sh scripts/*.sh
   
   # PowerShell scripts  
   pwsh -Command "Invoke-ScriptAnalyzer *.ps1 scripts/*.ps1"
   ```

2. **Test installation:**
   ```bash
   # Dry run (safe)
   ./install.sh --dry-run
   
   # Full installation (on clean system if possible)
   ./install.sh
   ```

3. **Test idempotency:**
   ```bash
   # Run multiple times - should be safe
   ./install.sh
   ./install.sh
   ```

### Commit Message Format

Use clear, descriptive commit messages:
- `feat: add LangFlow scheduling support`
- `fix: resolve Docker port conflict detection`
- `docs: update offline architecture guide`
- `refactor: improve error handling in setup-env.sh`

## 🎯 Areas for Contribution

### 🚨 High Priority
- **Cross-platform compatibility**: Testing and fixes for different OS versions
- **Windows installer testing**: Validation across Windows environments
- **Error handling**: Better detection and resolution of common issues  
- **Installation reliability**: Edge cases, dependency conflicts

### 📋 PM Workflow Contributions
We especially welcome contributions that **solve real PM problems** and provide **strategic value**:

#### **Workflow Quality Standards:**
- **Address authentic challenges**: Focus on real problems PMs face daily
- **Strategic AND tactical**: Balance high-level thinking with actionable steps
- **Cross-platform compatible**: Work across different tools and environments
- **Teaching focused**: Guide users through the thinking process
- **Measurable outcomes**: Clear value proposition and success criteria

#### **Required Workflow Metadata:**
When submitting workflows (n8n, LangFlow), include:
```yaml
# Workflow: Strategic Competitive Analysis
# Description: Weekly automated competitor monitoring with strategic insights
# Usage: Run weekly via scheduled agent, outputs to Slack/email
# Frameworks: Jobs-to-be-Done, Five Forces, SWOT
# Attribution: [Your name]
# License: MIT
```

#### **Workflow Categories Needed:**
- **Strategic PM**: OKRs, roadmapping, market analysis (beyond Scrum PO level)
- **Executive communication**: Board reports, stakeholder updates, metrics dashboards
- **Portfolio management**: Resource allocation, priority scoring, ROI analysis
- **Customer insights**: User research synthesis, feedback analysis, personas
- **Competitive intelligence**: Market monitoring, feature gap analysis

### 🔧 Medium Priority
- **New tool integrations**: Additional AI tools that fit the local-first philosophy
- **Performance optimization**: Faster installation, smaller Docker images
- **Advanced configuration**: More customization options
- **Testing**: Automated tests for different environments

### 💡 Lower Priority
- **UI improvements**: Better terminal output, progress indicators
- **Optional features**: Additional models, providers, workflows

## 🔍 Issue Reporting

When reporting issues:

1. **Search existing issues** first
2. **Use the issue template** provided
3. **Include system information**:
   - OS and version
   - Architecture (Intel/Apple Silicon/AMD)
   - Docker version
   - Installation logs

4. **Provide reproduction steps**
5. **Include relevant logs** (`install.log`, Docker logs)

## 🚀 Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the guidelines above

3. **Test thoroughly**:
   - Lint all scripts
   - Test dry run and full installation
   - Test on multiple systems if possible

4. **Update documentation** if needed

5. **Submit PR** using the provided template

6. **Address review feedback** promptly

## 📖 Documentation Style

- **Audience**: Product managers and professionals (not developers)
- **Tone**: Clear, step-by-step, minimal jargon
- **Format**: Use `~~~` for code blocks
- **Examples**: Include practical examples for PM workflows
- **Structure**: Start with quick start, then detailed explanations

## 🤝 Community Guidelines

### Core Principles
- **Collaboration over competition**: We're building together for the PM community
- **Learning is iterative**: Mistakes are opportunities for improvement
- **Teach while doing**: Share knowledge through working examples
- **Strategic thinking first**: Focus on "why" before "how"

### Community Behavior
- **Be respectful** and constructive in discussions
- **Help others** learn and contribute
- **Focus on the user experience** - keep things simple
- **Prioritize privacy and local-first** approaches
- **Test your changes** thoroughly before submitting

### Contribution Evaluation
When reviewing contributions, we consider:
- **Strategic AND tactical value**: Does it solve real PM problems?
- **Professional output quality**: Is it ready for enterprise use?
- **Cross-functional perspective**: Does it consider the broader product ecosystem?
- **Measurable learning outcomes**: Do users learn something valuable?
- **Local-first compatibility**: Does it maintain offline-first principles?

## 📞 Getting Help

- **Issues**: Use GitHub issues for bugs and feature requests
- **Questions**: Include context about your system and what you're trying to achieve
- **Documentation**: Check existing docs first - they're comprehensive!

## 🎉 Recognition

Contributors will be recognized in:
- README contributors section
- Release notes for significant contributions
- Project documentation where relevant

Thank you for helping make local AI accessible to everyone! 🚀