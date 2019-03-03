function Split-MultiFunctionFile
{
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        [string]$OutputFolder
    )

    if (-not (Test-Path $Path -PathType Leaf))
    {
        throw "Where's this silly file supposed to be then?"
    }
    
    $Path = (Resolve-Path $Path).Path

    if (-not $OutputFolder)
    {
        $OutputFolder = Split-Path $Path
    }

    $null = New-Item $OutputFolder -ItemType Directory -Force

    $ScriptblockAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $Path,
        [ref]$null,
        [ref]$null
    )

    $FunctionAsts = $ScriptblockAst.FindAll(
        {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]},
        $true
    )

    foreach ($FunctionAst in $FunctionAsts)
    {
        $FileName = $FunctionAst.Name + ".ps1"
        $FunctionAst.Extent.Text | Out-File (Join-Path $OutputFolder $FileName) -Encoding utf8
    }
}