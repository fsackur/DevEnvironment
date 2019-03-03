function Convert-Range
{
    param
    (
        [Parameter(Position = 0)]
        $min = -6,

        [Parameter(Position = 1)]
        $max = 244
    )

    $min, $max = $min, $max | sort

    if ($min -lt 0)
    {
        if ($max -le 0)
        {   
            return "-" + (Convert-Range ([Math]::Abs($min)) ([Math]::Abs($max)))
        }
        else
        {
            return "-" + (Convert-Range ([Math]::Abs($min)) 0) + "|" + (Convert-Range ([Math]::Abs($max)) 0)
        }
    }

    if ($min -eq 0 -and $max -eq 0) {return "0"}

    if ($min -eq 0)
    {
        $NextPowerOfTenFromMin = 0
    }
    else
    {
        $NextPowerOfTenFromMin = ([string]$min).Length
    }

    $LastPowerOfTenFromMax = ([string]$max).Length -1

    if ($LastPowerOfTenFromMax -gt $NextPowerOfTenFromMin)
    {
        $MidSection = "[1-9]" + "[0-9]{$($NextPowerOfTenFromMin-1),$($LastPowerOfTenFromMax-1)}"
    }

    return $MidSection




    if ($min -eq $max) {return [string]$min}

    if ($min -lt 10 -and $max -lt 10) {return "[$min-$max]"}

    if ($min -lt 10 -and 
}

Convert-Range 1 120



units

[x-9]

tens

[1-9][0-9]

hundredsonwards

[1-9][0-9]