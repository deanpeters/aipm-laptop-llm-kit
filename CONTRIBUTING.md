# Contributing to AIPM Laptop LLM Kit

Thank you for your interest in contributing! This document outlines how to contribute to the project.

## 🎯 Project Goals

This toolkit aims to provide a **one-command local AI stack** for Product Managers and professionals who want:
- Complete privacy and offline operation
- Zero recurring costs after hardware investment
- Easy setup without deep technical knowledge
- Integration between AI tools (LM Studio, n8n, LangFlow, VS Code)

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

### High Priority
- **Cross-platform compatibility**: Testing and fixes for different OS versions
- **Error handling**: Better detection and resolution of common issues  
- **Documentation**: User guides, troubleshooting, examples
- **Installation reliability**: Edge cases, dependency conflicts

### Medium Priority
- **New tool integrations**: Additional AI tools that fit the local-first philosophy
- **Performance optimization**: Faster installation, smaller Docker images
- **Advanced configuration**: More customization options
- **Testing**: Automated tests for different environments

### Lower Priority
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

- **Be respectful** and constructive in discussions
- **Help others** learn and contribute
- **Focus on the user experience** - keep things simple
- **Prioritize privacy and local-first** approaches
- **Test your changes** thoroughly before submitting

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