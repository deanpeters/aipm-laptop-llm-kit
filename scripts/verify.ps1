# Verification Script for AIPM Laptop LLM Kit - Windows
# Checks that all services are running and accessible

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Split-Path -Parent $ScriptDir

# Counters
$ChecksPassed = 0
$ChecksFailed = 0
$TotalChecks = 0

function Write-Success {
    param($Message)
    Write-Host "✅ $Message" -ForegroundColor Green
    $script:ChecksPassed++
}

function Write-Failure {
    param($Message)
    Write-Host "❌ $Message" -ForegroundColor Red
    $script:ChecksFailed++
}

function Write-Warning-Custom {
    param($Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Info {
    param($Message)
    Write-Host "ℹ️ $Message" -ForegroundColor Blue
}

function Write-Log {
    param($Message)
    Write-Host $Message
}

# Test if a URL is accessible
function Test-Url {
    param(
        [string]$Url,
        [string]$Service,
        [int]$TimeoutSeconds = 10
    )
    
    $script:TotalChecks++
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec $TimeoutSeconds -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Success "$Service is accessible at $Url"
            return $true
        }
    }
    catch {
        Write-Failure "$Service is not accessible at $Url"
        return $false
    }
}

# Test if a port is listening
function Test-Port {
    param(
        [int]$Port,
        [string]$Service
    )
    
    $script:TotalChecks++
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("localhost", $Port)
        $connection.Close()
        Write-Success "$Service is listening on port $Port"
        return $true
    }
    catch {
        Write-Failure "$Service is not listening on port $Port"
        return $false
    }
}

# Check command availability
function Test-Command {
    param(
        [string]$Command,
        [string]$Description
    )
    
    $script:TotalChecks++
    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Success "$Description is installed"
        return $true
    }
    else {
        Write-Failure "$Description is not installed"
        return $false
    }
}

# Check Docker service
function Test-DockerService {
    param(
        [string]$ContainerName
    )
    
    $script:TotalChecks++
    try {
        $containers = docker ps --format "table {{.Names}}" 2>$null
        if ($containers -contains $ContainerName) {
            Write-Success "Docker container '$ContainerName' is running"
            return $true
        }
        else {
            Write-Failure "Docker container '$ContainerName' is not running"
            return $false
        }
    }
    catch {
        Write-Failure "Failed to check Docker container '$ContainerName'"
        return $false
    }
}

# Check VS Code extension
function Test-VSCodeExtension {
    param(
        [string]$ExtensionId,
        [string]$ExtensionName
    )
    
    $script:TotalChecks++
    if (Get-Command code -ErrorAction SilentlyContinue) {
        try {
            $extensions = code --list-extensions 2>$null
            if ($extensions -contains $ExtensionId) {
                Write-Success "VS Code extension '$ExtensionName' is installed"
                return $true
            }
            else {
                Write-Failure "VS Code extension '$ExtensionName' is not installed"
                return $false
            }
        }
        catch {
            Write-Failure "Failed to check VS Code extensions"
            return $false
        }
    }
    else {
        Write-Failure "VS Code is not available to check extensions"
        return $false
    }
}

# Load environment variables
function Import-Environment {
    $envFile = Join-Path $ProjectRoot ".env"
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            if ($_ -match '^([^#][^=]*)=(.*)$') {
                $name = $matches[1].Trim()
                $value = $matches[2].Trim()
                $value = $value -replace '^["\']|["\']$', ''
                Set-Item -Path "env:$name" -Value $value -Force
            }
        }
        Write-Info "Loaded environment from .env"
    }
    
    # Set defaults
    if (-not $env:LLM_BASE_URL) { $env:LLM_BASE_URL = "http://localhost:1234/v1" }
    if (-not $env:ANYTHINGLLM_PORT) { $env:ANYTHINGLLM_PORT = "3001" }
    if (-not $env:N8N_PORT) { $env:N8N_PORT = "5678" }
}

# Print environment info
function Show-Environment {
    Write-Log ""
    Write-Log "=== Environment Configuration ==="
    Write-Log "LLM_BASE_URL: $env:LLM_BASE_URL"
    Write-Log "ANYTHINGLLM_PORT: $env:ANYTHINGLLM_PORT"
    Write-Log "N8N_PORT: $env:N8N_PORT"
    Write-Log "SOV_STACK_HOME: $($env:SOV_STACK_HOME -or $ProjectRoot)"
    Write-Log ""
}

# Check basic tools
function Test-BasicTools {
    Write-Log "=== Checking Basic Tools ==="
    Test-Command "docker" "Docker"
    Test-Command "code" "VS Code CLI"
    Write-Log ""
}

