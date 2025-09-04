# AIPM Laptop LLM Kit Installer - Windows PowerShell
# One-command setup for local AI stack

param(
    [switch]$DryRun,
    [switch]$Help
)

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$LogFile = Join-Path $ScriptDir "install.log"

# Show help
if ($Help) {
    Write-Host "AIPM Laptop LLM Kit Installer"
    Write-Host "Usage: .\install.ps1 [-DryRun] [-Help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -DryRun    Show what would be installed without making changes"
    Write-Host "  -Help      Show this help message"
    exit 0
}

# Logging function
function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $Message
    Add-Content -Path $LogFile -Value $logMessage
}

# Progress indicator
function Write-Progress-Custom {
    param($Message)
    Write-Host "🔄 $Message" -ForegroundColor Blue
    Write-Log $Message
}

# Success indicator
function Write-Success {
    param($Message)
    Write-Host "✅ $Message" -ForegroundColor Green
    Write-Log $Message
}

# Warning indicator
function Write-Warning-Custom {
    param($Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
    Write-Log $Message
}

# Error indicator
function Write-Error-Custom {
    param($Message)
    Write-Host "❌ $Message" -ForegroundColor Red
    Write-Log $Message
    exit 1
}

# Check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if command exists
function Test-Command {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Install and update package managers
function Install-PackageManager {
    $hasWinget = Test-Command winget
    $hasChocolatey = Test-Command choco
    
    # Prefer winget, fallback to Chocolatey
    if ($hasWinget) {
        Write-Success "winget already available"
        $script:PreferredPkgMgr = "winget"
    }
    elseif ($hasChocolatey) {
        Write-Success "Chocolatey already available"
        $script:PreferredPkgMgr = "choco"
    }
    else {
        # Try to install Chocolatey (more reliable than winget installation)
        Write-Progress-Custom "Installing Chocolatey package manager..."
        if ($DryRun) {
            Write-Log "[DRY RUN] Would install Chocolatey"
            $script:PreferredPkgMgr = "choco"
            return
        }
        
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            
            # Refresh environment variables
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
            
            if (Test-Command choco) {
                Write-Success "Chocolatey installed successfully"
                $script:PreferredPkgMgr = "choco"
            }
            else {
                Write-Warning-Custom "Chocolatey installation may have failed"
                $script:PreferredPkgMgr = "manual"
            }
        }
        catch {
            Write-Warning-Custom "Failed to install Chocolatey: $_"
            Write-Warning-Custom "Please install winget manually: https://aka.ms/getwinget"
            $script:PreferredPkgMgr = "manual"
        }
    }
    
    # Update pip for Python package consistency
    Update-Pip
}

# Update pip for consistency
function Update-Pip {
    Write-Progress-Custom "Updating pip for Python package consistency..."
    if ($DryRun) {
        Write-Log "[DRY RUN] Would update pip to latest version"
        return
    }
    
    $pipUpdated = $false
    
    # Try different Python/pip combinations
    try {
        if (Get-Command pip3 -ErrorAction SilentlyContinue) {
            pip3 install --upgrade pip 2>$null
            $pipUpdated = $true
        }
        elseif (Get-Command pip -ErrorAction SilentlyContinue) {
            pip install --upgrade pip 2>$null
            $pipUpdated = $true
        }
        elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
            python3 -m pip install --upgrade pip 2>$null
            $pipUpdated = $true
        }
        elseif (Get-Command python -ErrorAction SilentlyContinue) {
            python -m pip install --upgrade pip 2>$null
            $pipUpdated = $true
        }
    }
    catch {
        # Ignore pip update errors
    }
    
    if ($pipUpdated) {
        Write-Success "pip updated to latest version"
    }
    else {
        Write-Warning-Custom "Could not update pip (this may not affect installation)"
    }
}

# Install Docker
function Install-Docker {
    if (!(Test-Command docker)) {
        Write-Progress-Custom "Installing Docker Desktop..."
        if ($DryRun) {
            Write-Log "[DRY RUN] Would install Docker Desktop"
            return
        }
        
        $installed = $false
        try {
            switch ($script:PreferredPkgMgr) {
                "winget" {
                    winget install -e --id Docker.DockerDesktop --silent
                    $installed = $true
                }
                "choco" {
                    choco install docker-desktop -y
                    $installed = $true
                }
                default {
                    Write-Warning-Custom "No package manager available for automatic Docker installation"
                }
            }
            
            if ($installed) {
                Write-Success "Docker Desktop installed. Please restart your computer and start Docker Desktop."
                Write-Warning-Custom "After restart, you may need to enable WSL2 integration in Docker settings."
            }
        }
        catch {
            Write-Warning-Custom "Failed to install Docker via package manager. Please install manually: https://docs.docker.com/desktop/windows/install/"
        }
    }
    else {
        Write-Success "Docker already installed"
    }
}

