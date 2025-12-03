# BlueBox – IT Black Box by Ghass  
**The aircraft black box principle, finally implemented in information technology**

BlueBox is an always-on diagnostic logger for Windows PCs. Inspired by aviation's rugged flight data recorders, it runs silently on every startup, capturing BSODs, kernel faults, and unexpected shutdowns. As a computer lab manager, install it post-repair: If issues recur, get emailed proof before the client returns.

![Blue-Box](Blue-Box.png)  
*(Logo: Blue Box – Entering IT History)*

## Why BlueBox?
- **Aviation Roots:** Like a black box survives crashes to log "flight history," BlueBox preserves system events for forensic analysis. No more "it worked in the lab!" surprises.
- **For Lab Workflows:** Deploy on repaired devices. It auto-logs to `%APPDATA%\BlueBox\` and emails alerts. V1 is **free forever**—develop V2 collaboratively.
- **Ethical & Lightweight:** Logs only system crashes (no personal data). <1% CPU, uninstalls cleanly.

## Features (Version 1.0 – Free & Open Source)
- **Boot-Time Monitoring:** Scans Windows Event Logs (IDs 1001, 6008, 41) for crashes in the last 24h.
- **Tamper-Resistant Logs:** Timestamped .txt files with bugcheck codes, faulting modules, and device ID.
- **Email Alerts:** Optional SMTP notifications on detection (e.g., Gmail setup).
- **Easy Deploy:** One-command install as Scheduled Task (runs as SYSTEM).
- **User-Friendly:** Creates desktop uninstall shortcut. No GUI bloat.

## Quick Start (Test on Your Lab PC)
1. **Download:** Clone this repo or grab [BlueBox.ps1](BlueBox.ps1).
2. **Run as Admin (PowerShell):**
   ```powershell
   # Install (sets up startup task)
   & ".\BlueBox.ps1" -Install

   # Test logging (simulates a crash entry)
   & ".\BlueBox.ps1" -TestCrash

   # Check logs
   notepad "%APPDATA%\BlueBox\bluebox_log_$(Get-Date -Format 'yyyy-MM-dd').txt"
