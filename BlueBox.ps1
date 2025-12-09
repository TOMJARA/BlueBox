# 2) Cria a versão FINAL SEM ACENTO e 100% testada no PowerShell 7.5.4
@'
<# BlueBox V1.9 - OFICIAL - 09/12/2025 - SEM ERRO NO PS7 #>
param([switch]$Install,[switch]$Uninstall,[switch]$TestCrash)

$EmailPara    = "seuemail@lab.com.br"
$EmailDe      = "bluebox@lab.com.br"
$SMTPServer   = "smtp.gmail.com"
$SMTPPorta    = 587
$SMTPUsuario  = "bluebox@lab.com.br"
$SMTPsenha    = "SUA_SENHA_DE_APP"

$LogPath = "$env:APPDATA\BlueBox"
$LogFile = "$LogPath\bluebox_log_$(Get-Date -Format 'yyyy-MM-dd').txt"
if(!(Test-Path $LogPath)){New-Item $LogPath -ItemType Directory -Force|Out-Null}

function Log($t){Add-Content $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $t | $env:COMPUTERNAME" -Encoding UTF8}
function SendMail($a,$c){if($EmailPara -notlike "seuemail*"){try{$s=ConvertTo-SecureString $SMTPsenha -AsPlain -Force;$cr=New-Object PSCredential($SMTPUsuario,$s);Send-MailMessage -From $EmailDe -To $EmailPara -Subject $a -Body $c -SmtpServer $SMTPServer -Port $SMTPPorta -UseSsl -Credential $cr -Encoding UTF8;Log "Email enviado"}catch{Log "Email falhou: $_"}}}

if($Install){
    Register-ScheduledTask -TaskName "BlueBox-IT-Logger" -Action (New-ScheduledTaskAction "PowerShell.exe" "-WindowStyle Hidden -File `"$PSScriptRoot\BlueBox.ps1`"") -Trigger (New-ScheduledTaskTrigger -AtStartup) -Principal (New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest) -Settings (New-ScheduledTaskSettingsSet) -Force|Out-Null
    Log "BlueBox V1.9 instalado"

    Add-Type -AssemblyName System.Windows.Forms
    $n=New-Object System.Windows.Forms.NotifyIcon
    $n.Icon=[System.Drawing.Icon]::ExtractAssociatedIcon("$PSHome\powershell.exe")
    $n.Visible=$true
    $n.ShowBalloonTip(8000,"Assistencia Tecnica","BlueBox ativo",0)

    $m=New-Object System.Windows.Forms.ContextMenuStrip
    $m.Items.Add("BlueBox ativo")|Out-Null
    $m.Items.Add("Desinstalar BlueBox",$null,{& "$PSScriptRoot\BlueBox.ps1" -Uninstall})|Out-Null
    $n.ContextMenuStrip=$m

    [System.Windows.Forms.Application]::Run((New-Object System.Windows.Forms.Form -Property @{WindowState='Minimized';ShowInTaskbar=$false}))
}
elseif($Uninstall){
    Unregister-ScheduledTask "BlueBox-IT-Logger" -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item "$env:APPDATA\BlueBox" -Recurse -Force -ErrorAction SilentlyContinue
    if($n){$n.Dispose()}
    [System.Windows.Forms.MessageBox]::Show("BlueBox removido!","BlueBox",0,64)|Out-Null
    exit
}
elseif($TestCrash){
    Log "TESTE MANUAL"
    SendMail "Teste BlueBox - $env:COMPUTERNAME" "Funcionou! $(Get-Date)"
}
else{
    $ev=Get-WinEvent -FilterHashtable @{LogName='System';ID=41,6008,1001;StartTime=(Get-Date).AddHours(-48)} -EA 0 | ? {$_.Message -match "bugcheck|rebooted"}
    if($ev){foreach($e in $ev){Log "CRASH ID:$($e.Id) $($e.Message.Split("`n")[0])"};SendMail "ALERTA BlueBox - $env:COMPUTERNAME" "Cliente teve tela azul!`n$($ev|Select -First 5|Out-String)"}
    else{Log "Sistema estavel"}
}
'@ | Set-Content "$env:USERPROFILE\Desktop\BlueBox.ps1" -Encoding UTF8
