$lat5530 = Read-Host "Betreft het een Latitude 5530 (y/n)"



##
if ($lat5530 -eq 'y') {
	.\Latitude-5530-2VX2C_Win10_1.0_A03.exe /s
}




####check internet connection
if (!(test-connection 8.8.8.8 -Count 1 -Quiet)) {
	Write-host "De pc heeft geen verbinding met het internet!!! maak verbinding en probeer het opnieuw"  -ForegroundColor red
	Start-Sleep -s 10
	Read-Host "kabel aangesloten? (y/n)"
	.\Onboarding.ps1
} else {
##

####Vragen
$autopilot = Read-host "moet het apparaat autopilot ingeschreven worden? (y/n)"
if ($autopilot -eq 'n') {
$newname = Read-Host -prompt "Geef nieuwe computernaam"
#$officeversie = read-host -prompt "Office versie: Standaard OF Shared"
$OfficeStandaard = Read-Host "Moet de standaard office versie geinstalleerd worden? (y/n)"
if ($OfficeStandaard -eq 'n') {
$OfficeShared = Read-Host "moet de shared versie van office geinstalleerd worden? (y/n)"
}
$teams = Read-Host "Moet teams geinstalleerd worden? (y/n)"
$atera = read-host "Moet Atera geinstalleerd worden? (y/n)"
$StandaardApps = Read-Host "Moeten standaard apps geinstalleerd worden? (y/n)"
$updates = read-host "Moet windows update draaien? (y/n)"
	if ($updates -eq 'y') {
		$autoreboot = read-host "Mag de pc automatich opnieuw opgestart worden na het installeren van de updates? (y/n)"
		Write-Host "het script gaat nu alle taken op de achtergrond uitvoeren, u krijgt bericht wanneer het script voltooid is" -ForegroundColor green
	}
}

if ($lat5530 -eq 'n') {
	$dell = Read-Host "betreft het een zakelijk Dell apparaat? (y/n)"
}

####Office365 installatie
#$xml = ".xml"
#.\setup.exe /configure $officeversie$xml
if ($OfficeStandaard -eq 'y') {
.\setup.exe /configure Standaard.xml
}
if ($OfficeShared -eq 'y') {
.\setup.exe /configure Shared.xml
}
##


####Dell command update
if ($dell -eq 'y') {
.\Dell-Command-Update-Application_68GJ6_WIN_3.1.2_A00.EXE /s  ##installeer Dell command update
Start-Sleep -s 55 #Wacht 60 seconden
$env:Path = $env:Path + ';C:\Program Files (x86)\Dell\CommandUpdate\' ##Mount de envirowment om DCU-cli uit te voeren
Start-Sleep -s 5
& 'C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe' /driverinstall ##voer dcu-cli uit

#.\CommandUpdate\dcu-cli.exe /driverrestore
}
##


####copy splashtop to C:\
##Copy-Item ".\Hulp op afstand.exe" -Destination "C:\Hulp op afstand" -Recurse
##


#### disable windows hello
#$registrypath1 = 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork'
#$Name1 = 'Enabled'
#$Value1 = "0"
#Set-ItemProperty -path $registrypath1 -name $Name1 -value $Value1
#
#$registrypath2 = 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork'
#$Name2 = 'DisablePostLogonProvisioning'
#$Value2 = "0"
#Set-ItemProperty -path $registrypath2 -name $Name2 -value $Value2
	$registryPath1 = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork"
	$Name1 = "Enabled"
	$value1  = "1"
	IF (!(Test-Path $registryPath1))
	{
		New-Item -Path $registryPath1 -Force | Out-Null
		New-ItemProperty -Path $registryPath1 -Name $name1 -Value $value1 `
		-PropertyType DWORD -Force | Out-Null
	}
	ELSE
	{
		New-ItemProperty -Path $registryPath1 -Name $name1 -Value $value1 `
		-PropertyType DWORD -Force | Out-Null
	}
	
	$registryPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork"
	$Name2 = "DisablePostLogonProvisioning"
	$value2 = "1"
	IF (!(Test-Path $registryPath2))
	{
		New-Item -Path $registryPath2 -Force | Out-Null
		New-ItemProperty -Path $registryPath2 -Name $name2 -Value $value2 `
						 -PropertyType DWORD -Force | Out-Null
	}
	ELSE
	{
		New-ItemProperty -Path $registryPath2 -Name $name2 -Value $value2 `
						 -PropertyType DWORD -Force | Out-Null
	}
	##


####Ninite (VLC, Chrome, Reader, 7-Zip)
Start-Sleep -s 20
if ($StandaardApps -eq 'y') {
	cmd /c NinitePro.exe /silent . /select VLC Reader "7-Zip" /disableshortcuts
}
##


#### install edge
#Start-Sleep -s 20
#.\MicrosoftEdgeEnterpriseX64.msi /quiet
##
	
	####remove windows mail app
	Get-AppXProvisionedPackage -Online | `
	Where-Object PackageName -like microsoft.windowscommunicationsapps* | `
	Remove-AppXProvisionedPackage -Online -AllUsers
	
	Get-AppXPackage microsoft.windowscommunicationsapps | `
	Remove-AppXPackage -AllUsers
	##
	
	
	####remove Teams consumer and install teams for work
	Get-AppxPackage MicrosoftTeams* | Remove-AppxPackage
	##
		
if ($teams -eq 'y') {
Start-Sleep -s 20
.\Teams_windows_x64.msi /quiet
}
##


####set startmenu en bureaublad apps
Start-Sleep -s 5
Import-StartLayout defaultlayoutsv3.xml -MountPath c:\ 
Copy-Item '.\Shortcuts\*' C:\Users\Default\Desktop

dism /online /import-defaultappassociations:"Standaardapps.xml"
##
	
	####Disable chat and widget
	REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v TaskbarMn /t REG_DWORD /d 0
	
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" /f /v ChatIcon /t REG_DWORD /d 3
	
	#widget
	REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v TaskbarDa /t REG_DWORD /d 0
	
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh" /f /v AllowNewsAndInterests /t REG_DWORD /d 0
	
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /f /v EnableFeeds /t REG_DWORD /d 0
	
	Get-AppxPackage -Name *WebExperience* | ForEach-Object {Remove-AppxPackage $_.PackageFullName}
	
	Get-ProvisionedAppxPackage -Online | Where-Object { $_.PackageName -match 'WebExperience' } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -PackageName $_.PackageName }


####hernoem pc
if ($newname){
	Rename-Computer -newname $newname -force -passthru
	Start-Sleep -s 5
}
##


####install atera
if ($atera -eq 'y'){
.\Atera.msi /quiet ##/promptrestart
}
##


###enroll in autopilot
Install-Script -name Get-WindowsAutopilotInfo -Force
Get-WindowsAutopilotInfo -Online


####swindowsupdate
if ($updates -eq 'y' -Or $autopilot -eq 'y'){
Stop-Service -Name wuauserv
Get-ChildItem C:\Windows\SoftwareDistribution -Recurse | Remove-Item -Recurse -Force
Start-Service -Name wuauserv
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
$path = "C:\logs"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
if ($autoreboot -eq 'y') {
#Get-WindowsUpdate -Install -AcceptAll -RecurseCycle 2 -AutoReboot
Get-WindowsUpdate -AcceptAll -Install -AutoReboot | Out-File "c:\logs\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log" -force
} else {
Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot | Out-File "c:\logs\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log" -force
}
}
##


####security terug naar standaard
Set-ExecutionPolicy Restricted
##


Write-Host "het script is nu klaar, laat de pc herstarten en ga verder met de installatie" -ForegroundColor green

$restart = Read-Host "wilt u de pc nu herstarten? (y/n)"
if ($restart -eq 'y'){
shutdown /r
}

}
## TODO Pincode uitzetten. taskbalklayout. add dezepc + userfiles. background met contactgegevens.
