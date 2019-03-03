$Global:WhamCliSkipTemplateUpdate = $true
#Save to ~\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1

if ((Get-ExecutionPolicy) -in ('Bypass', 'Unrestricted')) {Set-ExecutionPolicy Bypass -Scope Process -Force -WarningAction Ignore}

sl C:\Githubdata

$PSDefaultParameterValues['Out-Default:OutVariable'] = '+LastOutput'

#$RecentFolder = Resolve-path (git config --global gui.recentrepo)
#$Global:ModuleUnderTest = "C:\Githubdata\PesterPasta\Gigo"
#$Global:ModuleUnderTest = "C:\Githubdata\PoshCore"

Set-Alias clip Set-Clipboard

function OnNextLoad {
    param ($Path, $Files)
    sl $Path
    $Files | %{try {ise $_} catch {}}
    #Get-Content $profile | ?{$_ -notmatch '^\s*OnNextLoad'} | Out-File $profile -Force
}

#OnNextLoad -Path C:\Githubdata\PoshCore -Files "C:\Githubdata\PoshCore\Untitled2.ps1", "C:\Users\mich8638\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1"
#ise C:\Githubdata\PoshCore\Untitled1.ps1




function Reload {
    #WIP!
    #'OnNextLoad -Path {0} -Files "{1}"' -f $PWD.Path, ($psISE.CurrentPowerShellTab.Files.FullPath -join '", "')
    Start-Process powershell_ise -ArgumentList (
        "-File",
        ('"' + ($psISE.CurrentPowerShellTab.Files.FullPath -join '","') + '"')
    )
    #exit
}

Function SaveAndImport {
    $psISE.CurrentFile.Save()
    switch -Regex ($psISE.CurrentFile.FullPath) {
        '\.psm1$' {Import-Module $psISE.CurrentFile.FullPath -Force}
        '\.psd1$' {Import-Module ($psISE.CurrentFile.FullPath -replace '\.psd1$') -Force}
        '\.ps1$' {& $psISE.CurrentFile.FullPath}
    }
}

Function ReimportModuleUnderTest {
    $ModuleBase = $PWD.Path
    while ($ModuleBase -notmatch '^\w:(\\?)$')
    {
        $ModuleName = Split-Path $ModuleBase -Leaf
        $Psd1Path   = Join-Path $ModuleBase "$ModuleName.psd1"
        if (Test-Path $Psd1Path)
        {
            Import-Module $Psd1Path -Force -DisableNameChecking -PassThru
            return
        }
        $ModuleBase = Split-Path $ModuleBase -Parent
    }
    Write-Warning "No module imported"
}

function EditSnippets {
    $psISE.CurrentPowerShellTab.Files.Add("C:\Users\mich8638\Documents\WindowsPowerShell\Snippets\DefaultDisplaySet.snippets.ps1xml")
}

function EditProfile {
    $psISE.CurrentPowerShellTab.Files.Add(
        #$profile
        'C:\GithubData\DevProfile\ISE\Microsoft.PowerShellISE_profile.ps1'  #this file
    )
}

function clippie {
    (history).CommandLine | clip
}

function VerboseOn {$Global:VerbosePreference = 'Continue'}
function VerboseOff {$Global:VerbosePreference = 'SilentlyContinue'}


