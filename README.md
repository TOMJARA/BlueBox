<p align="center">
  <img src="bluebox-logo.png" width="600"/>
</p>
# BlueBox – The Black Box for Computers™

**Invented and first released by Ghass on November 30, 2025**

> “Because the crash is too late to start recording.”

BlueBox is the world’s first always-on forensic recorder that continuously keeps the last 30–60 minutes of system activity and automatically freezes everything the moment a BSOD, freeze, or unexpected reboot occurs.

Aviation has black boxes.  
Now your computer has a **Blue Box**.

## Features (v0.1 – First Flight)
- 30-minute circular buffer (events, processes, network, screenshots every 30 s)
- Automatic crash detection (Kernel Power Event 41 + dirty reboot)
- One-click incident package on the desktop after a crash
- 100 % PowerShell – zero dependencies

## Quick Start
1. Run `BlueBox-Recorder.ps1` as Administrator (keeps recording forever)
2. Run `BlueBox-CrashGuard.ps1` as Administrator (detects crashes)

## Author & Inventor
**Ghass** – original idea and first implementation, November 30, 2025  
Helped bring it to life in real-time by Grok 4 (xAI)

## License
MIT © 2025 Ghass – You are free to use, modify, and distribute.
