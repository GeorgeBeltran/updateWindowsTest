# Create hidden folder if needed
if (-not (Test-Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
    attrib +s +h $folderPath
}
$scriptPath = Join-Path $folderPath $scriptName

# updateWindowsB.ps1 — Installs updates and reboots if needed
$logPath = "C:\ProgramData\MyScriptFolder\updateWindowsB_log.txt"

# Ensure log folder exists
$logDir = [System.IO.Path]::GetDirectoryName($logPath)
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Logging function
function Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logPath -Value "[$timestamp] $message"
}

Log "Starting Script B..."

# Install PSWindowsUpdate if missing
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    try {
        Install-PackageProvider -Name NuGet -Force -Scope AllUsers | Out-Null
        Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope AllUsers
        Log "Installed PSWindowsUpdate module."
    } catch {
        Log "Failed to install PSWindowsUpdate: $($_.Exception.Message)"
        exit 1
    }
} else {
    Log "PSWindowsUpdate module already installed."
}

Import-Module PSWindowsUpdate -Force
Log "Checking for available Windows Updates..."

# Get available updates
$updates = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot
if ($updates.Count -eq 0) {
    Log "No updates found. Skipping installation."
    exit 0
}

Log "Installing updates..."
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot | Out-Null

Log "Updates installed. Reboot will occur if required."
Log "Script B completed."
