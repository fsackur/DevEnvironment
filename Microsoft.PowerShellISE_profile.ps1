#Save to ~\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1


Set-ExecutionPolicy Bypass -Scope Process -Force
Set-Location C:\Githubdata

Function SaveAndImport {
    $psISE.CurrentFile.Save()
    switch -Regex ($psISE.CurrentFile.FullPath) {
        '\.psm1$' {Import-Module $psISE.CurrentFile.FullPath -Force}
        '\.psd1$' {Import-Module ($psISE.CurrentFile.FullPath -replace '\.psd1$') -Force}
        '\.ps1$' {& $psISE.CurrentFile.FullPath}
    }
}

Function ReimportModuleUnderTest {
    if ($null -eq $Global:ModuleUnderTest) {
        $ModuleString = Read-Host "What is the module you are working on?"
        $Global:ModuleUnderTest = (Get-Module $ModuleString -ListAvailable).Path
    }
    Import-Module $Global:ModuleUnderTest -Force
}

function EditSnippets {
    $psISE.CurrentPowerShellTab.Files.Add("C:\Users\mich8638\Documents\WindowsPowerShell\Snippets\DefaultDisplaySet.snippets.ps1xml")
}

function EditProfile {
    $psISE.CurrentPowerShellTab.Files.Add($profile)
}

function EditInVisualStudio {
    & 'C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe' $psISE.CurrentFile
}


$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear()
[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Save and import module",{SaveAndImport},"Ctrl+Alt+S")
[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Re-import module under test",{ReimportModuleUnderTest},"Ctrl+Alt+R")
[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Edit Snippets",{EditSnippets}, $null)
[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Edit Profile",{EditProfile}, $null)
[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Edit in Visual Studio",{EditInVisualStudio}, $null)

$PSDefaultParameterValues += @{
    "New-ModuleManifest:Author" = "Freddie Sackur" ;
    "New-ModuleManifest:CompanyName" = "Rackspace" ;
    "New-ModuleManifest:Copyright" = "2017" ;
    "New-ModuleManifest:FunctionsToExport" = "*" ;
}

$IsOnOfficeNetwork = $null -ne (Get-NetAdapter | Get-NetConnectionProfile -ErrorAction SilentlyContinue | where NetworkCategory -eq DomainAuthenticated)
if (-not $IsOnOfficeNetwork) {return}

H:\PowerShell\Solarize-PSISE-master\Solarize-PSISE.ps1 -Dark

###############################################################################################
#Added on 03/03/2017 16:18:37 by ModuleManager installer (https://rax.io/MMInstall)

Try
{
    Import-Module ModuleManager -Global -Force -ErrorAction Stop -DisableNameChecking
    Start-RaxModuleUpdate
}
Catch
{
    Throw "Failed to import ModuleManager! This is a required module, See help here: https://rax.io/MMInstall"
}

###############################################################################################
 
