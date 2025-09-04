# AIPM Laptop LLM Kit - CLI Agent Runner for Windows PowerShell
# Run n8n workflows as standalone agents with local LLM support
#
# Usage: 
#   .\run-agent.ps1 <WORKFLOW_ID>                    # Run once and exit
#   .\run-agent.ps1 <WORKFLOW_ID> -Background       # Run in background
#   .\run-agent.ps1 <WORKFLOW_ID> -Provider ollama  # Use Ollama instead of LM Studio
#   .\run-agent.ps1 list                            # List available workflows

param(
    [Parameter(Position=0)]
    [string]$WorkflowId,
    
    [switch]$Background,
    
    [ValidateSet("lmstudio", "ollama")]
    [string]$Provider = "lmstudio",
    
    [string]$LogFile,
    
    [switch]$Help
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Split-Path -Parent $ScriptDir
$EnvFile = Join-Path $ProjectRoot ".env"

function Write-Success {
    param($Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param($Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param($Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param($Message)
    Write-Host "ℹ️ $Message" -ForegroundColor Blue
}

function Show-Usage {
    Write-Host @"
AIPM CLI Agent Runner for Windows
Run n8n workflows as standalone agents with local LLM support

Usage:
  .\run-agent.ps1 <WORKFLOW_ID>                    Run workflow once and exit
  .\run-agent.ps1 <WORKFLOW_ID> -Background       Run workflow in background  
  .\run-agent.ps1 <WORKFLOW_ID> -Provider ollama  Use Ollama instead of LM Studio
  .\run-agent.ps1 <WORKFLOW_ID> -LogFile <file>   Save output to specific log file
  .\run-agent.ps1 list                            List all available workflows
  .\run-agent.ps1 status                          Show running background agents

Examples:
  .\run-agent.ps1 123e4567-e89b-12d3-a456-426614174000
  .\run-agent.ps1 my-workflow-id -Background -Provider ollama
  .\run-agent.ps1 list

Environment Variables (set automatically):
  LLM_BASE_URL, LLM_API_KEY, LLM_MODEL_NAME    (LM Studio)
  OLLAMA_BASE_URL, OLLAMA_API_KEY, OLLAMA_MODEL_NAME (Ollama)
  N8N_ENCRYPTION_KEY (if needed for encrypted credentials)

Notes:
  - Workflow ID can be found in n8n UI URL or workflow settings
  - Background agents log to ~/aipm-agents/<workflow-id>.log
  - Use 'docker logs -f n8n' to see container output if using Docker setup
"@ -ForegroundColor Blue
}

function Import-EnvFile {
    if (Test-Path $EnvFile) {
        Get-Content $EnvFile | ForEach-Object {
            if ($_ -match '^([^#][^=]*)=(.*)$') {
                $name = $matches[1].Trim()
                $value = $matches[2].Trim()
                # Remove quotes if present
                $value = $value -replace '^["'']|["'']$', ''
                Set-Item -Path "env:$name" -Value $value -Force
            }
        }
        Write-Success "Loaded environment from .env"
    }
    else {
        Write-Warning-Custom "No .env file found, using defaults"
    }
}

function Set-Provider {
    param($ProviderName, $ExecutionMode)
    
    switch ($ProviderName) {
        "lmstudio" {
            if ($ExecutionMode -eq "docker") {
                # Docker n8n -> use host.docker.internal
                $env:LLM_BASE_URL = if ($env:LLM_DOCKER_URL) { $env:LLM_DOCKER_URL } else { "http://host.docker.internal:1234/v1" }
                Write-Info "Using LM Studio provider for Docker n8n ($($env:LLM_BASE_URL))"
            } else {
                # CLI n8n -> use localhost
                $env:LLM_BASE_URL = if ($env:LLM_BASE_URL) { $env:LLM_BASE_URL } else { "http://localhost:1234/v1" }
                Write-Info "Using LM Studio provider for CLI n8n ($($env:LLM_BASE_URL))"
            }
            $env:LLM_API_KEY = if ($env:LLM_API_KEY) { $env:LLM_API_KEY } else { "local-lmstudio-key" }
            $env:LLM_MODEL_NAME = if ($env:LLM_MODEL_NAME) { $env:LLM_MODEL_NAME } else { "phi-3-mini-4k-instruct" }
        }
        "ollama" {
            if ($ExecutionMode -eq "docker") {
                # Docker n8n -> use host.docker.internal
                $env:OLLAMA_BASE_URL = if ($env:OLLAMA_DOCKER_URL) { $env:OLLAMA_DOCKER_URL } else { "http://host.docker.internal:11434/v1" }
                Write-Info "Using Ollama provider for Docker n8n ($($env:OLLAMA_BASE_URL))"
            } else {
                # CLI n8n -> use localhost
                $env:OLLAMA_BASE_URL = if ($env:OLLAMA_BASE_URL) { $env:OLLAMA_BASE_URL } else { "http://localhost:11434/v1" }
                Write-Info "Using Ollama provider for CLI n8n ($($env:OLLAMA_BASE_URL))"
            }
            $env:OLLAMA_API_KEY = if ($env:OLLAMA_API_KEY) { $env:OLLAMA_API_KEY } else { "local-ollama-key" }
            $env:OLLAMA_MODEL_NAME = if ($env:OLLAMA_MODEL_NAME) { $env:OLLAMA_MODEL_NAME } else { "phi3:mini" }
        }
        default {
            Write-Error-Custom "Unknown provider: $ProviderName. Use 'lmstudio' or 'ollama'"
            exit 1
        }
    }
}

function Test-N8nInstallation {
    # Check if n8n is available via Docker first (our default setup)
    $dockerRunning = docker ps 2>$null | Select-String "n8n"
    if ($dockerRunning) {
        Write-Info "Found n8n running in Docker container"
        $env:N8N_EXECUTION_MODE = "docker"
        return $true
    }
    
    # Check if n8n CLI is available globally
    $n8nCli = Get-Command n8n -ErrorAction SilentlyContinue
    if ($n8nCli) {
        Write-Info "Found n8n CLI installation"
        $env:N8N_EXECUTION_MODE = "cli"
        return $true
    }
    
    Write-Error-Custom "n8n not found! Please ensure n8n is running via Docker or install n8n CLI globally"
    Write-Host ""
    Write-Host "To use with Docker (recommended):"
    Write-Host "  docker compose up -d n8n"
    Write-Host ""
    Write-Host "To install n8n CLI globally:"
    Write-Host "  npm install -g n8n"
    return $false
}

function Invoke-N8nCommand {
    param($Command)
    
    # Try Docker first (our default setup)
    $dockerRunning = docker ps 2>$null | Select-String "n8n"
    if ($dockerRunning) {
        docker exec -u node n8n $Command
    }
    # Fall back to global CLI
    elseif (Get-Command n8n -ErrorAction SilentlyContinue) {
        & n8n $Command
    }
    else {
        Write-Error-Custom "Cannot execute n8n command: $Command"
        exit 1
    }
}

function Get-Workflows {
    Write-Info "Listing available workflows..."
    Invoke-N8nCommand "list:workflow"
}

function Show-Status {
    Write-Info "Checking running background agents..."
    
    # Check for background processes
    $logDir = Join-Path $env:USERPROFILE "aipm-agents"
    if (Test-Path $logDir) {
        $logFiles = Get-ChildItem -Path $logDir -Filter "*.log" -ErrorAction SilentlyContinue
        if ($logFiles) {
            Write-Info "Found $($logFiles.Count) agent log files in $logDir"
            $logFiles | Format-Table Name, LastWriteTime, Length
        }
        else {
            Write-Info "No background agent activity found"
        }
    }
    else {
        Write-Info "No background agents directory found"
    }
    
    # Show Docker container status
    $dockerRunning = docker ps 2>$null | Select-String "n8n"
    if ($dockerRunning) {
        Write-Info "n8n Docker container is running"
        docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}" | Select-String "n8n"
    }
}

function Start-WorkflowExecution {
    param(
        [string]$WorkflowId,
        [bool]$RunInBackground,
        [string]$LogPath
    )
    
    if ([string]::IsNullOrEmpty($WorkflowId)) {
        Write-Error-Custom "Workflow ID is required"
        Show-Usage
        exit 1
    }
    
    # Set up logging
    $logDir = Join-Path $env:USERPROFILE "aipm-agents"
    if ($RunInBackground -or ![string]::IsNullOrEmpty($LogPath)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        if ([string]::IsNullOrEmpty($LogPath)) {
            $LogPath = Join-Path $logDir "$WorkflowId.log"
        }
    }
    
    # Execute command
    $cmd = "execute --id $WorkflowId"
    
    if ($RunInBackground) {
        Write-Info "Running workflow $WorkflowId in background..."
        Write-Info "Log file: $LogPath"
        
        $dockerRunning = docker ps 2>$null | Select-String "n8n"
        if ($dockerRunning) {
            # For Docker, we need to handle background execution differently
            $scriptBlock = {
                param($WorkflowId, $LogPath)
                docker exec -u node n8n execute --id $WorkflowId > $LogPath 2>&1
            }
            Start-Job -ScriptBlock $scriptBlock -ArgumentList $WorkflowId, $LogPath | Out-Null
        }
        else {
            Start-Process n8n -ArgumentList $cmd -WindowStyle Hidden -RedirectStandardOutput $LogPath -RedirectStandardError $LogPath
        }
        
        Write-Success "Background agent started"
        Write-Info "Monitor with: Get-Content -Path '$LogPath' -Wait"
    }
    else {
        Write-Info "Running workflow $WorkflowId..."
        
        if (![string]::IsNullOrEmpty($LogPath)) {
            Invoke-N8nCommand $cmd | Tee-Object -FilePath $LogPath
        }
        else {
            Invoke-N8nCommand $cmd
        }
        
        Write-Success "Workflow execution completed"
    }
}

# Main script execution
function Main {
    if ($Help) {
        Show-Usage
        return
    }
    
    # Handle special commands
    switch ($WorkflowId) {
        "list" {
            if (!(Test-N8nInstallation)) { exit 1 }
            Get-Workflows
            return
        }
        "status" {
            Show-Status
            return
        }
        "" {
            Show-Usage
            return
        }
    }
    
    # Execute workflow
    Import-EnvFile
    if (!(Test-N8nInstallation)) { exit 1 }
    Set-Provider $Provider $env:N8N_EXECUTION_MODE
    Start-WorkflowExecution -WorkflowId $WorkflowId -RunInBackground $Background -LogPath $LogFile
}

Main