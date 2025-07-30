# === updateWindowsB.ps1 ===

$logPath = "C:\ProgramData\MyScriptFolder\loggingB.txt"

# Ensure log directory exists
$logDir = [System.IO.Path]::GetDirectoryName($logPath)
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Start-Transcript -Path $logPath -Append | Out-Null

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$ts] $msg"
}

Log "🟢 Script B starting..."

# Show current user for verification
Log "Running as: $([Environment]::UserName)"

# Install PSWindowsUpdate if needed
try {
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Log "Installing PSWindowsUpdate..."
        Install-PackageProvider -Name NuGet -Force -Scope AllUsers -ErrorAction Stop
        Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope AllUsers -ErrorAction Stop
        Log "✅ PSWindowsUpdate installed."
    } else {
        Log "✔️ PSWindowsUpdate already available."
    }

    Import-Module PSWindowsUpdate -Force
    Log "📥 Module imported successfully."
} catch {
    Log "❌ Failed to install or import PSWindowsUpdate: $_"
    Stop-Transcript
    exit 1
}

# Check for and install updates
try {
    Log "🔍 Checking for available Windows Updates..."
    $updates = Get-WindowsUpdate -AcceptAll -IgnoreReboot

    if ($updates.Count -gt 0) {
        Log "🚀 Installing updates..."
        Install-WindowsUpdate -AcceptAll -AutoReboot -ErrorAction Stop
    } else {
        Log "✅ No updates found."
    }
} catch {
    Log "❌ Update process failed: $_"
}

Log "✅ Script B complete."
Stop-Transcript
