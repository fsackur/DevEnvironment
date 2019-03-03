function Async
{
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory=$false, Position = 0)]
        [scriptblock]$Action = {Start-Sleep 2; Write-Output "I'm in the Action, and I've finished"},

        [Parameter(Mandatory=$false, Position = 0)]
        [scriptblock]$Callback = {Write-Host $EventArgs}
    )

    $PS = [Powershell]::Create()
    $PS.Runspace = [runspacefactory]::CreateRunspace()
    $PS.Runspace.Open()
    $null = $PS.AddScript($Action)
    
    
    $null = Register-ObjectEvent -InputObject $PS -EventName InvocationStateChanged -Action {
        if ($Sender.InvocationStateInfo.State -eq 'Completed')
        {
        Write-Host $Sender.EndInvoke($Global:AsyncResult)
        $EventSubscriber | Unregister-Event
        }
        
    }
    $Global:AsyncResult = $PS.BeginInvoke()

    

    #$PS.Dispose()
}

Async