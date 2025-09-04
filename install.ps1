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

# Early service detection and launch
function Start-EarlyServices {
    Write-Progress-Custom "Detecting and launching required services early..."
    
    # Variables to track what we launched
    $dockerLaunched = $false
    $lmStudioLaunched = $false
    
    # Check and launch Docker if available
    if (Test-Command docker) {
        Write-Progress-Custom "Docker detected - checking if running..."
        $dockerRunning = $false
        try {
            docker info 2>$null | Out-Null
            $dockerRunning = $true
        }
        catch {
            $dockerRunning = $false
        }
        
        if (-not $dockerRunning) {
            if ($DryRun) {
                Write-Log "[DRY RUN] Would launch Docker Desktop in background"
            }
            else {
                Write-Progress-Custom "Docker not running - attempting to start Docker Desktop..."
                $dockerPath = "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe"
                if (Test-Path $dockerPath) {
                    Write-Log "Starting Docker Desktop..."
                    Start-Process $dockerPath -WindowStyle Hidden
                    $dockerLaunched = $true
                }
                else {
                    Write-Warning-Custom "Docker Desktop not found at expected location"
                }
            }
        }
        else {
            Write-Success "Docker is already running"
        }
    }
    else {
        Write-Log "Docker not yet installed - will be installed later"
    }
    
    # Check and launch LM Studio if available (future: Ollama)
    if (Test-Command "lms") {
        Write-Progress-Custom "LM Studio detected - checking if server is running..."
        $lmsRunning = $false
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:1234/v1/models" -TimeoutSec 5 -ErrorAction SilentlyContinue
            $lmsRunning = $true
        }
        catch {
            $lmsRunning = $false
        }
        
        if (-not $lmsRunning) {
            if ($DryRun) {
                Write-Log "[DRY RUN] Would launch LM Studio server in background"
            }
            else {
                Write-Progress-Custom "LM Studio server not running - starting in background..."
                Write-Log "Starting LM Studio server..."
                Start-Process "lms" -ArgumentList "server", "start" -WindowStyle Hidden
                $lmStudioLaunched = $true
            }
        }
        else {
            Write-Success "LM Studio server is already running"
        }
    }
    else {
        Write-Log "LM Studio not yet installed - will be installed later"
    }
    
    # Wait for launched services to initialize
    if (($dockerLaunched -or $lmStudioLaunched) -and (-not $DryRun)) {
        Write-Progress-Custom "Waiting for launched services to initialize..."
        
        if ($dockerLaunched) {
            Write-Log "Waiting for Docker to be ready..."
            $dockerWait = 0
            while ($dockerWait -lt 30) {
                try {
                    docker info 2>$null | Out-Null
                    break
                }
                catch {
                    Start-Sleep 2
                    $dockerWait += 2
                    Write-Host "." -NoNewline
                }
            }
            Write-Host ""
            
            try {
                docker info 2>$null | Out-Null
                Write-Success "Docker is ready"
            }
            catch {
                Write-Warning-Custom "Docker may still be starting - installation will continue"
            }
        }
        
        if ($lmStudioLaunched) {
            Write-Log "Waiting for LM Studio server to be ready..."
            $lmsWait = 0
            while ($lmsWait -lt 15) {
                try {
                    $response = Invoke-WebRequest -Uri "http://localhost:1234/v1/models" -TimeoutSec 2 -ErrorAction SilentlyContinue
                    break
                }
                catch {
                    Start-Sleep 1
                    $lmsWait += 1
                    Write-Host "." -NoNewline
                }
            }
            Write-Host ""
            
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:1234/v1/models" -TimeoutSec 2 -ErrorAction SilentlyContinue
                Write-Success "LM Studio server is ready"
            }
            catch {
                Write-Warning-Custom "LM Studio server may still be starting - installation will continue"
            }
        }
    }
    
    Write-Log "Early service launch completed"
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
    
    # Launch existing services early to avoid warnings later
    Start-EarlyServices
    
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