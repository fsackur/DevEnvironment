#Save to ~\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1

Set-ExecutionPolicy Bypass -Scope Process -Force
Set-Location C:\Githubdata
#$env:PSModulePath = $env:PSModulePath + ";H:\PowerShell"
#$env:PSModulePath = $env:PSModulePath + ";K:\Interdepartmental\PowershellTools"
H:\PowerShell\Solarize-PSISE-master\Solarize-PSISE.ps1 -Dark

Function SaveAndImport {
    $psISE.CurrentFile.Save()
    switch -Regex ($psISE.CurrentFile.FullPath) {
        '\.psm1$' {Import-Module $psISE.CurrentFile.FullPath -Force}
        '\.psd1$' {Import-Module ($psISE.CurrentFile.FullPath -replace '\.psd1$') -Force}
        '\.ps1$' {& $psISE.CurrentFile.FullPath}
    }
}

function EditSnippets {
    $psISE.CurrentPowerShellTab.Files.Add("C:\Users\mich8638\Documents\WindowsPowerShell\Snippets\DefaultDisplaySet.snippets.ps1xml")
}

function EditProfile {
    $psISE.CurrentPowerShellTab.Files.Add($profile)
}


$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear()
[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Save and import module",{SaveAndImport},"Ctrl+Alt+S")
[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Edit Snippets",{EditSnippets}, $null)
[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Edit Profile",{EditProfile}, $null)

$PSDefaultParameterValues += @{
    "New-ModuleManifest:Author" = "Freddie Sackur" ;
    "New-ModuleManifest:CompanyName" = "Rackspace" ;
    "New-ModuleManifest:Copyright" = "2017" ;
    "New-ModuleManifest:FunctionsToExport" = "*" ;
}
