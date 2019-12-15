#SetupCompleted V.0.3
#A script to run after a new installation to: remove unused apps, change some settings
#https://github.com/WouterKromkamp/setupcompleted
#Delete the lines you don't want to execute 

Write-Host "SetupCompleted V.1.0" -ForegroundColor red 
Write-Host "https://github.com/WouterKromkamp/setupcompleted `r`n" -ForegroundColor red 

Set-ExecutionPolicy Unrestricted

Write-Host "All Windows Apps (execept the store) will be removed"

Get-AppxPackage -AllUsers | where-object {$_.name -notlike "*Microsoft.WindowsStore*"} | where-object {$_.name -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.name -notlike "*Microsoft.Windows.Photos*"} | Remove-AppxPackage -ErrorAction SilentlyContinue

Get-AppxProvisionedPackage -online | where-object {$_.packagename -notlike "*Microsoft.WindowsStore*"} | where-object {$_.packagename -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.packagename -notlike "*Microsoft.Windows.Photos*"} |Remove-AppxProvisionedPackage -online -ErrorAction SilentlyContinue

Write-Host "Set This PC as default startfolder for Windows Explorer"

reg import $PSScriptRoot\ThisPCLaunchToExplorer.reg

Write-Host "Disables the SearchBox in the taskbar"
reg import $PSScriptRoot\TurnOffSearchboxTaskbar.reg

Write-Host "Turn Update's on For other Microsoft products"
reg import $PSScriptRoot\TurnOnUpdatesForOtherMicrosoftProducts.reg

#Delete layout file if it already exists
If(Test-Path C:\Windows\StartLayout.xml)
{
    Remove-Item C:\Windows\StartLayout.xml
}

#Creates the blank layout file
echo "<LayoutModificationTemplate xmlns:defaultlayout=""http://schemas.microsoft.com/Start/2014/FullDefaultLayout"" xmlns:start=""http://schemas.microsoft.com/Start/2014/StartLayout"" Version=""1"" xmlns=""http://schemas.microsoft.com/Start/2014/LayoutModification"">" >> C:\Windows\StartLayout.xml
echo "  <LayoutOptions StartTileGroupCellWidth=""6"" />" >> C:\Windows\StartLayout.xml
echo "  <DefaultLayoutOverride>" >> C:\Windows\StartLayout.xml
echo "    <StartLayoutCollection>" >> C:\Windows\StartLayout.xml
echo "      <defaultlayout:StartLayout GroupCellWidth=""6"" />" >> C:\Windows\StartLayout.xml
echo "    </StartLayoutCollection>" >> C:\Windows\StartLayout.xml
echo "  </DefaultLayoutOverride>" >> C:\Windows\StartLayout.xml
echo "</LayoutModificationTemplate>" >> C:\Windows\StartLayout.xml

$regAliases = @("HKLM", "HKCU")

#Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    IF(!(Test-Path -Path $keyPath)) { 
        New-Item -Path $basePath -Name "Explorer"
    }
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value "C:\Windows\StartLayout.xml"
}

#Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
Stop-Process -name explorer
Start-Sleep -s 5
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
Start-Sleep -s 5

#Enable the ability to pin items again by disabling "LockedStartLayout"
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}

Write-Host "Remove all shortcuts"
Remove-Item C:\Users\*\Desktop\*lnk –Force

Write-Host "Remove pinned apps from taskbar"
# $appnames = "^Microsoft Edge$|^Store$" to only remove edge and store
$appnames = ""
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | 
  Where-Object{$_.Name -match $appnames}).Verbs() | 
  Where-Object{$_.Name.replace('&','') -match 'Unpin from taskbar|Von "Start" lösen|Van taakbalk losmaken'} | 
  ForEach-Object{$_.DoIt(); $exec = $true}

#Restart Explorer and delete the layout file
Stop-Process -name explorer
Remove-Item C:\Windows\StartLayout.xml

Write-Host "Remove OneDrive"
Start-Process -Verb RunAs cmd.exe -Args '/c', "$PSScriptRoot\RemoveOneDrive.cmd" 

Write-Host "The setupcompleted script is done, Enjoy!"
pause "Press any key to exit"

Function pause ($message)
{
    # Check if running Powershell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else
    {
        Write-Host "$message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}