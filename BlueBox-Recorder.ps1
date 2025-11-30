<#
    BlueBox v0.1 – "First Flight"
    The Computer Black Box – Records what happened BEFORE the crash
    Author & Inventor: Ghass (غسان)
    First public release: November 30, 2025
    License: MIT (you own it completely)
#>

# === CONFIGURATION ===
$BufferMinutes = 30                    # How many minutes we keep
$BufferFolder  = "$env:USERPROFILE\BlueBoxBuffer"
$FinalReport   = "$env:Desktop\BLUEBOX_INCIDENT_$(Get-Date -Format yyyy-MM-dd_HH-mm-ss).zip"
$LogFile       = "$BufferFolder\BlueBox.log"

# Create buffer folder
if (!(Test-Path $BufferFolder)) { New-Item -ItemType Directory -Path $BufferFolder -Force | Out-Null }

# Ring buffer cleanup (keep only last X minutes)
function Clean-OldLogs {
    $cutoff = (Get-Date).AddMinutes(-$BufferMinutes)
    Get-ChildItem $BufferFolder -Recurse | Where-Object {$_.LastWriteTime -lt $cutoff} | Remove-Item -Force -ErrorAction SilentlyContinue
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Main logging loop – runs forever
while ($true) {
    $now = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    
    # 1. System events (last 2 minutes)
    Get-WinEvent -LogName System -MaxEvents 500 -ErrorAction SilentlyContinue | 
        Where-Object {$_.TimeCreated -gt (Get-Date).AddMinutes(-2)} | 
        ConvertTo-Json -Depth 3 -Compress | Out-File "$BufferFolder\events_$now.json" -Force

    # 2. Running processes + CPU/RAM spikes
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 50 | 
        ConvertTo-Json -Compress | Out-File "$BufferFolder\processes_$now.json" -Force

    # 3. Network connections
    Get-NetTCPConnection | Where-Object {$_.State -eq "Established"} | 
        ConvertTo-Json -Compress | Out-File "$BufferFolder\net_$now.json" -Force

    # 4. PowerShell/command history
    Get-History -Count 50 | ConvertTo-Json -Compress | Out-File "$BufferFolder\history_$now.json" -Force

    # 5. Screenshot every 30 seconds (killer feature)
    $bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bmp = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($bounds.Left, $bounds.Top, 0, 0, $bounds.Size)
    $bmp.Save("$BufferFolder\screen_$now.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $graphics.Dispose()

    # Clean old files + heartbeat
    Clean-OldLogs
    "$now - BlueBox heartbeat – buffer active" | Out-File $LogFile -Append

    Start-Sleep -Seconds 30
}
