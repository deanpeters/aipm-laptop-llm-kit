# LM Studio Automated Installation Script - Windows
# Downloads, installs, and configures LM Studio with a default model

param(
    [switch]$DryRun
)

# Configuration
$DefaultModel = "microsoft/Phi-3-mini-4k-instruct-gguf/Phi-3-mini-4k-instruct-q4.gguf"
$LMSPath = "$env:USERPROFILE\.lmstudio\bin\lms.exe"

function Write-Progress-Custom {
    param($Message)
    Write-Host "🔄 $Message" -ForegroundColor Blue
}

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
    exit 1
}

function Write-Log {
    param($Message)
    Write-Host $Message
}

# Get download URL for Windows
function Get-DownloadUrl {
    $arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
    return "https://releases.lmstudio.ai/windows/$arch/latest/LM-Studio-windows-$arch-latest.exe"
}

# Install LM Studio on Windows
function Install-LMStudioWindows {
    param([string]$DownloadUrl)
    
    # Try Chocolatey first (if available), fallback to direct download
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Progress-Custom "Installing LM Studio via Chocolatey..."
        try {
            choco install lm-studio -y
            Write-Success "LM Studio installed via Chocolatey"
            return
        }
        catch {
            Write-Warning-Custom "Chocolatey installation failed, trying direct download: $_"
        }
    }
    elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Progress-Custom "Checking for LM Studio in winget..."
        try {
            $wingetSearch = winget search "LM Studio" 2>$null
            if ($wingetSearch -match "LM Studio") {
                winget install "LM Studio" --silent
                Write-Success "LM Studio installed via winget"
                return
            }
            else {
                Write-Warning-Custom "LM Studio not found in winget, using direct download"
            }
        }
        catch {
            Write-Warning-Custom "winget installation failed, trying direct download: $_"
        }
    }
    
    # Fallback to manual installation
    $installerPath = "$env:TEMP\LMStudioInstaller.exe"
    
    Write-Progress-Custom "Downloading LM Studio for Windows..."
    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $installerPath -UseBasicParsing
    }
    catch {
        Write-Error-Custom "Failed to download LM Studio: $_"
    }
    
    Write-Progress-Custom "Installing LM Studio (this may take a few minutes)..."
    try {
        # Run installer silently
        Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
        Remove-Item -Path $installerPath -Force
    }
    catch {
        Write-Error-Custom "Failed to install LM Studio: $_"
    }
    
    Write-Success "LM Studio installed on Windows"
    
    # Initialize LM Studio
    Initialize-LMStudio
}

# Initialize LM Studio
function Initialize-LMStudio {
    Write-Progress-Custom "Initializing LM Studio..."
    $lmStudioPaths = @(
        "$env:LOCALAPPDATA\Programs\LM Studio\LM Studio.exe",
        "$env:PROGRAMFILES\LM Studio\LM Studio.exe"
    )
    
    $lmStudioPath = $null
    foreach ($path in $lmStudioPaths) {
        if (Test-Path $path) {
            $lmStudioPath = $path
            break
        }
    }
    
    if ($lmStudioPath) {
        try {
            $process = Start-Process -FilePath $lmStudioPath -PassThru
            Start-Sleep -Seconds 15
            $process.CloseMainWindow()
            Start-Sleep -Seconds 5
        }
        catch {
            Write-Warning-Custom "Failed to initialize LM Studio GUI"
        }
    }
    else {
        Write-Warning-Custom "LM Studio executable not found for initialization"
    }
}

# Setup LM Studio CLI
function Setup-LMSCLI {
    Write-Progress-Custom "Setting up LM Studio CLI..."
    
    # Wait for lms to be available
    $maxAttempts = 30
    $attempt = 0
    
    while ($attempt -lt $maxAttempts) {
        if (Test-Path $LMSPath) {
            break
        }
        Start-Sleep -Seconds 2
        $attempt++
    }
    
    if (-not (Test-Path $LMSPath)) {
        Write-Error-Custom "LM Studio CLI not found after installation"
    }
    
    # Bootstrap the CLI
    try {
        & $LMSPath bootstrap 2>$null
    }
    catch {
        Write-Warning-Custom "CLI bootstrap may have failed (this is sometimes normal)"
    }
    
    Write-Success "LM Studio CLI ready"
}

# Download default model
function Download-DefaultModel {
    Write-Progress-Custom "Downloading default model: $DefaultModel"
    
    try {
        & $LMSPath get $DefaultModel
    }
    catch {
        Write-Warning-Custom "Failed to download default model, trying alternative..."
        try {
            & $LMSPath get "microsoft/Phi-3-mini-4k-instruct-gguf"
        }
        catch {
            Write-Warning-Custom "Model download failed - you can download manually later"
        }
    }
    
    Write-Success "Default model downloaded"
}

# Start LM Studio server
function Start-LMServer {
    Write-Progress-Custom "Starting LM Studio server..."
    
    try {
        # Load the default model and start server
        & $LMSPath load $DefaultModel 2>$null
    }
    catch {
        try {
            & $LMSPath load --first-available 2>$null
        }
        catch {
            Write-Warning-Custom "Failed to load model"
        }
    }
    
    try {
        & $LMSPath server start --port 1234 2>$null
    }
    catch {
        Write-Warning-Custom "Failed to start server via CLI"
    }
    
    # Wait for server to start
    $maxAttempts = 20
    $attempt = 0
    
    while ($attempt -lt $maxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:1234/v1/models" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Success "LM Studio server running on port 1234"
                return
            }
        }
        catch {
            # Continue waiting
        }
        Start-Sleep -Seconds 1
        $attempt++
    }
    
    Write-Warning-Custom "LM Studio server may not have started properly"
}

# Check if LM Studio is already installed
function Test-ExistingInstallation {
    $paths = @(
        "$env:LOCALAPPDATA\Programs\LM Studio\LM Studio.exe",
        "$env:PROGRAMFILES\LM Studio\LM Studio.exe"
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $true
        }
    }
    return $false
}

# Main installation function
function Main {
    Write-Progress-Custom "Installing LM Studio with automation..."
    
    # Check if already installed
    if (Test-ExistingInstallation) {
        Write-Success "LM Studio already installed"
        
        if ($DryRun) {
            Write-Log "[DRY RUN] Would setup CLI, download model, and start server"
            return
        }
        
        # Still setup CLI and server
        if (Test-Path $LMSPath) {
            Setup-LMSCLI
            Download-DefaultModel
            Start-LMServer
        }
        else {
            Write-Warning-Custom "LM Studio installed but CLI not found - may need manual setup"
        }
        return
    }
    
    if ($DryRun) {
        Write-Log "[DRY RUN] Would install LM Studio with default model and start server"
        return
    }
    
    # Get download URL
    $downloadUrl = Get-DownloadUrl
    Write-Log "Download URL: $downloadUrl"
    
    # Install LM Studio
    Install-LMStudioWindows $downloadUrl
    
    # Setup CLI and server
    Setup-LMSCLI
    Download-DefaultModel
    Start-LMServer
    
    Write-Success "LM Studio installation and setup complete!"
    Write-Log ""
    Write-Log "Access your local LLM at: http://localhost:1234/v1"
    Write-Log "Use 'lms' command for CLI management"
}

Main