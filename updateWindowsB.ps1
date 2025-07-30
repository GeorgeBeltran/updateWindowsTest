# === Script B: Run Updates and Restart (SYSTEM) ===

# Ensure unrestricted script execution
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

$scriptFolder  = "C:\ProgramData\MyScriptFolder"
$logFile       = "$scriptFolder\updateLog.txt"
$enableCleanup = $true  # Set to $false to preserve registry/scripts

# Ensure log directory exists
if (-not (Test-Path $scriptFolder)) {
    New-Item -Path $scriptFolder -ItemType Directory -Force | Out-Null
}

# Logging helper
function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $formatted = "[$timestamp] $msg"
    Write-Output $formatted
    Add-Content -Path $logFile -Value $formatted
}

Log "🟢 Script B starting."

# Ensure NuGet provider is available
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Log "📦 Installing NuGet provider..."
    try {
        Install-PackageProvider -Name NuGet -Force -Scope AllUsers -ErrorAction Stop
        Log "✅ NuGet provider installed."
    } catch {
        Log "❌ Failed to install NuGet provider: $($_.Exception.Message)"
    }
} else {
    Log "✔️ NuGet provider already available."
}

# Ensure PSWindowsUpdate module is installed
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Log "⬇️ Installing PSWindowsUpdate module..."
    try {
        Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope AllUsers -ErrorAction Stop
        Log "✅ PSWindowsUpdate module installed."
    } catch {
        Log "❌ Failed to install PSWindowsUpdate: $($_.Exception.Message)"
        exit 1
    }
} else {
    Log "✔️ PSWindowsUpdate module already installed."
}

# Import module
try {
    Import-Module PSWindowsUpdate -Force -ErrorAction Stop
    Log "📚 PSWindowsUpdate module imported successfully."
} catch {
    Log "❌ Failed to import PSWindowsUpdate: $($_.Exception.Message)"
    exit 1
}

# Check for updates
Log "🔍 Checking for available Windows Updates..."
$updates = Get-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue

if ($updates -and $updates.Count -gt 0) {
    Log "🚀 Installing $($updates.Count) update(s)..."
    try {
        Install-WindowsUpdate -AcceptAll -AutoReboot -ErrorAction Stop | ForEach-Object {
            Log "⬆️ Installed: $($_.Title)"
        }
    } catch {
        Log "❌ Update installation failed: $($_.Exception.Message)"
        exit 1
    }
} else {
    Log "✅ No updates found. Skipping installation."
}

Log "Script B completed successfully."