# Install VS Code
function Install-VSCode {
    if (!(Test-Command code)) {
        Write-Progress-Custom "Installing VS Code..."
        if ($DryRun) {
            Write-Log "[DRY RUN] Would install VS Code"
            return
        }
        
        $installed = $false
        try {
            switch ($script:PreferredPkgMgr) {
                "winget" {
                    winget install -e --id Microsoft.VisualStudioCode --silent
                    $installed = $true
                }
                "choco" {
                    choco install vscode -y
                    $installed = $true
                }
                default {
                    Write-Warning-Custom "No package manager available for automatic VS Code installation"
                }
            }
            
            if ($installed) {
                # Add VS Code to PATH
                $vsCodePaths = @(
                    "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\bin",
                    "${env:PROGRAMFILES}\Microsoft VS Code\bin"
                )
                
                foreach ($path in $vsCodePaths) {
                    if (Test-Path $path) {
                        $env:PATH += ";$path"
                        [Environment]::SetEnvironmentVariable("Path", $env:PATH, [EnvironmentVariableTarget]::User)
                        break
                    }
                }
                Write-Success "VS Code installed"
            }
        }
        catch {
            Write-Warning-Custom "Failed to install VS Code via package manager. Please install manually: https://code.visualstudio.com/"
        }
    }
    else {
        Write-Success "VS Code already installed"
    }
}

# Install VS Code extensions
function Install-Extensions {
    if (Test-Command code) {
        Write-Progress-Custom "Installing VS Code extensions..."
        if ($DryRun) {
            Write-Log "[DRY RUN] Would install Cline and Continue.dev extensions"
            return
        }
        
        try {
            code --install-extension saoudrizwan.claude-dev 2>$null
            code --install-extension Continue.continue 2>$null
            Write-Success "VS Code extensions installed"
        }
        catch {
            Write-Warning-Custom "Failed to install some VS Code extensions"
        }
    }
}

# Setup environment
function Setup-Environment {
    Write-Progress-Custom "Setting up environment variables..."
    if ($DryRun) {
        Write-Log "[DRY RUN] Would setup environment variables"
        return
    }
    
    & "$ScriptDir\scripts\setup-env.ps1"
    Write-Success "Environment configured"
}

# Start services
function Start-Services {
    Write-Progress-Custom "Starting Docker services..."
    if ($DryRun) {
        Write-Log "[DRY RUN] Would start AnythingLLM and n8n services"
        return
    }
    
    try {
        Set-Location $ScriptDir
        docker compose up -d anythingllm n8n
        Write-Success "Services started"
    }
    catch {
        Write-Warning-Custom "Failed to start services. Make sure Docker Desktop is running."
    }
}

# Verify installation
function Verify-Installation {
    Write-Progress-Custom "Verifying installation..."
    if ($DryRun) {
        Write-Log "[DRY RUN] Would verify all services are working"
        return
    }
    
    & "$ScriptDir\scripts\verify.ps1"
}

# Main installation flow
function Main {
    Write-Log "=== AIPM Laptop LLM Kit Installation Started ==="
    Write-Log "Timestamp: $(Get-Date)"
    Write-Log "OS: Windows"
    Write-Log "Dry run: $DryRun"
    Write-Log ""
    
    # Check execution policy
    $executionPolicy = Get-ExecutionPolicy
    if ($executionPolicy -eq "Restricted") {
        Write-Warning-Custom "PowerShell execution policy is Restricted. Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
        exit 1
    }
    
    # Install LM Studio with automation
    Write-Progress-Custom "Installing LM Studio with automated setup..."
    if ($DryRun) {
        Write-Log "[DRY RUN] Would install LM Studio with default model and start server"
    }
    else {
        & "$ScriptDir\scripts\install-lmstudio.ps1"
    }
    
    Install-PackageManager
    Install-Docker
    Install-VSCode
    Install-Extensions
    Setup-Environment
    Start-Services
    Verify-Installation
    
    Write-Log ""
    Write-Success "=== Installation Complete! ==="
    Write-Log ""
    Write-Log "Next steps:"
    Write-Log "1. Open VS Code: code ."
    Write-Log "2. Access AnythingLLM: http://localhost:3001"
    Write-Log "3. Access n8n: http://localhost:5678"
    Write-Log "4. Your local LLM: http://localhost:1234/v1"
    Write-Log ""
    Write-Log "For help: see README.md or run: .\scripts\verify.ps1"
}

# Handle Ctrl+C
trap {
    Write-Host "`nInstallation interrupted" -ForegroundColor Red
    exit 1
}

# Run main function
Main