
$Pester = Get-Module Pester
& $Pester {$mockTable}


$GuidPattern = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
Get-Command | ?{$_.Name -match $GuidPattern} | Remove-Item
Get-Alias | ?{$_.Definition -match $GuidPattern} | % {Remove-Item Alias:$($_.Name)}
