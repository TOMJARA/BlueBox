# BlueBox One-Click Installer v1.1 – Fully Silent Edition
# By Ghass – December 1, 2025

Write-Host "Installing Blue Box – The Black Box for Computers" -ForegroundColor Cyan

$folder = "$env:ProgramFiles\BlueBox"
if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder -Force }

Copy-Item "$PSScriptRoot\BlueBox-Recorder.ps1" "$folder\" -Force
Copy-Item "$PSScriptRoot\BlueBox-CrashGuard.ps1" "$folder\" -Force

# Recorder – fully hidden
$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\Start BlueBox.lnk")
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$folder\BlueBox-Recorder.ps1`""
$shortcut.IconLocation = "$folder\bluebox-logo.png"
$shortcut.Save()

# CrashGuard – fully hidden
$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\BlueBox Guard.lnk")
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$folder\BlueBox-CrashGuard.ps1`""
$shortcut.IconLocation = "$folder\bluebox-logo.png"
$shortcut.Save()

Write-Host "BlueBox v1.1 installed silently!" -ForegroundColor Green
Write-Host "Double-click 'Start BlueBox' and 'BlueBox Guard' → everything runs 100% hidden." -ForegroundColor Green
pause
