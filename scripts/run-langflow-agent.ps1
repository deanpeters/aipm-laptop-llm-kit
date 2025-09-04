# AIPM Laptop LLM Kit - LangFlow CLI Agent Runner for Windows PowerShell
# Run LangFlow flows as standalone agents with local LLM support
#
# Usage: 
#   .\run-langflow-agent.ps1 <FLOW_ID>                    # Run once and exit
#   .\run-langflow-agent.ps1 <FLOW_ID> -Background       # Run in background
#   .\run-langflow-agent.ps1 <FLOW_ID> -Provider ollama  # Use Ollama instead of LM Studio
#   .\run-langflow-agent.ps1 <FLOW_ID> -Input "text"     # Custom input text
#   .\run-langflow-agent.ps1 list                        # List available flows

param(
    [Parameter(Position=0)]
    [string]$FlowId,
    
    [switch]$Background,
    
    [ValidateSet("lmstudio", "ollama")]
    [string]$Provider = "lmstudio",
    
    [string]$Input = "run agent",
    
    [string]$Tweaks = "{}",
    
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
AIMP LangFlow CLI Agent Runner for Windows
Run LangFlow flows as standalone agents with local LLM support

Usage:
  .\run-langflow-agent.ps1 <FLOW_ID>                    Run flow once and exit
  .\run-langflow-agent.ps1 <FLOW_ID> -Background       Run flow in background  
  .\run-langflow-agent.ps1 <FLOW_ID> -Provider ollama  Use Ollama instead of LM Studio
  .\run-langflow-agent.ps1 <FLOW_ID> -Input "text"     Custom input text for the flow
  .\run-langflow-agent.ps1 <FLOW_ID> -LogFile <file>   Save output to specific log file
  .\run-langflow-agent.ps1 list                        List all available flows
  .\run-langflow-agent.ps1 status                      Show LangFlow server status

Examples:
  .\run-langflow-agent.ps1 123e4567-e89b-12d3-a456-426614174000
  .\run-langflow-agent.ps1 my-flow-id -Background -Provider ollama -Input "Generate user story"
  .\run-langflow-agent.ps1 my-flow-id -Tweaks '{"temperature":0.8,"max_tokens":500}'

Environment Variables (set automatically):
  LLM_BASE_URL, LLM_API_KEY, LLM_MODEL_NAME    (LM Studio)
  OLLAMA_BASE_URL, OLLAMA_API_KEY, OLLAMA_MODEL_NAME (Ollama)
  LANGFLOW_API_KEY (if API key authentication is enabled)

Notes:
  - Flow ID can be found in LangFlow UI: Share → API access
  - Background agents log to ~/aipm-langflow-agents/<flow-id>.log
  - LangFlow must be running on http://localhost:7860 (default)
  - Use Docker networking URLs if LangFlow is containerized
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
                # Docker LangFlow -> use host.docker.internal
                $env:LLM_BASE_URL = if ($env:LLM_DOCKER_URL) { $env:LLM_DOCKER_URL } else { "http://host.docker.internal:1234/v1" }
                Write-Info "Using LM Studio provider for Docker LangFlow ($($env:LLM_BASE_URL))"
            } else {
                # CLI LangFlow -> use localhost
                $env:LLM_BASE_URL = if ($env:LLM_BASE_URL) { $env:LLM_BASE_URL } else { "http://localhost:1234/v1" }
                Write-Info "Using LM Studio provider for CLI LangFlow ($($env:LLM_BASE_URL))"
            }
            $env:LLM_API_KEY = if ($env:LLM_API_KEY) { $env:LLM_API_KEY } else { "local-lmstudio-key" }
            $env:LLM_MODEL_NAME = if ($env:LLM_MODEL_NAME) { $env:LLM_MODEL_NAME } else { "phi-3-mini-4k-instruct" }
        }
        "ollama" {
            if ($ExecutionMode -eq "docker") {
                # Docker LangFlow -> use host.docker.internal
                $env:OLLAMA_BASE_URL = if ($env:OLLAMA_DOCKER_URL) { $env:OLLAMA_DOCKER_URL } else { "http://host.docker.internal:11434/v1" }
                Write-Info "Using Ollama provider for Docker LangFlow ($($env:OLLAMA_BASE_URL))"
            } else {
                # CLI LangFlow -> use localhost
                $env:OLLAMA_BASE_URL = if ($env:OLLAMA_BASE_URL) { $env:OLLAMA_BASE_URL } else { "http://localhost:11434/v1" }
                Write-Info "Using Ollama provider for CLI LangFlow ($($env:OLLAMA_BASE_URL))"
            }
            $env:OLLAMA_API_KEY = if ($env:OLLAMA_API_KEY) { $env:OLLAMA_API_KEY } else { "local-ollama-key" }
            $env:OLLAMA_MODEL_NAME = if ($env:OLLAMA_MODEL_NAME) { $env:OLLAMA_MODEL_NAME } else { "phi4-mini:latest" }
        }
        default {
            Write-Error-Custom "Unknown provider: $ProviderName. Use 'lmstudio' or 'ollama'"
            exit 1
        }
    }
}

