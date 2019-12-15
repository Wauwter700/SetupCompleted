#Win10AfterSetup V.1.0.
#A script to run after a new installation to: remove unused apps, change some settings
#https://github.com/WouterKromkamp/Win10AfterSetup

#Delete the lines you don't want to execute 

Set-ExecutionPolicy Unrestricted

Write-Host "All Windows Apps (execept the store) will be removed"


Get-AppxPackage -AllUsers | where-object {$_.name -notlike "*Microsoft.WindowsStore*"} | where-object {$_.name -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.name -notlike "*Microsoft.Windows.Photos*"} | Remove-AppxPackage

Get-AppxProvisionedPackage -online | where-object {$_.packagename -notlike "*Microsoft.WindowsStore*"} | where-object {$_.packagename -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.packagename -notlike "*Microsoft.Windows.Photos*"} |Remove-AppxProvisionedPackage -online

Write-Host "Set This PC as default startfolder for Windows Explorer"

reg import .\ThisPCLaunchToExplorer.reg

Write-Host "Disables the SearchBox in the taskbar"
reg import .\TurnOffSearchboxTaskbar.reg

Write-Host "Turn Update's on For other Microsoft products"
reg import .\TurnOnUpdatesForOtherMicrosoftProducts.reg

Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

pause "Press any key to continue"

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