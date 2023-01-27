# Check if running as administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Exit
}

# Check if Chocolatey is installed
If (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install packages
choco install -y microsoft-office-professional-plus googlechrome 7zip adobereader vlc atera webrootsecureanywhere

# Check if Dell device 
$manufacturer = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer

If ($manufacturer -eq 'Dell Inc.') {
    # Install Dell Command Update
    choco install -y dell-command-update
    # Run Dell Command Update
    Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\DellCommandUpdate.exe" -ArgumentList '/quiet'
}

# Install windows update 
choco install -y windowsupdate