function Test-LangFlowInstallation {
    # Check if LangFlow is available via Docker first (our default setup)
    $dockerRunning = docker ps 2>$null | Select-String "langflow"
    if ($dockerRunning) {
        Write-Info "Found LangFlow running in Docker container"
        $env:LANGFLOW_EXECUTION_MODE = "docker"
        $env:LANGFLOW_URL = "http://localhost:7860/api"
        return $true
    }
    
    # Check if LangFlow server is running locally
    try {
        $healthCheck = Invoke-RestMethod -Uri "http://localhost:7860/health" -TimeoutSec 5 -ErrorAction SilentlyContinue
        Write-Info "Found LangFlow server running on localhost:7860"
        $env:LANGFLOW_EXECUTION_MODE = "cli"
        $env:LANGFLOW_URL = "http://localhost:7860/api"
        return $true
    } catch {
        # Server not responding
    }
    
    # Check if langflow CLI is available
    $langflowCli = Get-Command langflow -ErrorAction SilentlyContinue
    if ($langflowCli) {
        Write-Warning-Custom "LangFlow CLI available but server not running"
        Write-Info "Start with: langflow run --host 0.0.0.0 --port 7860"
        $env:LANGFLOW_EXECUTION_MODE = "cli"
        $env:LANGFLOW_URL = "http://localhost:7860/api"
        return $false
    }
    
    Write-Error-Custom "LangFlow not found or not running!"
    Write-Host ""
    Write-Host "To use with Docker (recommended):"
    Write-Host "  docker compose --profile optional up -d langflow"
    Write-Host ""
    Write-Host "To install LangFlow CLI:"
    Write-Host "  pip install langflow"
    Write-Host "  langflow run --host 0.0.0.0 --port 7860"
    return $false
}

function Show-LangFlowStatus {
    Write-Info "Checking LangFlow server status..."
    
    # Check Docker container
    $dockerRunning = docker ps 2>$null | Select-String "langflow"
    if ($dockerRunning) {
        Write-Info "LangFlow Docker container is running"
        docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}" | Select-String "langflow"
    }
    
    # Check local server
    try {
        $healthCheck = Invoke-RestMethod -Uri "http://localhost:7860/health" -TimeoutSec 5 -ErrorAction SilentlyContinue
        $version = try { 
            $versionInfo = Invoke-RestMethod -Uri "http://localhost:7860/api/v1/version" -TimeoutSec 5 -ErrorAction SilentlyContinue
            $versionInfo.version
        } catch { "unknown" }
        
        Write-Success "LangFlow server is running on http://localhost:7860"
        Write-Info "Version: $version"
    } catch {
        Write-Warning-Custom "LangFlow server not responding on http://localhost:7860"
    }
    
    # Check for background agents
    $logDir = Join-Path $env:USERPROFILE "aipm-langflow-agents"
    if (Test-Path $logDir) {
        $logFiles = Get-ChildItem -Path $logDir -Filter "*.log" -ErrorAction SilentlyContinue
        if ($logFiles) {
            Write-Info "Found $($logFiles.Count) LangFlow agent log files in $logDir"
            $logFiles | Format-Table Name, LastWriteTime, Length
        } else {
            Write-Info "No background agent activity found"
        }
    } else {
        Write-Info "No background agents directory found"
    }
}

