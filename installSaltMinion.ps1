param (
   [string]$SALT_MASTER_SERVER = "salt",
   [string]$SALT_AGENT_ENVIRONMENT = "base",
   [string]$SALT_MINION_ID = $null
)

$WORKSTATION_FQDN = (Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain
$SALT_MINION_HOSTNAME = $WORKSTATION_FQDN.ToLower()

$SALT_MINION_version = '3005.1-5'
$SALT_MINION_x64_download_path = "https://repo.saltproject.io/windows/Salt-Minion-$SALT_MINION_version-Py3-AMD64-Setup.exe"
$SALT_MINION_x86_download_path = "https://repo.saltproject.io/windows/Salt-Minion-$SALT_MINION_version-Py3-x86-Setup.exe"

If ($env:PROCESSOR_ARCHITECTURE -eq "amd64") {
   Write-Host "64-bit operating system"

   Write-Host "checking if installed" 
   $regkeypath= "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Salt Minion" 
   $keyvalue = (Get-ItemProperty $regkeypath -ErrorAction SilentlyContinue).DisplayVersion

   If ($keyvalue -eq $SALT_MINION_version) { 
   Write-Host "salt-minion is already installed" 

   } Else { 
   Write-Host "downloading salt-minion exe installer" 
   $WebClient = New-Object System.Net.WebClient
   $WebClient.DownloadFile("$SALT_MINION_x64_download_path","$env:TEMP\Salt-Minion.exe")

   Write-Host "trying to install salt-minion"
   If ( $SALT_MINION_ID -eq $null ) {
       Start-Process "$env:TEMP\Salt-Minion.exe" -Wait -ArgumentList "/S /master=$SALT_MASTER_SERVER /start-minion-delayed"
   } Else {
       Start-Process "$env:TEMP\Salt-Minion.exe" -Wait -ArgumentList "/S /master=$SALT_MASTER_SERVER /start-minion-delayed /minion-name=$SALT_MINION_ID"
   }
   Set-Content -Path "C:\ProgramData\Salt Project\Salt\conf\minion_id" -Value "$SALT_MINION_ID"
   
   Write-Host "removing salt-minion exe installer"
   Remove-Item -Path "$env:TEMP\Salt-Minion.exe"
    
   Write-Host "first run salt-call"
   Start-Sleep -Seconds 5
   & "C:\Program Files\Salt Project\Salt\salt-call.bat" state.highstate

   }

} Else {

  Write-Host "Operating System Is Not 64-bit"

}
