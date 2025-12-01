# BlueBox One-Click Installer v1.0
# By Ghass – December 1, 2025
Write-Host "Installing Blue Box – The Black Box for Computers" -ForegroundColor Cyan
$folder = "$env:ProgramFiles\BlueBox"
if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder -Force }
Copy-Item "$PSScriptRoot\BlueBox-Recorder.ps1" "$folder\" -Force
Copy-Item "$PSScriptRoot\BlueBox-CrashGuard.ps1" "$folder\" -Force
$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\Start BlueBox.lnk")
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$folder\BlueBox-Recorder.ps1`""
$shortcut.IconLocation = "$folder\assets\logo-icon.png"
$shortcut.Save()
Write-Host "BlueBox installed! Double-click 'Start BlueBox' on your desktop." -ForegroundColor Green
pause
