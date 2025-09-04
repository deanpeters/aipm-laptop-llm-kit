# AIPM Laptop LLM Kit Uninstaller - Windows
# Removes services, configurations, and optionally data

param(
    [switch]$Force
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

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

function Write-Log {
    param($Message)
    Write-Host $Message
}

# Confirmation prompt
function Confirm-Action {
    param(
        [string]$Message,
        [bool]$DefaultYes = $false
    )
    
    if ($Force) {
        return $true
    }
    
    $prompt = if ($DefaultYes) { "$Message [Y/n]: " } else { "$Message [y/N]: " }
    $response = Read-Host $prompt
    
    if ($DefaultYes) {
        return $response -notmatch "^[Nn]$"
    } else {
        return $response -match "^[Yy]$"
    }
}

# Stop and remove Docker containers
function Remove-DockerServices {
    Write-Log "Stopping and removing Docker services..."
    
    try {
        Set-Location $ScriptDir
        
        # Stop services
        if (docker compose ps -q 2>$null) {
            docker compose down 2>$null
            Write-Success "Docker services stopped"
        }
        else {
            Write-Log "No running Docker services found"
        }
        
        # Remove volumes if confirmed
        if (Confirm-Action "Remove Docker volumes (this will delete all data)?" $false) {
            docker compose down -v 2>$null
            Write-Success "Docker volumes removed"
        }
        
        # Remove images if confirmed
        if (Confirm-Action "Remove Docker images?" $false) {
            $images = @(
                "mintplexlabs/anythingllm:latest",
                "n8nio/n8n:latest", 
                "zylonai/privategpt:latest",
                "langflowai/langflow:latest",
                "ghcr.io/open-webui/open-webui:main"
            )
            
            foreach ($image in $images) {
                try {
                    if (docker images -q $image 2>$null) {
                        docker rmi $image 2>$null
                    }
                }
                catch {
                    # Ignore errors for missing images
                }
            }
            Write-Success "Docker images removed"
        }
    }
    catch {
        Write-Warning-Custom "Some Docker cleanup operations failed (this is usually fine)"
    }
}

# Remove VS Code extensions
function Remove-VSCodeExtensions {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        if (Confirm-Action "Remove VS Code extensions (Cline, Continue.dev)?" $true) {
            try {
                code --uninstall-extension saoudrizwan.claude-dev 2>$null
                code --uninstall-extension Continue.continue 2>$null
                Write-Success "VS Code extensions removed"
            }
            catch {
                Write-Warning-Custom "Failed to remove some VS Code extensions"
            }
        }
    }
    else {
        Write-Log "VS Code not found, skipping extension removal"
    }
}

# Remove user environment variables
function Remove-UserEnvironment {
    Write-Log "Removing user environment variables..."
    
    $envVars = @(
        "LLM_BASE_URL",
        "ANYTHINGLLM_PORT",
        "N8N_PORT",
        "PRIVATEGPT_PORT",
        "LANGFLOW_PORT",
        "OLLAMA_WEBUI_PORT",
        "ANYTHINGLLM_STORAGE",
        "N8N_STORAGE",
        "SOV_STACK_HOME"
    )
    
    foreach ($var in $envVars) {
        try {
            [Environment]::SetEnvironmentVariable($var, $null, [EnvironmentVariableTarget]::User)
            Remove-Item -Path "env:$var" -ErrorAction SilentlyContinue
        }
        catch {
            # Ignore errors for variables that don't exist
        }
    }
    
    Write-Success "User environment variables removed"
    Write-Warning-Custom "Please restart PowerShell to clear session variables"
}

# Remove storage directories
function Remove-Storage {
    if (Confirm-Action "Remove storage directories (this will delete all data)?" $false) {
        $storageDir = Join-Path $ScriptDir "storage"
        if (Test-Path $storageDir) {
            try {
                Remove-Item -Path $storageDir -Recurse -Force
                Write-Success "Storage directories removed"
            }
            catch {
                Write-Warning-Custom "Failed to remove some storage directories"
            }
        }
    }
}

# Remove project files
function Remove-ProjectFiles {
    if (Confirm-Action "Remove configuration files (.env, logs)?" $true) {
        $filesToRemove = @(
            ".env",
            "install.log"
        )
        
        foreach ($file in $filesToRemove) {
            $fullPath = Join-Path $ScriptDir $file
            if (Test-Path $fullPath) {
                try {
                    Remove-Item -Path $fullPath -Force
                    Write-Success "Removed $file"
                }
                catch {
                    Write-Warning-Custom "Failed to remove $file"
                }
            }
        }
    }
}

# Show manual cleanup steps
function Show-ManualSteps {
    Write-Log ""
    Write-Warning-Custom "Manual cleanup steps (if needed):"
    Write-Log ""
    Write-Log "1. LM Studio (if installed manually):"
    Write-Log "   - Go to Settings > Apps > LM Studio > Uninstall"
    Write-Log "   - Or check: $env:LOCALAPPDATA\Programs\LM Studio"
    Write-Log ""
    Write-Log "2. Docker Desktop (if you want to remove it):"
    Write-Log "   - Go to Settings > Apps > Docker Desktop > Uninstall"
    Write-Log ""
    Write-Log "3. VS Code (if you want to remove it):"
    Write-Log "   - Go to Settings > Apps > Microsoft Visual Studio Code > Uninstall"
    Write-Log ""
    Write-Log "4. winget (if installed during setup):"
    Write-Log "   - Go to Settings > Apps > App Installer > Uninstall"
    Write-Log ""
}

# Main uninstall function
function Main {
    Write-Log "=== AIPM Laptop LLM Kit Uninstaller ==="
    Write-Log "This will remove services, configurations, and optionally data."
    Write-Log ""
    
    if (-not $Force -and -not (Confirm-Action "Continue with uninstallation?" $false)) {
        Write-Log "Uninstallation cancelled."
        exit 0
    }
    
    Write-Log ""
    Remove-DockerServices
    Remove-VSCodeExtensions  
    Remove-UserEnvironment
    Remove-Storage
    Remove-ProjectFiles
    
    Write-Log ""
    Write-Success "=== Uninstallation Complete ==="
    Write-Log ""
    Write-Warning-Custom "Please restart PowerShell to clear any remaining environment variables."
    Write-Log ""
    
    Show-ManualSteps
}

# Handle Ctrl+C
trap {
    Write-Host "`nUninstallation interrupted" -ForegroundColor Red
    exit 1
}

# Run main function
Main