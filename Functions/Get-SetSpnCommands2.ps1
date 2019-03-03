
#Parse connection string to SETSPN commands

$SpnListOnly = $false
'718603-LEGACY\LEGACYPAYROLL,1436',
'719384-IRIS\IRIS,1437',
'718601-HR\HR,1433',
'718602-PAYROLL\PAYROLL,1435',
'718609-PRACTICE\PRACTICE,1435',
'718608-RECRUIT\RECRUITMENT,1433',
'705963-SQLAJ1\SQLAGENTJOBS,1438',
'845646-PAYROLL\PAYROLL,1433',
'826156-SQLCLUS3,1433',
'854780-SQLENT1\SQLENT1,1433' | %{
    $Hostname = $InstanceName = $Port = $null
    $InstanceString, $Port = $_.Split(',')
    $Hostname, $InstanceName = $InstanceString.Split('\\')
    $Fqdn = $Hostname, "lon.intensive.int" -join '.'
    #Check yer strings!
    #return New-Object psobject -Property @{Hostname=$Hostname; InstanceName=$InstanceName; Port=$Port}

    if ($SpnListOnly) {
        "Setspn -L $Hostname"

    } else {
        $Switch = '-A'   #'-D' to delete

        [string]::Format("Setspn {0} MSSQLSvc/{1} {2}", $Switch, $Hostname, $Hostname)
        [string]::Format("Setspn {0} MSSQLSvc/{1} {2}", $Switch, $Fqdn, $Hostname)
        if ($InstanceName) {
            [string]::Format("Setspn {0} MSSQLSvc/{1}:{2} {3}", $Switch, $Hostname, $InstanceName, $Hostname)
            [string]::Format("Setspn {0} MSSQLSvc/{1}:{2} {3}", $Switch, $Fqdn, $InstanceName, $Hostname)
        }
        if ($Port) {
            [string]::Format("Setspn {0} MSSQLSvc/{1}:{2} {3}", $Switch, $Hostname, $Port, $Hostname)
            [string]::Format("Setspn {0} MSSQLSvc/{1}:{2} {3}", $Switch, $Fqdn, $Port, $Hostname)
        }
    }
}

