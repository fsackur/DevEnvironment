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