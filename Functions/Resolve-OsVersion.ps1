function Resolve-OsVersion
{
    param
    (
        [string]$InputObject,
        [switch]$AsVersion,
        [switch]$AsFriendlyName,
        [switch]$AsEdition,
        [switch]$AsServicePackLevel
    )

    $Lookup = @(
        @{
            Version = "6.0"
            FriendlyName = "2008"
        }

    )

    switch -Regex ($InputObject)
    {
        "^(\d+\.){1,3}\d+$" {
            $Version = [version]$InputObject
        }

        "^\s*\d\d\d\d( R2)" {
            
        }

    }
}