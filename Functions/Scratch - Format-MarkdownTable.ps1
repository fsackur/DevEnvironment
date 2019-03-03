$NumObjects = 3
$NumProperties = 3

$Objects = 1..$NumObjects | % {
    $Obj = New-Object psobject
    $Length = 3..13 | Get-Random

    1..$NumProperties | % {
        $Value = (
            1..$Length | % {
                [char](
                    ([int][char]'a')..([int][char]'z') | Get-Random
                )
            }
        ) -join ''

        Add-Member -InputObject $Obj -MemberType NoteProperty -Name "Property$_" -Value $Value
    }
    $Obj
}


function Format-MarkdownTable
{
    <#

    .ForwardHelpTargetName Microsoft.PowerShell.Utility\Format-Table
    .ForwardHelpCategory Cmdlet

    #>
    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkID=113303')]
    param(
        [switch]
        ${AutoSize},

        [switch]
        ${HideTableHeaders},

        [switch]
        ${Wrap},

        [Parameter(Position = 0)]
        [System.Object[]]
        ${Property},

        [System.Object]
        ${GroupBy},

        [string]
        ${View},

        [switch]
        ${ShowError},

        [switch]
        ${DisplayError},

        [switch]
        ${Force},

        [ValidateSet('CoreOnly', 'EnumOnly', 'Both')]
        [string]
        ${Expand},

        [Parameter(ValueFromPipeline = $true)]
        [psobject]
        ${InputObject}
    )
    <#
    begin
    {
        try
        {
            $SB = New-Object System.Text.StringBuilder
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Format-Table', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch
        {
            throw
        }
    }

    process
    {
        try
        {
            $steppablePipeline.Process($_)
        }
        catch
        {
            throw
        }
    }

    end
    {
        try
        {
            $steppablePipeline.End()
        }
        catch
        {
            throw
        }
        #>

        #$TableString = Format-Table @PSBoundParameters | Out-String
        #[regex]::Match($TableString, '(?<=\n)[ -]+(?=\r)', [System.Text.RegularExpressions.RegexOptions]::Multiline)

        #$TableString
    begin {
        $InputCollection = New-Object System.Collections.ArrayList
    }

    process {
        if ([System.Collections.ICollection].IsAssignableFrom($InputObject.GetType()))
        {
            $null = $InputCollection.AddRange($InputObject)
        }
        else
        {
            $null = $InputCollection.Add($InputObject)
        }
    }
    
    end {
        
        $PSBoundParameters.InputObject = $InputCollection | foreach {$_}
        $Global:TableStrings = Format-Table @PSBoundParameters | 
            Out-String -Stream | 
            where {-not [string]::IsNullOrWhiteSpace($_)}
        
        <#
        $Newline = [System.Environment]::NewLine
        $PatternLookbehind = "(?<=$([regex]::Escape($Newline)))"
        $PatternLookahead = "(?=$([regex]::Escape($Newline)))"
        $Pattern = "$PatternLookbehind[ -]+$PatternLookahead"  #line consisting only of spaces and dashes

        $DivRow = [regex]::Match(
            $TableString, 
            $Pattern,
            [System.Text.RegularExpressions.RegexOptions]::Multiline
        ).Value

        #$DivRow
        $HeaderBlock, $RowBlock = $TableString -split $DivRow
        #>
        $ColSeparator = '|'
        $DivRow = $TableStrings | where {$_ -match '^[ -]+$'}
        if ($DivRow.Count -ne 1) {throw "Parsing error"}
        $i = $TableStrings.IndexOf($DivRow)
        $HeaderStrings = $TableStrings[0..($i-1)]
        $RowStrings = $TableStrings[($i+1)..($TableStrings.Count-1)]
        $ColSepIndexes = [regex]::Matches($DivRow, ' (?=-)') | 
            select -ExpandProperty Index   #where are the gaps between columns
        
        $TableStrings

        $HeaderStrings = $HeaderStrings | foreach {
            [char[]]$Chars = $_.ToCharArray()
            $ColSepIndexes | foreach {
                $Chars[$_] = $ColSeparator
            }
            $Chars -join ''
        }

        $RowStrings = $RowStrings | foreach {
            [char[]]$Chars = $_.ToCharArray()
            $ColSepIndexes | foreach {
                $Chars[$_] = $ColSeparator
            }
            $Chars -join ''
        }

        $HeaderStrings
        $DivRow -replace ' (?=-)', $ColSeparator -replace ' ', '-'
        $RowStrings
    }
}

$Objects | Format-MarkdownTable
#Format-MarkdownTable -InputObject $Objects