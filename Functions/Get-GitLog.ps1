function Get-GitLog
{
    <#
        .SYNOPSIS
        Gets the git log.

        .DESCRIPTION
        Gets the git log. By default, gets commits since the last merge.

        .PARAMETER SinceLastPRMerge
        Specifies to fetch commits as far back as the last merged PR or the last commit by
        'whamapi-cicd-svc'.

        .PARAMETER Commits
        Specify how many commits to retrieve.

        .PARAMETER Remote
        Specify the remote name of the ref from which to fetch commits. Defaults to the local clone.

        .PARAMETER Branch
        Specify the branch name of the ref from which to fetch commits. Defaults to the current branch.

        .PARAMETER Weeks
        Specify how many weeks to look back. Defaults to 8.

        .OUTPUTS
        [psobject]

        .EXAMPLE
        ggl

            Count: 5

        Id      Author         UpdatedAt      Summary
        --      ------         ---------      -------
        23cdb63 Freddie Sackur 26 seconds ago Version increment 1.2.2.0 =>1.2.3.0
        efa2bbd Freddie Sackur 2 minutes ago  Colourised Get-GitLog output
        e9b62ae Freddie Sackur 31 minutes ago Added some usability tweaks to Get-GitLog
        8b912e7 Freddie Sackur 81 minutes ago New function Get-GitLog
        34c2df5 Freddie Sackur 82 minutes ago Tidy

        Gets the git log since the last merge.
    #>
    [CmdletBinding(DefaultParameterSetName = 'SinceLastPRMerge')]
    [OutputType([psobject])]
    param
    (
        [Parameter(ParameterSetName = 'SinceLastPRMerge')]
        [switch]$SinceLastPRMerge,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Position = 0)]
        [int]$Commits = 30,

        [Parameter()]
        [string]$Remote,

        [Parameter()]
        [string]$Branch,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter()]
        [int]$Weeks = 8
    )

    $OutputProperties = @(
        'Id',
        'Author',
        'UpdatedAt',
        'Summary'
    )

    if (-not $PSBoundParameters.ContainsKey('InformationAction'))
    {
        $InformationPreference = 'Continue'
    }

    $ArgumentList = @(
        "log",
        '--pretty=format:"%h;%an;%ar;%s"'
        "-$Commits"
    )

    if ($PSBoundParameters.ContainsKey('Remote') -or $PSBoundParameters.ContainsKey('Branch'))
    {
        if (-not $Remote) {$Remote = 'origin'}

        $Ref = $Remote, $Branch -join '/'
        $ArgumentList += $Ref

        if ($PSVersionTable.PSVersion.Major -ge 5)
        {
            Write-Information "$([Environment]::NewLine)    Ref: $Ref"
        }
    }


    if ($PSBoundParameters.ContainsKey('Weeks'))
    {
        $ArgumentList += "--since=$Weeks.weeks"
    }




    $CommitLines = & git $ArgumentList



    if ($PSCmdlet.ParameterSetName -eq 'SinceLastPRMerge')
    {
        $CommitLines = $CommitLines.Where({$_ -match 'whamapi-cicd-svc|;Merge pull request'}, 'Until')
    }


    $Output = $CommitLines | ConvertFrom-Csv -Delimiter ';' -Header $OutputProperties
    $Output | ForEach-Object {$_.PSTypeNames.Insert(0, 'GitCommit')}

    $Output

    if ($PSVersionTable.PSVersion.Major -ge 5)
    {
        Write-Information "$([string][char]8 * 4)    Count: $($Output.Count)`n"
    }
}
