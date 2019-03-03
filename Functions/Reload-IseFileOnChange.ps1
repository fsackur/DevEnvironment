$IseFileWatchers = @()

Get-EventSubscriber | Unregister-Event

$psISE.CurrentPowerShellTab.Files |
    Select-Object FullPath, @{Name = 'PSParentPath'; Expression = {Split-Path $_.FullPath}} |
    Group-Object PSParentPath |
    ForEach-Object {

        $FileSystemWatcher = New-Object System.IO.FileSystemWatcher
        $FileSystemWatcher.Path = $_.Name

        Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Changed -Action {

            $FullPath = $Event.SourceEventArgs.FullPath
            $IseFile = $psISE.CurrentPowerShellTab.Files | Where-Object {$_.FullPath -eq $FullPath}
            if ($IseFile) {

                $WriteHostParams  = @{
                    ForegroundColor = 'Green'
                    BackgroundColor =  'Black'
                    Object =  "Changed $FullPath"
                }

                Write-Host @WriteHostParams
            }
        }

    }

<#

Get-EventSubscriber | Unregister-Event
$Global:Watchers = [System.Collections.Generic.Dictionary[string, IO.FileSystemWatcher]]::new()

function Global:Update-Watchers
{
    $psISE.CurrentPowerShellTab.Files |
        Where-Object {
            #$_.IsSaved -and
            -not $Watchers.ContainsKey((Split-Path $_.FullPath))
        } |
        Foreach-Object {
            $Folder = Split-Path $_.FullPath
            $Watcher = [IO.FileSystemWatcher]::new($Folder, [IO.NotifyFilters]"FileName, DirectoryName")
            
            #Write-Warning "Watching $Folder"
            $Watchers.Add($Folder, $Watcher)

            $Action = {
                Write-Warning "hI"
                $Host.UI.WriteWarningLine("FOO") 
                Update-PsIse
                Write-Host "hi"
                #$args | Out-String | Write-Warning
            }
            'Changed', 'Created', 'Deleted' | %{
                $null = Register-ObjectEvent $Watcher -EventName $_ -Action $Action
            }
        }

    $CurrentIseFolders = $psISE.CurrentPowerShellTab.Files.FullPath | Split-Path | Get-Unique
    $Watchers.Keys | 
        #Where-Object {$_ -notin $CurrentIseFolders} |
        ForEach-Object {
            Write-Warning "No longer watching $_"
            #[Console]::WriteLine("foo")
        }
}

function Global:Update-PsIse
{
    Write-Warning "hi"
    [Console]::WriteLine("foo")
}

Update-Watchers

$null = Register-ObjectEvent $psISE.CurrentPowerShellTab.Files -EventName CollectionChanged -Action {

    Update-Watchers

}
#>