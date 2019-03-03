
#https://stackoverflow.com/questions/1722702/how-to-open-the-last-opened-files-in-ise-at-the-starting

if (test-path $env:TMP\ise_mru.txt)
{
    $global:recentFiles = gc $env:TMP\ise_mru.txt | ?{$_}
}

else
{
    $global:recentFiles = @()
}

function Update-MRU($newfile)
{
    $global:recentFiles = @($newfile) + ($global:recentFiles -ne $newfile) | Select-Object -First 10

    $psISE.PowerShellTabs | %{
        $pstab = $_
        @($pstab.AddOnsMenu.Submenus) | ?{$_.DisplayName -eq 'MRU'} | %{$pstab.AddOnsMenu.Submenus.Remove($_)}
        $menu = $pstab.AddOnsMenu.Submenus.Add("MRU", $null, $null)
        $global:recentFiles | ?{$_} | %{
            $null = $menu.Submenus.Add($_, [ScriptBlock]::Create("psEdit '$_'"), $null)
        }
    }
    $global:recentFiles | Out-File $env:TMP\ise_mru.txt
}

$null = Register-ObjectEvent -InputObject $psISE.PowerShellTabs -EventName CollectionChanged -Action {
    if ($eventArgs.Action -ne 'Add')
    {
        return
    }

    Register-ObjectEvent -InputObject $eventArgs.NewItems[0].Files -EventName CollectionChanged -Action {
        if ($eventArgs.Action -ne 'Add')
        {
            return
        }
        Update-MRU ($eventArgs.NewItems | ?{-not $_.IsUntitled}| %{$_.FullPath})
    }
}

$null = Register-ObjectEvent -InputObject $psISE.CurrentPowerShellTab.Files -EventName CollectionChanged -Action {
    if ($eventArgs.Action -ne 'Add')
    {
        return
    }
    Update-MRU ($eventArgs.NewItems | ?{-not $_.IsUntitled}| %{$_.FullPath})

}

Update-MRU