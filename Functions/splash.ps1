
$Width = $host.ui.RawUI.WindowSize.Width
$Height = $host.ui.RawUI.WindowSize.Height

for ($i = 0; $i -lt $Height; $i++)
{
    
    #[System.Management.Automation.Host.Coordinates]
    Write-Host (
        (' ' * $Width * $i) +
        ('▓' * $Width * ($Height - $i))
        )
    Start-Sleep -Milliseconds 10
}

cls