function Get-Flows {
    Write-Info "Attempting to list available flows..."
    
    try {
        $flowsResponse = Invoke-RestMethod -Uri "$env:LANGFLOW_URL/v1/flows" -TimeoutSec 10 -ErrorAction SilentlyContinue
        if ($flowsResponse.flows) {
            $flowsResponse.flows | ForEach-Object { "$($_.id): $($_.name)" }
        } else {
            Write-Warning-Custom "No flows found or API endpoint not available"
        }
    } catch {
        Write-Warning-Custom "Unable to list flows via API"
        Write-Info "To find your Flow ID:"
        Write-Host "1. Open LangFlow UI at http://localhost:7860"
        Write-Host "2. Open your flow"
        Write-Host "3. Click Share → API access"
        Write-Host "4. Copy the Flow ID from the generated code"
    }
}

function Start-FlowExecution {
    param(
        [string]$FlowId,
        [bool]$RunInBackground,
        [string]$InputText,
        [string]$TweaksJson,
        [string]$LogPath
    )
    
    if ([string]::IsNullOrEmpty($FlowId)) {
        Write-Error-Custom "Flow ID is required"
        Show-Usage
        exit 1
    }
    
    # Set up logging
    $logDir = Join-Path $env:USERPROFILE "aipm-langflow-agents"
    if ($RunInBackground -or ![string]::IsNullOrEmpty($LogPath)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        if ([string]::IsNullOrEmpty($LogPath)) {
            $LogPath = Join-Path $logDir "$FlowId.log"
        }
    }
    
    # Prepare API request
    $apiUrl = "$env:LANGFLOW_URL/v1/run/$FlowId" + "?stream=false"
    $headers = @{ "Content-Type" = "application/json" }
    
    if ($env:LANGFLOW_API_KEY) {
        $headers["x-api-key"] = $env:LANGFLOW_API_KEY
    }
    
    # Prepare request body
    $tweaksObject = $TweaksJson | ConvertFrom-Json -ErrorAction SilentlyContinue
    if (-not $tweaksObject) {
        $tweaksObject = @{}
    }
    
    $requestBody = @{
        input_value = $InputText
        input_type = "chat"
        output_type = "chat"
        tweaks = $tweaksObject
    } | ConvertTo-Json -Depth 10
    
    if ($RunInBackground) {
        Write-Info "Running LangFlow agent $FlowId in background..."
        Write-Info "Input: $InputText"
        Write-Info "Log file: $LogPath"
        
        # Run in background using Start-Job
        $scriptBlock = {
            param($ApiUrl, $Headers, $Body, $LogPath)
            try {
                $response = Invoke-RestMethod -Uri $ApiUrl -Method POST -Headers $Headers -Body $Body
                $response | ConvertTo-Json -Depth 10 | Out-File -FilePath $LogPath -Encoding UTF8
            } catch {
                $_.Exception.Message | Out-File -FilePath $LogPath -Encoding UTF8
            }
        }
        
        $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $apiUrl, $headers, $requestBody, $LogPath
        Write-Success "Background agent started (Job ID: $($job.Id))"
        Write-Info "Monitor with: Get-Content -Path '$LogPath' -Wait"
    } else {
        Write-Info "Running LangFlow agent $FlowId..."
        Write-Info "Input: $InputText"
        
        try {
            $response = Invoke-RestMethod -Uri $apiUrl -Method POST -Headers $headers -Body $requestBody
            
            if (![string]::IsNullOrEmpty($LogPath)) {
                $response | ConvertTo-Json -Depth 10 | Out-File -FilePath $LogPath -Encoding UTF8
            }
            
            # Pretty print JSON response
            $response | ConvertTo-Json -Depth 10
            
            Write-Success "Flow execution completed"
        } catch {
            Write-Error-Custom "Flow execution failed: $($_.Exception.Message)"
            if (![string]::IsNullOrEmpty($LogPath)) {
                $_.Exception.Message | Out-File -FilePath $LogPath -Encoding UTF8
            }
        }
    }
}

# Main script execution
function Main {
    if ($Help) {
        Show-Usage
        return
    }
    
    # Handle special commands
    switch ($FlowId) {
        "list" {
            if (!(Test-LangFlowInstallation)) { exit 1 }
            Get-Flows
            return
        }
        "status" {
            Show-LangFlowStatus
            return
        }
        "" {
            Show-Usage
            return
        }
    }
    
    # Execute flow
    Import-EnvFile
    if (!(Test-LangFlowInstallation)) { exit 1 }
    Set-Provider $Provider $env:LANGFLOW_EXECUTION_MODE
    Start-FlowExecution -FlowId $FlowId -RunInBackground $Background -InputText $Input -TweaksJson $Tweaks -LogPath $LogFile
}

Main