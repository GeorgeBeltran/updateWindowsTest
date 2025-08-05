param (
    [string]$folderPath = "C:\ProgramData\MyScriptFolder"
)

# Create hidden folder if needed
if (-not (Test-Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
    attrib +s +h $folderPath
}

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
log "Checking for updates..."
$updates = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll

if ($updates.Count -eq 0) {
    log "No updates available."
} else {
    log "Updates found:"
    foreach ($update in $updates) {
        log " - $($update.Title)"
    }

    log "Installing updates..."
    try {
        Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -Verbose -ErrorAction Stop | Out-Null
        log "Update installation complete. Reboot may be required."
    } catch {
        log "Error during update installation: $($_.Exception.Message)"
        exit 1
    }
}

log "Script B completed."
