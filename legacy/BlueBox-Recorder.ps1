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
