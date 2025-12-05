<# 
    BlueBox.ps1 – V1.3 FINAL (05/12/2025)
    O verdadeiro "caixa-preta" para computadores brasileiros
    by TOMJARA / Ghass – Laboratórios & Assistência Técnica
    MIT License – grátis para sempre
#>

param([switch]$Install,[switch]$Uninstall,[switch]$TestCrash)

$LogPath = "$env:APPDATA\BlueBox"
$LogFile = "$LogPath\bluebox_log_$(Get-Date -Format 'yyyy-MM-dd').txt"

# Cria pasta de logs
if (!(Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null }

function Log-Entry ($Texto) {
    $linha = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Texto | PC: $env:COMPUTERNAME | User: $env:USERNAME"
    Add-Content -Path $LogFile -Value $linha -Encoding UTF8
}

# ==================== INSTALAÇÃO ====================
if ($Install) {
    $TaskName = "BlueBox-IT-Logger"
    $Action   = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -File `"$PSScriptRoot\BlueBox.ps1`""
    $Trigger  = New-ScheduledTaskTrigger -AtStartup -Delay 00:00:30
    $Principal= New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Force | Out-Null

    Log-Entry "BlueBox V1.3 instalado com sucesso"

    Add-Type -AssemblyName System.Windows.Forms
    $global:Notify = New-Object System.Windows.Forms.NotifyIcon
    # Usa o ícone do PowerShell (ou troque por seu .ico no futuro)
    $global:Notify.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSHome\powershell.exe")
    $global:Notify.Visible = $true
    $global:Notify.BalloonTipIcon  = "Info"
    $global:Notify.BalloonTipTitle = "Assistência Técnica"
    BlueBox"
    $global:Notify.BalloonTipText  = "Diagnóstico ativo – estamos cuidando do seu PC"
    $global:Notify.ShowBalloonTip(10000)

    # Menu com botão direito
    $menu = New-Object System.Windows.Forms.ContextMenuStrip
    $menu.Items.Add("BlueBox V1.3 – ativo", $null, {}) | Out-Null
    $menu.Items.Add("-") | Out-Null
    $menu.Items.Add("Desinstalar BlueBox", $null, { & "$PSScriptRoot\BlueBox.ps1" -Uninstall }) | Out-Null
    $global:Notify.ContextMenuStrip = $menu

    # Mantém vivo em segundo plano
    [System.Windows.Forms.Application]::Run((New-Object System.Windows.Forms.Form -Property @{WindowState='Minimized';ShowInTaskbar=$false}))
}

# ==================== DESINSTALAÇÃO ====================
elseif ($Uninstall) {
    Unregister-ScheduledTask -TaskName "BlueBox-IT-Logger" -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item "$env:APPDATA\BlueBox" -Recurse -Force -ErrorAction SilentlyContinue
    if ($global:Notify) { $global:Notify.Dispose() }
    [System.Windows.Forms.MessageBox]::Show("BlueBox foi removido com sucesso!`nObrigado por usar nosso diagnóstico.", "BlueBox", 0, 64) | Out-Null
    exit
}

# ==================== TESTE RÁPIDO ====================
elseif ($TestCrash) {
    Log-Entry "TESTE MANUAL: BlueBox funcionando corretamente"
    [System.Windows.Forms.MessageBox]::Show("Teste registrado com sucesso!`nLog salvo em:`n$LogFile","BlueBox – Teste OK",0,64) | Out-Null
}

# ==================== EXECUÇÃO NORMAL (todo boot) ====================
else {
    $Eventos = Get-WinEvent -FilterHashtable @{LogName='System'; ID=41,6008,1001; StartTime=(Get-Date).AddHours(-24)} -ErrorAction SilentlyContinue |
               Where-Object { $_.Message -match "bugcheck|desligamento inesperado|rebooted from a bugcheck" }

    if ($Eventos) {
        foreach ($e in $Eventos) {
            Log-Entry "CRASH DETECTADO → ID:$($e.Id) → $($e.Message.Split("`n")[0])"
        }
    } else {
        Log-Entry "Sistema estável – nenhum crash nas últimas 24h"
    }
}
