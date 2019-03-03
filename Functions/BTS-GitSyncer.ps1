
$DeviceID = 502618


Import-Module C:\DFSRoots\BTS_SHARE\PowershellTools\WHAM\Repo\PoshSecret
Import-Module C:\DFSRoots\BTS_SHARE\PowershellTools\WHAM\Repo\Tokx
Import-Module C:\DFSRoots\BTS_SHARE\PowershellTools\WHAM\Repo\Shared_Modules -DisableNameChecking
Import-Module C:\DFSRoots\BTS_SHARE\PowershellTools\WHAM\Repo\PoshCore


$Device = Find-CoreComputer -Computers $DeviceID -Attributes Network, Password
$DeviceCred = New-Object pscredential (
    "$($Device.Name -replace '\..*')\rack",
    ($Device.rack_password | ConvertTo-SecureString -AsPlainText -Force)
)
New-PSDrive -Name TestBox -PSProvider FileSystem -Root ("\\" + $Device.primary_ip + '\C$\rs-pkgs') -Credential $DeviceCred




# Optional – git prompt

Import-Module C:\DFSRoots\BTS_SHARE\PowershellTools\WHAM\Repo\posh-git
function prompt
{
    $realLASTEXITCODE = $LASTEXITCODE
    Write-Host($pwd.Path) -NoNewline
    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE
    return "`n> "
}


Set-Location TestBox:\




# Optional - my aliases for git add / commit

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