# Check LM Studio
function Test-LMStudio {
    Write-Log "=== Checking LM Studio ==="
    
    $script:TotalChecks++
    $lmStudioPath = "$env:LOCALAPPDATA\Programs\LM Studio\LM Studio.exe"
    if (Test-Path $lmStudioPath) {
        Write-Success "LM Studio is installed"
    }
    else {
        Write-Failure "LM Studio not found at expected location"
    }
    
    # Test LM Studio API
    Test-Url "$env:LLM_BASE_URL/models" "LM Studio API" 5
    Write-Log ""
}

# Check VS Code extensions
function Test-VSCodeExtensions {
    Write-Log "=== Checking VS Code Extensions ==="
    Test-VSCodeExtension "saoudrizwan.claude-dev" "Cline"
    Test-VSCodeExtension "Continue.continue" "Continue.dev"
    Write-Log ""
}

# Check Docker services
function Test-DockerServices {
    Write-Log "=== Checking Docker Services ==="
    
    # Check if Docker is running
    $script:TotalChecks++
    try {
        docker info 2>$null | Out-Null
        Write-Success "Docker daemon is running"
    }
    catch {
        Write-Failure "Docker daemon is not running"
        Write-Warning-Custom "Start Docker Desktop and try again"
        return
    }
    
    Test-DockerService "anythingllm"
    Test-DockerService "n8n"
    Write-Log ""
}

# Check web services
function Test-WebServices {
    Write-Log "=== Checking Web Services ==="
    Test-Url "http://localhost:$env:ANYTHINGLLM_PORT" "AnythingLLM"
    Test-Url "http://localhost:$env:N8N_PORT" "n8n"
    Write-Log ""
}

# Check storage directories
function Test-Storage {
    Write-Log "=== Checking Storage Directories ==="
    $storageDirs = @(
        "$ProjectRoot\storage\anythingllm",
        "$ProjectRoot\storage\n8n"
    )
    
    foreach ($dir in $storageDirs) {
        $script:TotalChecks++
        if (Test-Path $dir) {
            Write-Success "Storage directory exists: $dir"
        }
        else {
            Write-Failure "Storage directory missing: $dir"
        }
    }
    Write-Log ""
}

# Print next steps
function Show-NextSteps {
    Write-Log "=== Next Steps ==="
    Write-Log ""
    
    if ($ChecksFailed -eq 0) {
        Write-Success "All checks passed! Your AIPM Laptop LLM Kit is ready to use."
        Write-Log ""
        Write-Log "Quick start:"
        Write-Log "1. Open VS Code: code ."
        Write-Log "2. Press Ctrl+Shift+P"
        Write-Log "3. Type 'Cline: Start Cline' to begin coding with AI"
        Write-Log "4. Visit AnythingLLM: http://localhost:$env:ANYTHINGLLM_PORT"
        Write-Log "5. Visit n8n: http://localhost:$env:N8N_PORT"
    }
    else {
        Write-Warning-Custom "Some checks failed. Common fixes:"
        Write-Log ""
        
        if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
            Write-Log "• Install Docker Desktop and start it"
        }
        
        try {
            docker info 2>$null | Out-Null
        }
        catch {
            Write-Log "• Start Docker Desktop"
        }
        
        if (!(docker ps 2>$null | Select-String "anythingllm|n8n")) {
            Write-Log "• Start services: docker compose up -d"
        }
        
        if (!(Get-Command code -ErrorAction SilentlyContinue)) {
            Write-Log "• Install VS Code or add it to PATH"
        }
        
        try {
            Invoke-WebRequest -Uri "$env:LLM_BASE_URL/models" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Log "• Start LM Studio and enable local server (port 1234)"
        }
        
        Write-Log ""
        Write-Log "For more help, see README.md"
    }
}

# Print summary
function Show-Summary {
    Write-Log ""
    Write-Log "=== Verification Summary ==="
    Write-Log "Total checks: $TotalChecks"
    Write-Success "Passed: $ChecksPassed"
    
    if ($ChecksFailed -gt 0) {
        Write-Failure "Failed: $ChecksFailed"
    }
    
    Write-Log ""
}

# Main verification function
function Main {
    Write-Log "=== AIPM Laptop LLM Kit Verification ==="
    Write-Log "Timestamp: $(Get-Date)"
    Write-Log ""
    
    Import-Environment
    Show-Environment
    Test-BasicTools
    Test-LMStudio
    Test-VSCodeExtensions
    Test-DockerServices
    Test-WebServices
    Test-Storage
    Show-NextSteps
    Show-Summary
    
    # Exit with appropriate code
    if ($ChecksFailed -gt 0) {
        exit 1
    }
    else {
        exit 0
    }
}

Main