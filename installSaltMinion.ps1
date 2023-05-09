param (
   [string]$SALT_MASTER_SERVER = "salt",
   [string]$SALT_AGENT_ENVIRONMENT = "base"
)

$WORKSTATION_FQDN = (Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain
$SALT_MINION_ID = $WORKSTATION_FQDN.ToLower()

$SALT_MINION_version = '3005.1-5'
$SALT_MINION_x64_download_path = "https://repo.saltproject.io/windows/Salt-Minion-$SALT_MINION_version-Py3-AMD64-Setup.exe"
$SALT_MINION_x86_download_path = "https://repo.saltproject.io/windows/Salt-Minion-$SALT_MINION_version-Py3-x86-Setup.exe"

if ($env:PROCESSOR_ARCHITECTURE -eq "amd64") {
    write-host "64-bit Operating System"
    
    # checking if installed
    $regkeypath= "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Salt Minion" 
    $keyvalue = (Get-ItemProperty $regkeypath -ErrorAction SilentlyContinue).DisplayVersion
  
    If ($keyvalue -eq $SALT_MINION_version) { 
    Write-Host "SALT-MINION is already installed" 
    
    } Else { 

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("$SALT_MINION_x64_download_path","$env:TEMP\Salt-Minion.exe")

    Start-Process "$env:TEMP\Salt-Minion.exe" -Wait -ArgumentList "/S /master=$SALT_MASTER_SERVER /start-minion-delayed /minion-name=$SALT_MINION_ID"
    Remove-Item -Path "$env:TEMP\Salt-Minion.exe"
    
    # first run
    Start-Sleep -Seconds 10
    Set-Content -Path "C:\ProgramData\Salt Project\Salt\conf\minion_id" -Value "$SALT_MINION_ID"
    & "C:\Program Files\Salt Project\Salt\salt-call.bat" state.highstate

    }

    

} Else {

  write-host "Operating System Is Not 64-bit"

}