$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear()
try {[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Save and import module",{SaveAndImport},"Ctrl+Alt+S")} catch {}
try {[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Re-import module under test",{ReimportModuleUnderTest},"Ctrl+Alt+R")} catch {}
try {[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Reload ISE",{Reload},"Ctrl+Alt+L")} catch {}
try {[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Edit Snippets",{EditSnippets}, $null)} catch {}
try {[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Edit Profile",{EditProfile}, $null)} catch {}
try {[void]$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Edit in Visual Studio",{EditInVisualStudio}, $null)} catch {}

try {
$PSDefaultParameterValues += @{
    "New-ModuleManifest:Author" = "Freddie Sackur" ;
    "New-ModuleManifest:CompanyName" = "Rackspace" ;
    "New-ModuleManifest:Copyright" = "2017" ;
    "New-ModuleManifest:FunctionsToExport" = "*" ;
}
} catch {}


$IsOnOfficeNetwork = $null -ne (Get-NetAdapter | Get-NetConnectionProfile -ErrorAction SilentlyContinue | where NetworkCategory -eq DomainAuthenticated)
if (-not $IsOnOfficeNetwork) {return}


& ("$HOME\Documents\WindowsPowerShell\Modules" -split ';' | 
    gci -Filter 'Solarize-PSISE' -ErrorAction SilentlyContinue | 
    gci -Filter 'Solarize-PSISE.ps1'
).FullName -Dark




function Enable-ExceptionDebugger {
    #.Synopsis
    #$StackTrace is touched on every exception. This causes you to break into the debugger before you enter the catch statement.

    $null = Set-PSBreakpoint -Variable StackTrace -Mode Write
}

function Disable-ExceptionDebugger {
    Get-PSBreakpoint -Variable StackTrace | Remove-PSBreakpoint
}

function ConvertTo-Base64 {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [string]$String,

        [ValidateSet('Unicode', 'ASCII', 'Default', 'BigEndianUnicode', 'UTF7', 'UTF8', 'UTF32')] 
        [string]$Encoding = 'Default'
    )
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($String)
    $Base64String = [Convert]::ToBase64String($Bytes)
    $Base64String
}

function ConvertFrom-Base64 {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [string]$Base64String,

        [ValidateSet('Unicode', 'ASCII', 'Default', 'BigEndianUnicode', 'UTF7', 'UTF8', 'UTF32')] 
        [string]$Encoding = 'Default'
    )
    $Bytes = [Convert]::FromBase64String($Base64String)
    $String = [System.Text.Encoding]::$Encoding.GetString($Bytes)
    $String
}

#$PSModuleAutoLoadingPreference = 'ModuleQualified'


Remove-Item Alias:\ise -Force -ErrorAction SilentlyContinue
function ise
{
    $null = $args | Resolve-Path | Select-Object -ExpandProperty Path | %{$psISE.CurrentPowerShellTab.Files.Add($_)}
}


$TestDevices = (
    487364,
    487376,
    497377,
    497378,
    497379,
    502618,
    502619,
    502620,
    502627,
    502664,
    502667,
    560559,
    560570,
    660537,
    660662
    #701380
)



function Export-AndDontAskQuestions
{
    <#
        .SYNOPSIS
        Exports non-exported functions from a module.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string]$Module
    )

    process
    {
        [psmoduleinfo]$Module = Get-Module $Module -ErrorAction Stop
        if ($Module.Count -gt 1) {throw}

        & $Module {
            $Module = $args[0]
            $Commands = Get-Command -Module $Module
            foreach ($Command in $Commands)
            {
                Write-Verbose "Exporting non-exported function $($Command.Name)"
                Set-Content function:\Global:$($Command.Name) $Module.NewBoundScriptBlock([scriptblock]::Create($Command.Definition))
            }

        } $Module
    }
}


function Proxy-Import-Module
{
    <#

    .ForwardHelpTargetName Microsoft.PowerShell.Core\Import-Module
    .ForwardHelpCategory Cmdlet

    #>
    [CmdletBinding(DefaultParameterSetName='Name', HelpUri='http://go.microsoft.com/fwlink/?LinkID=141553')]
    param(
        [Parameter(ParameterSetName='Name')]
        [Parameter(ParameterSetName='PSSession')]
        [Parameter(ParameterSetName='CimSession')]
        [Alias('Version')]
        [version]
        ${MinimumVersion},

        [switch]
        ${Force},

        [switch]
        ${DisableNameChecking},

        [switch]
        ${Global},

        [ValidateNotNull()]
        [string]
        ${Prefix},

        [Parameter(ParameterSetName='PSSession', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='Name', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='CimSession', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]]
        ${Name},

        [Parameter(ParameterSetName='FullyQualifiedName', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='FullyQualifiedNameAndPSSession', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]
        ${FullyQualifiedName},

        [Parameter(ParameterSetName='Assembly', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [System.Reflection.Assembly[]]
        ${Assembly},

        [ValidateNotNull()]
        [string[]]
        ${Function},

        [ValidateNotNull()]
        [string[]]
        ${Cmdlet},

        [ValidateNotNull()]
        [string[]]
        ${Variable},

        [ValidateNotNull()]
        [string[]]
        ${Alias},

        [switch]
        ${PassThru},

        [switch]
        ${GodMode},

        [switch]
        ${AsCustomObject},

        [Parameter(ParameterSetName='Name')]
        [Parameter(ParameterSetName='PSSession')]
        [Parameter(ParameterSetName='CimSession')]
        [string]
        ${MaximumVersion},

        [Parameter(ParameterSetName='Name')]
        [Parameter(ParameterSetName='PSSession')]
        [Parameter(ParameterSetName='CimSession')]
        [version]
        ${RequiredVersion},

        [Parameter(ParameterSetName='ModuleInfo', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [psmoduleinfo[]]
        ${ModuleInfo},

        [Alias('Args')]
        [System.Object[]]
        ${ArgumentList},

        [Alias('NoOverwrite')]
        [switch]
        ${NoClobber},

        [ValidateSet('Local','Global')]
        [string]
        ${Scope},

        [Parameter(ParameterSetName='FullyQualifiedNameAndPSSession', Mandatory=$true)]
        [Parameter(ParameterSetName='PSSession', Mandatory=$true)]
        [ValidateNotNull()]
        [System.Management.Automation.Runspaces.PSSession]
        ${PSSession},

        [Parameter(ParameterSetName='CimSession', Mandatory=$true)]
        [ValidateNotNull()]
        [CimSession]
        ${CimSession},

        [Parameter(ParameterSetName='CimSession')]
        [ValidateNotNull()]
        [uri]
        ${CimResourceUri},

        [Parameter(ParameterSetName='CimSession')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CimNamespace}
    )

    begin
    {
        if ($PSBoundParameters.ContainsKey('GodMode'))
        {
            $null = $PSBoundParameters.Remove('GodMode')
        }
        if (-not $PSBoundParameters.ContainsKey('PassThru'))
        {
            $null = $PSBoundParameters.Add('PassThru', [switch]::Present)
        }
    }

    process
    {
        $Modules = Microsoft.PowerShell.Core\Import-Module @PSBoundParameters

        foreach ($Module in $Modules)
        {
            & $Module {
                $Module = $args[0]
                $Commands = Get-Command -Module $Module
                foreach ($Command in $Commands)
                {
                    Write-Verbose "Exporting non-exported function $($Command.Name)"
                    Set-Content function:\Global:$($Command.Name) $Module.NewBoundScriptBlock([scriptblock]::Create($Command.Definition))

                    if (-not $Module.ExportedFunctions.ContainsKey($Command.Name))
                    {
                        $Module.ExportedFunctions.Add($Command.Name, $Command)
                    }
                }

            } $Module

            Get-Command -Module $Module | Where-Object {-not $Module.ExportedFunctions.ContainsKey($_.Name)} | ForEach-Object {$Module.ExportedFunctions.Add($_.Name, $_)}
        }

        if ($PassThru) {$Modules}
    }
}
