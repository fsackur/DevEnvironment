function New-GitRepo
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]$Description,

        [string]$RepoName = $(Split-Path $PWD -Leaf),

        [string]$GithubToken = $(Get-PoshSecret -Name GithubToken -Username fsackur -AsPlaintext).Password
    )

    $RepoRemoteUrl = "https://github.com/fsackur/$RepoName"
    
    $ApiUrl = "https://api.github.com/user/repos?access_token=$GithubToken"

    $Body = @{
        name             = $RepoName
        description      = $Description
        homepage         = "https://fsackur.github.io/$RepoName"
        license_template = 'mit'
    }

    $JsonBody = $Body | ConvertTo-Json -Compress
    
    try
    {
        #$Response = Invoke-RestMethod $ApiUrl -Body $JsonBody -Method Post -ErrorAction Stop
    }
    catch
    {
        if ($_ -notmatch 'already exists') {throw}
    }

    <#
    git init
    git remote add origin $RepoRemoteUrl
    git fetch origin
    git checkout -t origin/master
    #>

    $Readme = (
        "# $RepoName",
        $Description,
        '---',
        '_Copyright © 2019 Freddie Sackur_',
        "_Released under [MIT license](https://raw.githubusercontent.com/fsackur/$RepoName/master/LICENSE)_"
    ) -join "`n`n"

    $null = md docs -ErrorAction SilentlyContinue

    try
    {
        $Readme | Out-File .\docs\README.md -Encoding utf8 -NoClobber -ErrorAction Stop

        git add .\docs\README.md
        git commit -m 'Initial commit'
        git push
    }
    catch
    {
        "README already added - not committing"
    }

    $Manifest = @"
@{
    Description       = '$Description'
    ModuleVersion     = '0.0.0.0'
    GUID              = '$((New-Guid).Guid)'
    ModuleToProcess   = '$RepoName.psm1'

    Author            = 'Freddie Sackur'
    CompanyName       = 'dustyfox.uk'
    Copyright         = '(c) 2019 Freddie Sackur. All rights reserved.'

    RequiredModules   = @()
    FunctionsToExport = @(
        '*'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()


    PrivateData       = @{
        PSData = @{
            LicenseUri = 'https://raw.githubusercontent.com/fsackur/$RepoName/master/LICENSE'
            ProjectUri = 'https://fsackur.github.io/$RepoName/'
            Tags       = @(
            )
        }
    }
}
"@
    #$Manifest | Out-File .\$RepoName.psd1 -Encoding utf8 -NoClobber -ErrorAction Stop
    
    $RootModule = @'
Get-ChildItem $PSScriptRoot\Private -Filter '*.ps1' | Foreach-Object {. $_.FullName}
Get-ChildItem $PSScriptRoot\Public  -Filter '*.ps1' | Foreach-Object {. $_.FullName}
'@
    #$RootModule | Out-File .\$RepoName.psm1 -Encoding utf8 -NoClobber -ErrorAction Stop

    git add .\$RepoName.psd1
    git add .\$RepoName.psm1
    git commit -m 'Initial commit'
    git push
}
New-GitRepo -Description "Boilerplate inclusion for running pester tests in fresh runspaces."