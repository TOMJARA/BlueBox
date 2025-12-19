<# BlueBox V3.7 – FINAL – 18/12/2025 – E-MAIL 100% FUNCIONANDO #>
param([switch]$Install,[switch]$Uninstall,[switch]$TestCrash)

$EmailPara    = "tom7.jr777@gmail.com"
$EmailDe      = "tom7.jr777@gmail.com"
$SMTPServer   = "smtp.gmail.com"
$SMTPPorta    = 587
$SMTPUsuario  = "tom7.jr777@gmail.com"
$SMTPsenha    = "vqbmaxlnessdjnfc"   # ← Sua senha de app nova

$LogPath = "$env:APPDATA\BlueBox"
$LogFile = "$LogPath\bluebox_log_$(Get-Date -Format 'yyyy-MM-dd').txt"
if(!(Test-Path $LogPath)){New-Item $LogPath -ItemType Directory -Force|Out-Null}

function Log($t){Add-Content $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $t | $env:COMPUTERNAME" -Encoding UTF8}
function SendMail($a,$c){try{$s=ConvertTo-SecureString $SMTPsenha -AsPlain -Force;$cr=New-Object PSCredential($SMTPUsuario,$s);Send-MailMessage -From $EmailDe -To $EmailPara -Subject $a -Body $c -SmtpServer $SMTPServer -Port $SMTPPorta -UseSsl -Credential $cr -Encoding UTF8;Log "Email enviado"}catch{Log "Email falhou: $_"}}

if($Install){
    $action = New-ScheduledTaskAction "PowerShell.exe" "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\BlueBox.ps1`""
    $trigger1 = New-ScheduledTaskTrigger -AtLogOn
    $trigger2 = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(3) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 3650)
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -Hidden
    Register-ScheduledTask -TaskName "BlueBox-IT-Logger" -Action $action -Trigger $trigger1,$trigger2 -Principal $principal -Settings $settings -Force | Out-Null
    Log "BlueBox V3.7 instalado"
    Add-Type -AssemblyName System.Windows.Forms
    $n=New-Object System.Windows.Forms.NotifyIcon
    $n.Icon=[System.Drawing.Icon]::ExtractAssociatedIcon("$PSHome\powershell.exe")
    $n.Visible=$true;$n.ShowBalloonTip(8000,"Assistência Técnica","BlueBox ativo",0)
    $m=New-Object System.Windows.Forms.ContextMenuStrip
    $m.Items.Add("BlueBox V3.7 ativo")|Out-Null
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
    $ev=Get-WinEvent -FilterHashtable @{LogName='System';ID=41,6008,1001;StartTime=(Get-Date).AddHours(-72)} -EA 0 | ? {$_.Message -match "bugcheck|rebooted"}
    if($ev){foreach($e in $ev){Log "CRASH ID:$($e.Id) $($e.Message.Split("`n")[0])"};SendMail "ALERTA BlueBox - $env:COMPUTERNAME" "Cliente teve tela azul!`n$($ev|Select -First 5|Out-String)"}
    else{Log "Sistema estável"}
}
