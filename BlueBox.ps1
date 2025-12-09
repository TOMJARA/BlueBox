@'
<# BlueBox.ps1 – V1.6 OFICIAL – 09/12/2025 – Funciona em PowerShell 5 e 7 #>
param([switch]$Install,[switch]$Uninstall,[switch]$TestCrash)

$EmailPara = "seuemail@lab.com.br"          # ← SEU E-MAIL
$EmailDe   = "bluebox@lab.com.br"
$SMTPServer= "smtp.gmail.com"
$SMTPPorta = 587
$SMTPUsuario= "bluebox@lab.com.br"
$SMTPsenha = "SUA_SENHA_DE_APP"

$LogPath = "$env:APPDATA\BlueBox"
$LogFile = "$LogPath\bluebox_log_$(Get-Date -Format 'yyyy-MM-dd').txt"
if (!(Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null }

function Log-Entry($t){ Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $t | $env:COMPUTERNAME" -Encoding UTF8 }
function Send-Email($a,$c){ if($EmailPara -notlike "seuemail@*"){ try{ $s=ConvertTo-SecureString $SMTPsenha -AsPlainText -Force; $cr=New-Object System.Management.Automation.PSCredential($SMTPUsuario,$s); Send-MailMessage -From $EmailDe -To $EmailPara -Subject $a -Body $c -SmtpServer $SMTPServer -Port $SMTPPorta -UseSsl -Credential $cr -Encoding UTF8; Log-Entry "Email enviado" } catch { Log-Entry "Email falhou: $_" }}}

if($Install){
    Register-ScheduledTask -TaskName "BlueBox-IT-Logger" -Action (New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -File `"$PSScriptRoot\BlueBox.ps1`"") -Trigger (New-ScheduledTaskTrigger -AtStartup) -Principal (New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest) -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries) -Force | Out-Null
    Log-Entry "BlueBox V1.6 instalado"
    Add-Type -AssemblyName System.Windows.Forms
    $n=New-Object System.Windows.Forms.NotifyIcon
    $n.Icon=[System.Drawing.Icon]::ExtractAssociatedIcon("$PSHome\powershell.exe")
    $n.Visible=$true;$n.ShowBalloonTip(8000,"Assistência Técnica","BlueBox ativo",0)
    ($m=New-Object System.Windows.Forms.ContextMenuStrip).Items.Add("Desinstalar BlueBox",{& "$PSScriptRoot\BlueBox.ps1" -Uninstall})|Out-Null
    $n.ContextMenuStrip=$m
    [System.Windows.Forms.Application]::Run((New-Object System.Windows.Forms.Form -Property @{WindowState='Minimized';ShowInTaskbar=$false}))
}
elseif($Uninstall){
    Unregister-ScheduledTask "BlueBox-IT-Logger" -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item "$env:APPDATA\BlueBox" -Recurse -Force -ErrorAction SilentlyContinue
    Add-Type -AssemblyName System.Windows.Forms 2>$null
    [System.Windows.Forms.MessageBox]::Show("BlueBox removido!","BlueBox",0,64)|Out-Null
    exit
}
elseif($TestCrash){
    Log-Entry "TESTE MANUAL"
    Send-Email "Teste BlueBox – $env:COMPUTERNAME" "Funcionou! $(Get-Date)"
    Log-Entry "Teste concluído"
}
else{
    $ev=Get-WinEvent -FilterHashtable @{LogName='System';ID=41,6008,1001;StartTime=(Get-Date).AddHours(-48)} -ErrorAction SilentlyContinue | ? {$_.Message -match "bugcheck|rebooted"}
    if($ev){ foreach($e in $ev){ Log-Entry "CRASH ID:$($e.Id) $($e.Message.Split("`n")[0])" }; Send-Email "ALERTA BlueBox – $env:COMPUTERNAME" "Cliente teve tela azul!`n$($ev|Select -First 5|Out-String)" } 
    else { Log-Entry "Sistema estável" }
}
'@ | Set-Content "$env:USERPROFILE\Desktop\BlueBox.ps1" -Encoding UTF8
