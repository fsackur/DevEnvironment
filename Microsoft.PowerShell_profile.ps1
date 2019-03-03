Set-ExecutionPolicy Bypass -Scope Process -Force
Set-Location C:\GithubData -ErrorAction SilentlyContinue

# Vagrant stepladder BTS
function rdp {mstsc /v 10.0.2.85 /w 1200 /h 1000}

$Global:WhamCliSkipTemplateUpdate = $true
#$PSModuleAutoLoadingPreference = "ModuleQualified"

#$env:PSModulePath = $env:PSModulePath + ";H:\PowerShell;K:\Interdepartmental\PowershellTools"
#Import-Module C:\Githubdata\DeveloperTools
Remove-Item Alias:curl -ErrorAction SilentlyContinue

function Git-Add
{
    [CmdletBinding()]
    param ()
    git add *; git status -v; git status
}
Set-Alias a Git-Add

function Git-Commit
{
    [CmdletBinding()]
    param
    (
	    [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    git commit -m $Message
}
Set-Alias c Git-Commit

function Git-Branch
{
    param
    (
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Branch
    )

    $chbr = git checkout $Branch *>&1

    if ($chbr.ToString() -match 'did not match any file')
    {
        Write-Host -ForegroundColor DarkYellow 'Creating new branch...'
        $newbr = git checkout -b $Branch *>&1
        $pushbr = git push -u origin $Branch *>&1
        if (-not ($pushbr | Out-String) -match 'set up to track remote branch')
        {
            $pushbr
        }
    }
}
Set-Alias b Git-Branch

Import-Module Posh-Git

$GitPromptSettings | Add-Member NoteProperty -Name 'DefaultPromptSuffix' -Value '`n$(''>'' * ($nestedPromptLevel + 1)) '

function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host($pwd.ProviderPath) -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "`n> "
}



$IsOnOfficeNetwork = $null -ne (NetAdapter\Get-NetAdapter | NetConnection\Get-NetConnectionProfile -ErrorAction SilentlyContinue | where NetworkCategory -eq DomainAuthenticated)
if (-not $IsOnOfficeNetwork) {return}

<#
###############################################################################################
#Added on 03/02/2017 17:00:45 by ModuleManager installer (https://rax.io/MMInstall)

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
#>


# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}




function Invoke-Nucleus
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        $Session = (Get-PoshCoreToken -AsPlainText),

        [Parameter()]
        $TicketNum = '190222-02416',

        [Parameter()]
        $Account = '1103359',

        [Parameter()]
        [ValidateSet(
            'NucleusExst',
            'WindowsProvisioning'
        )]
        $Name = 'NucleusExst',

        [Parameter()]
        [ValidateSet(
            '\\rackspace.corp\UK\Public\Interdepartmental\PowershellTools',
            '\\rackspace.corp\UK\Public\Interdepartmental\PowershellTools\Dev',
            'C:\Githubdata'
        )]
        $Location = '\\rackspace.corp\UK\Public\Interdepartmental\PowershellTools'
    )

    function exit {}

    $Global:Session = $Session
    $Global:TicketNum = $TicketNum
    $Global:Account = $Account
    
    $ModuleBase = Join-Path $Location 'DynamicMenu'
    Import-Module $ModuleBase

    $MenuModule = Get-ChildItem $ModuleBase -Filter "$Name.psm1"

    Start-ModuleMenu -ModuleName $Name -ModulePath $MenuModule.FullName
}