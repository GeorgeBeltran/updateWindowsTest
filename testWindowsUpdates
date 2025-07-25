Add-Type -AssemblyName System.Windows.Forms

# Registry path for system-wide tracking
$regPath = "HKLM:\Software\windowsUpdateNotice"
$regName = "NotifyStage"

# Ensure the script is running elevated
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    [System.Windows.Forms.MessageBox]::Show("Script must be run as Administrator.", "Permission Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit 1
}

# Create or read NotifyStage from registry
try {
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    if (-not (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue)) {
        Set-ItemProperty -Path $regPath -Name $regName -Value 0
    }

    $stage = Get-ItemProperty -Path $regPath -Name $regName | Select-Object -ExpandProperty $regName
} catch {
    [System.Windows.Forms.MessageBox]::Show("Failed to access registry path $regPath.`n`n$_", "Registry Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit 1
}

# Install PSWindowsUpdate module if missing
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    try {
        Install-PackageProvider -Name NuGet -Force -Scope AllUsers
        Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope AllUsers
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to install PSWindowsUpdate module. Updates cannot proceed.`n`n$_", "Module Install Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit 1
    }
}

Import-Module PSWindowsUpdate

# Check for updates (skip this in testing if needed)
$pendingUpdates = Get-WindowsUpdate -AcceptAll -IgnoreReboot | Where-Object { $_.Title -ne $null }
if ($pendingUpdates.Count -eq 0) {
    Write-Host "No updates available."
    exit 0
}

# Notification logic
switch ($stage) {
    0 {
        $msg = "Windows updates are pending. Your system will reboot in 30 minutes to complete updates. Would you like to reboot now?"
        $response = [System.Windows.Forms.MessageBox]::Show($msg, "Windows Update Notification", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Information)

        if ($response -eq [System.Windows.Forms.DialogResult]::Yes) {
            Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose
        } else {
            Set-ItemProperty -Path $regPath -Name $regName -Value 1
        }
    }
    1 {
        $msg = "Reminder: Your system will reboot in 15 minutes to complete updates. Reboot now?"
        $response = [System.Windows.Forms.MessageBox]::Show($msg, "Windows Update Reminder", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)

        if ($response -eq [System.Windows.Forms.DialogResult]::Yes) {
            Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose
        } else {
            Set-ItemProperty -Path $regPath -Name $regName -Value 2
        }
    }
    2 {
        $msg = "FINAL REMINDER: System will reboot in 5 minutes. Click Yes to reboot now, or No to wait 5 minutes."
        $response = [System.Windows.Forms.MessageBox]::Show($msg, "Windows Update - Final Notice", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)

        if ($response -eq [System.Windows.Forms.DialogResult]::Yes) {
            Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose
        } else {
            Set-ItemProperty -Path $regPath -Name $regName -Value 3
        }
    }
    3 {
        Start-Sleep -Seconds 300  # 5-minute wait
        Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose
        Remove-Item -Path $regPath -Recurse -Force  # Reset for next round
    }
    default {
        Set-ItemProperty -Path $regPath -Name $regName -Value 0
    }
}
