<# BlueBox V3.0-Final – OFICIAL – 10/12/2025 – 100% FUNCIONAL #>
param([switch]$Install,[switch]$Uninstall,[switch]$TestCrash)

# SEU E-MAIL JÁ CONFIGURADO (recebe todos os alertas)
$EmailPara    = "tom7.jr777@gmail.com"
$EmailDe      = "bluebox@lab.com.br"
$SMTPServer   = "smtp.gmail.com"
$SMTPPorta    = 587
$SMTPUsuario  = "bluebox@lab.com.br"
$SMTPsenha    = "SUA_SENHA_DE_APP_AQUI"   # ← só colocar a senha de app do Gmail

$LogPath = "$env:APPDATA\BlueBox"
$LogFile = "$LogPath\bluebox_log_$(Get-Date -Format 'yyyy-MM-dd').txt"
if(!(Test-Path $LogPath)){New-Item $LogPath -ItemType Directory -Force|Out-Null}

function Log($t){Add-Content $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $t | $env:COMPUTERNAME" -Encoding UTF8}
function SendMail($a,$c){try{$s=ConvertTo-SecureString $SMTPsenha -AsPlain -Force;$cr=New-Object PSCredential($SMTPUsuario,$s);Send-MailMessage -From $EmailDe -To $EmailPara -Subject $a -Body $c -SmtpServer $SMTPServer -Port $SMTPPorta -UseSsl -Credential $cr -Encoding UTF8;Log "Email enviado"}catch{Log "Email falhou: $_"}}

if($Install){
    Register-ScheduledTask -TaskName "BlueBox-IT-Logger" -Action (New-ScheduledTaskAction "PowerShell.exe" "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\BlueBox.ps1`"") -Trigger (New-ScheduledTaskTrigger -AtLogOn) -Principal (New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest) -Settings (New-ScheduledTaskSettingsSet -Hidden) -Force|Out-Null
    Log "BlueBox V3.0-Final instalado"

    Add-Type -AssemblyName System.Windows.Forms
    $n=New-Object System.Windows.Forms.NotifyIcon
    $n.Icon=[System.Drawing.Icon]::ExtractAssociatedIcon("$PSHome\powershell.exe")
    $n.Visible=$true
    $n.ShowBalloonTip(8000,"Assistencia Tecnica","BlueBox ativo",0)
    $m=New-Object System.Windows.Forms.ContextMenuStrip
    $m.Items.Add("BlueBox V3.0-Final ativo")|Out-Null
    $m.Items.Add("Desinstalar BlueBox",$null,{& "$PSScriptRoot\BlueBox.ps1" -Uninstall})|Out-Null
    $n.ContextMenuStrip=$m
    [System.Windows.Forms.Application]::Run((New-Object System.Windows.Forms.Form -Property @{WindowState='Minimized';ShowInTaskbar=$false;Opacity=0}))
}
elseif($Uninstall){
    Unregister-ScheduledTask "BlueBox-IT-Logger" -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item "$env:APPDATA\BlueBox" -Recurse -Force -ErrorAction SilentlyContinue
    if($n){$n.Dispose()}
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
