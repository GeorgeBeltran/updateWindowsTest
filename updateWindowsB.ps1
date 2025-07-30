# === Script B: Run Updates and Restart (SYSTEM) ===

Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

$scriptFolder = "C:\ProgramData\MyScriptFolder"
$logFile = Join-Path $scriptFolder "updateWindowsB.log"
$enableCleanup = $true

if (-not (Test-Path $scriptFolder)) {
    New-Item -ItemType Directory -Path $scriptFolder -Force | Out-Null
}

function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $msg"
    Add-Content -Path $logFile -Value $entry
    Write-Output $entry
}

Log "Starting Script B..."

if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Log "Installing NuGet provider..."
    Install-PackageProvider -Name NuGet -Force -Scope AllUsers -ErrorAction SilentlyContinue
}

if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Log "Installing PSWindowsUpdate module..."
    try {
        Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope AllUsers -ErrorAction Stop
        Log "PSWindowsUpdate module installed."
    } catch {
        Log "Failed to install PSWindowsUpdate: $($_.Exception.Message)"
        exit 1
    }
} else {
    Log "PSWindowsUpdate module already installed."
}

Import-Module PSWindowsUpdate -Force -ErrorAction Stop

Log "Checking for available Windows Updates..."
$updates = Get-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue

if ($updates -and $updates.Count -gt 0) {
    Log "Installing updates..."
    Install-WindowsUpdate -AcceptAll -AutoReboot -ErrorAction SilentlyContinue
} else {
    Log "No updates found. Skipping installation."
}

Log "Script B completed."
