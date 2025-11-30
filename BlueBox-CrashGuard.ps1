<#
    BlueBox CrashGuard v0.1
    Detects BSOD / unexpected reboot and freezes the buffer
    Part of BlueBox by Ghass – November 30, 2025
#>

$BufferFolder = "$env:USERPROFILE\BlueBoxBuffer"

Write-Host "BlueBox CrashGuard is now ACTIVE" -ForegroundColor Cyan
Write-Host "Your computer now has a real Black Box. Waiting for any incident..." -ForegroundColor Green

# This event fires right after an unexpected shutdown/reboot (including most BSODs)
$Query = "SELECT * FROM Win32_PowerManagementEvent WHERE EventType = 11 OR EventType = 18"

Register-WmiEvent -Query $Query -Action {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - CRITICAL FAILURE DETECTED! Freezing BlueBox buffer..." | Out-File "$using:BufferFolder\!!!CRASH_DETECTED!!!.txt" -Append

    $zipPath = "$env:Desktop\BLUEBOX_INCIDENT_$(Get-Date -Format yyyy-MM-dd_HH-mm-ss).zip"
    Compress-Archive -Path "$using:BufferFolder\*" -DestinationPath $zipPath -Force

    Write-Host "BLUEBOX SAVED!" -ForegroundColor Red
    Write-Host "Pre-crash evidence package created on Desktop:" -ForegroundColor Yellow
    Write-Host $zipPath -ForegroundColor White
} -ErrorAction SilentlyContinue

# Keep the script alive forever
while ($true) { Start-Sleep -Seconds 3600 }
