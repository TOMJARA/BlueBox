# BlueBox.ps1 - IT Black Box Logger by Ghass.Ka7
# Inspired by aircraft black boxes: Logs system crashes on every startup for diagnostics.
# Version 1.0 - Free and Open Source (MIT License)
# Runs silently, emails alerts on crashes. Install on repaired devices.

param([switch]$Install, [switch]$Uninstall, [switch]$TestCrash)

# Config - Customize these
$LogPath = "$env:APPDATA\BlueBox"
$LogFile = "$$ LogPath\bluebox_log_ $$(Get-Date -Format 'yyyy-MM-dd').txt"
$EmailTo = "yourlab@email.com"  # Your email for alerts
$SMTPServer = "smtp.gmail.com"  # Or your SMTP server
$SMTPFrom = "bluebox@lab.com"
$SMTPPass = "your-app-password"  # Secure app password (not plain email pass)

# Ensure log directory exists
if (!(Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null }

# Function to log a crash event
function Log-Crash {
    param($Event)
    $$ entry = " $$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Bugcheck: $($Event.Id) | Fault: $($Event.Message.Split("`n")[0]) | Source: $($Event.Source) | Device: $env:COMPUTERNAME"
    Add-Content -Path $LogFile -Value $entry
    # Optional Email Alert (if configured)
    if ($EmailTo -and $SMTPServer -and $SMTPPass) {
        try {
            $cred = New-Object PSCredential $SMTPFrom, (ConvertTo-SecureString $SMTPPass -AsPlainText -Force)
            Send-MailMessage -To $EmailTo -From $SMTPFrom -Subject "BlueBox Alert: Crash on $env:COMPUTERNAME" -Body $entry -SmtpServer $SMTPServer -Credential $cred -UseSsl -ErrorAction Stop
        } catch {
            Add-Content -Path $$ LogFile -Value " $$(Get-Date) - Email alert failed: $_"
        }
    }
}

if ($Install) {
    # Install as Scheduled Task (runs on startup as SYSTEM)
    $TaskName = "BlueBox-IT-Logger"
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"$PSScriptRoot\BlueBox.ps1`""
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Force | Out-Null
    Add-Content -Path $$ LogFile -Value " $$(Get-Date) - BlueBox V1.0 installed by Ghass on $env:COMPUTERNAME"
    # Optional: Add uninstall shortcut on desktop
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:Public\Desktop\Remove BlueBox.lnk")
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-Command `"& '$PSScriptRoot\BlueBox.ps1' -Uninstall`""
    $Shortcut.Save()
    Write-Host "BlueBox installed. Logs crashes on every startup. Uninstall via desktop shortcut."
} elseif ($Uninstall) {
    Unregister-ScheduledTask -TaskName "BlueBox-IT-Logger" -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item $LogPath -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:Public\Desktop\Remove BlueBox.lnk" -ErrorAction SilentlyContinue
    Write-Host "BlueBox uninstalled and logs cleaned."
} elseif ($TestCrash) {
    # Simulate a log entry for testing
    Log-Crash @{Id=0xA; Message="Test kernel fault (IRQL)"; Source="ntoskrnl.exe"}
    Write-Host "Test log created in $LogFile"
} else {
    # Normal Startup Run: Check for recent crashes (last 24 hours)
    $Events = Get-WinEvent -FilterHashtable @{LogName='System'; ID=1001,6008,41; StartTime=(Get-Date).AddHours(-24)} -ErrorAction SilentlyContinue | Where-Object {$_.Message -match 'bugcheck|unexpected shutdown'}
    if ($Events) {
        foreach ($Event in $Events) { Log-Crash $Event }
    } else {
        Add-Content -Path $$ LogFile -Value " $$(Get-Date) - System stable, no crashes detected."
    }
}

# Future V2 Stub: Add PDF reports, cloud sync, etc.
## Pasta /legacy
Arquivos de simulação antiga (testes de BSOD de Dec 2025) – ignore para instalação real. Use apenas BlueBox.ps1 no root.

## Notas Importantes
- BlueBox.ps1: Verifique sintaxe antes de usar (possíveis erros de chaves em funções).
- Ícone Customizado: Para bandeja, baixe de /legacy/7.pig se aplicável.
# For now, V1 is free and ready!
